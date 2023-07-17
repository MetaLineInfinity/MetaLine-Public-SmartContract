// SPDX-License-Identifier: MIT
// Metaline Contracts (VMTT.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./core/CappedERC20.sol";

// Metaline VeToken
contract VMTT is CappedERC20, AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(address=>bool) public _poolAddrs;
    bool public _allowTransfer;

    constructor(uint256 v)
        CappedERC20("MetaLine VeToken", "VMTT", v)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
    }

    function setAllowTransfer(bool allow) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "VMTTMinePool: must have manager role");

        _allowTransfer = allow;
    }

    function addPoolAddr(address poolAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "VMTTMinePool: must have manager role");

        _poolAddrs[poolAddr] = true;
    }
    function rmvPoolAddr(address poolAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "VMTTMinePool: must have manager role");

        delete _poolAddrs[poolAddr];
    }

    function _isPoolAddr(address poolAddr) internal view returns(bool) {
        return _poolAddrs[poolAddr];
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(_allowTransfer || _isPoolAddr(from) || _isPoolAddr(to), "VMTT: transfer not allowed");
    }
}