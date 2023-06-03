// SPDX-License-Identifier: MIT
// Metaline Contracts (MysteryShardBase.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "../utility/GasFeeCharger.sol";

import "./MysteryBox1155.sol";
import "./MSRandomSourceBase.sol";

// 1155 id(256) : combine with type(uint8) << 64 |
//                              |-- type=0 (Mystery box) : randomType(uint32) << 32 | mysteryType(uint32)
//                              |-- type=1 (Mystery Shard) : shardID(uint16) << 48 | grade(uint8) << 40 | shardType(uint8) << 32 | randomType(uint16) << 16 | mysteryType(uint16)


abstract contract MysteryShardBase is 
    Context, 
    Pausable, 
    AccessControl,
    IOracleRandComsumer
{
    using GasFeeCharger for GasFeeCharger.MethodExtraFees;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");
    
    event OracleOpenMysteryShard(uint256 oracleRequestId, uint256 indexed mbTokenId, address indexed owner);
    event OpenMysteryShard(address indexed owner, uint256 indexed mbTokenId, MBContentMinter1155Info[] sfts, MBContentMinterNftInfo[] nfts);

    event BatchOracleOpenMysteryShard(uint256 oracleRequestId, uint256 indexed mbTokenId, address indexed owner, uint8 batchCount);
    event BatchOpenMysteryShard(address indexed owner, uint256 indexed mbTokenId, MBContentMinter1155Info[] sfts, MBContentMinterNftInfo[] nfts);

    struct UserData {
        address owner;
        uint8 count;
        uint256 tokenId;
        ShardAttr attr;
    }
    
    MysteryBox1155 public _mb1155;
    address public _fuelTokenAddr;
    
    mapping(uint32=>address) _randomSources; // random type => random source
    mapping(uint256 => UserData) public _oracleUserData; // indexed by oracle request id

    mapping(uint8=>uint64) public _shardOpenCount; // grade => open shard cost << 32 | open fuel token cost

    // Method extra fee
    // For smart contract method which need extra transaction by other service, we define extra fee
    // extra fee charge by method call tx with `value` paramter, and send to target service wallet address
    GasFeeCharger.MethodExtraFees _methodExtraFees;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() external virtual returns(string memory);

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "MysteryShard: must have pauser role to pause");
        _pause();
    }
    
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "MysteryShard: must have pauser role to unpause");
        _unpause();
    }

    function setNftAddress(address nftAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");
        _mb1155 = MysteryBox1155(nftAddr);
    }
    
    function setFuelToken(address fuelTokenAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");

        _fuelTokenAddr = fuelTokenAddr;
    }
    
    function setShardOpenCount(uint8 grade, uint32 shardCount, uint32 fuelCost) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");

        _shardOpenCount[grade] = (uint64(shardCount) << 32) | uint64(fuelCost);
    }

    function setRandomSource(uint32 randomType, address randomSrc) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "MysteryShard: must have manager role to manage");
        _randomSources[randomType] = randomSrc;
    }

    function getRandomSource(uint32 randomType) external view returns(address){
        return _randomSources[randomType];
    }

    /**
    * @dev set smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need extra fee
    * @param value extra fee value
    * @param target target address where extra fee goes to
    */
    function setMethodExtraFee(uint8 methodKey, uint256 value, address target) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "MysteryShard: must have manager role"
        );

        _methodExtraFees.setMethodExtraFee(methodKey, value, target);
    }

    /**
    * @dev cancel smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need cancel extra fee
    */
    function removeMethodExtraFee(uint8 methodKey) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "MysteryShard: must have manager role"
        );

        _methodExtraFees.removeMethodExtraFee(methodKey);
    }

    /**
    * @dev open mystery box, emit {OracleOpenMysteryShard}
    * call `oracleRand` in {Random} of address from `getRandSource` in {MBRandomSource}
    * send a oracle random request and emit {OracleRandRequest}
    *
    * Extrafees:
    * - `oracleOpenMysteryShard` call need charge extra fee for `fulfillRandom` in {Random} call by oracle service
    * - methodKey = 1, extra gas fee = 0.0013 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - caller must owner of `tokenId` in {MysteryBox1155}
    * - contract not paused
    *
    * @param tokenId token id of {MysteryBox1155}, if succeed, token will be burned
    */
    function oracleOpenMysteryShard(uint256 tokenId) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "MysteryShard: only for outside account");

        // check mb 1155 type
        uint8 tokenType;
        ShardAttr memory attr;
        (tokenType, attr) = _decodeTokenId(tokenId);

        require(tokenType == 1, "MysteryShard: token must be shard");

        address randSrcAddr = _randomSources[attr.randomType];
        require(randSrcAddr != address(0), "MysteryShard: not a mystry box");
        
        address rndAddr = MSRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "MysteryShard: rand address wrong");
        
        uint64 costv = _shardOpenCount[attr.grade];
        require(costv > 0, "MysteryShard: shard grade not exist");

        uint32 shardCost = uint32(costv >> 32 & 0xffffffff);
        uint32 fuelCost = uint32(costv & 0xffffffff);

        if(shardCost == 0){
            shardCost = 1; // at least cost 1
        }
        require(_mb1155.balanceOf(_msgSender(), tokenId) >= shardCost, "MysteryShard: insufficient mb");

        if(fuelCost > 0){
            require(ERC20Burnable(_fuelTokenAddr).balanceOf(_msgSender()) >= fuelCost, "MysteryShard: insufficient fuel");
            ERC20Burnable(_fuelTokenAddr).burnFrom(_msgSender(), fuelCost);
        }

        _methodExtraFees.chargeMethodExtraFee(1); // charge oracleOpenMysteryShard extra fee

        _mb1155.burn(_msgSender(), tokenId, shardCost);

        uint256 reqid = IRandom(rndAddr).oracleRand();

        UserData storage userData = _oracleUserData[reqid];
        userData.owner = _msgSender();
        userData.tokenId = tokenId;
        userData.count = 1;
        userData.attr = attr;
        
        emit OracleOpenMysteryShard(reqid, tokenId, _msgSender());
    }

    /**
    * @dev batch open mystery box, emit {BatchOracleOpenMysteryShard}
    * call `oracleRand` in {Random} of address from `getRandSource` in {MBRandomSource}
    * send a oracle random request and emit {OracleRandRequest}
    *
    * Extrafees:
    * - `batchOracleOpenMysteryShard` call need charge extra fee for `fulfillRandom` in {Random} call by oracle service
    * - methodKey = 2, extra gas fee = 0.0065 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - caller must owner of `tokenId` in {MysteryBox1155}
    * - contract not paused
    *
    * @param tokenId token id of {MysteryBox1155}, if succeed, token will be burned
    */
    function batchOracleOpenMysteryShard(uint256 tokenId, uint8 batchCount) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "MysteryShard: only for outside account");
        require(batchCount <= 10, "MysteryShard: batch count overflow");

        // check mb 1155 type
        uint8 tokenType;
        ShardAttr memory attr;
        (tokenType, attr) = _decodeTokenId(tokenId);

        require(tokenType == 1, "MysteryShard: token must be shard");

        address randSrcAddr = _randomSources[attr.randomType];
        require(randSrcAddr != address(0), "MysteryShard: not a mystry box");
        
        address rndAddr = MSRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "MysteryShard: rand address wrong");
        
        uint64 costv = _shardOpenCount[attr.grade];
        require(costv > 0, "MysteryShard: shard grade not exist");

        uint32 shardCost = uint32(costv >> 32 & 0xffffffff);
        uint32 fuelCost = uint32(costv & 0xffffffff);

        if(shardCost == 0){
            shardCost = 1; // at least cost 1
        }
        require(_mb1155.balanceOf(_msgSender(), tokenId) >= batchCount*shardCost, "MysteryShard: insufficient mb");

        if(fuelCost > 0){
            require(ERC20Burnable(_fuelTokenAddr).balanceOf(_msgSender()) >= batchCount*fuelCost, "MysteryShard: insufficient fuel");
            ERC20Burnable(_fuelTokenAddr).burnFrom(_msgSender(), batchCount*fuelCost);
        }

        _methodExtraFees.chargeMethodExtraFee(2); // charge batchOracleOpenMysteryShard extra fee

        _mb1155.burn(_msgSender(), tokenId, batchCount*shardCost);
        
        uint256 reqid = IRandom(rndAddr).oracleRand();

        UserData storage userData = _oracleUserData[reqid];
        userData.owner = _msgSender();
        userData.tokenId = tokenId;
        userData.count = batchCount;
        userData.attr = attr;
        
        emit BatchOracleOpenMysteryShard(reqid, tokenId, _msgSender(), batchCount);
    }

    // call back from random contract which triger by service call {fulfillOracleRand} function
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "MysteryShard: must have rand role");

        UserData storage userData = _oracleUserData[reqid];

        require(userData.owner != address(0), "MysteryShard: nftdata owner not exist");

        address randSrcAddr = _randomSources[userData.attr.randomType];
        require(randSrcAddr != address(0), "MysteryShard: not a mystry box");

        if(userData.count > 1) {

            (MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts) 
                = MSRandomSourceBase(randSrcAddr).sbatchRandomAndMint(randnum, userData.attr, userData.owner, userData.count);

            emit BatchOpenMysteryShard(userData.owner, userData.tokenId, sfts, nfts);
        }
        else {
            (MBContentMinter1155Info[] memory sfts, MBContentMinterNftInfo[] memory nfts) 
                = MSRandomSourceBase(randSrcAddr).srandomAndMint(randnum, userData.attr, userData.owner);

            emit OpenMysteryShard(userData.owner, userData.tokenId, sfts, nfts);
        }

        delete _oracleUserData[reqid];
    }

    // |-- type=1 (Mystery Shard) : shardID(uint16) << 48 | grade(uint8) << 40 | shardType(uint8) << 32 | randomType(uint16) << 16 | mysteryType(uint16)
    function _decodeTokenId(uint256 tokenId) internal pure returns(
        uint8 tokenType,
        ShardAttr memory attr
    ) {
        tokenType = (uint8)((tokenId >> 64) & 0xff);
        attr.shardID = (uint16)((tokenId >> 48) & 0xffff);
        attr.grade = (uint8)((tokenId >> 40) & 0xff);
        attr.shardType = (uint8)((tokenId >> 32) & 0xff);
        attr.randomType = (uint16)((tokenId >> 16) & 0xffff);
        attr.mysteryType = (uint16)(tokenId & 0xffff);
    }
}