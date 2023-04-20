
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';


describe("random Test", function () {
    before(inittest);
    it("should random succ", testRandom);
});


var testtool: TestTool;

import * as hre from "hardhat";
import { assert } from "chai";
var Random: Contract;
async function inittest() {
    testtool = await TestTool.Init();
    Random = ContractInfo.getContract("Random");
    ContractTool.PassBlock(hre, 1000);
}

async function testRandom() {
    
    logtools.log("--seed random");
    for(let i=0; i< 10; ++i){
        let reqrecp = await ContractTool.CallState(Random, "seedRand", [Date.now()]);
    }

    let roundv = 0;
    let r = Date.now();
    for(let i=0; i< 1000; ++i){
        let resultx = await ContractTool.CallView(Random, "nextRand", [i*2, r]);
        let resulty = await ContractTool.CallView(Random, "nextRand", [i*2+1, resultx]);
        r = resulty;

        resultx = (Number(resultx)%65536) / 65535.0 * 2.0 - 1.0;
        resulty = (Number(resulty)%65536) / 65535.0 * 2.0 - 1.0;
        if((resultx*resultx)+(resulty+resulty) < 1){
            roundv++;
        }

        if((i%100==0&&i>0)){
            let mathv = roundv / i*4.0;
            console.log("mathv="+mathv);
        }
    }
}
