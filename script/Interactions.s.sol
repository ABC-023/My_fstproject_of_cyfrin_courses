//withdraw
//fund

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 ETH in wei

    receive() external payable {}

    // This script is used to fund the most recently deployed FundMe contract

    function fundFundMe(address mostRecentlyDeployed) public {
        // This function can be used to fund the most recently deployed contract

        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();

        console.log(
            "Funded FundMe contract at address: %s with %s wei",
            mostRecentlyDeployed,
            SEND_VALUE
        );
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
        // We can use the most recently deployed contract address to fund it
        // This is useful for testing purposes
        // If we want to fund a specific contract, we can pass its address
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        // This function can be used to fund the most recently deployed contract
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawFundMe(mostRecentlyDeployed);

        // We can use the most recently deployed contract address to fund it
        // This is useful for testing purposes
        // If we want to fund a specific contract, we can pass its address
    }
}
