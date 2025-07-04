// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract Interactionstest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant START_BALANCE = 7 * 10 ** 18; // 7 ETH in wei
    uint256 constant SEND_VALUE = 7 * 10 ** 18;
    uint256 constant GAS_PRICE = 1 * 10 ** 9; // 1 Gwei in wei

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        console.log("FundMe contract deployed at:", address(fundMe));
        vm.deal(USER, START_BALANCE);
    }

    function testUserCanFundinteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.deal(address(fundFundMe), SEND_VALUE);
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(
            address(fundMe).balance,
            0,
            "Balance should be zero after withdrawal by owner"
        );
    }
}
