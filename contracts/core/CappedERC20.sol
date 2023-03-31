// SPDX-License-Identifier: MIT
// Metaline Contracts (CapedERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
contract CappedERC20 is 
    Context, 
    Pausable,
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    function pause() external 
    {
        _pause();
    }

    function  unpause() external
    {
        _unpause();
    }
}