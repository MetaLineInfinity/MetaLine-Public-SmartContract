
import { Contract, BigNumber, Signer } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';

//gen5
describe("port market Test", function () {
    before(inittest);
    it("should create market succ", createMarket);
    it("should create market pair succ", createMarketPair);
    it("should test mintLiquidity succ", mintLiquidity);
    it("should test swap succ", swap);
    it("should test burnLiquidity succ", burnLiquidity);
});

var testtool: TestTool;

import * as hre from "hardhat";

var MockERC20: Contract;

var PortMarket: Contract;
var PortMarketPair: Contract;
var PortMarketFactory: Contract;
var MTTGold: Contract;
var portMarketPorxy: Contract;
var PortMarketPairPorxy: Contract;
var pairAddr : string;
var pmAddr : string;

async function inittest() {
    testtool = await TestTool.Init();
    MockERC20 = await ContractTool.GetVistualContract(testtool.signer0, "MockERC20", "addr:MockERC20");
    PortMarket = ContractInfo.getContract("PortMarket");
    PortMarketPair = ContractInfo.getContract("PortMarketPair");
    PortMarketFactory = ContractInfo.getContract("PortMarketFactory");
    MTTGold = ContractInfo.getContract("MTTGold");
    //ContractTool.PassBlock(hre, 1000);
}

async function createMarket() {

    pmAddr = await ContractTool.CallView(PortMarketFactory, "portMarkets", [1]);
    if(pmAddr == undefined || pmAddr == "0x0000000000000000000000000000000000000000"){
        let recpt = await ContractTool.CallState(PortMarketFactory, "createPortMarket", [1]);
        let event = ContractTool.GetEvent(recpt, "PortMarketCreated");
        logtools.loggreen("create port market=" + event);
        pmAddr = event[1];
    }
    else {
        logtools.loggreen("port market already created");
    }
    
    // create succ
    logtools.logcyan("port 1 market addr=" + pmAddr);

    portMarketPorxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarket", pmAddr);

    logtools.loggreen("test succ");
}


async function createMarketPair() {

    pairAddr = await ContractTool.CallView(portMarketPorxy, "getSwapPair", [MTTGold.address, 1001]);
    if(pairAddr == undefined || pairAddr == "0x0000000000000000000000000000000000000000"){
        let recpt = await ContractTool.CallState(portMarketPorxy, "createSwapPair", [MTTGold.address, 1001]);
        let event = ContractTool.GetEvent(recpt, "Pair_Created");
        logtools.loggreen("create swap pair=" + event);
        pairAddr = event[3];
    }
    else {
        logtools.loggreen("swap pair already created");
    }
    
    // create succ
    logtools.logcyan("pair addr=" + pairAddr);

    PortMarketPairPorxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarketPair", pairAddr);

    logtools.loggreen("test succ");
}


async function mintLiquidity() {
    let recpt = await ContractTool.CallState(MTTGold, "changeBridgeAddr", [testtool.addr0, false]);
    recpt = await ContractTool.CallState(MTTGold, "mint", [testtool.addr0, "1000000000000000000000"]);
    recpt = await ContractTool.CallState(portMarketPorxy, "setServiceOp", [testtool.addr0]);
    recpt = await ContractTool.CallState(portMarketPorxy, "off2onChain_item", [1001, testtool.addr0, 10000]);
    
    recpt = await ContractTool.CallState(MTTGold, "approve", [pmAddr, "10000000000000000000000000000"]);

    recpt = await ContractTool.CallState(portMarketPorxy, "addLiquidity", [[MTTGold.address, 1001, "110000000000000000000", 1100, "100000000000000000000", 1000, testtool.addr0], 10000000000]);
    
    let liquidity = await ContractTool.CallView(PortMarketPairPorxy, "balanceOf", [testtool.addr0]);
    
    logtools.logcyan("mint liquidity=" + liquidity);
}

async function _logAssets(step) {
    
    let gold = await ContractTool.CallView(MTTGold, "balanceOf", [testtool.addr0]);
    logtools.logcyan(`${step} user gold=` + gold);

    let item = await ContractTool.CallView(portMarketPorxy, "itemBlanceOf", [1001, testtool.addr0]);
    logtools.logcyan(`${step} user item=` + item);
    
    let liquidity = await ContractTool.CallView(PortMarketPairPorxy, "balanceOf", [testtool.addr0]);
    logtools.logcyan(`${step} user liquidity=` + liquidity);

    let pairgold = await ContractTool.CallView(MTTGold, "balanceOf", [pairAddr]);
    logtools.logcyan(`${step} pair gold=` + pairgold);

    let pairitem = await ContractTool.CallView(portMarketPorxy, "itemBlanceOf", [1001, pairAddr]);
    logtools.logcyan(`${step} pair item=` + pairitem);
    
    let pairliquidity = await ContractTool.CallView(PortMarketPairPorxy, "totalSupply", []);
    logtools.logcyan(`${step} pair liquidity=` + pairliquidity);
}
async function swap() {
    await _logAssets("before swap");
    
    let r0 = await ContractTool.CallView(PortMarketPairPorxy, "reserve0", []);
    let r1 = await ContractTool.CallView(PortMarketPairPorxy, "reserve1", []);
    
    logtools.logcyan(`befor swap r0=${r0}, r1=${r1}`);

    let liquidity = await ContractTool.CallView(PortMarketPairPorxy, "balanceOf", [testtool.addr0]);

    let amountOut = await ContractTool.CallView(portMarketPorxy, "getAmountOut", ["1000000000000000000", r0, r1]);
    amountOut = Math.floor(amountOut * 95 / 100);

    let recpt = await ContractTool.CallState(portMarketPorxy, "swapExactTokenForToken", ["1000000000000000000", amountOut, pairAddr, testtool.addr0, 10000000000, false]);
    
    await _logAssets("after swap 1");
    
    r0 = await ContractTool.CallView(PortMarketPairPorxy, "reserve0", []);
    r1 = await ContractTool.CallView(PortMarketPairPorxy, "reserve1", []);
    
    logtools.logcyan(`after swap1 r0=${r0}, r1=${r1}`);

    liquidity = await ContractTool.CallView(PortMarketPairPorxy, "balanceOf", [testtool.addr0]);

    let amountIn = await ContractTool.CallView(portMarketPorxy, "getAmountIn", ["1000000000000000000", r1, r0]);

    amountIn = Math.ceil(amountIn * 105 / 100);
    recpt = await ContractTool.CallState(portMarketPorxy, "swapTokenForExactToken", ["1000000000000000000", amountIn, pairAddr, testtool.addr0, 10000000000, true]);
    
    await _logAssets("after swap 2");
}

async function burnLiquidity() {
    
    let r0 = await ContractTool.CallView(PortMarketPairPorxy, "reserve0", []);
    let r1 = await ContractTool.CallView(PortMarketPairPorxy, "reserve1", []);
    let liquidity = await ContractTool.CallView(PortMarketPairPorxy, "balanceOf", [testtool.addr0]);
    
    logtools.logcyan(`befor burn r0=${r0}, r1=${r1}, liquidity=${liquidity}`);

    let recpt = await ContractTool.CallState(PortMarketPairPorxy, "approve", [pmAddr, "100000000000000000000000000000000"]);

    recpt = await ContractTool.CallState(portMarketPorxy, "removeLiquidity", [pairAddr, liquidity, 0, 0, testtool.addr0, 10000000000]);
    
    r0 = await ContractTool.CallView(PortMarketPairPorxy, "reserve0", []);
    r1 = await ContractTool.CallView(PortMarketPairPorxy, "reserve1", []);
    liquidity = await ContractTool.CallView(PortMarketPairPorxy, "balanceOf", [testtool.addr0]);
    
    logtools.logcyan(`after burn r0=${r0}, r1=${r1}, liquidity=${liquidity}`);
}