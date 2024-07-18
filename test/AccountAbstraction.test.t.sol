// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { AccountAbstraction } from "src/Ethereum/AccountAbstraction.sol";
import { DeployAccountAbstraction } from "script/DeployAccountAbstraction.s.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";
import { SendPackedUserOp, IEntryPoint } from "script/SendPackedUserOp.s.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { PackedUserOperation } from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AccountAbstractionTest is Test {

    using MessageHashUtils for bytes32;

    ERC20Mock usdc;

    HelperConfig helperConfig;
    AccountAbstraction accountAbstraction;
    SendPackedUserOp sendPackedUserOp;

    uint256 constant AMOUNT = 1e18;

    address randomUser = makeAddr("randomUser");

    function setUp() public {
        DeployAccountAbstraction deployAA = new DeployAccountAbstraction();
        (helperConfig, accountAbstraction) = deployAA.deployAccountAbstraction();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecute() public {
        assertEq(usdc.balanceOf(address(accountAbstraction)), 0);

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstraction), AMOUNT);

        vm.prank(accountAbstraction.owner());
        accountAbstraction.executeTransaction(dest, value, data);

        assertEq(usdc.balanceOf(address(accountAbstraction)), AMOUNT);
    }

    function testNonOwnerCannotExecute() public {
        assertEq(usdc.balanceOf(address(accountAbstraction)), 0);

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstraction), AMOUNT);

        vm.prank(randomUser);
        vm.expectRevert(AccountAbstraction.NotFromEntryPointOrOwner.selector);
        accountAbstraction.executeTransaction(dest, value, data);
    }

    function testRecoverSignedOp() public {
        assertEq(usdc.balanceOf(address(accountAbstraction)), 0);

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstraction), AMOUNT);
        bytes memory executeCallData = abi.encodeWithSelector(AccountAbstraction.executeTransaction.selector, dest, value, data);
        
        HelperConfig.NetworkConfig memory network = helperConfig.getNetwork();
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedUserOp(executeCallData, helperConfig.getNetwork(), address(accountAbstraction));

        // bytes32 userOpHash = IEntryPoint(network.entryPoint).getUserOpHash(packedUserOp);
        // address finalSigner = ECDSA.recover(userOpHash.toEthSignedMessageHash(), packedUserOp.signature);

        // assertEq(finalSigner, accountAbstraction.owner());
    }
}