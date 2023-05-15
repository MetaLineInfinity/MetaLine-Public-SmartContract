// SPDX-License-Identifier: MIT
// MetaLine Contracts (IPortMarketPair.sol)

pragma solidity ^0.8.0;

interface IPortMarketPair {
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve1155, uint112 reserve20);

    function market() external view returns (address); // address of PortMarket
    function portid() external view returns (uint16); // port id
    function token0() external view returns (address); // token0
    function itemid() external view returns (uint32); // token1 is item id in game
    
    function reserve0() external view returns (uint112);
    function reserve1() external view returns (uint112);
    function getReserves() external view returns (uint112 r0, uint112 r1, uint32 blockTimestampLast);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0, uint amount1, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}