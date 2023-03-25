// SPDX-License-Identifier: MIT
// Metaline Contracts (CapedERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MTTGold is 
    Context, 
    AccessControl,
    ERC20Burnable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function mint(address toAddr, uint256 value) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "MTTGold: must have minter role");
        _mint(toAddr, value);
    }
}