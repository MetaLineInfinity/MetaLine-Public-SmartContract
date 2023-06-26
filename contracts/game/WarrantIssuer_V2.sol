// SPDX-License-Identifier: MIT
// Metaline Contracts (WarrantIssuer_V2.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../utility/OracleCharger.sol";
import "../utility/SerialBuffer.sol";

import "../nft/WarrantNFT.sol";

struct WarrantExt1Data {
    uint16 version; // data version
    uint32 expiredTime; // expired timestamp in second
    uint32 valueLevel; // total upgrade usd price * 1000;
}

contract WarrantIssuer_V2 is
    Context,
    Pausable,
    AccessControl 
{
    using SerialBuffer for SerialBuffer.Buffer;
    using OracleCharger for OracleCharger.OracleChargerStruct;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct expireTimeConfig {
        uint32 time; // time in second
        uint256 usdPrice; // usd price
    }

    event OnWarrantExt1DataChange(address indexed userAddr, uint256 indexed tokenId, WarrantExt1Data data);

    OracleCharger.OracleChargerStruct public _oracleCharger;

    address public _warrantNFTAddr;

    mapping(uint16=>uint256) public _warrantPrices; // port id => usd price
    mapping(uint16=>mapping(uint8=>mapping(uint16=>uint256))) public _warrantUpgradePrice; // port id => upgrade type => level => usd price

    mapping(uint16=>mapping(uint8=>expireTimeConfig)) public _warrantExipreTimeConfig; // port id => expire time type => expireTimeConfig

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "WarrantIssuer: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "WarrantIssuer: must have pauser role to unpause"
        );
        _unpause();
    }
    
    function setTPOracleAddr(address tpOracleAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _oracleCharger.setTPOracleAddr(tpOracleAddr);
    }

    function setReceiveIncomeAddr(address incomeAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

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
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _oracleCharger.removeChargeToken(tokenName);
    }

    function init(
        address warrantNFTAddr
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _warrantNFTAddr = warrantNFTAddr;
    }

    // usdPrice: 18 decimal
    function setWarrantPrice(uint16 portID, uint256 usdPrice) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _warrantPrices[portID] = usdPrice;
    }
    // usdPrice: 18 decimal
    function setWarrantUpgradePrice(uint16 portID, uint8 upgradeType, uint16 level, uint256 usdPrice) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _warrantUpgradePrice[portID][upgradeType][level] = usdPrice;
    }
    function clearWarrantUpgradePrice(uint16 portID, uint8 upgradeType, uint16 level) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        delete _warrantUpgradePrice[portID][upgradeType][level];
    }
    
    // usdPrice: 18 decimal
    function setWarrantExpireConf(uint16 portID, uint8 expireType, expireTimeConfig memory conf) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "WarrantIssuer: must have manager role");

        _warrantExipreTimeConfig[portID][expireType] = conf;
    }

    function mint_MTTWarrant(uint16 portID, uint256 usdPrice, string memory tokenName) external payable whenNotPaused {
        uint256 _usdPrice = _warrantPrices[portID];
        require(_usdPrice > 0, "WarrantIssuer: port not exist");
        require(_usdPrice <= usdPrice, "WarrantIssuer: price parameter error");

        _oracleCharger.charge(tokenName, _usdPrice);

        _mint_MTTWarrant(portID, _msgSender(), _usdPrice);
    }

    function mint_MTTWarrantByService(uint16 portID, address toAddr) external whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "WarrantIssuer: must have minter role");

        uint256 usdPrice = _warrantPrices[portID];
        require(usdPrice > 0, "WarrantIssuer: port not exist");

        _mint_MTTWarrant(portID, toAddr, usdPrice);
    }

    function _mint_MTTWarrant(uint16 portID, address toAddr, uint256 usdPrice) internal {
        uint256 tokenId = WarrantNFT(_warrantNFTAddr).mint(toAddr, WarrantNFTData({
            portID:portID,
            storehouseLv:1,
            factoryLv:1,
            shopLv:1,
            shipyardLv:0,
            createTm:uint32(block.timestamp)
        }));

        WarrantExt1Data memory ext1Data = WarrantExt1Data({
            version:1,
            expiredTime:uint32(block.timestamp + 2592000), // 30 days
            valueLevel:uint32(usdPrice / 10**15) // = usd price * 1000
        });
        bytes memory ext1DataBytes = _encodeExt1Data(ext1Data);
        WarrantNFT(_warrantNFTAddr).addTokenExtendNftData(tokenId, "ext1", ext1DataBytes);

        emit OnWarrantExt1DataChange(_msgSender(), tokenId, ext1Data);
    }

    function extend_MTTWarrantExipredTime(
        uint256 tokenId, 
        uint256 usdPrice, 
        uint8 timeType,
        string memory tokenName
    ) external payable whenNotPaused {
        // get warrant nft data
        WarrantNFTData memory wdata = WarrantNFT(_warrantNFTAddr).getNftData(tokenId);
        expireTimeConfig memory conf = _warrantExipreTimeConfig[wdata.portID][timeType];
        require(conf.usdPrice > 0, "WarrantIssuer: expire config not exist");

        uint256 mintUsdPrice = _warrantPrices[wdata.portID];
        require(mintUsdPrice > 0, "WarrantIssuer: port not exist");

        bytes memory ext1Bytes = WarrantNFT(_warrantNFTAddr).getTokenExtendNftData(tokenId, "ext1");
        WarrantExt1Data memory ext1Data = _decodeExt1Data(ext1Bytes);
        
        uint256 _usdPrice  = conf.usdPrice * ext1Data.valueLevel / (mintUsdPrice/10**15);
        
        require(_usdPrice > 0 && _usdPrice <= usdPrice, "WarrantIssuer: price error");
        require(block.timestamp > (ext1Data.expiredTime - 3600*72), "WarrantIssuer: don't need extend yet");

        _oracleCharger.charge(tokenName, _usdPrice);

        uint32 timeLeft = 0;
        if(ext1Data.expiredTime > block.timestamp){
            timeLeft = uint32(ext1Data.expiredTime - block.timestamp);
        }

        ext1Data.expiredTime = uint32(block.timestamp + timeLeft + conf.time);
        
        ext1Bytes = _encodeExt1Data(ext1Data);

        WarrantNFT(_warrantNFTAddr).modifyTokenExtendNftData(tokenId, "ext1", ext1Bytes);

        emit OnWarrantExt1DataChange(_msgSender(), tokenId, ext1Data);
    }

    function get_MTTWarrantExt1Data(
        uint256 tokenId
    ) external view returns(WarrantExt1Data memory ext1Data) {
        bytes memory ext1Bytes = WarrantNFT(_warrantNFTAddr).getTokenExtendNftData(tokenId, "ext1");
        ext1Data = _decodeExt1Data(ext1Bytes);
    }

    function upgrade_MTTWarrant(
        uint256 warrantNFTID,
        uint8 upgradeType,
        uint256 usdPrice,
        string memory tokenName
    ) external payable whenNotPaused{
        require(WarrantNFT(_warrantNFTAddr).ownerOf(warrantNFTID) == _msgSender(), "WarrantIssuer: ownership error");

        // get warrant nft data
        WarrantNFTData memory wdata = WarrantNFT(_warrantNFTAddr).getNftData(warrantNFTID);
        uint256 _usdPrice = 0;

        mapping(uint8=>mapping(uint16=>uint256)) storage upPrices = _warrantUpgradePrice[wdata.portID];

        if(upgradeType == 1) { // upgrade storehouse
            _usdPrice = upPrices[upgradeType][wdata.storehouseLv];
            ++wdata.storehouseLv;
        }
        else if(upgradeType == 2) { // upgrade factory
            _usdPrice = upPrices[upgradeType][wdata.factoryLv];
            ++wdata.factoryLv;
        }
        else if(upgradeType == 3) { // upgrade shop
            _usdPrice = upPrices[upgradeType][wdata.shopLv];
            ++wdata.shopLv;
        }
        else if(upgradeType == 4) { // upgrade shipyard
            _usdPrice = upPrices[upgradeType][wdata.shipyardLv];
            ++wdata.shipyardLv;
        }
        
        require(_usdPrice > 0 && _usdPrice <= usdPrice, "WarrantIssuer: price error");

        _oracleCharger.charge(tokenName, _usdPrice);

        WarrantNFT(_warrantNFTAddr).modNftData(warrantNFTID, wdata);

        bytes memory ext1Bytes = WarrantNFT(_warrantNFTAddr).getTokenExtendNftData(warrantNFTID, "ext1");
        WarrantExt1Data memory ext1Data = _decodeExt1Data(ext1Bytes);
        ext1Data.valueLevel += uint32(_usdPrice / 10**15); // = usd price * 1000;

        ext1Bytes = _encodeExt1Data(ext1Data);

        WarrantNFT(_warrantNFTAddr).modifyTokenExtendNftData(warrantNFTID, "ext1", ext1Bytes);

        emit OnWarrantExt1DataChange(_msgSender(), warrantNFTID, ext1Data);
    }

    function _encodeExt1Data(WarrantExt1Data memory data) internal pure returns(bytes memory bydata) {
        
        uint32 size = 2 + 4 + 4 + 32; // uint16 + uint32 + uint32 + uint256
        bydata = new bytes(size);

        SerialBuffer.Buffer memory coder = SerialBuffer.Buffer({
            index: size,
            buffer: bydata
        });

        coder.writeUint16(data.version);
        coder.writeUint32(data.expiredTime);
        coder.writeUint32(data.valueLevel);
        coder.writeUint256(0);
    } 

    function _decodeExt1Data(bytes memory bydata) internal pure returns(WarrantExt1Data memory data) {
        
        SerialBuffer.Buffer memory coder = SerialBuffer.Buffer({
            index: bydata.length,
            buffer: bydata
        });

        data.version = coder.readUint16();
        data.expiredTime = coder.readUint32();
        data.valueLevel = coder.readUint32();
        //data.__end = coder.readUint256();
    }
}