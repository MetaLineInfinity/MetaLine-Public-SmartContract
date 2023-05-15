// SPDX-License-Identifier: MIT
// MetaLine Contracts (PortMarketPairProxy.sol)

pragma solidity ^0.8.0;

import "../utility/Proxy.sol";

contract PortMarketPairProxy is Proxy {
    constructor(address impl) payable Proxy(impl) {}

}
