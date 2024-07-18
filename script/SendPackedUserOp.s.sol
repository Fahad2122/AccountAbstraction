// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";
import { PackedUserOperation } from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { IEntryPoint } from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SendPackedUserOp is Test {

    using MessageHashUtils for bytes32;

    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 constant ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function generateSignedUserOp(bytes memory _calldata, HelperConfig.NetworkConfig memory _network, address _accountAbstraction) public view returns (PackedUserOperation memory) {

        uint256 nonce = vm.getNonce(_accountAbstraction) - 1;
        PackedUserOperation memory unsignedUserOp = generateUnsignedOp(_accountAbstraction, nonce, _calldata);

        bytes32 userOpHash = IEntryPoint(_network.entryPoint).getUserOpHash(unsignedUserOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        uint8 v;
        bytes32 r;
        bytes32 s;
        if(block.chainid == 31337) {
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        }
        unsignedUserOp.signature = abi.encodePacked(r, s, v);
        return unsignedUserOp;
    }

    function generateUnsignedOp(address _sender, uint256 _nonce, bytes memory _calldata) internal pure returns (PackedUserOperation memory) {

        uint256 accountGasLimit = 16777216;
        uint256 maxGasLimit = accountGasLimit;
        uint256 maxPriorityPerGas = 256;
        uint256 maxGasFee = maxPriorityPerGas;
        return PackedUserOperation({
            sender: _sender,
            nonce: _nonce,
            initCode: hex"",
            callData: _calldata,
            accountGasLimits: bytes32(uint256(accountGasLimit) << 128 | maxGasLimit),
            preVerificationGas: accountGasLimit,
            gasFees: bytes32(uint256(maxPriorityPerGas) << 128 | maxGasFee),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}