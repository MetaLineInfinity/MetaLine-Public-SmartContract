
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';


describe("mtt Test", function () {
    before(inittest);
    //it("should mint succ", mint);
    it("should transfer batch succ", transfer);
    // it("should pause batch succ", pause);
});


var testtool: TestTool;

import * as hre from "hardhat";
import { assert } from "chai";
var MTT: Contract;
async function inittest() {
    testtool = await TestTool.Init();
    MTT = ContractInfo.getContract("MTT");
    ContractTool.PassBlock(hre, 1000);
}

//already mintall to admin on constructor of CappedERC20
// async function mint() {
    
//     logtools.log("--mint all");
//     let signerAddr = await MTT.signer.getAddress();
//     await ContractTool.CallState(MTT, "mint", [signerAddr, "300000000000000000000000000"]);

// }
async function transfer() {
    
    logtools.log("--transfer");
    await ContractTool.CallState(MTT, "transfer", [testtool.addr1, "1000000000000000000"]);
}
// async function pause() {

//     logtools.log("--pause");
//     await ContractTool.CallState(MTT, "pause", []);

//     let tstate=0;
//     try
//     {
//         logtools.log("--transfer when paused");
//         await ContractTool.CallState(MTT, "transfer", [testtool.addr1, "1000000000000000000"]);
//         tstate=1;
//     }
//     catch
//     {
//         tstate=2;
//     }

//     assert(tstate==2,"transfer should fail.");

//     logtools.log("--unpause");
//     await ContractTool.CallState(MTT, "unpause", []);
    
//     logtools.log("--transfer after unpaused");
//     await ContractTool.CallState(MTT, "transfer", [testtool.addr1, "1000000000000000000"]);

// }
