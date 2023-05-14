// SPDX-License-Identifier: MIT
// MetaLine Contracts (IPortMarket.sol)

pragma solidity ^0.8.0;

struct PortMarketAddLiquidityParameter {
    address token0; // token0 address
    uint32 itemid; // game item id as token1
    uint amount0Desired; // amount0 value in desire, must >= amount0Min
    uint amount1Desired; // amount1 value in desire, must >= amount1Min
    uint amount0Min; // amout0 minimum value, if allow amount0 < amount0Min, add liquidity will be fail
    uint amount1Min; // amout1 minimum value, if allow amount1 < amount1Min, add liquidity will be fail
    address to; // liquidity mint to user address
}

interface IPortMarket {

    function feeTo() external view returns(address);
    function portFee() external view returns(uint16); // fee in 1000, swap fee = value * fee / 1000;

    function portID() external view returns(uint16);

    function createSwapPair(address token0, uint32 itemid) external returns(address);
    function getSwapPair(address token0, uint32 itemid) external returns(address);

    function addLiquidity(
        PortMarketAddLiquidityParameter calldata par,
        uint deadline // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
    ) external returns (
        uint amount0, // amount0 of token0 received by swap pair contract
        uint amount1, // amount1 of token1 received by swap pair contract
        uint liquidity // liquidity of lp token received by user address
    );

    function removeLiquidity(
        address swapPair, // swap pair address
        uint liquidity, // to remove liquidity lp token value
        uint amount0Min, // amout0 minimum value, if receive amount0 < amount0Min, remove liquidity will be fail
        uint amount1Min, // amout1 minimum value, if receive amount1 < amount1Min, remove liquidity will be fail
        address to, // token0 and token1 transfer to user address
        uint deadline // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
    ) external returns (
        uint amount0, // amount0 of token0 received by user address
        uint amount1 // amount1 of token1 received by user address
    );
    
    function swapExactTokenForToken(
        uint amountIn, // amount that user want transfer to swap pair contract
        uint amountOutMin, // minimum amount that user want receive, if amountOut < amountOutMin, swap fail
        address swapPair, // swap pair contract address
        address to, // receive token user address
        uint deadline, // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
        bool buy // = ture: token1 swap to token0, = false: token0 swap to token1
    ) external returns (
        uint amountOut // amount of token received by user address
    );

    function swapTokenForExactToken(
        uint amountOut, // amount that usr want receive
        uint amountInMax, // maximum amount that user allow transfer to swap pair contract, if amountIn > amountInMax, swap fail
        address swapPair, // swap pair contract address
        address to, // receive token user address
        uint deadline, // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
        bool buy // = ture: token1 swap to token0, = false: token0 swap to token1
    ) external returns (
        uint amountIn // amount of token received by swap pair contract
    );

    function getAmountOut(
        uint amountIn, // amount transfer to swap pair contract
        uint reserveIn, // reserveIn of swap pair contract (if amountIn is amount0, than reserveIn is reserve0, otherwise is reserve1)
        uint reserveOut // reserveOut of swap pair contract (if amountIn is amount0, than reserveOut is reserve1, otherwise is reserve0)
    ) external returns (
        uint amountOut // amount transfer to user address
    );

    function getAmountIn(
        uint amountOut, // amount transfer to user address
        uint reserveIn, // reserveIn of swap pair contract (if amountOut is amount0, than reserveIn is reserve1, otherwise is reserve0)
        uint reserveOut // reserveOut of swap pair contract (if amountOut is amount0, than reserveOut is reserve0, otherwise is reserve1)
    ) external returns (
        uint amountIn // amount transfer to swap pair contract
    );

    function off2onChain_item(uint32 itemid, address addr, uint256 value) external;
    function on2offChain_item(uint32 itemid, uint256 value) external;

    function itemBlanceOf(uint32 itemid, address addr) external returns(uint256);
    function itemTransfer(uint32 itemid, address to, uint256 value) external;
    function itemTransferFrom(uint32 itemid, address from, address to, uint256 value) external;
}