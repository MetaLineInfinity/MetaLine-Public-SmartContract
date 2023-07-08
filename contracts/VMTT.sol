// SPDX-License-Identifier: MIT
// Metaline Contracts (VMTT.sol)

pragma solidity ^0.8.0;

import "./core/CappedERC20.sol";

// Metaline VeToken
contract VMTT is CappedERC20 {

    constructor(uint256 v)
        CappedERC20("MetaLine VeToken", "VMTT", v)
    {

    }
}