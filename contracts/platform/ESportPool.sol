// SPDX-License-Identifier: MIT
// Metaline Contracts (ESportPool.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../utility/TransferHelper.sol";
import "../utility/OracleCharger_V1.sol";

contract ESportPool is 
    Context,
    Pausable,
    AccessControl
{
    using OracleCharger_V1 for OracleCharger_V1.OracleChargerStruct;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");

    event OnBuyTicket(uint32 poolId, uint256 usdPrice, uint256 tokenValue, uint256 poolValue, uint64 totalTickets, uint64 currentRoundTickets);
    event DispatchAward(uint32 poolId, uint256 poolValue, uint64 currentRound, RoundInfos rinfo);
    
    struct PoolConfig {
        uint256 ticketUsdPrice;
        uint32 priceGrowPer; // per = priceGrowPer / 10000
        uint32 priceGrowCount;
        uint16[] winnerShares;
        string tokenName;
        address tokenAddr;
    }
    struct PoolInfo {
        uint256 poolValue;
        uint64 currentRound;
        uint64 totalTickets;
        uint64 currentRoundTickets;
    }

    struct WinnerInfo {
        address winnerAddr;
        uint256 winnerAwardValue;
    }
    struct RoundInfos {
        uint64 tickets;
        WinnerInfo[] winnerInfos;
    }

    OracleCharger_V1.OracleChargerStruct public _oracleCharger;

    mapping(uint32=>PoolConfig) public _poolConfig; // pool id => pool config
    mapping(uint32=>PoolInfo) public _poolInfo; // pool id => pool Info

    mapping(uint32=>mapping(uint64=>RoundInfos)) _roundInfos; // pool id => round => round infos
    
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(SERVICE_ROLE, _msgSender());
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ESportPool: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ESportPool: must have pauser role to unpause"
        );
        _unpause();
    }

    function setTPOracleAddr(address tpOracleAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "ESportPool: must have manager role");

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
        require(hasRole(MANAGER_ROLE, _msgSender()), "ESportPool: must have manager role");

        _oracleCharger.addChargeToken(tokenName, tokenAddr, maximumUSDPrice, minimumUSDPrice);
    }

    function removeChargeToken(string memory tokenName) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "ESportPool: must have manager role");

        _oracleCharger.removeChargeToken(tokenName);
    }

    function setPoolConfig(uint32 poolId, PoolConfig calldata conf) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "ESportPool: must have manager role");

        uint16 total = 0;
        for(uint i=0; i< conf.winnerShares.length; ++i){
            total += conf.winnerShares[i];
        }

        require(total <= 10000, "ESportPool: winner share config error");

        _poolConfig[poolId] = conf;
    }

    function getPoolWinnerInfos(uint32 poolId, uint64 round) external view returns(RoundInfos memory ret) {
        ret = _roundInfos[poolId][round];
    }

    function buyTicket(uint32 poolId, uint256 usdPrice) external {
        PoolConfig memory conf = _poolConfig[poolId];
        require(conf.ticketUsdPrice > 0, "ESportPool: pool not exist");

        PoolInfo storage info = _poolInfo[poolId];
        if(info.currentRound == 0){
            info.currentRound = 1;
        }
        
        // calc price
        uint256 _usdPrice = conf.ticketUsdPrice;
        if(conf.priceGrowCount > 0) {
            uint count = info.currentRoundTickets / conf.priceGrowCount;
            _usdPrice +=  _usdPrice * count * conf.priceGrowPer / 10000;
        }
        require(usdPrice >= _usdPrice, "ESportPool: price error");

        uint256 tokenValue = _oracleCharger.charge(conf.tokenName, _usdPrice, address(this));
        ++info.totalTickets;
        ++info.currentRoundTickets;
        info.poolValue += tokenValue;

        emit OnBuyTicket(poolId, _usdPrice, tokenValue, info.poolValue, info.totalTickets, info.currentRoundTickets);
    }

    function dispatchAward(uint32 poolId, address[] calldata winners) external {
        require(hasRole(SERVICE_ROLE, _msgSender()), "ESportPool: must have service role");

        PoolConfig memory conf = _poolConfig[poolId];
        require(conf.ticketUsdPrice > 0, "ESportPool: pool not exist");
        require(winners.length <= conf.winnerShares.length, "ESportPool: too much winner");

        PoolInfo storage info = _poolInfo[poolId];
        if(info.currentRound == 0){
            info.currentRound = 1;
        }

        RoundInfos storage rinfo = _roundInfos[poolId][info.currentRound];
        rinfo.tickets = info.currentRoundTickets;
        info.currentRoundTickets = 0; // clear current round ticket

        uint256 balance = IERC20(conf.tokenAddr).balanceOf(address(this));
        require(info.poolValue <= balance, "ESportPool: insufficient token");

        uint256 poolValue = info.poolValue;
        for(uint i=0; i< winners.length; ++i){
            uint256 awardV = poolValue * conf.winnerShares[i] / 10000;
            TransferHelper.safeTransfer(conf.tokenAddr, winners[i], awardV);
            info.poolValue -= awardV;

            rinfo.winnerInfos.push(WinnerInfo({
                winnerAwardValue:awardV,
                winnerAddr:winners[i]
            }));
        }

        emit DispatchAward(poolId, info.poolValue, info.currentRound, rinfo);

        ++info.currentRound;
    }
}