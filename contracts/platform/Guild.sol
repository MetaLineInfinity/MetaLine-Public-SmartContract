// SPDX-License-Identifier: MIT
// Metaline Contracts (Guild.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../utility/TransferHelper.sol";
import "../utility/OracleCharger_V1.sol";

contract Guild is 
    Context,
    Pausable,
    AccessControl
{
    using OracleCharger_V1 for OracleCharger_V1.OracleChargerStruct;
    
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");
    bytes32 public constant DATA_ROLE = keccak256("DATA_ROLE");

    OracleCharger_V1.OracleChargerStruct public _oracleCharger;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(SERVICE_ROLE, _msgSender());
        _setupRole(DATA_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Guild: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Guild: must have pauser role to unpause"
        );
        _unpause();
    }

    function setTPOracleAddr(address tpOracleAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Billing: must have manager role");

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
        require(hasRole(MANAGER_ROLE, _msgSender()), "Billing: must have manager role");

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Billing: must have manager role");

        _oracleCharger.removeChargeToken(tokenName);
    }

    // build user sbt
    // create guild from sbt

    // guild extend from nft with extendable data

    function CreateGuild(bool allowForceQuit) external returns(uint256 guildID) {

    }

    function TransferGuild(uint256 guildID, address toUserAddr) external {

    }

    function JoinGuild(uint256 guildID) external {

    }

    function ReqQuitGuild() external {

    }

    function KickGuildMember() external {

    }

    function ExtendGuildData(string memory extendName) external {

    }

    function ModifyGuildData(uint256 guildID, string memory extendName, bytes memory extendData) external {

    }

    function GetGuildData(uint256 guildID, string memory extendName) external returns (bytes memory extendData) {
    }

    function GetGuildAccount(uint256 guildID) external returns(address) {
        // ERC-6551
    }
}