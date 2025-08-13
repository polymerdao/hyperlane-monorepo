# Tron Mainnet Contract Addresses

## 📖 Address Format Conversion Guide

TRON addresses need to be converted to EVM format for cross-chain compatibility:

- TRON addresses start with '41' prefix
- To convert TRON → EVM address: Remove '41' prefix and add '0x'
  - Example: 415b34081e9d453fc2ba925d893583d89d1b7175dd → 0x5b34081e9d453fc2ba925d893583d89d1b7175dd
- To view on TronScan, use the converter tool: https://tronscan.org/#/tools/code-converter/tron-ethereum-address

---

## 🎉 Tron Mainnet Deployment Summary

### 📋 Configuration:
- **Target Chain Hyperlane Domain ID**: 728126428
- **Deployer/Owner**: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
- **Network**: mainnet
- **Everclear Mailbox**: 0x7f50C5776722630a0024fAE05fDe8b47571D7B39

### 📍 Core Contract Addresses:
- **Mailbox Proxy Address**: 415b34081e9d453fc2ba925d893583d89d1b7175dd
- **Mailbox Implementation Address**: 41b05b346a0773f37e9a511251399c701959eb9b0e
- **MockISM Address**: 41470c64a6cb6792268394f54c197ce13cac4f408b
- **Mock Default Hook Address**: 41bff447cc666c24e439529a9899d3723e279bb52c
- **Mock Required Hook Address**: 41bff447cc666c24e439529a9899d3723e279bb52c

### 📍 Cross-Chain Infrastructure:
- **PolymerISM Address**: 4151c8a61db22daa6aedfe97395fa5e0ac9812a242
- **Polymer Prover Address**: 41D4D1314724652392356AA169CDE870B34640A38B
- **SimpleMessageSenderReceiver**: 414a6000be6885c3178a558ae8fcce8b473f740a41

### 🔗 Integration Info:
- **Use the Mailbox Proxy Address**: 415b34081e9d453fc2ba925d893583d89d1b7175dd
- **For cross-chain messaging**: Use SimpleMessageSenderReceiver contract
- **Message verification**: Uses PolymerISM to verify messages from Everclear
- **Origin chain**: Messages verified from Everclear Mailbox (0x7f50C5776722630a0024fAE05fDe8b47571D7B39)

### Deploying protocol fee contract

```
❯ just deploy-mainnet-protocol-fee
PROTOCOL_FEE_MAX=100000000 PROTOCOL_FEE_INITIAL=2000000 PROTOCOL_FEE_BENEFICIARY=TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9 PROTOCOL_FEE_OWNER=TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9 npx tronbox migrate --network mainnet -f 6 --to 6
Using network 'mainnet'.

Running migration: 6_deploy_protocol_fee.js
==================================================
Starting ProtocolFee Deployment
==================================================
Network: mainnet
Deployer Address: T
Max Protocol Fee (SUN): 100000000 (100 TRX)
Initial Protocol Fee (SUN): 2000000 (2 TRX)
Beneficiary Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
Owner Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
==================================================

🚀 Deploying ProtocolFee...
  Deploying ProtocolFee...
  ProtocolFee:
    (base58) TDnYG5K5dF29esG4vQbcVcfB5fvANc8Voe
    (hex) 4129dc010b0de7831c174f5a8f2bea4fcb00ae2044
✅ ProtocolFee deployed at: 4129dc010b0de7831c174f5a8f2bea4fcb00ae2044

🔍 Verifying ProtocolFee configuration...
✅ ProtocolFee configured with:
  • Max Protocol Fee: 100000000 SUN (100 TRX)
  • Current Protocol Fee: 2000000 SUN (2 TRX)
  • Beneficiary: 41cc3dee77dd3a77dc623d6c8b931a1b0aab56d81d
  • Owner: 41cc3dee77dd3a77dc623d6c8b931a1b0aab56d81d
  • Hook Type: 8

============================================================
🎉 PROTOCOL FEE DEPLOYMENT SUMMARY
============================================================
📋 Configuration:
  • Network: mainnet
  • Deployer: T

📍 Contract Address:
  • ProtocolFee Address: 4129dc010b0de7831c174f5a8f2bea4fcb00ae2044

💰 Fee Configuration:
  • Max Fee (immutable): 100 TRX
  • Current Fee (adjustable): 2 TRX
  • Fee Beneficiary: 41cc3dee77dd3a77dc623d6c8b931a1b0aab56d81d

📨 Next Steps:
  • Update Mailbox required hook to use this ProtocolFee contract
  • Call mailbox.setRequiredHook(4129dc010b0de7831c174f5a8f2bea4fcb00ae2044)
  • Target Mailbox: 415b34081e9d453fc2ba925d893583d89d1b7175dd
============================================================

💾 Save this address for your records:
PROTOCOL_FEE_ADDRESS=4129dc010b0de7831c174f5a8f2bea4fcb00ae2044
Saving successful migration to network...
Saving artifacts...
```

---

## Deploying PolymerISM contract

```
❯ just deploy-mainnet-polymer-ism
POLYMER_PROVER_ADDRESS=418769615eb43fa257d2f0b3956a114dcd84117b64 ORIGIN_CHAIN_MAILBOX_ADDRESS=0x7f50C5776722630a0024fAE05fDe8b47571D7B39 npx tronbox migrate --network mainnet -f 3 --to 3
Using network 'mainnet'.

Running migration: 3_deploy_polymer_ism.js
==================================================
Starting PolymerISM Deployment
==================================================
Network: mainnet
Deployer Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
Polymer Prover Address: 418769615eb43fa257d2f0b3956a114dcd84117b64
Origin Chain Mailbox Address: 0x7f50C5776722630a0024fAE05fDe8b47571D7B39
==================================================

🚀 Deploying PolymerISM...
  Deploying PolymerISM...
  PolymerISM:
    (base58) TUYnHD7dc6toEybj6K2Lfys1qMiaLZXPQg
    (hex) 41cbcbc532cf88bacf1c8a6359604c784d042bb692
✅ PolymerISM deployed at: 41cbcbc532cf88bacf1c8a6359604c784d042bb692

🔍 Verifying PolymerISM configuration...
✅ PolymerISM configured with:
  • Polymer Prover: 418769615eb43fa257d2f0b3956a114dcd84117b64
  • Origin Mailbox: 417f50c5776722630a0024fae05fde8b47571d7b39

============================================================
🎉 POLYMERISM DEPLOYMENT SUMMARY
============================================================
📋 Configuration:
  • Network: mainnet
  • Deployer: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9

📍 Contract Address:
  • PolymerISM Address: 41cbcbc532cf88bacf1c8a6359604c784d042bb692

📨 Usage Instructions:
  • This PolymerISM verifies messages from: 0x7f50C5776722630a0024fAE05fDe8b47571D7B39
  • Message receivers should specify ISM address: 41cbcbc532cf88bacf1c8a6359604c784d042bb692
  • In their `interchainSecurityModule()` function or ISM configuration
============================================================

💾 Save this address for your records:
POLYMER_ISM_ADDRESS=41cbcbc532cf88bacf1c8a6359604c784d042bb692
Saving successful migration to network...
Saving artifacts...
```

## 💾 Environment Variables

```bash
# Core Infrastructure
MAILBOX_PROXY_ADDRESS=415b34081e9d453fc2ba925d893583d89d1b7175dd
MAILBOX_IMPLEMENTATION_ADDRESS=41b05b346a0773f37e9a511251399c701959eb9b0e
MOCK_ISM_ADDRESS=41470c64a6cb6792268394f54c197ce13cac4f408b
MOCK_DEFAULT_HOOK_ADDRESS=41bff447cc666c24e439529a9899d3723e279bb52c
MOCK_REQUIRED_HOOK_ADDRESS=41bff447cc666c24e439529a9899d3723e279bb52c

# Cross-Chain Components
POLYMER_ISM_ADDRESS=4151c8a61db22daa6aedfe97395fa5e0ac9812a242
SIMPLE_MESSAGE_SENDER_RECEIVER_ADDRESS=414a6000be6885c3178a558ae8fcce8b473f740a41

# Configuration
HYPERLANE_DOMAIN_ID=728126428
POLYMER_PROVER_ADDRESS=41D4D1314724652392356AA169CDE870B34640A38B
EVERCLEAR_MAILBOX_ADDRESS=0x7f50C5776722630a0024fAE05fDe8b47571D7B39
```

---

## 📨 Usage Instructions

### Sending Messages from Tron to Everclear:
1. Call `sendMessage()` on SimpleMessageSenderReceiver contract
2. Messages will be dispatched via the Mailbox and verified by PolymerISM on Everclear

### Receiving Messages from Everclear to Tron:
1. Messages from Everclear are processed by the Mailbox contract
2. PolymerISM verifies message authenticity using the configured prover
3. Verified messages are delivered to the SimpleMessageSenderReceiver contract

### Contract Verification:
- View contracts on TronScan: https://tronscan.org/
- All contracts deployed successfully with proper configuration
- Cross-chain infrastructure ready for message relay operations

---

## 🔍 TronScan Links

- [Mailbox Proxy](https://tronscan.org/#/contract/415b34081e9d453fc2ba925d893583d89d1b7175dd)
- [PolymerISM](https://tronscan.org/#/contract/4151c8a61db22daa6aedfe97395fa5e0ac9812a242)
- [SimpleMessageSenderReceiver](https://tronscan.org/#/contract/414a6000be6885c3178a558ae8fcce8b473f740a41)