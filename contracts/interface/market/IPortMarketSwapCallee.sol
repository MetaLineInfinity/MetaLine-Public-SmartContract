// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// see {IUniswapV2Callee}
interface IPortMarketSwapCallee {
    function PortMarketCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}