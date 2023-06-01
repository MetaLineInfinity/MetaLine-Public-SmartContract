// SPDX-License-Identifier: MIT
// Metaline Contracts (Billing.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../interface/platform/IBilling.sol";
import "../utility/TransferHelper.sol";
import "../utility/OracleCharger_V1.sol";

contract Billing is 
    Context,
    Pausable,
    AccessControl,
    IBilling
{
    using OracleCharger_V1 for OracleCharger_V1.OracleChargerStruct;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    OracleCharger_V1.OracleChargerStruct public _oracleCharger;

    mapping(string=>address) public _billingApps;
    mapping(string=>address) public _tokens;
    
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Billing: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Billing: must have pauser role to unpause"
        );
        _unpause();
    }

    function setTokens(string calldata token, address tokenAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Billing: must have manager role");

        _tokens[token] = tokenAddr;
    }
    function setBillingApp(string calldata appid, address receiver) external override {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Billing: must have manager role");

        _billingApps[appid] = receiver;
    }
    
    function setTPOracleAddr(address tpOracleAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "OffOnChainBridge: must have manager role");

        _oracleCharger.setTPOracleAddr(tpOracleAddr);
    }

    // maximumUSDPrice = 0: no limit
    // minimumUSDPrice = 0: no limit
    function addChargeToken(
        string memory tokenName, 
        address tokenAddr, 
        uint256 maximumUSDPrice, 
        uint256 minimumUSDPrice
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "OffOnChainBridge: must have manager role");

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "OffOnChainBridge: must have manager role");

        _oracleCharger.removeChargeToken(tokenName);
    }

    function payBill(
        string calldata appid, 
        string calldata orderid, 
        string calldata reason, 
        string calldata token, 
        uint256 value
    ) override external {
        address receiver = _billingApps[appid];
        require(receiver != address(0), "Billing: app not exist");

        address tokenAddr = _tokens[token];
        require(tokenAddr != address(0), "Billing: token not exist");

        TransferHelper.safeTransferFrom(tokenAddr, _msgSender(), receiver, value);

        if(_isContract(receiver)){
            IBillReceiver(receiver).onBillPaied(appid, orderid, reason, token, value);
        }

        emit PayBill(_msgSender(), appid, orderid, reason, token, value);
    }

    function payBillByUSDValue(
        string calldata appid, 
        string calldata orderid, 
        string calldata reason, 
        string calldata token, 
        uint256 usdValue
    ) override external {
        address receiver = _billingApps[appid];
        require(receiver != address(0), "Billing: app not exist");

        address tokenAddr = _tokens[token];
        require(tokenAddr != address(0), "Billing: token not exist");

        uint256 tokenValue = _oracleCharger.charge(token, usdValue, receiver);

        if(_isContract(receiver)){
            IBillReceiver(receiver).onBillPaied(appid, orderid, reason, token, tokenValue);
        }

        emit PayBillByUSDValue(_msgSender(), appid, orderid, reason, token, tokenValue, usdValue);
    }

    
    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}