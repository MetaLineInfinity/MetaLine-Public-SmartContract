// SPDX-License-Identifier: MIT
// Metaline Contracts (Billing.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../utility/TransferHelper.sol";

contract VeTokenPool is 
    Context,
    Pausable,
    AccessControl
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    struct stakeInfo{
        uint256 stakeValue; // stake VeToken value
        uint256 lastWithdrawBlock; // last widthdraw block height
    }

    address public VeToken;
    address public PoolToken; // = address(0) means eth
    uint256 public withdrawBlockInterval;
    uint256 public revenueBlocks; // revenue run out blocks, e.g. blocks represent 30 days

    mapping(address=>stakeInfo) public _stakes; // user adder => stake info
    uint256 public totalStakeValue; // total stake Vetoken value

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }
    
    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "VeTokenPool: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "VeTokenPool: must have pauser role to unpause"
        );
        _unpause();
    }

    function Init(
        address VeToken_,
        address PoolToken_,
        uint256 withdrawBlockInterval_,
        uint256 revenueBlocks_
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "VeTokenPool: must have manager role"
        );

        VeToken = VeToken_;
        PoolToken_ = PoolToken_;
        withdrawBlockInterval = withdrawBlockInterval_;
        revenueBlocks = revenueBlocks_;
    }

    function fillPool(uint256 value) external {
        if(PoolToken != address(0)){
            require(IERC20(PoolToken).balanceOf(_msgSender()) >= value, "VeTokenPool: insufficient token");

            TransferHelper.safeTransferFrom(PoolToken, _msgSender(), address(this), value);
        }
        // else {
        //     // eth
        //     require(msg.value >= value, "VeTokenPool: value error");
        // }
    }

    function stakeVeToken(uint256 value) external whenNotPaused {
        require(_stakes[_msgSender()].stakeValue == 0, "VeTokenPool: already staked");
        require(IERC20(VeToken).balanceOf(_msgSender()) >= value, "VeTokenPool: insufficient token");

        TransferHelper.safeTransferFrom(VeToken, _msgSender(), address(this), value);
        totalStakeValue += value;

        _stakes[_msgSender()] = stakeInfo({
            stakeValue: value,
            lastWithdrawBlock: block.number
        });
    }

    function unstakeVeToken(uint256 value) external whenNotPaused {
        stakeInfo storage si = _stakes[_msgSender()];
        uint256 stakeValue = si.stakeValue;
        require(stakeValue > 0, "VeTokenPool: not staked");
        require(totalStakeValue >= stakeValue, "VeTokenPool: stakeValue error");
        
        require(IERC20(VeToken).balanceOf(address(this)) >= stakeValue, "VeTokenPool: insufficient token");

        TransferHelper.safeTransferFrom(VeToken, address(this), _msgSender(), stakeValue);
        totalStakeValue -= stakeValue;

        if(si.lastWithdrawBlock + withdrawBlockInterval < block.number) {
            _withdrawRevenue(si);
        }
    }

    function withdrawRevenue() external whenNotPaused {
        stakeInfo storage si = _stakes[_msgSender()];
        require(si.stakeValue > 0, "VeTokenPool: not staked");
        require(si.lastWithdrawBlock + withdrawBlockInterval < block.number, "VeTokenPool: withdraw block error");
        
        _withdrawRevenue(si);
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Metaline: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function _withdrawRevenue(stakeInfo storage si) internal lock {
        if(PoolToken != address(0)){
            uint256 poolValue = IERC20(PoolToken).balanceOf(address(this));
            if(poolValue == 0){
                return;
            }

            uint256 withdrawValue = poolValue * si.stakeValue * (block.number - si.lastWithdrawBlock) / (totalStakeValue * revenueBlocks);
            if(withdrawValue > poolValue)
            {
                withdrawValue = poolValue;
            }

            TransferHelper.safeTransferFrom(PoolToken, address(this), _msgSender(),  withdrawValue);
        }
        else {
            // eth
            uint256 poolValue = address(this).balance;
            if(poolValue == 0){
                return;
            }

            uint256 withdrawValue = poolValue * si.stakeValue * (block.number - si.lastWithdrawBlock) / (totalStakeValue * revenueBlocks);
            if(withdrawValue > poolValue)
            {
                withdrawValue = poolValue;
            }

            TransferHelper.safeTransferETH(_msgSender(),  withdrawValue);
        }
        
        si.lastWithdrawBlock = block.number;
    }
}