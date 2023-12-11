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

import "./GuildERC721.sol";
import "./GuildFactory.sol";
import "./GuildConfig.sol";

contract Guild is 
    IERC2981Royalties,
    GuildERC721
{
    using Counters for Counters.Counter;

    struct MemberNFTData {
        uint256 invitorTokenId;
        bytes writeabelData;
    }

    event GuildMemberNFTMint(address indexed toAddr, uint256 indexed tokenId, MemberNFTData data);
    event GuildMemberNFTDataModified(uint256 indexed tokenId, bytes newData);
    event GuildDataModified(string dataName, bytes newData);
    event GuildPayByUSDValue(address indexed userAddr, uint256 usdPrice, string tokenName, uint256 tokenValue);
    
    Counters.Counter internal _tokenIdTracker;

    string public guildName;
    address public guildFactory;
    uint256 public ownerTokenID;
    address public guildConfigAddr;

    // erc2981 royalty fee, /10000
    uint256 public _royalties;
    string internal _baseTokenURI;

    uint32 public membersCount; // guild total members count
    mapping(uint256 => uint32) private _inviteCount; // token id => invite member count
    
    mapping(uint256 => MemberNFTData) private _memberNFTData; // token id => nft data stucture
    mapping(string => bytes) private _guildDatas; // data name => data

    // proxy implementation do not use constructor, use initialize instead
    constructor() payable {}

    function _bytesToUint(bytes memory b) internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }
    
    function isOwner(address addr) public view returns(bool) {
        return ownerOf(ownerTokenID) == addr;
    }

    function setGuildConfig(address confAddr) external {
        require(msg.sender == guildFactory, 'GuildFactory: FORBIDDEN');
        guildConfigAddr = confAddr;
    }
    
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

        ownerTokenID = _internalMint(creatorAddr, 0);
    }
    
    function _internalMint(address to, uint256 invitorTokenID) internal returns(uint256) {
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        MemberNFTData memory data = MemberNFTData({
            invitorTokenId:invitorTokenID,
            writeabelData:new bytes(0)
        });

        // Save token datas
        _memberNFTData[curID] = data;

        emit GuildMemberNFTMint(to, curID, data);

        // increase token id
        _tokenIdTracker.increment();

        membersCount++;
        if (curID != invitorTokenID) {
            _inviteCount[invitorTokenID]++;
        }

        return curID;
    }

    function mint(address to, uint256 invitorTokenID) public returns(uint256) {
        require(_exists(invitorTokenID), "Guild: Invitor not exist");
        require(balanceOf(to) == 0, "Guild: already minted");

        GuildLvConfig memory lvConf = GuildConfig(guildConfigAddr).getLvConfig(uint8(_bytesToUint(_guildDatas["level"])));
        require(membersCount < lvConf.maxMembers, "Guild: too many members");

        return _internalMint(to, invitorTokenID);
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
        if (tokenId == ownerTokenID) { // owner
            require(membersCount == 1, "Guild: has members");
        }
        else { // member
            require(_inviteCount[tokenId] == 0, "Guild: has invite members");
        }

        _burn(tokenId);

        membersCount--;
        uint256 invitorTokenID = _memberNFTData[tokenId].invitorTokenId;
        if (tokenId != invitorTokenID) {
            _inviteCount[invitorTokenID]--;
        }
    }
    
    function modMemberNFTData(uint256 tokenId, bytes memory writeabelData) external {
        require(msg.sender == guildFactory, "Guild: FORBIDDEN");

        _memberNFTData[tokenId].writeabelData = writeabelData;

        emit GuildMemberNFTDataModified(tokenId, writeabelData);
    }

    function getNftData(uint256 tokenId) external view returns(MemberNFTData memory data){
        require(_exists(tokenId), "Guild: token not exist");

        data = _memberNFTData[tokenId];
    }

    function TransferGuild(address to) external {
        //require(_isApprovedOrOwner(msg.sender, ownerTokenID), "GuildERC: transfer caller is not owner nor approved");
        _transferInternal(msg.sender, to, ownerTokenID);
    }

    function ModifyGuildData(string memory extendName, bytes memory extendData) external {
        require(msg.sender == guildFactory, "Guild: FORBIDDEN");

        _guildDatas[extendName] = extendData;

        emit GuildDataModified(extendName, extendData);
    }

    function GetGuildData(string memory extendName) external view returns (bytes memory extendData) {
        return _guildDatas[extendName];
    }

    function PayByUSDValue(uint256 usdPrice, string memory tokenName) external payable {

        uint256 tokenValue = GuildFactory(guildFactory).charge(tokenName, usdPrice, msg.sender);
        // TO DO : send share to owner|invitor ?

        uint16 invitorShare = GuildConfig(guildConfigAddr).GuildInvitorShare();
        if(invitorShare > 0){
            uint256 invitorValue = tokenValue * invitorShare / 10000;
            if(invitorValue > 0) {
                // TO DO
            }
        }
        uint16 ownerShare = GuildConfig(guildConfigAddr).GuildOwnerShare();
        if(ownerShare > 0){
            uint256 ownerValue = tokenValue * ownerShare / 10000;
            if(ownerValue > 0){
                // TO DO
            }
        }

        emit GuildPayByUSDValue(msg.sender, usdPrice, tokenName, tokenValue);
    }

    function GetGuildAccount(uint256 guildID) external returns(address) {
        // ERC-6551
        // use owner token to create guild account
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal view override {
        if (from == address(0) || to == address(0)) return; // mint or burn
        require(tokenId != ownerTokenID, "Guild: use 'TransferGuild' to transfer owner token");
        require(balanceOf(to) == 0, "Guild: transfer to address balance > 0");
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

    function transferToken(address erc20, uint256 value, address receiver) external {
        require(msg.sender == guildFactory, "Guild: FORBIDDEN");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            require(value <= amount, "Guild: insufficient token");
            TransferHelper.safeTransfer(erc20, receiver, value);
        }
    }
    function transferEth(uint256 value, address receiver) external {
        require(msg.sender == guildFactory, "Guild: FORBIDDEN");
        require(value <= address(this).balance, "Guild: insufficient value");

        // send eth
        (bool sent, ) = receiver.call{value:value}("");
        require(sent, "Guild: transfer error");
    }
}