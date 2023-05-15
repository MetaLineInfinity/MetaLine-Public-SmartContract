// SPDX-License-Identifier: MIT
// MetaLine Contracts (PortMarketLibrary.sol)

pragma solidity ^0.8.0;

import "../interface/market/IPortMarketPair.sol";

import '../utility/LowGasSafeMath.sol';

// see {UniswapV2Library}
library PortMarketLibrary {
    using LowGasSafeMath for uint;

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'BeaverSwapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'BeaverSwapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint16 fee) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BeaverSwapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BeaverSwapLibrary: INSUFFICIENT_LIQUIDITY');
        require(fee < 1000, "BeaverSwapLibrary: FEE_OVERFLOW");
        uint amountInWithFee = amountIn.mul(1000-fee);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint16 fee) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BeaverSwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BeaverSwapLibrary: INSUFFICIENT_LIQUIDITY');
        require(fee < 1000, "BeaverSwapLibrary: FEE_OVERFLOW");
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(1000-fee);
        amountIn = (numerator / denominator).add(1);
    }
}