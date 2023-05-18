
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';

//gen5
describe("port market Test", function () {
    before(inittest);
    it("should create market succ", createMarket);
    it("should create market pair succ", createMarketPair);
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

    let recpt = await ContractTool.CallState(PortMarketFactory, "createPortMarket", [1]);
    let event = ContractTool.GetEvent(recpt, "PortMarketCreated");
    logtools.loggreen("create port market=" + event);
    let pmAddr = event[1];
    
    // create succ
    logtools.logcyan("port 1 market addr=" + pmAddr);

    portMarketPorxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarket", pmAddr);

    logtools.loggreen("test succ");
}


async function createMarketPair() {

    let recpt = await ContractTool.CallState(portMarketPorxy, "createSwapPair", [MTTGold.address, 1001]);
    let event = ContractTool.GetEvent(recpt, "Pair_Created");
    logtools.loggreen("create swap pair=" + event);
    let pairAddr = event[3];
    
    // create succ
    logtools.logcyan("pair addr=" + pairAddr);

    PortMarketPairPorxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarketPair", pairAddr);

    logtools.loggreen("test succ");
}