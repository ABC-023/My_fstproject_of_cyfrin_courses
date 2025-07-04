//SPDX-Licence-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //Si tu travail sur Anvil en local, tu peux utiliser les mocks
    //Sinon, tu peux utiliser les vrais contrats Chainlink sur Sepolia ou Mainnet

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address ethUsdPriceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) {
            // Anvil
            activeNetworkConfig = getAnvilEthConfig();
        } else {
            revert("Unsupported network");
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia ETH/USD price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD price feed address
        });
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        // Anvil ETH/USD price feed address (mock)
        //1. Deploy the mock contract using the script
        //2. Use the address of the deployed mock contract

        if (activeNetworkConfig.ethUsdPriceFeed != address(0)) {
            return activeNetworkConfig; // Return existing config if already set
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(8, 2000e8); // 2000 USD in 8 decimals
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            ethUsdPriceFeed: address(mockV3Aggregator) // Anvil ETH/USD price feed address (mock)
        });
        return anvilConfig;
    }
}
