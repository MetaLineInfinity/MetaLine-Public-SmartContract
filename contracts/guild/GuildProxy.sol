// SPDX-License-Identifier: MIT
// MetaLine Contracts (GuildProxy.sol)

pragma solidity ^0.8.0;

import "../utility/ProxyUpgradeable.sol";

contract GuildProxy is ProxyUpgradeable {

    constructor(address impl) 
        payable 
        ProxyUpgradeable(impl)
    {

    }
}