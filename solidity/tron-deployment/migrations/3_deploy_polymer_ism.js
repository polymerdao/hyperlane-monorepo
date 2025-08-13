const PolymerISM = artifacts.require('PolymerIsm');

module.exports = async function (deployer, network, account) {
  const deployerAddress = account;

  // Configuration - You can set these via environment variables
  const polymerProverAddress = process.env.POLYMER_PROVER_ADDRESS;
  const originChainMailboxAddress = process.env.ORIGIN_CHAIN_MAILBOX_ADDRESS;

  console.log('='.repeat(50));
  console.log('Starting PolymerISM Deployment');
  console.log('='.repeat(50));
  console.log('Network:', network);
  console.log('Deployer Address:', deployerAddress);

  // Check if required parameters are provided
  if (!polymerProverAddress || !originChainMailboxAddress) {
    console.log('\n❌ Missing required configuration!');
    console.log('Please provide the following environment variables:');
    console.log('  • POLYMER_PROVER_ADDRESS: Address of the Polymer prover on this chain');
    console.log('  • ORIGIN_CHAIN_MAILBOX_ADDRESS: Address of the Mailbox on the origin chain');
    console.log('\nExample:');
    console.log('POLYMER_PROVER_ADDRESS=0x... ORIGIN_CHAIN_MAILBOX_ADDRESS=0x... npx tronbox migrate --network nile');
    return;
  }

  console.log('Polymer Prover Address:', polymerProverAddress);
  console.log('Origin Chain Mailbox Address:', originChainMailboxAddress);
  console.log('='.repeat(50));

  try {
    // Deploy PolymerISM
    console.log('\n🚀 Deploying PolymerISM...');
    await deployer.deploy(PolymerISM, polymerProverAddress, originChainMailboxAddress);
    const polymerIsm = await PolymerISM.deployed();
    console.log('✅ PolymerISM deployed at:', polymerIsm.address);
    
    // Verify PolymerISM configuration
    console.log('\n🔍 Verifying PolymerISM configuration...');
    const configuredProver = await polymerIsm.polymerProver();
    const configuredMailbox = await polymerIsm.originMailbox();
    console.log('✅ PolymerISM configured with:');
    console.log('  • Polymer Prover:', configuredProver);
    console.log('  • Origin Mailbox:', configuredMailbox);

    // Post-Deployment Summary
    console.log('\n' + '='.repeat(60));
    console.log('🎉 POLYMERISM DEPLOYMENT SUMMARY');
    console.log('='.repeat(60));
    console.log('📋 Configuration:');
    console.log('  • Network:', network);
    console.log('  • Deployer:', deployerAddress);
    console.log('\n📍 Contract Address:');
    console.log('  • PolymerISM Address:', polymerIsm.address);
    console.log('\n📨 Usage Instructions:');
    console.log('  • This PolymerISM verifies messages from:', originChainMailboxAddress);
    console.log('  • Message receivers should specify ISM address:', polymerIsm.address);
    console.log('  • In their `interchainSecurityModule()` function or ISM configuration');
    console.log('='.repeat(60));

    // Store important addresses for reference
    console.log('\n💾 Save this address for your records:');
    console.log('POLYMER_ISM_ADDRESS=' + polymerIsm.address);

  } catch (error) {
    console.error('\n❌ PolymerISM deployment failed:', error);
    throw error;
  }
};