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

        // Address of the Mailbox contract on THIS chain (for fallback mechanism)

        // The domain ID of the remote chain for which we are setting a specific PolymerISM route
        uint32 remoteOriginDomainId = uint32(
            vm.envUint("REMOTE_ORIGIN_DOMAIN_ID")
        );

        require(
            remoteOriginDomainId != 0,
            "DeployDomainRoutingIsm: Set REMOTE_ORIGIN_DOMAIN_ID env var"
        );

        // The address of the PolymerISM (deployed on THIS chain) that verifies messages FROM the remoteOriginDomainId
        address polymerIsmForRemoteOrigin = vm.envAddress(
            "POLYMER_ISM_FOR_REMOTE_ORIGIN_ADDRESS"
        );
        require(
            polymerIsmForRemoteOrigin != address(0),
            "DeployDomainRoutingIsm: Set POLYMER_ISM_FOR_REMOTE_ORIGIN_ADDRESS env var"
        );

        console.log("--- Deploying DomainRoutingIsm ---");
        console.log("Deployer Address:", deployerAddress);
        console.log(
            "Configuring route for remote origin domain:",
            remoteOriginDomainId
        );
        console.log("  Using PolymerISM at:", polymerIsmForRemoteOrigin);
        console.log("-------------------------------------------");

        vm.startBroadcast(deployerPrivateKey);

        // --- 1. Deploy DomainRoutingIsm ---
        // The constructor takes the local mailbox address.
        DomainRoutingIsm routingIsm = new DomainRoutingIsm();
        deployedRoutingIsmAddress = address(routingIsm);
        console.log("DomainRoutingIsm deployed at:", deployedRoutingIsmAddress);

        // --- 2. Initialize Ownership and Configure Route ---
        // DomainRoutingIsm inherits from DomainRoutingIsm, which is OwnableUpgradeable.
        // We need to initialize it to set the owner, then the owner can set routes.
        routingIsm.initialize(deployerAddress); // Sets deployerAddress as the owner
        console.log(
            "Initialized DomainRoutingIsm ownership to deployer:",
            deployerAddress
        );

        // Now, set the specific route for the remoteOriginDomainId to use the designated PolymerISM.
        routingIsm.set(
            remoteOriginDomainId,
            IInterchainSecurityModule(polymerIsmForRemoteOrigin)
        );
        console.log(
            "Route configured: Messages from domain",
            remoteOriginDomainId,
            "will use ISM",
            polymerIsmForRemoteOrigin
        );

        vm.stopBroadcast();

        // --- Post-Deployment Info ---
        console.log("-----------------------------------------");
        console.log("Deployment Summary:");
        console.log("  DomainRoutingIsm Address:", deployedRoutingIsmAddress);
        console.log(
            "  Explicit route configured for domain:",
            remoteOriginDomainId
        );
        console.log("    -> Using PolymerISM:", polymerIsmForRemoteOrigin);
        console.log("  Messages from other domains will revert.");
        console.log("-----------------------------------------");

        return deployedRoutingIsmAddress;
    }
}
