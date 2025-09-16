// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.6.11 >=0.8.0 ^0.8.0;

// ../node_modules/@polymerdao/prover-contracts/contracts/interfaces/ICrossL2ProverV2.sol

/*
 * Copyright 2024, Polymer Labs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @title ICrossL2Prover
 * @author Polymer Labs
 * @notice A contract that can prove peptides state. Since peptide is an aggregator of many chains' states, this
 * contract can in turn be used to prove any arbitrary events and/or storage on counterparty chains.
 */
interface ICrossL2ProverV2 {
    /**
     * @notice A a log at a given raw rlp encoded receipt at a given logIndex within the receipt.
     * @notice the receiptRLP should first be validated by calling validateReceipt.
     * @param proof: The proof of a given rlp bytes for the receipt, returned from the receipt MMPT of a block.
     * @return chainId The chainID that the proof proves the log for
     * @return emittingContract The address of the contract that emitted the log on the source chain
     * @return topics The topics of the event. First topic is the event signature that can be calculated by
     * Event.selector. The remaining elements in this array are the indexed parameters of the event.
     * @return unindexedData // The abi encoded non-indexed parameters of the event.
     */
    function validateEvent(bytes calldata proof)
        external
        view
        returns (uint32 chainId, address emittingContract, bytes calldata topics, bytes calldata unindexedData);

    /**
     * Return srcChain, Block Number, Receipt Index, and Local Index for a requested proof
     */
    function inspectLogIdentifier(bytes calldata proof)
        external
        pure
        returns (uint32 srcChain, uint64 blockNumber, uint16 receiptIndex, uint8 logIndex);

    /**
     * Return polymer state root, height , and signature over height and root which can be verified by
     * crypto.pubkey(keccak(peptideStateRoot, peptideHeight))
     */
    function inspectPolymerState(bytes calldata proof)
        external
        pure
        returns (bytes32 stateRoot, uint64 height, bytes memory signature);
}

// contracts/interfaces/IInterchainSecurityModule.sol

interface IInterchainSecurityModule {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        LEGACY_MULTISIG,
        MERKLE_ROOT_MULTISIG,
        MESSAGE_ID_MULTISIG,
        NULL, // used with relayer carrying no metadata
        CCIP_READ,
        ARB_L2_TO_L1,
        WEIGHTED_MERKLE_ROOT_MULTISIG,
        WEIGHTED_MESSAGE_ID_MULTISIG,
        OP_L2_TO_L1,
        POLYMER
    }

    /**
     * @notice Returns an enum that represents the type of security model
     * encoded by this ISM.
     * @dev Relayers infer how to fetch and format metadata.
     */
    function moduleType() external view returns (uint8);

    /**
     * @notice Defines a security model responsible for verifying interchain
     * messages based on the provided metadata.
     * @param _metadata Off-chain metadata provided by a relayer, specific to
     * the security model encoded by the module (e.g. validator signatures)
     * @param _message Hyperlane encoded interchain message
     * @return True if the message was verified
     */
    function verify(
        bytes calldata _metadata,
        bytes calldata _message
    ) external returns (bool);
}

interface ISpecifiesInterchainSecurityModule {
    function interchainSecurityModule()
        external
        view
        returns (IInterchainSecurityModule);
}

// contracts/libs/TypeCasts.sol

library TypeCasts {
    // alignment preserving cast
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        require(
            uint256(_buf) <= uint256(type(uint160).max),
            "TypeCasts: bytes32ToAddress overflow"
        );
        return address(uint160(uint256(_buf)));
    }
}

// contracts/libs/Message.sol

/**
 * @title Hyperlane Message Library
 * @notice Library for formatted messages used by Mailbox
 **/
library Message {
    using TypeCasts for bytes32;

    uint256 private constant VERSION_OFFSET = 0;
    uint256 private constant NONCE_OFFSET = 1;
    uint256 private constant ORIGIN_OFFSET = 5;
    uint256 private constant SENDER_OFFSET = 9;
    uint256 private constant DESTINATION_OFFSET = 41;
    uint256 private constant RECIPIENT_OFFSET = 45;
    uint256 private constant BODY_OFFSET = 77;

    /**
     * @notice Returns formatted (packed) Hyperlane message with provided fields
     * @dev This function should only be used in memory message construction.
     * @param _version The version of the origin and destination Mailboxes
     * @param _nonce A nonce to uniquely identify the message on its origin chain
     * @param _originDomain Domain of origin chain
     * @param _sender Address of sender as bytes32
     * @param _destinationDomain Domain of destination chain
     * @param _recipient Address of recipient on destination chain as bytes32
     * @param _messageBody Raw bytes of message body
     * @return Formatted message
     */
    function formatMessage(
        uint8 _version,
        uint32 _nonce,
        uint32 _originDomain,
        bytes32 _sender,
        uint32 _destinationDomain,
        bytes32 _recipient,
        bytes calldata _messageBody
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _version,
                _nonce,
                _originDomain,
                _sender,
                _destinationDomain,
                _recipient,
                _messageBody
            );
    }

    /**
     * @notice Returns the message ID.
     * @param _message ABI encoded Hyperlane message.
     * @return ID of `_message`
     */
    function id(bytes memory _message) internal pure returns (bytes32) {
        return keccak256(_message);
    }

    /**
     * @notice Returns the message version.
     * @param _message ABI encoded Hyperlane message.
     * @return Version of `_message`
     */
    function version(bytes calldata _message) internal pure returns (uint8) {
        return uint8(bytes1(_message[VERSION_OFFSET:NONCE_OFFSET]));
    }

    /**
     * @notice Returns the message nonce.
     * @param _message ABI encoded Hyperlane message.
     * @return Nonce of `_message`
     */
    function nonce(bytes calldata _message) internal pure returns (uint32) {
        return uint32(bytes4(_message[NONCE_OFFSET:ORIGIN_OFFSET]));
    }

    /**
     * @notice Returns the message origin domain.
     * @param _message ABI encoded Hyperlane message.
     * @return Origin domain of `_message`
     */
    function origin(bytes calldata _message) internal pure returns (uint32) {
        return uint32(bytes4(_message[ORIGIN_OFFSET:SENDER_OFFSET]));
    }

    /**
     * @notice Returns the message sender as bytes32.
     * @param _message ABI encoded Hyperlane message.
     * @return Sender of `_message` as bytes32
     */
    function sender(bytes calldata _message) internal pure returns (bytes32) {
        return bytes32(_message[SENDER_OFFSET:DESTINATION_OFFSET]);
    }

    /**
     * @notice Returns the message sender as address.
     * @param _message ABI encoded Hyperlane message.
     * @return Sender of `_message` as address
     */
    function senderAddress(
        bytes calldata _message
    ) internal pure returns (address) {
        return sender(_message).bytes32ToAddress();
    }

    /**
     * @notice Returns the message destination domain.
     * @param _message ABI encoded Hyperlane message.
     * @return Destination domain of `_message`
     */
    function destination(
        bytes calldata _message
    ) internal pure returns (uint32) {
        return uint32(bytes4(_message[DESTINATION_OFFSET:RECIPIENT_OFFSET]));
    }

    /**
     * @notice Returns the message recipient as bytes32.
     * @param _message ABI encoded Hyperlane message.
     * @return Recipient of `_message` as bytes32
     */
    function recipient(
        bytes calldata _message
    ) internal pure returns (bytes32) {
        return bytes32(_message[RECIPIENT_OFFSET:BODY_OFFSET]);
    }

    /**
     * @notice Returns the message recipient as address.
     * @param _message ABI encoded Hyperlane message.
     * @return Recipient of `_message` as address
     */
    function recipientAddress(
        bytes calldata _message
    ) internal pure returns (address) {
        return recipient(_message).bytes32ToAddress();
    }

    /**
     * @notice Returns the message body.
     * @param _message ABI encoded Hyperlane message.
     * @return Body of `_message`
     */
    function body(
        bytes calldata _message
    ) internal pure returns (bytes calldata) {
        return bytes(_message[BODY_OFFSET:]);
    }
}

// contracts/isms/PolymerIsm.sol

/**
 * @title PolymerISM
 * @author PolymerLabs
 * @notice A generic Interchain Security Module (ISM) for Hyperlane that verifies
 * messages using Polymer proofs of Hyperlane Mailbox `Dispatch` events.
 *
 * @dev This ISM verifies the authenticity of a `Dispatch` event from a specific
 * Mailbox contract on an origin chain, ensuring it targeted this local chain
 * and that the message content matches the proof. It *does not* perform
 * application-specific checks on the message content (e.g., original sender or
 * intended recipient specified within the event data). Such checks should be
 * implemented by the Hyperlane message recipient contract.
 *
 * This ISM expects the `_metadata` field in `verify` to contain *only* the
 * raw `polymerProofBytes` obtained from the Polymer proof service for the
 * corresponding `Dispatch` event on the origin chain.
 */
contract PolymerISM is IInterchainSecurityModule {
    // --- Libraries ---
    using Message for bytes;

    // --- Constants ---

    /**
     * @dev The keccak256 hash of the signature of the Hyperlane Mailbox Dispatch event.
     * keccak256("Dispatch(address,uint32,bytes32,bytes)")
     * Used to ensure the Polymer proof corresponds to the correct event type.
     */
    bytes32 public constant DISPATCH_EVENT_SIGNATURE =
        0x769f711d20c679153d382254f59892613b58a97cc876b249134ac25c80f9c814;

    // --- State Variables ---

    /// @notice The Polymer prover contract deployed on this (local) chain.
    ICrossL2ProverV2 public immutable polymerProver;

    /// TODO: Add support for multiple Mailbox contract addresses.
    /// @notice The Hyperlane Mailbox contract address on the origin chain.
    /// @dev This is the contract expected to emit the Dispatch event proven by Polymer.
    /// This naive appraoch assumes the Mailbox contract is deployed to the same address on all chains.
    /// This approach does not scale to multiple Mailbox contract addresses.
    address public immutable originMailbox;

    // --- Events ---

    event PolymerISMConfigured(
        address indexed polymerProver,
        address indexed originMailbox
    );

    // --- Constructor ---

    /**
     * @notice Deploys and configures the PolymerISM.
     * @param _polymerProver Address of the ICrossL2ProverV2 contract on this chain.
     * @param _originMailbox Address of the Mailbox contract on the origin chain.
     */
    constructor(address _polymerProver, address _originMailbox) {
        require(
            _polymerProver != address(0),
            "PolymerISM: Invalid polymer prover address"
        );
        require(
            _originMailbox != address(0),
            "PolymerISM: Invalid origin mailbox address"
        );

        polymerProver = ICrossL2ProverV2(_polymerProver);
        originMailbox = _originMailbox;

        emit PolymerISMConfigured(_polymerProver, _originMailbox);
    }

    // --- IInterchainSecurityModule Implementation ---
    /**
     * @notice Returns the module type for this ISM.
     * @dev This ISM implements a Polymer-specific verification scheme.
     * @return uint8 The module type identifier (Types.POLYMER)
     */
    function moduleType() external view override returns (uint8) {
        return uint8(Types.POLYMER);
    }

    /**
     * @inheritdoc IInterchainSecurityModule
     * @notice Verifies a Hyperlane message by validating a Polymer proof of the
     * corresponding `Dispatch` event from the configured origin Mailbox.
     * @param _metadata The raw Polymer proof bytes (`polymerProofBytes`) for the Dispatch event.
     * @param _message The Hyperlane message bytes being verified. This *must* correspond
     * to the `message` field within the proven Dispatch event.
     * @return True if the Polymer proof is valid and confirms a `Dispatch` event
     * from the origin chain targeting this chain with matching `message` content
     * matching `message` content was emitted. False otherwise.
     */
    function verify(
        bytes calldata _metadata,
        bytes calldata _message
    ) external override returns (bool) {
        // Step 1: Assume metadata is the raw Polymer proof bytes
        bytes calldata polymerProofBytes = _metadata;
        // Basic check: ensure proof is not empty
        require(polymerProofBytes.length > 0, "PolymerISM: Empty proof");

        // Step 2: Call Polymer Prover to validate the event proof and extract details.
        // This reverts if the proof itself is invalid according to the Polymer contract.
        (
            uint32 chainId_from_proof,
            address emittingContract_from_proof,
            bytes memory topics_from_proof,
            bytes memory data_from_proof
        ) = polymerProver.validateEvent(polymerProofBytes);

        // --- Perform Generic Verification Checks ---

        // Check 1: Verify message origin matches the chain ID from the proof
        require(
            _message.origin() == chainId_from_proof,
            "PolymerISM: Message origin mismatch"
        );

        // Check 2: Verify the event was emitted by the correct Mailbox contract
        require(
            emittingContract_from_proof == originMailbox,
            "PolymerISM: Proof emitter mismatch (origin mailbox)"
        );

        // Check 3: Does the proven event match the Hyperlane Dispatch event signature?
        // Dispatch has signature + 3 indexed topics = 4 total topics.
        require(
            topics_from_proof.length == 128,
            "PolymerISM: Invalid packed topics length for Dispatch event"
        );
        // Extract topic0 (event signature)
        bytes32 signature_from_proof;
        assembly {
            signature_from_proof := mload(add(topics_from_proof, 0x20)) // 0x20 is the offset for the first element in a bytes array
        }
        require(
            signature_from_proof == DISPATCH_EVENT_SIGNATURE,
            "PolymerISM: Invalid event signature in proof"
        );

        // Check 4: Decode the indexed 'destination' topic. Must be this local domain.
        // Extract topic2 (destination domain)
        bytes32 destination_topic;
        assembly {
            destination_topic := mload(add(topics_from_proof, 0x60)) // Offset for the third topic (0x20 + 2*0x20 = 0x60)
        }
        // Topic 2: uint32 indexed destination (Hyperlane Mailbox Dispatch event format)
        uint32 destination_from_proof = uint32(uint256(destination_topic));
        require(
            destination_from_proof == block.chainid,
            "PolymerISM: Proof destination mismatch (local domain)"
        );

        // Check 5: Decode the non-indexed 'message' data from the proof's data field.
        // The 'data' field of the Dispatch event contains only the abi.encode(bytes message).
        bytes memory message_from_proof = abi.decode(data_from_proof, (bytes));

        // Check 6: Does the *full message* content from the proof match the *full message* being verified?
        require(
            keccak256(message_from_proof) == keccak256(_message),
            "PolymerISM: Proof message content mismatch"
        );

        // If all checks pass, the ISM considers the message verified *at this level*.
        // Further application-specific checks (on sender/recipient within the message)
        // must be done by the receiving contract.
        return true;
    }
}

