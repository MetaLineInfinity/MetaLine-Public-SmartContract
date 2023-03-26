// SPDX-License-Identifier: MIT
// Metaline Contracts (HeroPetTrain.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../utility/OracleCharger.sol";

import "../nft/WarrantNFT.sol";

contract HeroPetTrain is
    Context,
    Pausable,
    AccessControl 
{
    using OracleCharger for OracleCharger.OracleChargerStruct;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");

    OracleCharger.OracleChargerStruct public _oracleCharger;

    address public _warrantNFTAddr;
    address public _heroNFTAddr;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(SERVICE_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "HeroPetTrain: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "HeroPetTrain: must have pauser role to unpause"
        );
        _unpause();
    }
    
    function setTPOracleAddr(address tpOracleAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroPetTrain: must have manager role");

        _oracleCharger.setTPOracleAddr(tpOracleAddr);
    }

    function setReceiveIncomeAddr(address incomeAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroPetTrain: must have manager role");

        _oracleCharger.setReceiveIncomeAddr(incomeAddr);
    }

    // maximumUSDPrice = 0: no limit
    // minimumUSDPrice = 0: no limit
    function addChargeToken(
        string memory tokenName, 
        address tokenAddr, 
        uint256 maximumUSDPrice, 
        uint256 minimumUSDPrice
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroPetTrain: must have manager role");

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroPetTrain: must have manager role");

        _oracleCharger.removeChargeToken(tokenName);
    }

    function init(
        address warrantNFTAddr,
        address heroNFTAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroPetTrain: must have manager role");

        _warrantNFTAddr = warrantNFTAddr;
        _heroNFTAddr = heroNFTAddr;
    }
    
    function startUpgrade_Hero(
        uint256 heroNFTID,
        uint256 usdPrice,
        string memory tokenName
    ) external whenNotPaused {

    }

    function finishUpgrade_Hero(

    ) external whenNotPaused {
        
    }
}