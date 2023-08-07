// SPDX-License-Identifier: MIT
// Metaline Contracts (Guild.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../interface/ERC/IERC2981Royalties.sol";

import "../core/ExtendableNFT.sol";

import "../utility/ProxyImplInitializer.sol";
import "../utility/TransferHelper.sol";
import "../utility/OracleCharger_V1.sol";

import "./GuildERC721.sol";

contract Guild is 
    IERC2981Royalties,
    GuildERC721
{
    string public guildName;
    address public guildFactory;

    // erc2981 royalty fee, /10000
    uint256 public _royalties;
    string internal _baseTokenURI;

    // proxy implementation do not use constructor, use initialize instead
    constructor() {}
    
    function initialize() external initOnce {
        guildFactory = msg.sender;

        _royalties = 500; // 5%
    }
    
    function initGuild(
        string memory guildName_,
        address creatorAddr
    ) external initOnceStep(2) {
        guildName = guildName_;

        __chain_initialize_GuildERC721(string(abi.encodePacked("MetaLine Guild ", guildName)), "MTGT");

        creatorAddr;
        //mint();
    }
    
    // set royalties
    function setRoyalties(uint256 royalties) external {
        require(msg.sender == guildFactory, "M1");
        _royalties = royalties;
    }

    /// @inheritdoc	IERC2981Royalties
    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = guildFactory;
        royaltyAmount = (value * _royalties) / 10000;
    }
    
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(abi.encodePacked(_baseTokenURI, guildName, "/"));
    }

    function updateURI(string calldata baseTokenURI) public virtual {
        require((msg.sender == guildFactory), "M1");
        _baseTokenURI = baseTokenURI;
    }
    
    // build user sbt
    // create guild from sbt

    // guild extend from nft with extendable data

    function CreateGuild(bool allowForceQuit) external returns(uint256 guildID) {

    }

    function TransferGuild(uint256 guildID, address toUserAddr) external {

    }

    function JoinGuild(uint256 guildID) external {

    }

    function ReqQuitGuild() external {

    }

    function KickGuildMember() external {

    }

    function ExtendGuildData(string memory extendName) external {

    }

    function ModifyGuildData(uint256 guildID, string memory extendName, bytes memory extendData) external {

    }

    function GetGuildData(uint256 guildID, string memory extendName) external returns (bytes memory extendData) {
    }

    function GetGuildAccount(uint256 guildID) external returns(address) {
        // ERC-6551
    }
}