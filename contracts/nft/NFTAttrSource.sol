// SPDX-License-Identifier: MIT
// Metaline Contracts (HeroNFTAttrSource.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

 /**
  * @dev hero nft miner attribute
  */
 struct HeroNFTMinerAttr {
     uint8 minerJob;
     uint8 minerRate;
     uint8 sailerSpeedPer;
     uint8 sailerLoadPer;
     uint8 sailerRangePer;
     uint32 hashRate;
 }

 /**
  * @dev hero nft battle attribute
  */
 struct HeroNFTBattleAttr { 
     uint16 attackPer;
     uint16 defensePer;
     uint16 hitpointPer;
     uint16 missPer;
     uint16 dogePer;
     uint16 criticalPer;
     uint16 decriticalPer;
     uint16 speedPer;
 }
 
 /**
  * @dev ship nft miner attribute
  */
 struct ShipNFTMinerAttr {
    // TO DO : add attr
    uint32 hashRate;
    uint8 maxSailer;
 }

 /**
  * @dev ship nft battle attribute
  */
 struct ShipNFTBattleAttr { 
     uint16 attackPer;

    // TO DO : add attr
 }

/**
 * @dev nft attribute source contract
 */
contract NFTAttrSource_V1 is
    Context,
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(uint32=>HeroNFTMinerAttr) public _heroMineAttrs;
    mapping(uint32=>HeroNFTBattleAttr) public _heroBattleAttrs;

    mapping(uint32=>ShipNFTMinerAttr) public _shipMineAttrs;
    mapping(uint32=>ShipNFTBattleAttr) public _shipBattleAttrs;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    /**
    * @dev get hero or pet miner attribute by mineAttr
    * @param mineAttr miner attribtue id
    * @param starLevel hero star level, if nft is pet, startLevel always = 1
    * @return data output data of HeroNFTMinerAttr
    */
    function getHeroMinerAttr(uint32 mineAttr, uint16 starLevel) external view returns (HeroNFTMinerAttr memory data)
    {
        // TO DO : calc attr by level
        starLevel;
        return _heroMineAttrs[mineAttr];
    }

    /**
    * @dev get hero or pet battle attribute by battleAttr
    * @param battleAttr battle attribtue id
    * @param level hero or pet nft level
    * @return data output data of HeroNFTBattleAttr
    */
    function getHeroBattleAttr(uint32 battleAttr, uint16 level) external view returns (HeroNFTBattleAttr memory data)
    {
        // TO DO : calc attr by level
        level;
        return _heroBattleAttrs[battleAttr];
    }

    /**
    * @dev set hero or pet miner attributes
    * @param mineAttrs mine attribute ids
    * @param datas input data array of HeroNFTMinerAttr
    */
    function setHeroMinerAttr(uint32[] memory mineAttrs, HeroNFTMinerAttr[] memory datas) external
    {
        require(mineAttrs.length == datas.length, "NFTAttrSource_V1: parameter error");
        require(hasRole(MANAGER_ROLE, _msgSender()), "NFTAttrSource_V1: must have manager role to manage");

        for(uint i=0; i< mineAttrs.length; ++i){
            _heroMineAttrs[mineAttrs[i]] = datas[i];
        }
    }

    /**
    * @dev set hero or pet battle attributes
    * @param battleAttrs battle attribute ids
    * @param datas input data array of HeroNFTBattleAttr
    */
    function setHeroBattleAttr(uint32[] memory battleAttrs, HeroNFTBattleAttr[] memory datas) external
    {
        require(battleAttrs.length == datas.length, "NFTAttrSource_V1: parameter error");
        require(hasRole(MANAGER_ROLE, _msgSender()), "NFTAttrSource_V1: must have manager role to manage");

        for(uint i=0; i< battleAttrs.length; ++i){
            _heroBattleAttrs[battleAttrs[i]] = datas[i];
        }
    }
    
    /**
    * @dev get ship miner attribute by mineAttr
    * @param mineAttr miner attribtue id
    * @param level ship nft level
    * @return data output data of ShipNFTMinerAttr
    */
    function getShipMinerAttr(uint32 mineAttr, uint16 level) external view returns (ShipNFTMinerAttr memory data)
    {
        // TO DO : calc attr by level
        level;
        return _shipMineAttrs[mineAttr];
    }

    /**
    * @dev get ship battle attribute by battleAttr
    * @param battleAttr battle attribtue id
    * @param level ship nft level
    * @return data output data of ShipNFTBattleAttr
    */
    function getShipBattleAttr(uint32 battleAttr, uint16 level) external view returns (ShipNFTBattleAttr memory data)
    {
        // TO DO : calc attr by level
        level;
        return _shipBattleAttrs[battleAttr];
    }

    /**
    * @dev set ship miner attributes
    * @param mineAttrs mine attribute ids
    * @param datas input data array of ShipNFTMinerAttr
    */
    function setShipMinerAttr(uint32[] memory mineAttrs, ShipNFTMinerAttr[] memory datas) external
    {
        require(mineAttrs.length == datas.length, "NFTAttrSource_V1: parameter error");
        require(hasRole(MANAGER_ROLE, _msgSender()), "NFTAttrSource_V1: must have manager role to manage");

        for(uint i=0; i< mineAttrs.length; ++i){
            _shipMineAttrs[mineAttrs[i]] = datas[i];
        }
    }

    /**
    * @dev set ship battle attributes
    * @param battleAttrs battle attribute ids
    * @param datas input data array of ShipNFTBattleAttr
    */
    function setShipBattleAttr(uint32[] memory battleAttrs, ShipNFTBattleAttr[] memory datas) external
    {
        require(battleAttrs.length == datas.length, "NFTAttrSource_V1: parameter error");
        require(hasRole(MANAGER_ROLE, _msgSender()), "NFTAttrSource_V1: must have manager role to manage");

        for(uint i=0; i< battleAttrs.length; ++i){
            _shipBattleAttrs[battleAttrs[i]] = datas[i];
        }
    }
}
