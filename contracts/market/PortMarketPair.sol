// SPDX-License-Identifier: MIT
// MetaLine Contracts (PortMarketPair.sol)

pragma solidity ^0.8.0;

import "../interface/market/IPortMarket.sol";
import "../interface/market/IPortMarketSwapCallee.sol";
import "../interface/market/IPortMarketPair.sol";

import "../utility/Math.sol";
import "../utility/UQ112x112.sol";
import "../utility/TransferHelper.sol";

import "./PortMarketPairERC20.sol";
//import "hardhat/console.sol";

// 1155 swap pair base on uniswap v2 swap algorithm
// see {UniswapV2Pair}
contract PortMarketPair is IPortMarketPair, PortMarketPairERC20 {
    using LowGasSafeMath for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public override market;
    uint16 public override portid;
    address public override token0;
    uint32 public override itemid;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event
    
    uint112 private _r0; // uses single storage slot, accessible via getReserves
    uint112 private _r1; // uses single storage slot, accessible via getReserves
    uint32 private _blockTimestampLast; // uses single storage slot, accessible via getReserves

    bool private _locked;

    // proxy implementation do not use constructor, use initialize instead
    constructor() {}

    function __chain_initialize_PortMarketPairBase (
        address t0,
        uint32 t1,
        uint16 pid
    ) internal onlyInitializing {

        __chain_initialize_PortMarketERC20();

        _locked = false;
        market = msg.sender;
        token0 = t0;
        itemid = t1;
        portid = pid;
    }
    
    function initialize(
        address t0,
        uint32 t1,
        uint16 pid
    ) external initOnce {
        __chain_initialize_PortMarketPairBase(t0, t1, pid);
    }

    modifier lock() {
        require(!_locked, 'PortMarket: LOCKED');
        _locked = true;
        _;
        _locked = false;
    }

    function reserve0() external override view returns (uint112) {
        return _r0;
    }
    function reserve1() external override view returns (uint112) {
        return _r1;
    }

    function getReserves() public override view returns (uint112 r0, uint112 r1, uint32 blockTimestampLast) {
        r0 = _r0;
        r1 = _r1;
        blockTimestampLast = _blockTimestampLast;
    }

    function _update(uint b0, uint b1, uint112 r0, uint112 r1) private {
        require(b0 <= type(uint112).max && b1 <= type(uint112).max, 'PortMarket: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - _blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && r0 != 0 && r1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(r1).uqdiv(r0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(r0).uqdiv(r1)) * timeElapsed;
        }
        _r0 = uint112(b0);
        _r1 = uint112(b1);
        _blockTimestampLast = blockTimestamp;
        emit Sync(_r0, _r1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 r0, uint112 r1) private returns (bool feeOn) {
        address feeTo = IPortMarket(market).feeTo();
        feeOn = feeTo != address(0);
        uint kl = kLast; // gas savings
        if (feeOn) {
            if (kl != 0) {
                uint rootK = Math.sqrt(uint(r0).mul(r1));
                uint rootKLast = Math.sqrt(kl);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (kl != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external override lock returns (uint liquidity) {
        (uint112 r0, uint112 r1,) = getReserves(); // gas savings
        uint balance0 = PortMarketPairERC20(token0).balanceOf(address(this));
        uint balance1 = IPortMarket(market).itemBlanceOf(itemid, address(this));
        uint amount0 = balance0.sub(r0);
        uint amount1 = balance1.sub(r1);

        bool feeOn = _mintFee(r0, r1);
        uint total = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (total == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(total) / r0, amount1.mul(total) / r1);
        }
        require(liquidity > 0, 'PortMarket: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, r0, r1);
        if (feeOn) kLast = uint(_r0).mul(_r1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external override lock returns (uint amount0, uint amount1) {
        (uint112 r0, uint112 r1,) = getReserves(); // gas savings
        uint balance0 = PortMarketPairERC20(token0).balanceOf(address(this));
        uint balance1 = IPortMarket(market).itemBlanceOf(itemid, address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(r0, r1);
        uint total = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / total; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / total; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'PortMarket: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        TransferHelper.safeTransfer(token0, to, amount0);
        IPortMarket(market).itemTransfer(itemid, to, amount1);
        balance0 = PortMarketPairERC20(token0).balanceOf(address(this));
        balance1 = IPortMarket(market).itemBlanceOf(itemid, address(this));

        _update(balance0, balance1, r0, r1);
        if (feeOn) kLast = uint(_r0).mul(_r1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external override lock {
        require(amount0Out > 0 || amount1Out > 0, 'PortMarket: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 r0, uint112 r1,) = getReserves(); // gas savings
        require(amount0Out < r0 && amount1Out < r1, 'PortMarket: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
            address t0 = token0;
            require(to != t0, 'PortMarket: INVALID_TO');
            if (amount0Out > 0) {
                TransferHelper.safeTransfer(token0, to, amount0Out);
            }
            if (amount1Out > 0) {
                IPortMarket(market).itemTransfer(itemid, to, amount1Out);
            }
            if (data.length > 0) IPortMarketSwapCallee(to).PortMarketCall(msg.sender, amount0Out, amount1Out, data);
            balance0 = PortMarketPairERC20(token0).balanceOf(address(this));
            balance1 = IPortMarket(market).itemBlanceOf(itemid, address(this));
        }
        uint amount0In = balance0 > r0 - amount0Out ? balance0 - (r0 - amount0Out) : 0;
        uint amount1In = balance1 > r1 - amount1Out ? balance1 - (r1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'PortMarket: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(IPortMarket(market).portFee()));
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(IPortMarket(market).portFee()));
            require(balance0Adjusted.mul(balance1Adjusted) >= uint(r0).mul(r1).mul(1000**2), 'PortMarket: K');
        }

        _update(balance0, balance1, r0, r1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external override lock {
        TransferHelper.safeTransfer(token0, to, PortMarketPairERC20(token0).balanceOf(address(this)).sub(_r0));
        IPortMarket(market).itemTransfer(itemid, to, IPortMarket(market).itemBlanceOf(itemid, address(this)).sub(_r1));
    }

    // force reserves to match balances
    function sync() external override lock {
        _update(
            PortMarketPairERC20(token0).balanceOf(address(this)), 
            IPortMarket(market).itemBlanceOf(itemid, address(this)), 
            _r0, 
            _r1
        );
    }
}