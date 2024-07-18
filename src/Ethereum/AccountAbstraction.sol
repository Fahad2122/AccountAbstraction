// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IAccount } from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import { PackedUserOperation } from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS } from "lib/account-abstraction/contracts/core/Helpers.sol";
import { IEntryPoint } from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract AccountAbstraction is IAccount, Ownable {

    error NotFromEntryPoint();
    error NotFromEntryPointOrOwner();
    error TransactionExecutionFailed(bytes);

    IEntryPoint immutable private i_entryPoint;

    modifier requireFromEntryPoint{
        if(msg.sender != address(i_entryPoint)) {
            revert NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner{
        if(msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert NotFromEntryPointOrOwner();
        }
        _;
    }

    receive() external payable {}

    constructor(address _entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(_entryPoint);
    }

    function executeTransaction(address _dest, uint256 _value, bytes calldata _data) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = _dest.call{value: _value}(_data);
        if(!success) {
            revert TransactionExecutionFailed(result);
        }
    }

    function validateUserOp (PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) external requireFromEntryPoint returns (uint256 validationData) {
        validationData = _validateSignature(userOp, userOpHash);
        _payPreFund(missingAccountFunds);
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash) internal view returns (uint256 validationData) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if(signer != owner()) {
            return SIG_VALIDATION_FAILED;
        } else {
            return SIG_VALIDATION_SUCCESS;
        }
    }

    function _payPreFund(uint256 missingAccountFunds) internal {
        if(missingAccountFunds != 0) {
            (bool success, ) = payable(msg.sender).call{ value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }

    function getEntryPoint() public view returns (address) {
        return address(i_entryPoint);
    }
}