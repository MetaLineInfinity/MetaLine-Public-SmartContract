// SPDX-License-Identifier: MIT
// Metaline Contracts (IBilling.sol)

pragma solidity ^0.8.0;

interface IBillReceiver {
    function onBillPaied(string calldata appid, string calldata orderid, string calldata reason, string calldata token, uint256 value) external returns(bool);
}

interface IBilling {
    event PayBill(address indexed userAddr, string indexed appid, string indexed orderid, string reason, string token, uint256 value);
    event PayBillByUSDValue(address indexed userAddr, string indexed appid, string indexed orderid, string reason, string token, uint256 value, uint256 usdValue);

    function setBillingApp(string calldata appid, address receiver) external;
    function payBill(string calldata appid, string calldata orderid, string calldata reason, string calldata token, uint256 value) external;
    function payBillByUSDValue(string calldata appid, string calldata orderid, string calldata reason, string calldata token, uint256 usdValue) external;
}