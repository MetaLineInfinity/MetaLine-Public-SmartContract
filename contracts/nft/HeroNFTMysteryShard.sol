// SPDX-License-Identifier: MIT
// DreamIdol Contracts (HeroNFTMysteryShard.sol)

pragma solidity ^0.8.0;

import "../mysterybox/MysteryShardBase.sol";

contract HeroNFTMysteryShard is MysteryShardBase
{    
    function getName() external virtual override returns(string memory)
    {
        return "Hero NFT Mystery Shard";
    }
}