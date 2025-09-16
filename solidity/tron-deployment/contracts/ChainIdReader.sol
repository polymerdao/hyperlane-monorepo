// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChainIdReader {
    function getChainId() public view returns (uint256) {
        return block.chainid;
    }
    
    function getCurrentChainId() external view returns (uint256) {
        return block.chainid;
    }
}