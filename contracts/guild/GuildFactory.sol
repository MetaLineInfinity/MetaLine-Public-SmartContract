// SPDX-License-Identifier: MIT
// Metaline Contracts (GuildFactory.sol)

pragma solidity ^0.8.0;

import "./Guild.sol";
import "./GuildProxy.sol";

contract GuildFactory {
    using OracleCharger_V1 for OracleCharger_V1.OracleChargerStruct;

    event GuildCreated(string indexed guildName, address indexed guildAddr);
    
    OracleCharger_V1.OracleChargerStruct public _oracleCharger;

    address public owner;
    address public GuildImpl;

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

    function charge(string memory tokenName, uint256 usdValue, address receiveAddr) external {
        require(bytes(guildsByName[msg.sender]).length > 0, 'GuildFactory: FORBIDDEN');

        _oracleCharger.charge(tokenName, usdValue, receiveAddr);
    }

    function createGuild(
       string memory guildName
    ) external returns(address guildAddr) {
        require(msg.sender == owner, 'GuildFactory: FORBIDDEN');
        require(guilds[guildName] == address(0), 'GuildFactory: AlreadyExist');

        // TO DO : Charge

        bytes32 salt = keccak256(abi.encodePacked(guildName));
        guildAddr = address(
            new GuildProxy{salt: salt}(
                GuildImpl
            )
        );

        guilds[guildName] = guildAddr;
        guildsByName[guildAddr] = guildName;

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
    
    // fetch royalty income
    function fetchIncome(address erc20) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "M1");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            TransferHelper.safeTransfer(erc20, _msgSender(), amount);
        }
    }
    function fetchIncomeEth() external {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role");

        // send eth
        (bool sent, ) = _msgSender().call{value:address(this).balance}("");
        require(sent, "ERC1155PresetMinterPauser: transfer error");
    }
}