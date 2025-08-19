// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {IInterchainSecurityModule} from "../interfaces/IInterchainSecurityModule.sol";

contract RevertingISM is IInterchainSecurityModule {
    function moduleType() external view override returns (uint8) {
        return uint8(Types.UNUSED); // Or any appropriate type, doesn't matter much for mock
    }

    function verify(
        bytes calldata _metadata,
        bytes calldata _message
    ) external override returns (bool) {
        // Err towards reverting since false negatives are more secure than false positives
        return false;
    }
}
