// SPDX-License-Identifier: MIT
// MetaLine Contracts (GuildProxy.sol)

pragma solidity ^0.8.0;

contract GuildConfig {
    
    address public owner;

    uint256 public CreateGuildUSDPrice;
    uint16 public GuildInvitorShare; // share/10000
    uint16 public GuildOwnerShare; // share/10000

    constructor()
    {
        owner = msg.sender;

        CreateGuildUSDPrice = 100000000; // 1 usd
        GuildInvitorShare = 800; // 8%
        GuildOwnerShare = 200; // 2%
    }
    
    function changeOwner(address newOwner) external {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');
        owner = newOwner;
    }

    function SetConfig(
        uint256 CreateGuildUSDPrice_,
        uint16 GuildInvitorShare_,
        uint16 GuildOwnerShare_
    ) external {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');

        CreateGuildUSDPrice = CreateGuildUSDPrice_;
        GuildInvitorShare = GuildInvitorShare_;
        GuildOwnerShare = GuildOwnerShare_;
    }
    
}