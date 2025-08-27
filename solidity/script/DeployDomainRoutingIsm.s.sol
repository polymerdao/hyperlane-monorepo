// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {DomainRoutingIsm} from "../contracts/isms/routing/DomainRoutingIsm.sol";
import {IInterchainSecurityModule} from "../contracts/interfaces/IInterchainSecurityModule.sol";

contract DeployDomainRoutingIsm is Script {
    function run() external returns (address deployedRoutingIsmAddress) {
        // --- Configuration (Read from environment variables) ---
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("--- Deploying DomainRoutingIsm ---");
        console.log("Deployer Address:", deployerAddress);
        console.log("-------------------------------------------");

        vm.startBroadcast(deployerPrivateKey);

        // --- 1. Deploy DomainRoutingIsm ---
        DomainRoutingIsm routingIsm = new DomainRoutingIsm();
        deployedRoutingIsmAddress = address(routingIsm);
        console.log("DomainRoutingIsm deployed at:", deployedRoutingIsmAddress);

        // --- 2. Initialize Ownership ---
        // DomainRoutingIsm inherits from DomainRoutingIsm, which is OwnableUpgradeable.
        // We need to initialize it to set the owner, then the owner can set routes later.
        routingIsm.initialize(deployerAddress); // Sets deployerAddress as the owner
        console.log(
            "Initialized DomainRoutingIsm ownership to deployer:",
            deployerAddress
        );

        vm.stopBroadcast();

        // --- Post-Deployment Info ---
        console.log("-----------------------------------------");
        console.log("Deployment Summary:");
        console.log("  DomainRoutingIsm Address:", deployedRoutingIsmAddress);
        console.log("  Ready for route configuration via separate scripts");
        console.log("-----------------------------------------");

        return deployedRoutingIsmAddress;
    }
}
