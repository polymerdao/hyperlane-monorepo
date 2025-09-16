const ProtocolFee = artifacts.require('ProtocolFee');

module.exports = async function (deployer, network, accounts) {
  const deployerAddress = accounts[0];

  // Configuration - You can set these via environment variables
  const maxProtocolFee = process.env.PROTOCOL_FEE_MAX;
  const initialProtocolFee = process.env.PROTOCOL_FEE_INITIAL;
  const beneficiaryAddress = process.env.PROTOCOL_FEE_BENEFICIARY;
  const ownerAddress = process.env.PROTOCOL_FEE_OWNER;

  console.log('='.repeat(50));
  console.log('Starting ProtocolFee Deployment');
  console.log('='.repeat(50));
  console.log('Network:', network);
  console.log('Deployer Address:', deployerAddress);

  // Check if required parameters are provided
  if (!maxProtocolFee || !initialProtocolFee || !beneficiaryAddress || !ownerAddress) {
    console.log('\n❌ Missing required configuration!');
    console.log('Please provide the following environment variables:');
    console.log('  • PROTOCOL_FEE_MAX: Maximum protocol fee (immutable, in SUN)');
    console.log('  • PROTOCOL_FEE_INITIAL: Initial protocol fee (adjustable, in SUN)');
    console.log('  • PROTOCOL_FEE_BENEFICIARY: Address to receive protocol fees');
    console.log('  • PROTOCOL_FEE_OWNER: Address that can adjust protocol fee');
    console.log('\nExample:');
    console.log('PROTOCOL_FEE_MAX=100000000 PROTOCOL_FEE_INITIAL=2000000 PROTOCOL_FEE_BENEFICIARY=TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9 PROTOCOL_FEE_OWNER=TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9 npx tronbox migrate --network mainnet');
    return;
  }

  console.log('Max Protocol Fee (SUN):', maxProtocolFee, '(' + (parseInt(maxProtocolFee) / 1000000) + ' TRX)');
  console.log('Initial Protocol Fee (SUN):', initialProtocolFee, '(' + (parseInt(initialProtocolFee) / 1000000) + ' TRX)');
  console.log('Beneficiary Address:', beneficiaryAddress);
  console.log('Owner Address:', ownerAddress);
  console.log('='.repeat(50));

  try {
    // Deploy ProtocolFee
    console.log('\n🚀 Deploying ProtocolFee...');
    await deployer.deploy(
      ProtocolFee,
      maxProtocolFee,
      initialProtocolFee,
      beneficiaryAddress,
      ownerAddress
    );
    const protocolFee = await ProtocolFee.deployed();
    console.log('✅ ProtocolFee deployed at:', protocolFee.address);
    
    // Verify ProtocolFee configuration
    console.log('\n🔍 Verifying ProtocolFee configuration...');
    const configuredMaxFee = await protocolFee.MAX_PROTOCOL_FEE();
    const configuredCurrentFee = await protocolFee.protocolFee();
    const configuredBeneficiary = await protocolFee.beneficiary();
    const configuredOwner = await protocolFee.owner();
    
    console.log('✅ ProtocolFee configured with:');
    console.log('  • Max Protocol Fee:', configuredMaxFee.toString(), 'SUN (' + (parseInt(configuredMaxFee) / 1000000) + ' TRX)');
    console.log('  • Current Protocol Fee:', configuredCurrentFee.toString(), 'SUN (' + (parseInt(configuredCurrentFee) / 1000000) + ' TRX)');
    console.log('  • Beneficiary:', configuredBeneficiary);
    console.log('  • Owner:', configuredOwner);

    // Verify hook type
    const hookType = await protocolFee.hookType();
    console.log('  • Hook Type:', hookType.toString());

    // Post-Deployment Summary
    console.log('\n' + '='.repeat(60));
    console.log('🎉 PROTOCOL FEE DEPLOYMENT SUMMARY');
    console.log('='.repeat(60));
    console.log('📋 Configuration:');
    console.log('  • Network:', network);
    console.log('  • Deployer:', deployerAddress);
    console.log('\n📍 Contract Address:');
    console.log('  • ProtocolFee Address:', protocolFee.address);
    console.log('\n💰 Fee Configuration:');
    console.log('  • Max Fee (immutable):', (parseInt(configuredMaxFee) / 1000000) + ' TRX');
    console.log('  • Current Fee (adjustable):', (parseInt(configuredCurrentFee) / 1000000) + ' TRX');
    console.log('  • Fee Beneficiary:', configuredBeneficiary);
    console.log('\n📨 Next Steps:');
    console.log('  • Update Mailbox required hook to use this ProtocolFee contract');
    console.log('  • Call mailbox.setRequiredHook(' + protocolFee.address + ')');
    console.log('  • Target Mailbox: 415b34081e9d453fc2ba925d893583d89d1b7175dd');
    console.log('='.repeat(60));

    // Store important addresses for reference
    console.log('\n💾 Save this address for your records:');
    console.log('PROTOCOL_FEE_ADDRESS=' + protocolFee.address);

  } catch (error) {
    console.error('\n❌ ProtocolFee deployment failed:', error);
    throw error;
  }
};