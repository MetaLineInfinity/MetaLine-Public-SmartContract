// SPDX-License-Identifier: MIT
// Metaline Contracts (DirectMysteryBox.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../MTT.sol";
import "../MTTGold.sol";
import "../nft/HeroNFT.sol";

import "../utility/TransferHelper.sol";

contract GameService is
    Context,
    Pausable,
    AccessControl 
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event BindHeroNFTUsage(address indexed userAddr, uint256 indexed heroNFTID, string usage);
    event UnbindHeroNFTUsage(address indexed userAddr, uint256 indexed heroNFTID, string usage);
    
    address public _heroNFTAddr;
    address public _MTTAddr;
    address public _MTTGoldAddr;

    mapping(uint256=>string) public _heroNFTUsage; // nftid=>usage

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(SERVICE_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "GameService: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "GameService: must have pauser role to unpause"
        );
        _unpause();
    }
    
    function init(
        address heroNFTAddr,
        address MTTAddr,
        address MTTGoldAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "GameService: must have manager role");

        _heroNFTAddr = heroNFTAddr;
        _MTTAddr = MTTAddr;
        _MTTGoldAddr = MTTGoldAddr;
    }

    function bindHeroNFTUsage(uint256 heroNFTID, string calldata usage) external {
        require(hasRole(SERVICE_ROLE, _msgSender()), "GameService: must have service role");
        require(HeroNFT(_heroNFTAddr).ownerOf(heroNFTID) == _msgSender(), "GameService: ownership error");

        HeroNFT(_heroNFTAddr).freeze(heroNFTID);

        _heroNFTUsage[heroNFTID] = usage;

        emit BindHeroNFTUsage(_msgSender(), heroNFTID, usage);
    }

    function unbindHeroNFTUsage(uint256 heroNFTID, string calldata usage) external {
        require(hasRole(SERVICE_ROLE, _msgSender()), "GameService: must have service role");
        require(HeroNFT(_heroNFTAddr).ownerOf(heroNFTID) == _msgSender(), "GameService: ownership error");

        HeroNFT(_heroNFTAddr).unfreeze(heroNFTID);

        delete _heroNFTUsage[heroNFTID];

        emit UnbindHeroNFTUsage(_msgSender(), heroNFTID, usage);
    }

    function mint_MTTGold(address userAddr, uint256 goldValue) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "GameService: must have minter role");

        // TO DO : check mint risk
        // TO DO : charge mtt fee
        // TO DO : mint on chain mttgold

        MTTGold(_MTTGoldAddr).mint(userAddr, goldValue);
    }

    function off2onChain_MTTGold(address userAddr, uint256 goldValue) external {
        require(hasRole(SERVICE_ROLE, _msgSender()), "GameService: must have service role");
        require(MTTGold(_MTTGoldAddr).balanceOf(address(this)) >= goldValue, "GameService: insufficient MTTGold");

        // TO DO : check risk

        TransferHelper.safeTransferFrom(_MTTGoldAddr, address(this), userAddr, goldValue);
        
        // TO DO : emit event
    }

    function on2offChain_MTTGold(uint256 goldValue) external {
        require(MTTGold(_MTTGoldAddr).balanceOf(address(_msgSender())) >= goldValue, "GameService: insufficient MTTGold");

        // TO DO : check risk

        TransferHelper.safeTransferFrom(_MTTGoldAddr, _msgSender(), address(this), goldValue);

        // TO DO : emit event
    }
}