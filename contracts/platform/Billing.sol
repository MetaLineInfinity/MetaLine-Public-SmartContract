// SPDX-License-Identifier: MIT
// Metaline Contracts (Billing.sol)

pragma solidity ^0.8.0;

import "../interface/platform/IBilling.sol";

contract Billing is IBilling {

    function setBillingApp(string calldata appid, address receiver) external override {

    }
    function payBill(
        string calldata appid, 
        string calldata orderid, 
        string calldata reason, 
        string calldata token, 
        uint256 value
    ) override external {


    }

    function payBillByUSDValue(
        string calldata appid, 
        string calldata orderid, 
        string calldata reason, 
        string calldata token, 
        uint256 usdValue
    ) override external {

    }
}