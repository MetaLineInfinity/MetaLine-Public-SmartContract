// SPDX-License-Identifier: MIT
// Metaline Contracts (Expedition.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../nft/HeroNFT.sol";
import "../nft/ShipNFT.sol";
import "../nft/WarrantNFT.sol";

contract AssetMinter is
    Context,
    Pausable,
    AccessControl
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    event MintPackage(uint32 packageId, address indexed userAddr, uint32 totalCount, uint32 mintedCount);

    struct PackageInfo {
        uint32 totalCount;
        uint32 mintedCount;
        uint16[] portIDs;
        HeroNFTDataBase[] heros;
        ShipNFTData[] ships;
    }
    
    address public _warrantNFTAddr;
    address public _heroNFTAddr;
    address public _shipNFTAddr;

    mapping(uint32=>PackageInfo) _packages;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "AssetMinter: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "AssetMinter: must have pauser role to unpause"
        );
        _unpause();
    }

    function init(
        address heroNFTAddr,
        address shipNFTAddr,
        address warrantNFTAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "AssetMinter: must have manager role");

        _heroNFTAddr = heroNFTAddr;
        _shipNFTAddr = shipNFTAddr;
        _warrantNFTAddr = warrantNFTAddr;
    }

    function getPackage(uint32 packageId) external view returns (
        HeroNFTDataBase[] memory heros, 
        ShipNFTData[] memory ships,
        uint16[] memory portIDs,
        uint32 totalCount,
        uint32 mintedCount
    ) {
        PackageInfo memory pi = _packages[packageId];
        heros = pi.heros;
        ships = pi.ships;
        portIDs = pi.portIDs;
        totalCount = pi.totalCount;
        mintedCount = pi.mintedCount;
    }

    function setPackage(
        uint32 packageId, 
        uint32 totalCount, 
        HeroNFTDataBase[] calldata heros, 
        ShipNFTData[] calldata ships, 
        uint16[] memory portIDs
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "AssetMinter: must have manager role");
        require(heros.length > 0 || ships.length > 0, "AssetMinter: input parameter error");
        require(heros.length < 10 && ships.length < 5, "AssetMinter: input parameter error");

        PackageInfo storage pi = _packages[packageId];
        for(uint i=0; i<heros.length; ++i){
            pi.heros.push(heros[i]);
        }
        for(uint i=0; i<ships.length; ++i){
            pi.ships.push(ships[i]);
        }
        for(uint i=0; i<portIDs.length; ++i){
            pi.portIDs.push(portIDs[i]);
        }
        pi.totalCount = totalCount;
    }

    function setPackageTotalCount(uint32 packageId, uint32 totalCount) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "AssetMinter: must have manager role");
        PackageInfo storage pi = _packages[packageId];
        require(pi.totalCount > 0, "AssetMinter: package not exist");

        pi.totalCount = totalCount;
    }

    function removePackage(uint32 packageId) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "AssetMinter: must have manager role");

        delete _packages[packageId];
    }

    function mintPackage(uint32 packageId, address userAddr) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "AssetMinter: must have minter role");

        PackageInfo memory pi = _packages[packageId];

        require(pi.totalCount > 0, "AssetMinter: package not exist");
        require(pi.totalCount >= pi.mintedCount + 1, "AssetMinter: insufficient package");

        for(uint i=0; i< pi.heros.length; ++i){
            HeroNFT(_heroNFTAddr).mint(userAddr, pi.heros[i]);
        }
        for(uint i=0; i< pi.ships.length; ++i){
            ShipNFT(_shipNFTAddr).mint(userAddr, pi.ships[i]);
        }
        for(uint i=0; i< pi.portIDs.length; ++i){
            WarrantNFT(_warrantNFTAddr).mint(userAddr, WarrantNFTData({
                portID:pi.portIDs[i],
                storehouseLv:1,
                factoryLv:1,
                shopLv:1,
                shipyardLv:0,
                createTm:uint32(block.timestamp)
            }));
        }

        ++pi.mintedCount;

        emit MintPackage(packageId, userAddr, pi.totalCount, pi.mintedCount);
    }
}