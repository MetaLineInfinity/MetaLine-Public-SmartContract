// SPDX-License-Identifier: MIT
// Metaline Contracts (Expedition.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../MTT.sol";

import "../utility/TransferHelper.sol";

contract MTTMinePool is
    Context,
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    event MTTMinePoolSend(address indexed userAddr, address indexed caller, uint256 value, bytes reason);

    uint256 public immutable _MTT_PER_BLOCK; 

    MTT public _MTT;

    uint256 public _MTT_TOTAL_OUTPUT;

    uint256 public _MTT_LIQUIDITY;
    uint256 public _MTT_LAST_OUTPUT_BLOCK;

    constructor(
        address _MTTAddr,
        uint256 _perblock
    ) {
        require(_perblock > 0, "MTTMinePool: mtt per block must >0");

        _MTT = MTT(_MTTAddr);

        _MTT_PER_BLOCK = _perblock;
        _MTT_LAST_OUTPUT_BLOCK = block.number;
        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function _output() internal {
        if(_MTT_LAST_OUTPUT_BLOCK >= block.number){
            return;
        }

        uint256 output = (block.number - _MTT_LAST_OUTPUT_BLOCK) * _MTT_PER_BLOCK;
        _MTT_LAST_OUTPUT_BLOCK = block.number;
        _MTT_LIQUIDITY += output;
        _MTT_TOTAL_OUTPUT += output;
    }

    function send(address userAddr, uint256 value, bytes memory reason) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "MTTMinePool: must have minter role");

        _output();

        require(_MTT_LIQUIDITY >= value, "MTTMinePool: short of liquidity");
        require(_MTT.balanceOf(address(this)) >= value, "MTTMinePool: insufficient MTT");

        _MTT_LIQUIDITY -= value;
        TransferHelper.safeTransfer(address(_MTT), userAddr, value);

        emit MTTMinePoolSend(userAddr, _msgSender(), value, reason);
    }
}