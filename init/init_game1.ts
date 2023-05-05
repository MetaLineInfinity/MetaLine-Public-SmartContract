import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

import { AddrTool } from "../utils/util_addrtool";

export class Init_Game1 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Game1");
        let addrtool = await AddrTool.Init(hre);
//======init WarrantIssuer
        var WarrantIssuer = ContractInfo.getContract("WarrantIssuer");
        var WarrantNFT = ContractInfo.getContract("WarrantNFT");
        // //addChargeToken   string memory tokenName, 
        // address tokenAddr, 
        // uint256 maximumUSDPrice, 
        // uint256 minimumUSDPrice
        await ContractTool.CallState(WarrantIssuer, "setTPOracleAddr", ["addr:MockTPO"]);

        await ContractTool.CallState(WarrantIssuer, "init", ["addr:WarrantNFT"]);

        //grant WarrantNFT's MINTER_ROLE => WarrantIssuer
        let MINTER_ROLE = await ContractTool.CallView(WarrantNFT, "MINTER_ROLE", []);
        await ContractTool.CallState(WarrantNFT, "grantRole", [MINTER_ROLE,"addr:WarrantIssuer"]);
        let DATA_ROLE = await ContractTool.CallView(WarrantNFT, "DATA_ROLE", []);
        await ContractTool.CallState(WarrantNFT, "grantRole", [DATA_ROLE,"addr:WarrantIssuer"]);

//======init Shipyard
        let Shipyard  = ContractInfo.getContract("Shipyard");
        let ShipNFT =ContractInfo.getContract("ShipNFT");
        await  ContractTool.CallState(Shipyard, "setTPOracleAddr", ["addr:MockTPO"]);

        await ContractTool.CallState(Shipyard, "init", ["addr:WarrantNFT","addr:ShipNFT"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [MINTER_ROLE,"addr:Shipyard"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [DATA_ROLE,"addr:Shipyard"]);
        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Game1");
        let addrtool = await AddrTool.Init(hre);
    
//======config WarrantIssuer
        var WarrantIssuer = ContractInfo.getContract("WarrantIssuer");

        await ContractTool.CallState(WarrantIssuer, "setReceiveIncomeAddr", [addrtool.addr1]);
        await ContractTool.CallState(WarrantIssuer, "addChargeToken", ["MTT","addr:MTT","99000000000000000000","1000000000000000000"]);
        await ContractTool.CallState(WarrantIssuer, "setWarrantPrice", [1,"1000000000000000000"]);
        //upgrade storehouseLv in Warrant
        await ContractTool.CallState(WarrantIssuer, "setWarrantUpgradePrice", [1,1,1,"1000000000000000000"]);


//======config Shipyard
        let Shipyard  = ContractInfo.getContract("Shipyard");
        await ContractTool.CallState(Shipyard, "setReceiveIncomeAddr", [addrtool.addr1]);
        await ContractTool.CallState(Shipyard, "addChargeToken", ["MTT","addr:MTT","99000000000000000000","1000000000000000000"]);

        //uint24 shipID = (uint24(shipType)<<16 | shipTypeID);
        let shipid = 1<<16|1;
        let shipid2 = 2<<16|2;
        await ContractTool.CallState(Shipyard, "setBuildableShips", [1,0,[shipid,shipid2]]);
        await ContractTool.CallState(Shipyard, "setUpgradeConf", [1,1,1,["1000000000000000000",5,1,1]]);
        
        return true;
    }
}     
