// SPDX-License-Identifier: MIT
// DreamIdol Contracts (HeroNFTMSCombiner.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "../mysterybox/MSRandomSourceBase.sol";
import "../mysterybox/MysteryBox1155.sol";

import "./HeroNFT.sol";

contract HeroNFTMSCombiner is 
    Context, 
    Pausable, 
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event SpliteToShards(address indexed userAddr, uint256 heroTokenId, uint256 shardId, uint256 shardCount);
    event CombineShards(address indexed userAddr, uint256 shardId, uint256 value, uint256 newShardId, uint256 newCount);

    HeroNFT public _heroNFT;
    MysteryBox1155 public _mb1155;
    address public _fuelTokenAddr;

    mapping(uint8=>uint64) public _shardCombineCount; // grade => combine count << 32 | fuel token cost
    mapping(uint8=>uint64) public _shardSpliteCount; // grade => splite count << 32 | fuel token cost

    mapping(uint16=>uint32) public _heroJobgrade2MB; // job<<8 | grade => randomType << 16 | mysteryType
    mapping(uint8=>uint32) public _petId2MB; // petId => randomType << 16 | mysteryType

    mapping(uint8=>uint8) public _heroJobMaxGrade; // job => max grade;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "HeroNFTMSCombiner: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "HeroNFTMSCombiner: must have pauser role to unpause"
        );
        _unpause();
    }

    function setHeroNftAddress(address nftAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");
        _heroNFT = HeroNFT(nftAddr);
    }

    function setMB1155Address(address nftAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");
        _mb1155 = MysteryBox1155(nftAddr);
    }
    
    function setFuelToken(address fuelTokenAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");

        _fuelTokenAddr = fuelTokenAddr;
    }

    function setShardCombineCount(uint8 grade, uint32 combineCount, uint32 fuelCost) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTMSCombiner: must have manager role to manage");

        _shardCombineCount[grade] = (uint64(combineCount) << 32) | uint64(fuelCost);
    }

    function setShardSpliteCount(uint8 grade, uint32 splietCount, uint32 fuelCost) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTMSCombiner: must have manager role to manage");

        _shardSpliteCount[grade] =  (uint64(splietCount) << 32) | uint64(fuelCost);
    }

    function setHeroJobGrade2MB(uint8 job, uint8 grade, uint16 randomType, uint16 mysteryType) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTMSCombiner: must have manager role to manage");

        _heroJobgrade2MB[(uint16(job)<<8) | uint16(grade)] = (uint32(randomType) << 16) | uint32(mysteryType);
    }
    function setPetId2MB(uint8 petId, uint16 randomType, uint16 mysteryType) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTMSCombiner: must have manager role to manage");

        _petId2MB[petId] = (uint32(randomType) << 16) | uint32(mysteryType);
    }

    function setHeroJobMaxGrade(uint8 job, uint8 maxGrade) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "HeroNFTMSCombiner: must have manager role to manage");

        _heroJobMaxGrade[job] = maxGrade;
    }

    function spliteToShards(uint256 tokenId) external {
        require(_heroNFT.ownerOf(tokenId) == _msgSender(), "HeroNFTMSCombiner: ownership error");

        IHeroNFTCodec_V1 codec = IHeroNFTCodec_V1(_heroNFT.getCodec());
        HeroNFTDataBase memory hdb = _heroNFT.getNftData(tokenId);

        ShardAttr memory attr;
        attr.shardType = uint8(hdb.nftType); // shard type = nft type : =1 hero, =2 pet

        if(attr.shardType == 1){
            // hero
            HeroNFTFixedData_V1 memory hndata = codec.getHeroNftFixedData(hdb);
            attr.grade = hndata.grade;
            attr.shardID = hndata.job; // shardID = hero job
            
            uint32 mbv = _heroJobgrade2MB[(uint16(hndata.job)<<8) | uint16(hndata.grade)];
            attr.randomType = uint16(mbv >> 16 & 0xffff);
            attr.mysteryType = uint16(mbv & 0xffff);
        }
        else if(attr.shardType == 2){
            // pet
            HeroPetNFTFixedData_V1 memory hndata = codec.getHeroPetNftFixedData(hdb);
            attr.grade = 7; // pet grade default = 7
            attr.shardID = hndata.petId; // shardID = petId

            uint32 mbv = _petId2MB[hndata.petId];
            attr.randomType = uint16(mbv >> 16 & 0xffff);
            attr.mysteryType = uint16(mbv & 0xffff);
        }

        uint256 costv = _shardSpliteCount[attr.grade];
        uint32 spliteCount = uint32(costv >> 32 & 0xffffffff);
        require(spliteCount > 0, "HeroNFTMSCombiner: wrong shard splite count");

        uint256 fuelCost = uint256(costv & 0xffffffff) * 10**18;
        if(fuelCost > 0){
            require(ERC20Burnable(_fuelTokenAddr).balanceOf(_msgSender()) >= fuelCost, "MysteryShard: insufficient fuel");
            ERC20Burnable(_fuelTokenAddr).burnFrom(_msgSender(), fuelCost);
        }

        _heroNFT.burn(tokenId);

        uint256 shardId = _encodeShardId(attr);
        _mb1155.mint(_msgSender(), shardId, spliteCount, "splite");

        emit SpliteToShards(_msgSender(), tokenId, shardId, spliteCount);
    }

    function combineShards(uint256 shardId, uint256 value) external {
        require(_mb1155.balanceOf(_msgSender(), shardId)>=value, "HeroNFTMSCombiner: shard not enough");

        (uint8 tokenType, ShardAttr memory attr) = _decodeShardId(shardId);
        require(tokenType == 1, "HeroNFTMSCombiner: not shard token");
        require(attr.shardType == 1, "HeroNFTMSCombiner: not hero shard token");
        
        uint256 costv = _shardCombineCount[attr.grade];
        uint32 combineCount = uint32(costv >> 32 & 0xffffffff);
        require(combineCount > 0, "HeroNFTMSCombiner: wrong shard combine count");

        uint256 fuelCost = uint256(costv & 0xffffffff) * 10**18;
        if(fuelCost > 0){
            require(ERC20Burnable(_fuelTokenAddr).balanceOf(_msgSender()) >= fuelCost, "MysteryShard: insufficient fuel");
            ERC20Burnable(_fuelTokenAddr).burnFrom(_msgSender(), fuelCost);
        }

        require(value >= combineCount && value == combineCount * (value/combineCount),  "HeroNFTMSCombiner: wrong shard combine value");

        //console.log("[sol]id=",id);
        uint8 maxGrade = _heroJobMaxGrade[uint8(attr.shardID)];
        if(maxGrade == 0){
            maxGrade = 10; // default max grade = 10
        }

        require(attr.grade < maxGrade, "can not combine max grade shard"); 

        _mb1155.burn(_msgSender(), shardId, value);

        attr.grade = attr.grade + 1;
        uint256 newShardId = _encodeShardId(attr);
        
        uint256 newCount = value/combineCount;
        //console.log("[sol]newid=",newId,newCount);

        _mb1155.mint(_msgSender(), newShardId, newCount, "combine");

        emit CombineShards(_msgSender(), shardId, value, newShardId, newCount);
    }
    
    // |-- type=1 (Mystery Shard) : shardID(uint16) << 48 | grade(uint8) << 40 | shardType(uint8) << 32 | randomType(uint16) << 16 | mysteryType(uint16)
    function _decodeShardId(uint256 tokenId) internal pure returns(
        uint8 tokenType,
        ShardAttr memory attr
    ) {
        tokenType = (uint8)((tokenId >> 64) & 0xff);
        attr.shardID = (uint16)((tokenId >> 48) & 0xffff);
        attr.grade = (uint8)((tokenId >> 40) & 0xff);
        attr.shardType = (uint8)((tokenId >> 32) & 0xff);
        attr.randomType = (uint16)((tokenId >> 16) & 0xffff);
        attr.mysteryType = (uint16)(tokenId & 0xffff);
    }
    function _encodeShardId(ShardAttr memory attr) internal pure returns(uint256 tokenId) {
        tokenId = (0x01 << 64) | // token type = 1 : Mystery Shard
            ((uint256(attr.shardID) & 0xffff) << 48 ) |
            ((uint256(attr.grade) & 0xff) << 40 ) |
            ((uint256(attr.shardType) & 0xff) << 32 ) |
            ((uint256(attr.randomType) & 0xffff) << 16 ) |
            (uint256(attr.mysteryType) & 0xffff);
    }
}