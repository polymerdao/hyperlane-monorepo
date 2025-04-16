use base64::{engine::general_purpose, Engine};
use derive_new::new;
use eyre::Result;
use ethers::types::Bytes;
use hyperlane_base::CoreMetrics;
use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender};
use tracing::{debug, error, info};

/// Message sent to the FSR provider
#[derive(Debug)]
pub struct FSRRequest {
    /// The chain ID of the source chain
    pub chain_id: u64,
    /// The block number of the message
    pub block_number: u64,
    /// The transaction index of the message
    pub tx_index: u32,
    /// The log index of the message
    pub log_index: u32,
}

/// Response from the FSR provider
#[derive(Debug)]
pub struct FSRResponse {
    /// The proof for the message
    pub proof: Bytes,
}

/// Fetches proofs for messages using Polymer's FSR
#[derive(Debug, new)]
pub struct PolymerFSRProvider {
    /// The metrics to use for tracking proof fetching
    metrics: CoreMetrics,
    /// The channel to receive FSR requests on
    fsr_request_rx: UnboundedReceiver<FSRRequest>,
    /// The channel to send FSR responses on
    fsr_response_tx: UnboundedSender<FSRResponse>,
    /// The API token for Polymer
    api_token: String,
    /// The API endpoint for Polymer
    api_endpoint: String,
}

impl PolymerFSRProvider {
    /// Start the FSR provider
    pub async fn start(mut self) -> Result<()> {
        info!("Starting Polymer FSR provider");
        while let Some(request) = self.fsr_request_rx.recv().await {
            match self.fetch_proof(&request).await {
                Ok(proof) => {
                    let response = FSRResponse { proof };
                    if let Err(e) = self.fsr_response_tx.send(response) {
                        error!(error = ?e, "Failed to send FSR response");
                    }
                }
                Err(e) => {
                    error!(error = ?e, "Failed to fetch proof");
                }
            }
        }
        Ok(())
    }

    /// Fetch a proof for a message
    async fn fetch_proof(&self, request: &FSRRequest) -> Result<Bytes> {
        debug!(
            chain_id = request.chain_id,
            block_number = request.block_number,
            tx_index = request.tx_index,
            log_index = request.log_index,
            "Fetching proof from Polymer FSR"
        );

        // Create the proof API client
        let client = reqwest::Client::new();

        // Request the proof
        let response = client
            .post(&self.api_endpoint)
            .header("Authorization", format!("Bearer {}", self.api_token))
            .json(&serde_json::json!({
                "jsonrpc": "2.0",
                "id": 1,
                "method": "log_requestProof",
                "params": [
                    request.chain_id,
                    request.block_number,
                    request.tx_index,
                    request.log_index
                ]
            }))
            .send()
            .await?;

        let job_id = response.json::<i64>().await?;

        // Poll for the proof
        let mut attempts = 0;
        loop {
            let response = client
                .post(&self.api_endpoint)
                .json(&serde_json::json!({
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": "log_queryProof",
                    "params": [job_id]
                }))
                .send()
                .await?;

            let result = response.json::<serde_json::Value>().await?;
            if result["status"] == "ready" || result["status"] == "complete" {
                let proof = general_purpose::STANDARD.decode(result["proof"].as_str().unwrap())?;
                return Ok(Bytes::from(proof));
            }

            attempts += 1;
            if attempts > 5 {
                return Err(eyre::eyre!("Timeout waiting for proof"));
            }

            tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;
        }
    }
}