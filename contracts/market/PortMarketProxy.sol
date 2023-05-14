// SPDX-License-Identifier: MIT
// MetaLine Contracts (PortMarketProxy.sol)

pragma solidity ^0.8.0;

import "../utility/ProxyUpgradeable.sol";

contract PortMarketProxy is ProxyUpgradeable {

    constructor(address impl) 
        payable 
        ProxyUpgradeable(impl)
    {

    }
}