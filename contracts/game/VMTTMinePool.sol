// SPDX-License-Identifier: MIT
// Metaline Contracts (VMTTMinePool.sol)

pragma solidity >=0.8.0 <=0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../VMTT.sol";

import "../utility/TransferHelper.sol";

contract VMTTMinePool is
    Context,
    AccessControl
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    event MTTMinePoolSend(address indexed userAddr, address indexed caller, uint256 value, bytes reason);

    uint256 public immutable VMTT_PER_BLOCK; 

    VMTT public VMTTContract;

    uint256 public VMTT_TOTAL_OUTPUT;

    uint256 public VMTT_LIQUIDITY;
    uint256 public VMTT_LAST_OUTPUT_BLOCK;

    constructor(
        address _MTTAddr,
        uint256 _perblock
    ) {
        require(_perblock > 0, "VMTTMinePool: mtt per block must >0");

        VMTTContract = VMTT(_MTTAddr);

        VMTT_PER_BLOCK = _perblock;
        VMTT_LAST_OUTPUT_BLOCK = block.number;
        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function _output() internal {
        if(VMTT_LAST_OUTPUT_BLOCK >= block.number){
            return;
        }

        uint256 output = (block.number - VMTT_LAST_OUTPUT_BLOCK) * VMTT_PER_BLOCK;
        VMTT_LAST_OUTPUT_BLOCK = block.number;
        VMTT_LIQUIDITY += output;
        VMTT_TOTAL_OUTPUT += output;
    }

    function send(address userAddr, uint256 value, bytes memory reason) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "VMTTMinePool: must have minter role");

        _output();

        require(VMTT_LIQUIDITY >= value, "VMTTMinePool: short of liquidity");
        require(VMTTContract.balanceOf(address(this)) >= value, "VMTTMinePool: insufficient VMTT");

        VMTT_LIQUIDITY -= value;
        TransferHelper.safeTransfer(address(VMTTContract), userAddr, value);

        emit MTTMinePoolSend(userAddr, _msgSender(), value, reason);
    }
}