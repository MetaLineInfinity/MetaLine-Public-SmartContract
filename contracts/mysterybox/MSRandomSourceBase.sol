// SPDX-License-Identifier: MIT
// Metaline Contracts (MSRandomSourceBase.sol)

pragma solidity ^0.8.0;

import "./MBRandomSourceBase.sol";

struct ShardAttr {
    uint16 shardID; // hero job or petId
    uint8 grade; // 
    uint8 shardType; // shard type = nft type : =1 hero, =2 pet
    uint16 randomType;
    uint16 mysteryType;
}

abstract contract MSRandomSourceBase is MBRandomSourceBase {

    function randomAndMint(uint256 r, uint32 mysteryTp, address to) override external pure
        returns(MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts) 
    {
        r;
        mysteryTp;
        to;
        sfts;
        nfts;
        revert("not implement");
    }

    function batchRandomAndMint(uint256 r, uint32 mysteryTp, address to, uint8 batchCount) override external pure
        returns(MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts)
    {
        r;
        mysteryTp;
        to;
        sfts;
        nfts;
        batchCount;
        revert("not implement");
    }

    function srandomAndMint(uint256 r, ShardAttr memory attr, address to) virtual external
        returns(MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts);

    function sbatchRandomAndMint(uint256 r, ShardAttr memory attr, address to, uint8 batchCount) virtual external
        returns(MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts);
}