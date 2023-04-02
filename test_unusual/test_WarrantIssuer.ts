
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';


describe("WarrantIssuer Test", function () {
    before(inittest);
    
    it("should mint_MTTWarrant succ", test_mint_MTTWarrant);
  
});


var testtool: TestTool;


var MTT: Contract;
var WarrantIssuer:Contract

async function inittest() {

    testtool = await TestTool.Init();
    MTT = ContractInfo.getContract("MTT");
    WarrantIssuer =ContractInfo.getContract("WarrantIssuer");

}

async function test_mint_MTTWarrant() {
    
    logtools.log("--transfer");
    
    //apport mtt to WarrantIssuer
    await ContractTool.CallState(MTT,"approve",["addr:WarrantIssuer","1000000000000000000"]);

    //mint_MTTWarrant
    let portID =1;
    let  usdPrice ="1000000000000000000";
    let  tokenName="MTT";
    await ContractTool.CallState(WarrantIssuer, "mint_MTTWarrant", [portID, usdPrice,tokenName]);
}
