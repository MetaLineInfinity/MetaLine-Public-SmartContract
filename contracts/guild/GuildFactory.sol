// SPDX-License-Identifier: MIT
// Metaline Contracts (GuildFactory.sol)

pragma solidity ^0.8.0;

import "../utility/OracleCharger_V2.sol";

import "./Guild.sol";
import "./GuildProxy.sol";
import "./GuildConfig.sol";

contract GuildFactory {
    using OracleCharger_V2 for OracleCharger_V2.OracleChargerStruct;

    event GuildCreated(string indexed guildName, address indexed guildAddr);
    
    OracleCharger_V2.OracleChargerStruct public _oracleCharger;

    address public owner;
    address public GuildImpl;
    address public GuildConfigAddr;

    mapping(string=>address) public guilds;
    mapping(address=>string) public guildsByName;
    
    constructor(
        address gi
    ) payable {
        owner = msg.sender;
        GuildImpl = gi;
    }
    
    function changeOwner(address newOwner) external {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');
        owner = newOwner;
    }

    function setGuildConfig(address confAddr) external {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');

        GuildConfigAddr = confAddr;
    }
    
    function setTPOracleAddr(address tpOracleAddr) external {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');

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
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');

        _oracleCharger.removeChargeToken(tokenName);
    }

    function charge(string memory tokenName, uint256 usdValue, address from, address receiveAddr) external returns(uint256 tokenValue) {
        require(bytes(guildsByName[msg.sender]).length > 0, 'GuildFactory: FORBIDDEN');

        return _oracleCharger.charge(tokenName, usdValue, from, receiveAddr);
    }

    function createGuild(
       string memory guildName,
       string memory tokenName,
       uint256 usdValue
    ) external returns(address guildAddr) {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');
        require(guilds[guildName] == address(0), 'GuildFactory: AlreadyExist');

        uint256 _usdPrice = GuildConfig(GuildConfigAddr).CreateGuildUSDPrice();
        require(usdValue >= _usdPrice, "GuildFactory: price error");

        _oracleCharger.charge(tokenName, _usdPrice, msg.sender, address(this));

        bytes32 salt = keccak256(abi.encodePacked(guildName));
        guildAddr = address(
            new GuildProxy{salt: salt}(
                GuildImpl
            )
        );

        guilds[guildName] = guildAddr;
        guildsByName[guildAddr] = guildName;

        // init guild
        Guild guildCont = Guild(guildAddr);
        guildCont.setGuildConfig(GuildConfigAddr);

        emit GuildCreated(guildName, guildAddr);
    }

    function callGuild(string memory guildName, bytes memory callData)
        external
        returns (bytes memory retrundata)
    {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');

        address guildAddr = guilds[guildName];

        bool success;
        (success, retrundata) = guildAddr.call(callData);

        require(success, "GuildFactory: CallError");
    }
    
    function fetchIncome(address erc20) external {
        require(msg.sender == owner, "GuildFactory: FORBIDDEN");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            TransferHelper.safeTransfer(erc20, msg.sender, amount);
        }
    }
    function fetchIncomeEth() external {
        require(msg.sender == owner, "GuildFactory: FORBIDDEN");

        // send eth
        (bool sent, ) = msg.sender.call{value:address(this).balance}("");
        require(sent, "GuildFactory: transfer error");
    }
}