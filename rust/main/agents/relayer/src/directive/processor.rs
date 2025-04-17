use std::{
    fmt::{Debug, Formatter},
    sync::Arc,
    time::Duration,
    collections::HashMap,
};

use async_trait::async_trait;
use derive_new::new;
use eyre::Result;
use hyperlane_base::{
    db::{HyperlaneDb, HyperlaneRocksDB},
    CoreMetrics,
};
use hyperlane_core::{HyperlaneDomain, HyperlaneMessage, ModuleType};
use prometheus::IntGauge;
use tokio::sync::mpsc::{UnboundedSender, UnboundedReceiver};
use tracing::{debug, instrument, trace};

use crate::processor::ProcessorExt;
use crate::directive::fsr_providers::polymer::{PolymerFSRProvider, FSRRequest, FSRResponse};

/// Finds unprocessed messages from an origin and submits them through a channel
/// for processing.
pub struct DirectiveProcessor {
    db: HyperlaneRocksDB,
    metrics: DirectiveProcessorMetrics,
    nonce_iterator: ForwardBackwardIterator,
    max_retries: u32,
    /// Map of ISM module types to their corresponding FSR providers
    fsr_providers: HashMap<ModuleType, (UnboundedSender<FSRRequest>, UnboundedReceiver<FSRResponse>)>,
}

impl DirectiveProcessor {
    pub fn new(
        db: HyperlaneRocksDB,
        metrics: DirectiveProcessorMetrics,
        max_retries: u32,
        polymer_api_token: String,
        polymer_api_endpoint: String,
    ) -> Self {
        let nonce_iterator = ForwardBackwardIterator::new(Arc::new(db.clone()));
        
        let (polymer_request_tx, polymer_request_rx) = tokio::sync::mpsc::unbounded_channel();
        let (polymer_response_tx, polymer_response_rx) = tokio::sync::mpsc::unbounded_channel();

        let polymer_provider = PolymerFSRProvider::new(
            polymer_request_rx,
            polymer_response_tx,
            polymer_api_token,
            polymer_api_endpoint,
        );

        // Start the Polymer FSR provider
        tokio::spawn(async move {
            if let Err(e) = polymer_provider.start().await {
                tracing::error!(error = ?e, "Polymer FSR provider failed");
            }
        });

        let mut fsr_providers = HashMap::new();
        fsr_providers.insert(
            ModuleType::Polymer,
            (polymer_request_tx, polymer_response_rx),
        );

        Self {
            db,
            metrics,
            nonce_iterator,
            max_retries,
            fsr_providers,
        }
    }
}

impl Debug for DirectiveProcessor {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "DirectiveProcessor {{ nonce_iterator: {:?}, max_retries: {} }}",
            self.nonce_iterator, self.max_retries
        )
    }
}

#[async_trait]
impl ProcessorExt for DirectiveProcessor {
    fn name(&self) -> String {
        format!("directive_processor::{}", self.domain().name())
    }

    fn domain(&self) -> &HyperlaneDomain {
        self.db.domain()
    }

    async fn tick(&mut self) -> Result<()> {
        if let Some(msg) = self.try_get_unprocessed_message().await? {
            // Process the message
            debug!(hyp_message=?msg, "Found processable message");
            // TODO: Add message processing logic here
        } else {
            tokio::time::sleep(Duration::from_secs(1)).await;
        }
        Ok(())
    }
}

impl DirectiveProcessor {
    async fn try_get_unprocessed_message(&mut self) -> Result<Option<HyperlaneMessage>> {
        trace!(nonce_iterator=?self.nonce_iterator, "Trying to get the next processor message");
        let next_message = self
            .nonce_iterator
            .try_get_next_message(&self.metrics)
            .await?;
        if next_message.is_none() {
            trace!(nonce_iterator=?self.nonce_iterator, "No message found in DB for nonce");
        }
        Ok(next_message)
    }
}

#[derive(Debug)]
pub struct DirectiveProcessorMetrics {
    max_last_known_message_nonce_gauge: IntGauge,
    last_known_message_nonce_gauges: HashMap<u32, IntGauge>,
}

impl DirectiveProcessorMetrics {
    pub fn new<'a>(
        metrics: &CoreMetrics,
        origin: &HyperlaneDomain,
        destinations: impl Iterator<Item = &'a HyperlaneDomain>,
    ) -> Self {
        let mut gauges: HashMap<u32, IntGauge> = HashMap::new();
        for destination in destinations {
            gauges.insert(
                destination.id(),
                metrics.last_known_message_nonce().with_label_values(&[
                    "processor_loop",
                    origin.name(),
                    destination.name(),
                ]),
            );
        }
        Self {
            max_last_known_message_nonce_gauge: metrics
                .last_known_message_nonce()
                .with_label_values(&["processor_loop", origin.name(), "any"]),
            last_known_message_nonce_gauges: gauges,
        }
    }

    fn get(&self, destination: u32) -> Option<&IntGauge> {
        self.last_known_message_nonce_gauges.get(&destination)
    }
}

#[derive(Debug)]
struct ForwardBackwardIterator {
    low_nonce_iter: DirectionalNonceIterator,
    high_nonce_iter: DirectionalNonceIterator,
    // here for debugging purposes
    _domain: String,
}

impl ForwardBackwardIterator {
    #[instrument(skip(db), ret)]
    fn new(db: Arc<dyn HyperlaneDb>) -> Self {
        let high_nonce = db.retrieve_highest_seen_message_nonce().ok().flatten();
        let domain = db.domain().name().to_owned();
        let high_nonce_iter = DirectionalNonceIterator::new(
            // If the high nonce is None, we start from the beginning
            high_nonce.unwrap_or_default().into(),
            NonceDirection::High,
            db.clone(),
            domain.clone(),
        );
        let mut low_nonce_iter =
            DirectionalNonceIterator::new(high_nonce, NonceDirection::Low, db, domain.clone());
        // Decrement the low nonce to avoid processing the same message twice, which causes double counts in metrics
        low_nonce_iter.iterate();
        debug!(
            ?low_nonce_iter,
            ?high_nonce_iter,
            ?domain,
            "Initialized ForwardBackwardIterator"
        );
        Self {
            low_nonce_iter,
            high_nonce_iter,
            _domain: domain,
        }
    }

    async fn try_get_next_message(
        &mut self,
        metrics: &DirectiveProcessorMetrics,
    ) -> Result<Option<HyperlaneMessage>> {
        loop {
            let high_nonce_message_status = self.high_nonce_iter.try_get_next_nonce(metrics)?;
            let low_nonce_message_status = self.low_nonce_iter.try_get_next_nonce(metrics)?;

            match (high_nonce_message_status, low_nonce_message_status) {
                // Always prioritize advancing the the high nonce iterator, as
                // we have a preference for higher nonces
                (MessageStatus::Processed, _) => {
                    self.high_nonce_iter.iterate();
                }
                (MessageStatus::Processable(high_nonce_message), _) => {
                    self.high_nonce_iter.iterate();
                    return Ok(Some(high_nonce_message));
                }

                // Low nonce messages are only processed if the high nonce iterator
                // can't make any progress
                (_, MessageStatus::Processed) => {
                    self.low_nonce_iter.iterate();
                }
                (_, MessageStatus::Processable(low_nonce_message)) => {
                    self.low_nonce_iter.iterate();
                    return Ok(Some(low_nonce_message));
                }

                // If both iterators give us unindexed messages, there are no messages at the moment
                (MessageStatus::Unindexed, MessageStatus::Unindexed) => return Ok(None),
            }
            // This loop may iterate through millions of processed messages, blocking the runtime.
            // So, to avoid starving other futures in this task, yield to the runtime
            // on each iteration
            tokio::task::yield_now().await;
        }
    }
}

#[derive(Debug, Clone, Copy, Default, PartialEq)]
enum NonceDirection {
    #[default]
    High,
    Low,
}

#[derive(new)]
struct DirectionalNonceIterator {
    nonce: Option<u32>,
    direction: NonceDirection,
    db: Arc<dyn HyperlaneDb>,
    domain_name: String,
}

impl Debug for DirectionalNonceIterator {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "DirectionalNonceIterator {{ nonce: {:?}, direction: {:?}, domain: {:?} }}",
            self.nonce, self.direction, self.domain_name
        )
    }
}

impl DirectionalNonceIterator {
    #[instrument]
    fn iterate(&mut self) {
        match self.direction {
            NonceDirection::High => {
                self.nonce = self.nonce.map(|n| n.saturating_add(1));
                debug!(?self, "Iterating high nonce");
            }
            NonceDirection::Low => {
                if let Some(nonce) = self.nonce {
                    // once the message with nonce zero is processed, we should stop going backwards
                    self.nonce = nonce.checked_sub(1);
                }
            }
        }
    }

    fn try_get_next_nonce(
        &self,
        metrics: &DirectiveProcessorMetrics,
    ) -> Result<MessageStatus<HyperlaneMessage>> {
        if let Some(message) = self.indexed_message_with_nonce()? {
            Self::update_max_nonce_gauge(&message, metrics);
            if !self.is_message_processed()? {
                debug!(hyp_message=?message, iterator=?self, "Found processable message");
                return Ok(MessageStatus::Processable(message));
            } else {
                return Ok(MessageStatus::Processed);
            }
        }
        Ok(MessageStatus::Unindexed)
    }

    fn update_max_nonce_gauge(message: &HyperlaneMessage, metrics: &DirectiveProcessorMetrics) {
        let current_max = metrics.max_last_known_message_nonce_gauge.get();
        metrics
            .max_last_known_message_nonce_gauge
            .set(std::cmp::max(current_max, message.nonce as i64));
        if let Some(metrics) = metrics.get(message.destination) {
            metrics.set(message.nonce as i64);
        }
    }

    fn indexed_message_with_nonce(&self) -> Result<Option<HyperlaneMessage>> {
        match self.nonce {
            Some(nonce) => {
                let msg = self.db.retrieve_message_by_nonce(nonce)?;
                Ok(msg)
            }
            None => Ok(None),
        }
    }

    fn is_message_processed(&self) -> Result<bool> {
        let Some(nonce) = self.nonce else {
            return Ok(false);
        };
        let processed = self
            .db
            .retrieve_processed_by_nonce(&nonce)?
            .unwrap_or(false);
        if processed {
            trace!(
                nonce,
                domain = self.db.domain().name(),
                "Message already marked as processed in DB"
            );
        }
        Ok(processed)
    }
}

#[derive(Debug)]
enum MessageStatus<T> {
    /// The message wasn't indexed yet so can't be processed.
    Unindexed,
    // The message was indexed and is ready to be processed.
    Processable(T),
    // The message was indexed and already processed.
    Processed,
} 