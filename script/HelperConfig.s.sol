// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";

contract HelperConfig {

    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;

    address constant BURNER_WALLET = 0x790D6cd73ca1cB7D68525b587C6928aC2883E50c;

    NetworkConfig public localConfig;
    mapping(uint256 => NetworkConfig) private networkConfig;

    constructor() {
        networkConfig[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaNetwork();
        networkConfig[ZKSYNC_SEPOLIA_CHAIN_ID] = getZkSyncSepoliaNetwork();
    }

    function getNetwork() public view returns (NetworkConfig memory) {
        return getNetworkByChainId(block.chainid);
    }

    function getNetworkByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        if(chainId == LOCAL_CHAIN_ID) {
            return getOrCreateLocalNetwork();
        } else if(networkConfig[chainId].account != address(0)) {
            return networkConfig[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaNetwork() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x0576a174D229E3cFA37253523E645A78A0C91B57,
            account: BURNER_WALLET
        });
    }

    function getZkSyncSepoliaNetwork() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0),
            account: BURNER_WALLET
        });
    }

    function getOrCreateLocalNetwork() internal view returns (NetworkConfig memory) {
        if(localConfig.account != address(0)) {
            return localConfig;
        }
        vm.broadcast()
        return NetworkConfig({
            entryPoint: address(0),
            account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        });
    }
}