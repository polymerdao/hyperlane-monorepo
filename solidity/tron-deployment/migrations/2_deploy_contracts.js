const Mailbox = artifacts.require('Mailbox');
const MockISM = artifacts.require('MockISM');
const MockHook = artifacts.require('MockHook');
const ERC1967Proxy = artifacts.require('ERC1967Proxy');
const PolymerISM = artifacts.require('PolymerIsm');

module.exports = async function (deployer, network, account) {
  const deployerAddress = account;

  // Configuration - You can set these via environment variables
  const hyperlaneDomainId = process.env.HYPERLANE_DOMAIN_ID
    ? parseInt(process.env.HYPERLANE_DOMAIN_ID)
    : 728126428; // Default Tron Mainnet Domain ID
  const owner = deployerAddress; // Use deployer as the initial owner for simplicity

  // PolymerISM configuration - for receiving messages from other chains
  const polymerProverAddress = process.env.POLYMER_PROVER_ADDRESS || null;
  const originChainMailboxAddress =
    process.env.ORIGIN_CHAIN_MAILBOX_ADDRESS || null;

  console.log('='.repeat(50));
  console.log('Starting Mailbox Deployment');
  console.log('='.repeat(50));
  console.log('Network:', network);
  console.log('Deployer Address:', deployerAddress);

  // Get and display account balance
  try {
    // In TronBox migrations, we need to access tronWeb through the global context
    const TronWeb = require('tronweb');
    const fullHost =
      network === 'dynamic'
        ? process.env.RPC_URL
        : deployer.networks[network].fullHost;
    console.log('using fullhost:', fullHost);
    const tronWeb = new TronWeb({
      fullHost: fullHost,
    });
  } catch (error) {
    console.log('⚠️  Could not fetch balance:', error.message);
  }

  console.log('Hyperlane Domain ID:', hyperlaneDomainId);
  console.log('Owner Address:', owner);
  console.log('='.repeat(50));

  try {
    // --- Step 1: Deploy Mock Dependencies ---
    console.log('\n🚀 Step 1: Deploying Mock Dependencies...');

    console.log('Deploying MockISM...');
    await deployer.deploy(MockISM);
    const mockIsm = await MockISM.deployed();
    console.log('✅ MockISM deployed at:', mockIsm.address);

    console.log('Deploying MockHook...');
    await deployer.deploy(MockHook);
    const mockHook = await MockHook.deployed();
    console.log('✅ MockHook deployed at:', mockHook.address);

    // Use the same MockHook instance for both default and required hooks
    const mockDefaultHook = mockHook;
    const mockRequiredHook = mockHook;
    console.log('✅ Using same MockHook for both default and required hooks');

    // --- Step 2: Deploy Mailbox Implementation ---
    console.log('\n🚀 Step 2: Deploying Mailbox Implementation...');
    console.log(
      'Deploying Mailbox implementation with domain ID:',
      hyperlaneDomainId,
    );
    await deployer.deploy(Mailbox, hyperlaneDomainId);
    const mailboxImplementation = await Mailbox.deployed();
    console.log(
      '✅ Mailbox implementation deployed at:',
      mailboxImplementation.address,
    );

    // --- Step 3: Prepare Initialization Data ---
    console.log('\n🚀 Step 3: Preparing Initialization Data...');

    // For now, let's deploy the proxy without initialization data
    // and initialize it separately
    const encodedInitData = '0x';

    console.log(
      'Deploying proxy without initialization (will initialize separately)...',
    );

    // --- Step 4: Deploy ERC1967Proxy ---
    console.log('\n🚀 Step 4: Deploying ERC1967Proxy for Mailbox...');
    await deployer.deploy(
      ERC1967Proxy,
      mailboxImplementation.address,
      encodedInitData,
    );
    const mailboxProxy = await ERC1967Proxy.deployed();
    console.log('✅ Mailbox Proxy deployed at:', mailboxProxy.address);

    // --- Step 5: Initialize the Mailbox through Proxy ---
    console.log('\n🚀 Step 5: Initializing Mailbox through Proxy...');

    // Create a Mailbox instance pointing to the proxy address for interaction
    const mailboxInstance = await Mailbox.at(mailboxProxy.address);

    try {
      // Initialize the mailbox
      console.log('Calling initialize function...');
      await mailboxInstance.initialize(
        owner,
        mockIsm.address,
        mockDefaultHook.address,
        mockRequiredHook.address,
      );
      console.log('✅ Mailbox initialized successfully');
    } catch (error) {
      console.log(
        '⚠️  Initialize failed (might already be initialized):',
        error.message,
      );
    }

    // --- Step 7: Deploy PolymerISM (optional) ---
    let polymerIsm = null;
    if (polymerProverAddress && originChainMailboxAddress) {
      console.log('\n🚀 Step 7: Deploying PolymerISM...');
      console.log('Polymer Prover Address:', polymerProverAddress);
      console.log('Origin Chain Mailbox Address:', originChainMailboxAddress);

      try {
        await deployer.deploy(
          PolymerISM,
          polymerProverAddress,
          originChainMailboxAddress,
        );
        polymerIsm = await PolymerISM.deployed();
        console.log('✅ PolymerISM deployed at:', polymerIsm.address);

        // Verify PolymerISM configuration
        const configuredProver = await polymerIsm.polymerProver();
        const configuredMailbox = await polymerIsm.originMailbox();
        console.log('✅ PolymerISM configured with:');
        console.log('  • Polymer Prover:', configuredProver);
        console.log('  • Origin Mailbox:', configuredMailbox);
      } catch (error) {
        console.log('❌ PolymerISM deployment failed:', error.message);
      }
    } else {
      console.log('\n⚠️  Step 7: Skipping PolymerISM deployment');
      console.log(
        '  To deploy PolymerISM for receiving messages from other chains, provide:',
      );
      console.log(
        '  • POLYMER_PROVER_ADDRESS: Address of the Polymer prover on this chain',
      );
      console.log(
        '  • ORIGIN_CHAIN_MAILBOX_ADDRESS: Address of the Mailbox on the origin chain',
      );
    }

    // --- Post-Deployment Summary ---
    console.log('\n' + '='.repeat(60));
    console.log('🎉 DEPLOYMENT SUMMARY');
    console.log('='.repeat(60));
    console.log('📋 Configuration:');
    console.log('  • Target Chain Hyperlane Domain ID:', hyperlaneDomainId);
    console.log('  • Deployer/Owner:', owner);
    console.log('  • Network:', network);
    console.log('\n📍 Contract Addresses:');
    console.log('  • MockISM Address:', mockIsm.address);
    console.log('  • Mock Default Hook Address:', mockDefaultHook.address);
    console.log('  • Mock Required Hook Address:', mockRequiredHook.address);
    console.log(
      '  • Mailbox Implementation Address:',
      mailboxImplementation.address,
    );
    console.log('  • Mailbox Proxy Address:', mailboxProxy.address);
    if (polymerIsm) {
      console.log('  • PolymerISM Address:', polymerIsm.address);
    }
    console.log('\n🔗 Integration Info:');
    console.log('  • Use the Mailbox Proxy Address:', mailboxProxy.address);
    console.log(
      '  • As the `originMailbox` when deploying PolymerISM on the destination chain.',
    );
    if (polymerIsm) {
      console.log('\n📨 Receiving Messages:');
      console.log(
        '  • PolymerISM is deployed to verify messages from:',
        originChainMailboxAddress,
      );
      console.log(
        '  • Message receivers should specify ISM address:',
        polymerIsm.address,
      );
      console.log(
        '  • In their `interchainSecurityModule()` function or ISM configuration',
      );
    }
    console.log('='.repeat(60));

    // Store important addresses for reference
    console.log('\n💾 Save these addresses for your records:');
    console.log('MAILBOX_PROXY_ADDRESS=' + mailboxProxy.address);
    console.log(
      'MAILBOX_IMPLEMENTATION_ADDRESS=' + mailboxImplementation.address,
    );
    console.log('MOCK_ISM_ADDRESS=' + mockIsm.address);
    console.log('MOCK_DEFAULT_HOOK_ADDRESS=' + mockDefaultHook.address);
    console.log('MOCK_REQUIRED_HOOK_ADDRESS=' + mockRequiredHook.address);
    console.log('HYPERLANE_DOMAIN_ID=' + hyperlaneDomainId);
    if (polymerIsm) {
      console.log('POLYMER_ISM_ADDRESS=' + polymerIsm.address);
    }
  } catch (error) {
    console.error('\n❌ Deployment failed:', error);
    throw error;
  }
};
