# Contract Addresses

## 📖 Address Format Conversion Guide

TRON addresses need to be converted to EVM format for cross-chain compatibility:

- TRON addresses start with '41' prefix
- To convert TRON → EVM address: Remove '41' prefix and add '0x'
  - Example: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7 → 0x77d2287aff6124ac5e01f417ad97cd39f2c31df7
- To view on TronScan, use the converter tool: https://tronscan.org/#/tools/code-converter/tron-ethereum-address

---

## 🎉 Latest Deployment Summary

<!-- Copy/paste the deployment output below this line -->

```
============================================================
🎉 DEPLOYMENT SUMMARY
============================================================
📋 Configuration:
  • Target Chain Hyperlane Domain ID: 3448148188
  • Deployer/Owner: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
  • Network: nile

📍 Contract Addresses:
  • MockISM Address: 41ec4313b31334838f2951f4d14979e594b783257c
  • Mock Default Hook Address: 417fd8c7e488f8b1657a90f3dc8730a8f6453243a9
  • Mock Required Hook Address: 417fd8c7e488f8b1657a90f3dc8730a8f6453243a9
  • Mailbox Implementation Address: 419bf0aa4dd56d155f45497c095415384c4cb5d9ba
  • Mailbox Proxy Address: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7

🔗 Integration Info:
  • Use the Mailbox Proxy Address: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7
  • As the `originMailbox` when deploying PolymerISM on the destination chain.
============================================================

💾 Save these addresses for your records:
MAILBOX_PROXY_ADDRESS=4177d2287aff6124ac5e01f417ad97cd39f2c31df7
MAILBOX_IMPLEMENTATION_ADDRESS=419bf0aa4dd56d155f45497c095415384c4cb5d9ba
MOCK_ISM_ADDRESS=41ec4313b31334838f2951f4d14979e594b783257c
MOCK_DEFAULT_HOOK_ADDRESS=417fd8c7e488f8b1657a90f3dc8730a8f6453243a9
MOCK_REQUIRED_HOOK_ADDRESS=417fd8c7e488f8b1657a90f3dc8730a8f6453243a9
HYPERLANE_DOMAIN_ID=3448148188
```

```
Running migration: 3_deploy_polymer_ism.js
==================================================
Starting PolymerISM Deployment
==================================================
Network: nile
Deployer Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
Polymer Prover Address: 414AF0B36D0C91FC4E1A4CFB6D15F3354A44A0371A
Origin Chain Mailbox Address: 0x7f50C5776722630a0024fAE05fDe8b47571D7B39
==================================================

🚀 Deploying PolymerISM...
  Replacing PolymerISM...
  PolymerISM:
    (base58) TDNcS1m8C43vNeJvnzAfyLyP2kEcEBE4sG
    (hex) 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8
✅ PolymerISM deployed at: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8

🔍 Verifying PolymerISM configuration...
✅ PolymerISM configured with:
  • Polymer Prover: 414af0b36d0c91fc4e1a4cfb6d15f3354a44a0371a
  • Origin Mailbox: 417f50c5776722630a0024fae05fde8b47571d7b39

============================================================
🎉 POLYMERISM DEPLOYMENT SUMMARY
============================================================
📋 Configuration:
  • Network: nile
  • Deployer: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9

📍 Contract Address:
  • PolymerISM Address: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8

📨 Usage Instructions:
  • This PolymerISM verifies messages from: 0x7f50C5776722630a0024fAE05fDe8b47571D7B39
  • Message receivers should specify ISM address: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8
  • In their `interchainSecurityModule()` function or ISM configuration
============================================================

💾 Save this address for your records:
POLYMER_ISM_ADDRESS=41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8
Saving successful migration to network...
Saving artifacts...
```

```
Running migration: 4_deploy_simple_message_sender_receiver.js
==================================================
Starting SimpleMessageSenderReceiver Deployment
==================================================
Network: nile
Deployer Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
⚠️  Could not fetch balance: Cannot read properties of undefined (reading 'nile')

📋 Using existing contracts:
  • Mailbox Proxy Address: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7
  • PolymerISM Address: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8
==================================================

🚀 Deploying SimpleMessageSenderReceiver...
Constructor parameters:
  • _mailbox: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7
  • _polymerIsm: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8
  Replacing SimpleMessageSenderReceiver...
  SimpleMessageSenderReceiver:
    (base58) TSDXeJ21x4gpFNVpdg9cTYHu8yZKGhEgYa
    (hex) 41b23765c5fbaaa78012d1f81f32a8cbec4eb3b278
✅ SimpleMessageSenderReceiver deployed at: 41b23765c5fbaaa78012d1f81f32a8cbec4eb3b278

🔍 Verifying deployment...
✅ Configured Mailbox: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7
✅ Configured PolymerISM: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8
✅ Initial message counter: 0

============================================================
🎉 SIMPLE MESSAGE SENDER/RECEIVER DEPLOYMENT SUMMARY
============================================================
📋 Configuration:
  • Network: nile
  • Deployer: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
  • Mailbox: 4177d2287aff6124ac5e01f417ad97cd39f2c31df7
  • PolymerISM: 41255580c8f6c1a2d46d47aa622ebc3ed25b4a0da8

📍 Contract Address:
  • SimpleMessageSenderReceiver: 41b23765c5fbaaa78012d1f81f32a8cbec4eb3b278

📨 Usage Instructions:
  • Use sendMessage() to dispatch messages to other chains
  • The contract will receive messages via handle() function
  • Messages are verified using the configured PolymerISM
  • Query getLatestMessageDetails() to see received messages
============================================================

💾 Save this address for your records:
SIMPLE_MESSAGE_SENDER_RECEIVER_ADDRESS=41b23765c5fbaaa78012d1f81f32a8cbec4eb3b278
Saving successful migration to network...
Saving artifacts...
```

```
❯ just deploy-testnet-protocol-fee
PROTOCOL_FEE_MAX=100000000 PROTOCOL_FEE_INITIAL=2000000 PROTOCOL_FEE_BENEFICIARY=TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9 PROTOCOL_FEE_OWNER=TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9 npx tronbox migrate --network nile -f 6 --to 6
Using network 'nile'.

Running migration: 6_deploy_protocol_fee.js
==================================================
Starting ProtocolFee Deployment
==================================================
Network: nile
Deployer Address: T
Max Protocol Fee (SUN): 100000000 (100 TRX)
Initial Protocol Fee (SUN): 2000000 (2 TRX)
Beneficiary Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
Owner Address: TUb93GbDTKS2RCbfmRzNwEiCTQ8iFPwXF9
==================================================

🚀 Deploying ProtocolFee...
  Deploying ProtocolFee...
  ProtocolFee:
    (base58) TE9NWkhb9Q2cKcXvXTK5fUraFe4ThD6MGa
    (hex) 412dcc9a5b9821f179279be16a156fac232dce070e
✅ ProtocolFee deployed at: 412dcc9a5b9821f179279be16a156fac232dce070e

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
  • Network: nile
  • Deployer: T

📍 Contract Address:
  • ProtocolFee Address: 412dcc9a5b9821f179279be16a156fac232dce070e

💰 Fee Configuration:
  • Max Fee (immutable): 100 TRX
  • Current Fee (adjustable): 2 TRX
  • Fee Beneficiary: 41cc3dee77dd3a77dc623d6c8b931a1b0aab56d81d

📨 Next Steps:
  • Update Mailbox required hook to use this ProtocolFee contract
  • Call mailbox.setRequiredHook(412dcc9a5b9821f179279be16a156fac232dce070e)
  • Target Mailbox: 415b34081e9d453fc2ba925d893583d89d1b7175dd
============================================================

💾 Save this address for your records:
PROTOCOL_FEE_ADDRESS=412dcc9a5b9821f179279be16a156fac232dce070e
Saving successful migration to network...
Saving artifacts...
```