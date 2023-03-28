// SPDX-License-Identifier: MIT
// Metaline Contracts (Expedition.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../MTT.sol";
import "../MTTGold.sol";
import "../nft/HeroNFT.sol";
import "../nft/WarrantNFT.sol";
import "../nft/ShipNFT.sol";

contract Expedition is
    Context,
    Pausable,
    AccessControl 
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    struct ExpeditionPoolConf {
        uint32 baseGoldToMTT;
        uint256 maxMTTPerSecond; 
        uint256 maxOutputhashRate;
    }

    struct ExpeditionShip {
        uint256 shipNFTID;
        uint256[] heroNFTIDs;
    }
    struct ShipExpeditionTeam {
        uint256 teamHashRate;
        ExpeditionShip[] ships;
    }

    struct HeroExpeditionTeam {
        uint256 teamHashRate; // all nft hashrate
        uint256[] heroNFTIDs; // hero nfts, 0 must be hero nft, 
    }

    struct PortHeroExpedPool {
        uint256 totalHashRate; // all team hashrate
        ExpeditionPoolConf poolConf; 
        mapping(address=>HeroExpeditionTeam) _expedHeros; // user addr => hero expedition team
    }

    address public _warrantNFTAddr;
    address public _heroNFTAddr;
    address public _shipNFTAddr;
    address public _MTTGoldAddr;
    address public _MTTAddr;

    mapping(uint16=>PortHeroExpedPool) _heroExpeditions;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Expedition: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Expedition: must have pauser role to unpause"
        );
        _unpause();
    }

    function init(
        address warrantNFTAddr,
        address heroNFTAddr,
        address shipNFTAddr,
        address MTTAddr,
        address MTTGoldAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Expedition: must have manager role");

        _warrantNFTAddr = warrantNFTAddr;
        _heroNFTAddr = heroNFTAddr;
        _shipNFTAddr = shipNFTAddr;
        _MTTAddr = MTTAddr;
        _MTTGoldAddr = MTTGoldAddr;
    }

    function setHeroExpedTeam(uint256[] memory heroNftIDs) external {

    }

    function unsetHeroExpedTeam() external {

    }

    function setShipExpedTeam(ExpeditionShip[] memory expedShips) external {

    }
    function unsetShipExpedTeam() external {

    }
}
