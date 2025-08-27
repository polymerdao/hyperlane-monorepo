// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {DomainRoutingIsm} from "../contracts/isms/routing/DomainRoutingIsm.sol";
import {IInterchainSecurityModule} from "../contracts/interfaces/IInterchainSecurityModule.sol";

contract ConfigureDomainRoutingIsm is Script {
    function run() external {
        // --- Configuration (Read from environment variables) ---
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        // Address of the DefaultFallbackRoutingIsm to configure
        address domainRoutingIsmAddress = vm.envAddress(
            "DOMAIN_ROUTING_ISM_ADDRESS"
        );
        require(
            domainRoutingIsmAddress != address(0),
            "ConfigureDomainRoutingIsm: Set DOMAIN_ROUTING_ISM_ADDRESS env var"
        );

        // Origin domain to be configured
        uint32 originDomain = uint32(vm.envUint("ORIGIN_DOMAIN"));
        require(
            originDomain > 0,
            "ConfigureDomainRoutingIsm: Set ORIGIN_DOMAIN env var"
        );

        // ISM address for the origin domain
        address ismAddress = vm.envAddress("ISM_ADDRESS");
        require(
            ismAddress != address(0),
            "ConfigureDomainRoutingIsm: Set ISM_ADDRESS env var"
        );

        console.log("--- Configuring DomainRoutingIsm ---");
        console.log("Deployer Address:", deployerAddress);
        console.log("DomainRoutingIsm Address:", domainRoutingIsmAddress);
        console.log("Origin Domain to Configure:", originDomain);
        console.log("ISM Address for Origin:", ismAddress);
        console.log("---------------------------------------------");

        vm.startBroadcast(deployerPrivateKey);

        // Get the contract instance
        DomainRoutingIsm domainRoutingIsm = DomainRoutingIsm(
            domainRoutingIsmAddress
        );

        // Configure the origin domain mapping
        domainRoutingIsm.set(
            originDomain,
            IInterchainSecurityModule(ismAddress)
        );
        console.log(
            "Successfully set Origin Domain",
            originDomain,
            "to ISM",
            ismAddress
        );

        vm.stopBroadcast();

        console.log("---------------------------------------------");
        console.log("DomainRoutingIsm Configuration Complete");
        console.log("---------------------------------------------");
    }
}
