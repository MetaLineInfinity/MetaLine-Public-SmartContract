// SPDX-License-Identifier: MIT
// Metaline Contracts (CapedERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CappedERC20 is 
    Context, 
    ERC20Burnable
{
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 cap_
    ) ERC20(name_, symbol_)
    {
        _mint(_msgSender(), cap_);
    }
}