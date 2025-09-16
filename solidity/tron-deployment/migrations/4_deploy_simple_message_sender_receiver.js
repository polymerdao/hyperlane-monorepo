const SimpleMessageSenderReceiver = artifacts.require('SimpleMessageSenderReceiver');

module.exports = async function (deployer, network, account) {
  const deployerAddress = account;

  // Configuration - Use deployed contract addresses from previous migrations
  // These addresses must be provided via environment variables
  const mailboxProxyAddress = process.env.MAILBOX_PROXY_ADDRESS;
  const polymerIsmAddress = process.env.POLYMER_ISM_ADDRESS;

  // Validate required environment variables
  if (!mailboxProxyAddress) {
    throw new Error('❌ MAILBOX_PROXY_ADDRESS environment variable is required but not set');
  }
  if (!polymerIsmAddress) {
    throw new Error('❌ POLYMER_ISM_ADDRESS environment variable is required but not set');
  }

  console.log('='.repeat(50));
  console.log('Starting SimpleMessageSenderReceiver Deployment');
  console.log('='.repeat(50));
  console.log('Network:', network);
  console.log('Deployer Address:', deployerAddress);
  
  // Get and display account balance
  try {
    const TronWeb = require('tronweb');
    const tronWeb = new TronWeb({
      fullHost: deployer.networks[network].fullHost
    });
    
    const balance = await tronWeb.trx.getBalance(deployerAddress);
    const balanceInTRX = tronWeb.fromSun(balance);
    console.log('Deployer Balance:', balanceInTRX, 'TRX');
  } catch (error) {
    console.log('⚠️  Could not fetch balance:', error.message);
  }

  console.log('\n📋 Using existing contracts:');
  console.log('  • Mailbox Proxy Address:', mailboxProxyAddress);
  console.log('  • PolymerISM Address:', polymerIsmAddress);
  console.log('='.repeat(50));

  try {
    // Deploy SimpleMessageSenderReceiver
    console.log('\n🚀 Deploying SimpleMessageSenderReceiver...');
    console.log('Constructor parameters:');
    console.log('  • _mailbox:', mailboxProxyAddress);
    console.log('  • _polymerIsm:', polymerIsmAddress);
    
    await deployer.deploy(
      SimpleMessageSenderReceiver,
      mailboxProxyAddress,
      polymerIsmAddress
    );
    
    const senderReceiver = await SimpleMessageSenderReceiver.deployed();
    console.log('✅ SimpleMessageSenderReceiver deployed at:', senderReceiver.address);

    // Verify the deployment
    console.log('\n🔍 Verifying deployment...');
    
    const configuredMailbox = await senderReceiver.mailbox();
    console.log('✅ Configured Mailbox:', configuredMailbox);
    
    const configuredISM = await senderReceiver.polymerIsm();
    console.log('✅ Configured PolymerISM:', configuredISM);
    
    const messageCounter = await senderReceiver.messageCounter();
    console.log('✅ Initial message counter:', messageCounter.toString());

    // Post-Deployment Summary
    console.log('\n' + '='.repeat(60));
    console.log('🎉 SIMPLE MESSAGE SENDER/RECEIVER DEPLOYMENT SUMMARY');
    console.log('='.repeat(60));
    console.log('📋 Configuration:');
    console.log('  • Network:', network);
    console.log('  • Deployer:', deployerAddress);
    console.log('  • Mailbox:', mailboxProxyAddress);
    console.log('  • PolymerISM:', polymerIsmAddress);
    console.log('\n📍 Contract Address:');
    console.log('  • SimpleMessageSenderReceiver:', senderReceiver.address);
    console.log('\n📨 Usage Instructions:');
    console.log('  • Use sendMessage() to dispatch messages to other chains');
    console.log('  • The contract will receive messages via handle() function');
    console.log('  • Messages are verified using the configured PolymerISM');
    console.log('  • Query getLatestMessageDetails() to see received messages');
    console.log('='.repeat(60));

    // Store important addresses for reference
    console.log('\n💾 Save this address for your records:');
    console.log('SIMPLE_MESSAGE_SENDER_RECEIVER_ADDRESS=' + senderReceiver.address);

  } catch (error) {
    console.error('\n❌ SimpleMessageSenderReceiver deployment failed:', error);
    throw error;
  }
};