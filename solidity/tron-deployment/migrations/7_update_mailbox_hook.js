// This migration updates the Mailbox contract's required hook to use the deployed ProtocolFee contract
const Mailbox = artifacts.require('Mailbox');

module.exports = async function (deployer, network, accounts) {
  const deployerAddress = accounts[0];

  // Configuration - Use different mailbox addresses for different networks
  let mailboxProxyAddress;
  if (network === 'mainnet') {
    mailboxProxyAddress = "415b34081e9d453fc2ba925d893583d89d1b7175dd"; // Mainnet mailbox
  } else if (network === 'nile') {
    mailboxProxyAddress = "4177d2287aff6124ac5e01f417ad97cd39f2c31df7"; // Testnet mailbox
  } else {
    console.log('\n❌ Unsupported network for mailbox update:', network);
    return;
  }

  const protocolFeeAddress = process.env.PROTOCOL_FEE_ADDRESS; // Set this to the deployed ProtocolFee address

  console.log('='.repeat(50));
  console.log('Updating Mailbox Required Hook');
  console.log('='.repeat(50));
  console.log('Network:', network);
  console.log('Deployer Address:', deployerAddress);

  // Check if required parameters are provided
  if (!protocolFeeAddress) {
    console.log('\n❌ Missing required configuration!');
    console.log('Please provide the following environment variable:');
    console.log('  • PROTOCOL_FEE_ADDRESS: Address of the deployed ProtocolFee contract');
    console.log('\nExample:');
    console.log('PROTOCOL_FEE_ADDRESS=41abcd... npx tronbox migrate --network', network, '-f 7 --to 7');
    return;
  }

  console.log('Mailbox Proxy Address:', mailboxProxyAddress);
  console.log('New ProtocolFee Address:', protocolFeeAddress);
  console.log('='.repeat(50));

  try {
    // Get the Mailbox contract instance using the proxy address
    const mailboxContract = await Mailbox.at(mailboxProxyAddress);

    console.log('\n🔍 Checking current required hook...');
    const currentHook = await mailboxContract.requiredHook();
    console.log('Current Required Hook:', currentHook);

    console.log('\n🔄 Updating required hook...');
    console.log('Setting required hook to:', protocolFeeAddress);

    // Call setRequiredHook
    const transaction = await mailboxContract.setRequiredHook(protocolFeeAddress);
    console.log('✅ Transaction confirmed!');
    console.log('Transaction ID:', transaction);

    // Wait a moment for the transaction to be confirmed
    console.log('\n⏳ Waiting for transaction confirmation...');
    await new Promise(resolve => setTimeout(resolve, 3000));

    // Verify the update
    console.log('\n🔍 Verifying the update...');
    const newHook = await mailboxContract.requiredHook();
    console.log('New Required Hook:', newHook);

    // Check if the update was successful
    if (newHook.toLowerCase() === protocolFeeAddress.toLowerCase()) {
      console.log('✅ Mailbox required hook updated successfully!');
    } else {
      console.error('❌ Hook update verification failed!');
      console.error('Expected:', protocolFeeAddress);
      console.error('Actual:', newHook);
      throw new Error('Hook update verification failed');
    }

    // Post-Update Summary
    console.log('\n' + '='.repeat(60));
    console.log('🎉 MAILBOX HOOK UPDATE SUMMARY');
    console.log('='.repeat(60));
    console.log('📋 Configuration:');
    console.log('  • Network:', network);
    console.log('  • Deployer:', deployerAddress);
    console.log('\n📍 Addresses:');
    console.log('  • Mailbox Proxy:', mailboxProxyAddress);
    console.log('  • Previous Hook:', currentHook);
    console.log('  • New ProtocolFee Hook:', newHook);
    console.log('\n📨 Transaction Details:');
    console.log('  • Transaction ID:', transaction);
    console.log('\n✅ The Mailbox now uses ProtocolFee as the required hook!');
    console.log('✅ All messages will now incur the configured protocol fee');
    console.log('='.repeat(60));

  } catch (error) {
    console.error('\n❌ Mailbox hook update failed:', error);
    throw error;
  }
};