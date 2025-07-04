//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Tout ce qui est avant startBroadcast est exécuté en local donc n'est pas une real transaction
        // Nous allons déployer le contrat FundMe avec l'adresse du price feed ETH/USD
        // HelperConfig est utilisé pour obtenir la configuration du réseau actif
        // et le prix de l'ETH/USD.
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
