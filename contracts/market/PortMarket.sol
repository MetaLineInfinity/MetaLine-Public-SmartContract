// SPDX-License-Identifier: MIT
// Metaline Contracts (PortMarket.sol)

pragma solidity ^0.8.0;

import "../interface/market/IPortMarket.sol";
import "../interface/market/IPortMarketPair.sol";

import "../utility/ProxyImplInitializer.sol";

import "./PortMarketPair.sol";
import "./PortMarketPairProxy.sol";
import "./PortMarketLibrary.sol";

contract PortMarket is ProxyImplInitializer,IPortMarket {
    using LowGasSafeMath for uint;
    
    event Fee_Changed(uint16 indexed portid, uint16 newFee);
    event Pair_Created(uint16 indexed portid, address indexed token0, uint32 indexed itemid, address pair);
    
    event ItemTransfer(uint16 indexed portid, uint32 itemid, address indexed from, address indexed to, uint value);
    event Off2onChain_item(uint16 indexed portid, uint32 indexed itemid, address indexed addr, uint256 value);
    event On2offChain_item(uint16 indexed portid, uint32 indexed itemid, address indexed addr, uint256 value);
    
    address public owner;
    address public serviceOp;
    address _feeTo;
    uint16 _fee;
    uint16 _portID;

    // swap pair implementation contracts
    address public swapPairimpl;
    
    // swap pairs
    mapping(bytes32=>address) public _swapPair; // keccak256(abi.encodePacked(token0, itemid) => swap pair address
    mapping(address=>uint32) public _swapPairAddrToItemid; // swap pair address => itemid

    mapping(address=>mapping(uint32=>uint256)) _itemBalances; // itemid => user addr => value
    
    // proxy implementation do not use constructor, use initialize instead
    constructor() {}
    
    function initialize() external initOnce {
        owner = msg.sender;
        _feeTo = msg.sender; 
        _fee = 50; 
    }

    function initPortMarket(
        uint16 pid,
        address pmp
    ) external initOnceStep(2) {
        require(msg.sender == owner, 'PortMarket: FORBIDDEN');
        swapPairimpl = pmp;
        _portID = pid;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == owner, 'PortMarket: FORBIDDEN');
        owner = newOwner;
    }

    function setServiceOp(address op) external {
        require(msg.sender == owner, 'PortMarket: FORBIDDEN');
        serviceOp = op;
    }

    function setFeeTo(address newFeeTo) external {
        require(msg.sender == owner, 'PortMarket: FORBIDDEN');
        _feeTo = newFeeTo;
    }
    function setPortFee(uint16 newFee) external {
        require(msg.sender == _feeTo, 'PortMarket: FORBIDDEN');
        _fee = newFee;

        emit Fee_Changed(_portID, newFee);
    }

    function feeTo() external override view returns(address) {
        return _feeTo;
    }
    function portFee() external override view returns(uint16) {
        return _fee;
    }
    
    function portID() external override view returns(uint16) {
        return _portID;
    }

    function _getKey(
        address token0, 
        uint32 itemid
    ) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(token0, itemid));
    }
    function createSwapPair(address token0, uint32 itemid) public override returns(address swapAddr) {
        bytes32 key = _getKey(token0, itemid);
        require(_swapPair[key] == address(0), "PortMarket: pair already created");

        swapAddr = address(
            new PortMarketPairProxy{salt: key}(
                swapPairimpl
            )
        );

        _swapPair[key] = swapAddr;
        _swapPairAddrToItemid[swapAddr] = itemid;

        PortMarketPair swapPair = PortMarketPair(swapAddr);
        swapPair.initialize(token0, itemid, _portID);

        emit Pair_Created(_portID, token0, itemid, swapAddr);
    }
    function getSwapPair(address token0, uint32 itemid) public view override returns(address) {
        bytes32 key = _getKey(token0, itemid);
        return _swapPair[key];
    }
    
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PortMarket: EXPIRED');
        _;
    }
    function _addLiquidity(
        address swapPair,
        uint amount0Desired,
        uint amount1Desired,
        uint amount0Min,
        uint amount1Min,
        address to
    ) internal returns (uint amount0, uint amount1, uint liquidity) {
        (uint reserve0, uint reserve1,) = IPortMarketPair(swapPair).getReserves();
        if (reserve0 == 0 && reserve1 == 0) {
            (amount0, amount1) = (amount0Desired, amount1Desired);
        } else {
            uint amount1Optimal = PortMarketLibrary.quote(amount0Desired, reserve0, reserve1);
            if (amount1Optimal <= amount1Desired) {
                require(amount1Optimal >= amount1Min, 'PortMarket: INSUFFICIENT_B_AMOUNT');
                (amount0, amount1) = (amount0Desired, amount1Optimal);
            } else {
                uint amount0Optimal = PortMarketLibrary.quote(amount1Desired, reserve1, reserve0);
                assert(amount0Optimal <= amount0Desired);
                require(amount0Optimal >= amount0Min, 'PortMarket: INSUFFICIENT_A_AMOUNT');
                (amount0, amount1) = (amount0Optimal, amount1Desired);
            }
        }

        address token0 = IPortMarketPair(swapPair).token0();
        TransferHelper.safeTransferFrom(token0, msg.sender, swapPair, amount0);
        itemTransferFrom(IPortMarketPair(swapPair).itemid(), msg.sender, swapPair, amount1);
        liquidity = IPortMarketPair(swapPair).mint(to);
    }

    function addLiquidity(
        PortMarketAddLiquidityParameter calldata par,
        uint deadline // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
    ) external override ensure(deadline) returns (
        uint amount0, // amount0 of token0 received by swap pair contract
        uint amount1, // amount1 of token1 received by swap pair contract
        uint liquidity // liquidity of lp token received by user address
    ) {
        address pair = getSwapPair(par.token0, par.itemid);

        if(pair == address(0)){
            pair = createSwapPair(par.token0, par.itemid);
        }

        (amount0, amount1, liquidity) = _addLiquidity(pair, par.amount0Desired, par.amount1Desired, par.amount0Min, par.amount1Min, par.to);
    }

    function removeLiquidity(
        address swapPair, // swap pair address
        uint liquidity, // to remove liquidity lp token value
        uint amount0Min, // amout0 minimum value, if receive amount0 < amount0Min, remove liquidity will be fail
        uint amount1Min, // amout1 minimum value, if receive amount1 < amount1Min, remove liquidity will be fail
        address to, // token0 and token1 transfer to user address
        uint deadline // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
    ) external override ensure(deadline) returns (
        uint amount0, // amount0 of token0 received by user address
        uint amount1 // amount1 of token1 received by user address
    ) {
        PortMarketPairERC20(swapPair).transferFrom(msg.sender, swapPair, liquidity); // send liquidity to pair
        (amount0, amount1) = IPortMarketPair(swapPair).burn(to);
        require(amount0 >= amount0Min, 'PortMarket: INSUFFICIENT_A_AMOUNT');
        require(amount1 >= amount1Min, 'PortMarket: INSUFFICIENT_B_AMOUNT');
    }
    
    function swapExactTokenForToken(
        uint amountIn, // amount that user want transfer to swap pair contract
        uint amountOutMin, // minimum amount that user want receive, if amountOut < amountOutMin, swap fail
        address swapPair, // swap pair contract address
        address to, // receive token user address
        uint deadline, // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
        bool buy // = ture: token1 swap to token0, = false: token0 swap to token1
    ) external override ensure(deadline) returns (
        uint amountOut // amount of token received by user address
    ) {
        (uint reserve0, uint reserve1,) = IPortMarketPair(swapPair).getReserves();
        (uint reserveIn, uint reserveOut) = buy ? (reserve1, reserve0) : (reserve0, reserve1);
        amountOut = PortMarketLibrary.getAmountOut(amountIn, reserveIn, reserveOut, _fee);
        require(amountOut >= amountOutMin, 'PortMarket: INSUFFICIENT_OUTPUT_AMOUNT');
        if(buy) {
            itemTransferFrom(IPortMarketPair(swapPair).itemid(), msg.sender, swapPair, amountIn);
            IPortMarketPair(swapPair).swap(amountOut, 0, to, "");
        }
        else {
            TransferHelper.safeTransferFrom(IPortMarketPair(swapPair).token0(), msg.sender, swapPair, amountIn);
            IPortMarketPair(swapPair).swap(0, amountOut, to, "");
        }
    }

    function swapTokenForExactToken(
        uint amountOut, // amount that usr want receive
        uint amountInMax, // maximum amount that user allow transfer to swap pair contract, if amountIn > amountInMax, swap fail
        address swapPair, // swap pair contract address
        address to, // receive token user address
        uint deadline, // time stamp, in sec, if block.timestamp > deadline, add liquidity will be fail
        bool buy // = ture: token1 swap to token0, = false: token0 swap to token1
    ) external override ensure(deadline) returns (
        uint amountIn // amount of token received by swap pair contract
    ) {
        (uint reserve0, uint reserve1,) = IPortMarketPair(swapPair).getReserves();
        (uint reserveIn, uint reserveOut) = buy ? (reserve1, reserve0) : (reserve0, reserve1);
        amountIn = PortMarketLibrary.getAmountIn(amountOut, reserveIn, reserveOut, _fee);
        require(amountIn <= amountInMax, 'PortMarket: EXCESSIVE_INPUT_AMOUNT');
        if(buy) {
            itemTransferFrom(IPortMarketPair(swapPair).itemid(), msg.sender, swapPair, amountIn);
            IPortMarketPair(swapPair).swap(amountOut, 0, to, "");
        }
        else {
            TransferHelper.safeTransferFrom(IPortMarketPair(swapPair).token0(), msg.sender, swapPair, amountIn);
            IPortMarketPair(swapPair).swap(0, amountOut, to, "");
        }
    }

    function getAmountOut(
        uint amountIn, // amount transfer to swap pair contract
        uint reserveIn, // reserveIn of swap pair contract (if amountIn is amount0, than reserveIn is reserve0, otherwise is reserve1)
        uint reserveOut // reserveOut of swap pair contract (if amountIn is amount0, than reserveOut is reserve1, otherwise is reserve0)
    ) external override view returns (
        uint amountOut // amount transfer to user address
    ) {
        amountOut = PortMarketLibrary.getAmountOut(amountIn, reserveIn, reserveOut, _fee);
    }

    function getAmountIn(
        uint amountOut, // amount transfer to user address
        uint reserveIn, // reserveIn of swap pair contract (if amountOut is amount0, than reserveIn is reserve1, otherwise is reserve0)
        uint reserveOut // reserveOut of swap pair contract (if amountOut is amount0, than reserveOut is reserve0, otherwise is reserve1)
    ) external override view returns (
        uint amountIn // amount transfer to swap pair contract
    ) {
        amountIn = PortMarketLibrary.getAmountIn(amountOut, reserveIn, reserveOut, _fee);
    }

    function off2onChain_item(uint32 itemid, address addr, uint256 value) external override {
        require(msg.sender == serviceOp, "PortMarket: FORBIDDEN");

        _itemBalances[addr][itemid] = _itemBalances[addr][itemid].add(value);
        
        emit Off2onChain_item(_portID, itemid, addr, value);
    }
    function on2offChain_item(uint32 itemid, uint256 value) external override {
        require(itemBlanceOf(itemid, msg.sender) >= value, "PortMarket: insufficient items");

        _itemBalances[msg.sender][itemid] = _itemBalances[msg.sender][itemid].sub(value);

        emit On2offChain_item(_portID, itemid, msg.sender, value);
    }

    function itemBlanceOf(uint32 itemid, address addr) public override view returns(uint256) {
        return _itemBalances[addr][itemid];
    }
    
    function _transfer(uint32 itemid, address from, address to, uint value) private {
        _itemBalances[from][itemid] = _itemBalances[from][itemid].sub(value);
        _itemBalances[to][itemid] = _itemBalances[to][itemid].add(value);
        emit ItemTransfer(_portID, itemid, from, to, value);
    }
    function itemTransfer(uint32 itemid, address to, uint256 value) public override {
        require(msg.sender == address(this) || _swapPairAddrToItemid[msg.sender] != 0, "PortMarket: FORBIDDEN");
        _transfer(itemid, msg.sender, to, value);
    }
    function itemTransferFrom(uint32 itemid, address from, address to, uint256 value) public override {
        require(msg.sender == address(this) || _swapPairAddrToItemid[msg.sender] != 0, "PortMarket: FORBIDDEN");
        _transfer(itemid, from, to, value);
    }
}

