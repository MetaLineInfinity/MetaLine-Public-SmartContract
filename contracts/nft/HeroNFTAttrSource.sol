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
 * @dev hero nft attribute source contract
 */
contract HeroNFTAttrSource_V1 is
    Context,
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(uint16=>HeroNFTMinerAttr) public _mineAttrs;
    mapping(uint16=>HeroNFTBattleAttr) public _battleAttrs;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    /**
    * @dev get miner attribute by mineAttr
    * @param mineAttr miner attribtue id
    * @return data output data of HeroNFTMinerAttr
    */
    function getMinerAttr(uint16 mineAttr) external view returns (HeroNFTMinerAttr memory data)
    {
        return _mineAttrs[mineAttr];
    }

    /**
    * @dev get battle attribute by battleAttr
    * @param battleAttr battle attribtue id
    * @return data output data of HeroNFTBattleAttr
    */
    function getBattleAttr(uint16 battleAttr) external view returns (HeroNFTBattleAttr memory data)
    {
        return _battleAttrs[battleAttr];
    }

    /**
    * @dev set miner attributes
    * @param mineAttrs mine attribute ids
    * @param datas input data array of HeroNFTMinerAttr
    */
    function setMinerAttr(uint16[] memory mineAttrs, HeroNFTMinerAttr[] memory datas) external
    {
        require(mineAttrs.length == datas.length, "HeroNFTAttrSource: parameter error");
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTAttrSource: must have manager role to manage");

        for(uint i=0; i< mineAttrs.length; ++i){
            _mineAttrs[mineAttrs[i]] = datas[i];
        }
    }

    /**
    * @dev set battle attributes
    * @param battleAttrs battle attribute ids
    * @param datas input data array of HeroNFTBattleAttr
    */
    function setBattleAttr(uint16[] memory battleAttrs, HeroNFTBattleAttr[] memory datas) external
    {
        require(battleAttrs.length == datas.length, "HeroNFTAttrSource: parameter error");
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTAttrSource: must have manager role to manage");

        for(uint i=0; i< battleAttrs.length; ++i){
            _battleAttrs[battleAttrs[i]] = datas[i];
        }
    }
}
