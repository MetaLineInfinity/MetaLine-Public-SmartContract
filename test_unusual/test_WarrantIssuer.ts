
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';
import * as hre from "hardhat";


describe("WarrantIssuer Test", function () {
    before(inittest);
    
    it("should mint_MTTWarrant succ", test_mint_MTTWarrant);
    it("should upgrade_MTTWarrant succ", test_upgrade_MTTWarrant);
});


var testtool: TestTool;


var MTT: Contract;
var WarrantIssuer:Contract
var WarrantNFT :Contract

async function inittest() {

    testtool = await TestTool.Init();
    MTT = ContractInfo.getContract("MTT");
    WarrantIssuer =ContractInfo.getContract("WarrantIssuer");
    WarrantNFT =ContractInfo.getContract("WarrantNFT");
}
var warrid;
async function test_mint_MTTWarrant() {
    
    logtools.log("--test_mint_MTTWarrant");

    //apport mtt to WarrantIssuer
    await ContractTool.CallState(MTT,"approve",["addr:WarrantIssuer","1000000000000000000"]);

    //mint_MTTWarrant
    let portID =1;
    let  usdPrice ="1000000000000000000";
    let  tokenName="MTT";

    //mint //gen two events  ,can not get event direct.
  
    warrid=-1;
    WarrantNFT.once("WarrantNFTMint",(to,id,data)=>
    {
  
        warrid = id;
        logtools.loggreen("Warrant id = "+warrid);

    });

    let rc= await ContractTool.CallState(WarrantIssuer, "mint_MTTWarrant", [portID, usdPrice,tokenName]);
    await ContractTool.PassBlockOne(hre);
    while(warrid<0)
    {
        let delay = 1000;
        await new Promise(res => setTimeout(() => res(null), delay));
    }
    //logtools.log("rc="+JSON.stringify(rc));

    // //let ev2=ContractTool.GetEvent(rc,"WarrantNFTMint");//two events  
    // logtools.loggreen("Warrant id =  "+ JSON.stringify(ev));

    // warrid = ev[1];
    // logtools.loggreen("Warrant id = "+warrid);
}
async function test_upgrade_MTTWarrant() {
    
    logtools.log("--test_upgrade_MTTWarrant");

    //apport mtt to WarrantIssuer
    await ContractTool.CallState(MTT,"approve",["addr:WarrantIssuer","1000000000000000000"]);

    {
        let data= await ContractTool.CallView(WarrantNFT,"getNftData",[warrid]);
        let level =data[2];
        logtools.loggreen("curlevel="+level);
    }
    //        //upgrade storehouseLv in Warrant
    let portID =1;
    let  usdPrice ="1000000000000000000";
    let  tokenName="MTT";


    await ContractTool.CallState(WarrantIssuer, "upgrade_MTTWarrant", [warrid,1, usdPrice,tokenName]);

    {
        let data= await ContractTool.CallView(WarrantNFT,"getNftData",[warrid]);
        let level =data[2];
        logtools.loggreen("curlevel="+level);
    }
}
