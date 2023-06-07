// SPDX-License-Identifier: MIT
// Metaline Contracts (PlatOnOffChainBridge.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../utility/TransferHelper.sol";
import "../mysterybox/MysteryBox1155.sol";

import "./UniversalNFT.sol";

contract PlatOnOffChainBridge is
    Context,
    Pausable,
    AccessControl 
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Off2OnChain_UniNFT(string indexed appid, address indexed userAddr, uint256 tokenId);
    event On2OffChain_UniNFT(string indexed appid, address indexed userAddr, uint256 tokenId);

    address public _uniNFTAddr;
    address public _mb1155;
    mapping(string=>uint32) public _appUniNFTMintCount;
    mapping(string=>uint32) public _mysteryShardMintCount;
    
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(SERVICE_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PlatOnOffChainBridge: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PlatOnOffChainBridge: must have pauser role to unpause"
        );
        _unpause();
    }
    
    function init(
        address uniNFTAddr,
        address mb1155Addr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "PlatOnOffChainBridge: must have manager role");

        _uniNFTAddr = uniNFTAddr;
        _mb1155 = mb1155Addr;
    }

    function setAppUniNFTMintCount(string memory appid, uint32 count) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "PlatOnOffChainBridge: must have manager role");

        _appUniNFTMintCount[appid] = count;
    }

    function setMysteryShardMintCount(string memory appid, uint32 count) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "PlatOnOffChainBridge: must have manager role");

        _mysteryShardMintCount[appid] = count;
    }

    function mintUniNFT(address userAddr, UniversalNFTData memory data) external whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "PlatOnOffChainBridge: must have minter role");
        require(_appUniNFTMintCount[data.appid] > 0, "PlatOnOffChainBridge: app insufficient nft");

        // limit per app uninft mint count
        --_appUniNFTMintCount[data.appid];

        UniversalNFT(_uniNFTAddr).mint(userAddr, data);
    }

    function mintMysteryShard(string memory appid, address userAddr, uint64 shardCombinedID, uint32 count) external whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "PlatOnOffChainBridge: must have minter role");
        require(_mysteryShardMintCount[appid] >= count, "PlatOnOffChainBridge: app insufficient nft");

        // limit per app mystery shard mint count
        _mysteryShardMintCount[appid] -= count;

        MysteryBox1155(_mb1155).mint(userAddr, (uint256(1<<64) | uint256(shardCombinedID)), count, "onoffchain mint");
    }

    function off2onChain_UniNFT(string memory appid, address userAddr, uint256 tokenId) external whenNotPaused {
        require(hasRole(SERVICE_ROLE, _msgSender()), "PlatOnOffChainBridge: must have service role");
        require(IERC721(_uniNFTAddr).ownerOf(tokenId) == address(this), "PlatOnOffChainBridge: ownership error");

        IERC721(_uniNFTAddr).transferFrom(address(this), userAddr, tokenId);
        
        emit Off2OnChain_UniNFT(appid, userAddr, tokenId);
    }

    function on2offChain_UniNFT(string memory appid, uint256 tokenId) external whenNotPaused {
        require(IERC721(_uniNFTAddr).ownerOf(tokenId) == address(_msgSender()), "PlatOnOffChainBridge: ownership error");

        IERC721(_uniNFTAddr).transferFrom(_msgSender(), address(this), tokenId);

        emit On2OffChain_UniNFT(appid, _msgSender(), tokenId);
    }
}