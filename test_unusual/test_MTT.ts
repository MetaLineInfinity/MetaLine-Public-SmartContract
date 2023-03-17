
import { Contract, BigNumber } from "ethers";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';


describe("mystery box Test", function () {
    before(inittest);
    it("should mint succ", mint);
    it("should transfer batch succ", transfer);
    it("should pause batch succ", pause);
});


var testtool: TestTool;

import * as hre from "hardhat";
var MTT: Contract;
async function inittest() {
    testtool = await TestTool.Init();
    MTT = ContractInfo.getContract("MTT");
    ContractTool.PassBlock(hre, 1000);
}

async function mint() {
    
    logtools.log("--mint all");
    let signerAddr = await MTT.signer.getAddress();
    await ContractTool.CallState(MTT, "mint", [signerAddr, "300000000000000000000000000"]);

}
async function transfer() {
    
    logtools.log("--transfer");
    await ContractTool.CallState(MTT, "transfer", [testtool.addr1, "1000000000000000000"]);
}
async function pause() {

    logtools.log("--pause");
    await ContractTool.CallState(MTT, "pause", []);

    logtools.log("--transfer when paused");
    await ContractTool.CallState(MTT, "transfer", [testtool.addr1, "1000000000000000000"]);
    
    logtools.log("--unpause");
    await ContractTool.CallState(MTT, "unpause", []);
    
    logtools.log("--transfer after unpaused");
    await ContractTool.CallState(MTT, "transfer", [testtool.addr1, "1000000000000000000"]);

}
