// SPDX-License-Identifier: MIT
// Metaline Contracts (Shipyard.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../utility/OracleCharger.sol";

import "../nft/WarrantNFT.sol";
import "../nft/ShipNFT.sol";

contract Shipyard is
    Context,
    Pausable,
    AccessControl 
{
    using OracleCharger for OracleCharger.OracleChargerStruct;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    OracleCharger.OracleChargerStruct public _oracleCharger;

    address public _warrantNFTAddr;
    address public _shipNFTAddr;

    mapping(uint16=>mapping(uint16=>uint24[])) _buildabelShips; // port id => shipyard level => array of mintable ships (shipType<<16 | shipTypeID)
    mapping(uint24=>mapping(uint16=>uint256)) _upgradeUsdPrices; // (shipType<<16 | shipTypeID) => ship level => upgrade cost usd

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
            "Shipyard: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Shipyard: must have pauser role to unpause"
        );
        _unpause();
    }
    
    function setTPOracleAddr(address tpOracleAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _oracleCharger.setTPOracleAddr(tpOracleAddr);
    }

    function setReceiveIncomeAddr(address incomeAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _oracleCharger.setReceiveIncomeAddr(incomeAddr);
    }

    // maximumUSDPrice = 0: no limit
    // minimumUSDPrice = 0: no limit
    function addChargeToken(
        string memory tokenName, 
        address tokenAddr, 
        uint256 maximumUSDPrice, 
        uint256 minimumUSDPrice
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _oracleCharger.removeChargeToken(tokenName);
    }

    function init(
        address warrantNFTAddr,
        address shipNFTAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _warrantNFTAddr = warrantNFTAddr;
        _shipNFTAddr = shipNFTAddr;
    }

    function setBuildableShips(uint16 portID, uint8 shipyardLv, uint24[] memory buildableShipArray) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _buildabelShips[portID][shipyardLv] = buildableShipArray;
    }
    function clearBuildableShips(uint16 portID, uint8 shipyardLv) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        delete _buildabelShips[portID][shipyardLv];
    }
    // usdPrice: 18 decimal
    function setUpgradePrice(uint8 shipType, uint16 shipTypeID, uint16 shipLevel, uint256 usdPrice) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        _upgradeUsdPrices[(uint24(shipType)<<16 | shipTypeID)][shipLevel] = usdPrice;
    }
    function clearUpgradePrice(uint8 shipType, uint16 shipTypeID, uint16 shipLevel) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Shipyard: must have manager role");

        delete _upgradeUsdPrices[(uint24(shipType)<<16 | shipTypeID)][shipLevel];
    }

    function mint_Ship(
        address userAddr, 
        uint8 shipType, 
        uint16 shipTypeID,
        uint8 grade,
        uint32 minerAttr,
        uint32 battleAttr,
        uint256 warrantNFTID
    ) external whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "Shipyard: must have minter role");
        require(WarrantNFT(_warrantNFTAddr).ownerOf(warrantNFTID) == userAddr, "Shipyard: warrant ownership error");

        // get warrant nft data
        WarrantNFTData memory wdata = WarrantNFT(_warrantNFTAddr).getNftData(warrantNFTID);

        uint24 shipID = (uint24(shipType)<<16 | shipTypeID);
        uint24[] storage shipArray = _buildabelShips[wdata.portID][wdata.shipyardLv];
        uint i=0;
        for(; i< shipArray.length; ++i){
            if(shipID == shipArray[i]){
                break;
            }
        }

        require(i < shipArray.length, "Shipyard: ship not buildable");

        ShipNFT(_shipNFTAddr).mint(userAddr, ShipNFTData({
            shipType:shipType,
            shipTypeID:shipTypeID,
            grade:grade,
            minerAttr:minerAttr,
            battleAttr:battleAttr,
            level:0
        }));
    }

    function startUpgrade_Ship(
        uint256 shipNFTID,
        uint256 usdPrice,
        string memory tokenName
    ) external whenNotPaused {

    }

    function finishUpgrade_Ship(

    ) external whenNotPaused {
        
    }
}