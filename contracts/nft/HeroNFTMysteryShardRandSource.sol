// SPDX-License-Identifier: MIT
// DreamIdol Contracts (HeroNFTMysteryShardRandSource.sol)

pragma solidity ^0.8.0;

import "../mysterybox/MSRandomSourceBase.sol";

import "./HeroNFTCodec.sol";
import "./HeroNFT.sol";


contract HeroNFTMysteryShardRandSource is 
    MSRandomSourceBase
{
    using RandomPoolLib for RandomPoolLib.RandomPool;

    HeroNFT public _heroNFTContract;

    constructor(address heroNftAddr)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        _heroNFTContract = HeroNFT(heroNftAddr);
    }
    
    function srandomAndMint(uint256 r, ShardAttr memory attr, address to) override external
        returns(MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts) 
    {
        require(hasRole(MINTER_ROLE, _msgSender()), "ownership error");

        uint32[] storage poolIDArray = _mbRandomSets[attr.mysteryType];

        require(poolIDArray.length == 31, "mb type config wrong");

        HeroNFTDataBase memory baseData = _getSingleRandHero(r, attr, poolIDArray);

        // mint 
        uint256 newId = _heroNFTContract.mint(to, baseData);

        nfts = new MBContentMinterNftInfo[](1); // 1 nft
        sfts = new MBContentMinter1155Info[](0); // no sft

        nfts[0] = MBContentMinterNftInfo({
            addr : address(_heroNFTContract),
            tokenIds : new uint256[](1)
        });
        nfts[0].tokenIds[0] = newId;
    }

    function sbatchRandomAndMint(uint256 r, ShardAttr memory attr, address to, uint8 batchCount) override external
        returns(MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts)
    {
        require(hasRole(MINTER_ROLE, _msgSender()), "ownership error");

        uint32[] storage poolIDArray = _mbRandomSets[attr.mysteryType];

        require(poolIDArray.length == 31, "mb type config wrong");

        nfts = new MBContentMinterNftInfo[](1); // 1 nft
        sfts = new MBContentMinter1155Info[](0); // no sft record

        nfts[0] = MBContentMinterNftInfo({
            addr : address(_heroNFTContract),
            tokenIds : new uint256[](batchCount)
        });

        for(uint8 i=0; i< batchCount; ++i)
        {
            r = _rand.nextRand(i, r);
            HeroNFTDataBase memory baseData = _getSingleRandHero(r, attr, poolIDArray);

            // mint 
            uint256 newId = _heroNFTContract.mint(to, baseData);

            nfts[0].tokenIds[i] = newId;
        }
    }

    function _getSingleRandHero(
        uint256 r,
        ShardAttr memory attr,
        uint32[] storage poolIDArray
    ) internal view returns (HeroNFTDataBase memory baseData)
    {
        uint32 index = 0;
        
        NFTRandPool storage pool; /* = _randPools[poolIDArray[0]]; */ // index 0 : ignore
        uint8 job = uint8(attr.shardID); // shardID is job of hero

        if(job <= 2){
            pool = _randPools[poolIDArray[/*0 +*/ attr.grade]]; // index 1-10 : job(1-2) mineAttr rand by grade 
        }
        else{
            pool = _randPools[poolIDArray[10 + attr.grade]]; // index 11-20 : job(3-15) mineAttr rand by grade
        }
        r = _rand.nextRand(++index, r);
        require(pool.exist, "mineAttr pool not exist");
        uint16 mineAttr = uint8(pool.randPool.random(r));

        pool = _randPools[poolIDArray[20 + attr.grade]]; // index 21-30 : battleAttr rand by grade
        r = _rand.nextRand(++index, r);
        require(pool.exist, "battleAttr pool not exist");
        uint16 battleAttr = uint8(pool.randPool.random(r));

        HeroNFTFixedData_V1 memory fdata = HeroNFTFixedData_V1({
            job : job,
            grade : attr.grade,
            minerAttr : mineAttr,
            battleAttr : battleAttr
        });

        HeroNFTWriteableData_V1 memory wdata = HeroNFTWriteableData_V1({
            starLevel: 0,
            level : 1
        });

        IHeroNFTCodec_V1 codec = IHeroNFTCodec_V1(_heroNFTContract.getCodec());
        baseData = codec.fromHeroNftFixedAnWriteableData(fdata, wdata);
        baseData.mintType = 0;
    }
}