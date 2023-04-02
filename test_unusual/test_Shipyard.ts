
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';
import * as hre from "hardhat";


describe("Shipyard Test", function () {
    before(inittest);
    it("should mint_MTTWarrant succ", test_mint_MTTWarrant);
    it("should mint_Ship succ", test_mint_Ship);
    //it("should upgrade_MTTWarrant succ", test_upgrade_MTTWarrant);
});


var testtool: TestTool;


var MTT: Contract;
var Shipyard:Contract
var ShipNFT :Contract
var WarrantIssuer:Contract
var WarrantNFT :Contract
async function inittest() {

    testtool = await TestTool.Init();
    MTT = ContractInfo.getContract("MTT");
    Shipyard =ContractInfo.getContract("Shipyard");
    ShipNFT =ContractInfo.getContract("ShipNFT");
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
  
    // WarrantNFT.once("WarrantNFTMint",(to,id,data)=>
    // {
  
    //     warrid = id;
    //     logtools.loggreen("Warrant id = "+warrid);
    // });

    let rc= await ContractTool.CallState(WarrantIssuer, "mint_MTTWarrant", [portID, usdPrice,tokenName]);
    //force to get this, but i do not now how.
    //transfer _mit mint,so 0 1 2=2, why id at index 3?
    let ev =(rc.events as any)[2]["topics"][3];
    warrid = BigNumber.from(ev);
    logtools.loggreen("warrid="+warrid);
    // await ContractTool.PassBlockOne(hre);
    // while(warrid<0)
    // {
    //     let delay = 1000;
    //     await new Promise(res => setTimeout(() => res(null), delay));
    // }

}

var shipid;
async function test_mint_Ship() {
    
    logtools.log("--test_mint_Ship");

    //apport mtt to WarrantIssuer
    await ContractTool.CallState(MTT,"approve",["addr:WarrantIssuer","1000000000000000000"]);

    //mint_MTTWarrant
    let portID =1;
    let  usdPrice ="1000000000000000000";
    let  tokenName="MTT";

    //mint //gen two events  ,can not get event direct.
  
    shipid=-1;
    // ShipNFT.removeAllListeners();
    // ShipNFT.once("ShipNFTMint",(to,id,data)=>
    // {
  
    //     shipid = id;
    //     logtools.loggreen("Ship id = "+shipid);
    // });
 
    let rc= await ContractTool.CallState(Shipyard, "mint_Ship", [testtool.addr0,1,1,1,1,1,warrid]);
    //var ev =ContractTool.GetEvent(rc,"ShipNFTMint");
     //force to get this, but i do not now how.
     
     let ev =(rc.events as any)[1]["topics"][2];
     shipid = BigNumber.from(ev);
     logtools.loggreen("shipid="+warrid);


    // await ContractTool.PassBlockOne(hre);
    // while(shipid<0)
    //  {
    //      let delay = 1000;
    //      await new Promise(res => setTimeout(() => res(null), delay));
    //  }
    //logtools.log("rc="+JSON.stringify(rc));

    // //let ev2=ContractTool.GetEvent(rc,"WarrantNFTMint");//two events  
    // logtools.loggreen("Warrant id =  "+ JSON.stringify(ev));

    // warrid = ev[1];
    // logtools.loggreen("Warrant id = "+warrid);
}
// async function test_upgrade_MTTWarrant() {
    
//     logtools.log("--transfer");

//     //apport mtt to WarrantIssuer
//     await ContractTool.CallState(MTT,"approve",["addr:WarrantIssuer","1000000000000000000"]);

//     {
//         let data= await ContractTool.CallView(WarrantNFT,"getNftData",[warrid]);
//         let level =data[2];
//         logtools.loggreen("curlevel="+level);
//     }
//     //        //upgrade storehouseLv in Warrant
//     let portID =1;
//     let  usdPrice ="1000000000000000000";
//     let  tokenName="MTT";


//     await ContractTool.CallState(WarrantIssuer, "upgrade_MTTWarrant", [warrid,1, usdPrice,tokenName]);

//     {
//         let data= await ContractTool.CallView(WarrantNFT,"getNftData",[warrid]);
//         let level =data[2];
//         logtools.loggreen("curlevel="+level);
//     }
// }
