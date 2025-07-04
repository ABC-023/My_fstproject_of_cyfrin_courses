// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // Deploy the FundMe contract before running tests
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

    function testMinimumUsd() public pure {
        console.log("Testing minimum USD value...");
        uint256 minimumUsd = 5 * 10 ** 18; // 5 USD in wei
        assertEq(minimumUsd, 5000000000000000000);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeed() public view {
        // This test checks if the price feed is correctly set up
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        // Assuming the version is 4, adjust as necessary
    }

    function testFundFailsWithoutMinimumUsd() public {
        // This test checks if funding fails when less than minimum USD is sent
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund{value: 0 * 10 ** 18}(); // Sending 1 ETH, which is less than 5 USD
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // Simulate a different user funding the contract
        fundMe.fund{value: SEND_VALUE}();
        address funder = USER; // The address of the test contract
        uint256 amountFunded = fundMe.getAddressToAmountFunded(funder);
        assertEq(amountFunded, 7 * 10 ** 18);
        emit log_named_uint("USER balance", USER.balance);
    }

    function testAddsFunderToArrayofFunder() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        uint256 gasStart = gasleft(); // Start measuring gas
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft(); // Stop measuring gas
        uint256 gasUsed = gasStart - gasEnd; // Calculate gas used
        emit log_named_uint("Gas used for withdrawal", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        emit log_named_uint("startingOwnerBalance", startingOwnerBalance);
        emit log_named_uint("startingFundMeBalance", startingFundMeBalance);
        emit log_named_uint("endingOwnerBalance", endingOwnerBalance);
        emit log_named_uint("endingFundMeBalance", endingFundMeBalance);
    }

    function testWithDrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderindex = 1;
        for (uint256 i = startingFunderindex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            //fund the fundMe
            hoax(address(uint160(i)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        emit log_named_uint("startingOwnerBalance", startingOwnerBalance);
        emit log_named_uint("startingFundMeBalance", startingFundMeBalance);
        emit log_named_uint("endingOwnerBalance", endingOwnerBalance);
        emit log_named_uint("endingFundMeBalance", endingFundMeBalance);
    }
}
