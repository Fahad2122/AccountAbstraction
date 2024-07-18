// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { AccountAbstraction } from "../src/Ethereum/AccountAbstraction.sol";

contract DeployAccountAbstraction is Script {
    constructor() {}

    function deployAccountAbstraction() public returns(HelperConfig, AccountAbstraction) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory network = helperConfig.getNetwork();

        vm.startBroadcast(network.account);
        AccountAbstraction accountAbstraction = new AccountAbstraction(network.entryPoint);
        accountAbstraction.transferOwnership(msg.sender);
        vm.stopBroadcast();
        
        return (helperConfig, accountAbstraction);
    }
}