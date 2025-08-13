// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.6.11 >=0.8.0 ^0.8.0;

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

// contracts/interfaces/IMessageRecipient.sol

interface IMessageRecipient {
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable;
}

// contracts/interfaces/hooks/IPostDispatchHook.sol

/*@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@  HYPERLANE  @@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
@@@@@@@@@       @@@@@@@@*/

interface IPostDispatchHook {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        MERKLE_TREE,
        INTERCHAIN_GAS_PAYMASTER,
        FALLBACK_ROUTING,
        ID_AUTH_ISM,
        PAUSABLE,
        PROTOCOL_FEE,
        LAYER_ZERO_V1,
        RATE_LIMITED,
        ARB_L2_TO_L1,
        OP_L2_TO_L1,
        MAILBOX_DEFAULT_HOOK,
        AMOUNT_ROUTING
    }

    /**
     * @notice Returns an enum that represents the type of hook
     */
    function hookType() external view returns (uint8);

    /**
     * @notice Returns whether the hook supports metadata
     * @param metadata metadata
     * @return Whether the hook supports metadata
     */
    function supportsMetadata(
        bytes calldata metadata
    ) external view returns (bool);

    /**
     * @notice Post action after a message is dispatched via the Mailbox
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     */
    function postDispatch(
        bytes calldata metadata,
        bytes calldata message
    ) external payable;

    /**
     * @notice Compute the payment required by the postDispatch call
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     * @return Quoted payment for the postDispatch call
     */
    function quoteDispatch(
        bytes calldata metadata,
        bytes calldata message
    ) external view returns (uint256);
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

// contracts/interfaces/IMailbox.sol

interface IMailbox {
    // ============ Events ============
    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param sender The address that dispatched the message
     * @param destination The destination domain of the message
     * @param recipient The message recipient address on `destination`
     * @param message Raw bytes of message
     */
    event Dispatch(
        address indexed sender,
        uint32 indexed destination,
        bytes32 indexed recipient,
        bytes message
    );

    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param messageId The unique message identifier
     */
    event DispatchId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is processed
     * @param messageId The unique message identifier
     */
    event ProcessId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is delivered
     * @param origin The origin domain of the message
     * @param sender The message sender address on `origin`
     * @param recipient The address that handled the message
     */
    event Process(
        uint32 indexed origin,
        bytes32 indexed sender,
        address indexed recipient
    );

    function localDomain() external view returns (uint32);

    function delivered(bytes32 messageId) external view returns (bool);

    function defaultIsm() external view returns (IInterchainSecurityModule);

    function defaultHook() external view returns (IPostDispatchHook);

    function requiredHook() external view returns (IPostDispatchHook);

    function latestDispatchedId() external view returns (bytes32);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external view returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata defaultHookMetadata
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata defaultHookMetadata
    ) external view returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    ) external view returns (uint256 fee);

    function process(
        bytes calldata metadata,
        bytes calldata message
    ) external payable;

    function recipientIsm(
        address recipient
    ) external view returns (IInterchainSecurityModule module);
}

// contracts/test/SimpleMessageSenderReceiver.sol

/**
 * @title SimpleMessageSenderReceiver
 * @notice A simple contract to test sending and receiving Hyperlane messages
 * using a Mailbox configured with PolymerISM.
 * Supports protocol fees by forwarding msg.value to mailbox dispatch calls.
 */
contract SimpleMessageSenderReceiver is
    IMessageRecipient,
    ISpecifiesInterchainSecurityModule
{
    using TypeCasts for address;

    // --- State Variables ---

    /// @notice Address of the Mailbox contract on the local chain.
    IMailbox public immutable mailbox;
    /// @notice Address of the PolymerISM contract on the local chain (used when this contract receives messages).
    IInterchainSecurityModule public immutable polymerIsm;

    uint32 public messageCounter;
    bytes public latestReceivedMessage;
    uint32 public latestReceivedOrigin;
    bytes32 public latestReceivedSender;

    // --- Events ---

    event MessageSent(
        uint32 destinationDomain,
        address recipientAddress,
        bytes messageBody,
        bytes32 messageId
    );
    event MessageReceived(
        uint32 originDomain,
        bytes32 senderAddress,
        bytes messageBody
    );

    // --- Constructor ---

    /**
     * @notice Deploys the test contract.
     * @param _mailbox Address of the local Mailbox contract.
     * @param _polymerIsm Address of the local PolymerISM contract.
     */
    constructor(address _mailbox, address _polymerIsm) {
        require(_mailbox != address(0), "Invalid mailbox address");
        require(_polymerIsm != address(0), "Invalid ISM address");
        mailbox = IMailbox(_mailbox);
        polymerIsm = IInterchainSecurityModule(_polymerIsm);
    }

    // --- Sending Logic ---

    /**
     * @notice Dispatches a message via the local Mailbox.
     * @param _destinationDomain The target chain's domain ID.
     * @param _recipientAddress The address of the recipient contract on the destination chain.
     * @param _messageBody The content of the message to send.
     * @dev Now payable to support protocol fees. Pass fee as msg.value.
     */
    function sendMessage(
        uint32 _destinationDomain,
        address _recipientAddress,
        bytes calldata _messageBody
    ) external payable returns (bytes32) {
        // Convert recipient address to bytes32 for Mailbox dispatch
        bytes32 recipientBytes32 = _recipientAddress.addressToBytes32();

        // Dispatch the message, forwarding any fee sent with this transaction
        bytes32 messageId = mailbox.dispatch{value: msg.value}(
            _destinationDomain,
            recipientBytes32,
            _messageBody
        );

        emit MessageSent(
            _destinationDomain,
            _recipientAddress,
            _messageBody,
            messageId
        );

        return messageId;
    }

    /**
     * @notice Quote the fee required to dispatch a message.
     * @param _destinationDomain The target chain's domain ID.
     * @param _recipientAddress The address of the recipient contract on the destination chain.
     * @param _messageBody The content of the message to send.
     * @return fee The fee required to dispatch this message.
     */
    function quoteDispatch(
        uint32 _destinationDomain,
        address _recipientAddress,
        bytes calldata _messageBody
    ) external view returns (uint256 fee) {
        bytes32 recipientBytes32 = _recipientAddress.addressToBytes32();
        return mailbox.quoteDispatch(
            _destinationDomain,
            recipientBytes32,
            _messageBody
        );
    }

    // --- Receiving Logic (IMessageRecipient) ---

    /**
     * @notice Handles an incoming message delivered by the Mailbox.
     * @param _origin The domain ID of the chain where the message originated.
     * @param _sender The address (bytes32) of the contract that sent the message on the origin chain.
     * @param _body The body of the message.
     * @dev This function can only be successfully called by the local Mailbox contract
     * after it has verified the message using the specified ISM (PolymerISM in this case).
     */
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _body
    ) external payable override {
        messageCounter++;
        latestReceivedOrigin = _origin;
        latestReceivedSender = _sender;
        latestReceivedMessage = _body;

        emit MessageReceived(_origin, _sender, _body);
    }

    // --- ISM Specification (ISpecifiesInterchainSecurityModule) ---

    /**
     * @notice Specifies the ISM to be used for verifying messages sent to this contract.
     * @return The address of the PolymerISM contract.
     */
    function interchainSecurityModule()
        external
        view
        override
        returns (IInterchainSecurityModule)
    {
        return polymerIsm;
    }

    // --- View Functions ---

    function getLatestMessageDetails()
        external
        view
        returns (uint32 origin, bytes32 sender, bytes memory body, uint32 count)
    {
        return (
            latestReceivedOrigin,
            latestReceivedSender,
            latestReceivedMessage,
            messageCounter
        );
    }
}

