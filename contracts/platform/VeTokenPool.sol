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

    function fillPool() external {

    }

    function stakeVeToken(uint256 value) external {

    }

    function unstakeVeToken(uint256 value) external {

    }

    function withdrawRevenue() external {

    }
}