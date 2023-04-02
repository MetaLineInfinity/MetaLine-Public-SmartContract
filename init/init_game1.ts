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

        return true;
    }
    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Game1");
        let addrtool = await AddrTool.Init(hre);
        var WarrantIssuer = ContractInfo.getContract("WarrantIssuer");


        await ContractTool.CallState(WarrantIssuer, "setReceiveIncomeAddr", [addrtool.addr1]);
        await ContractTool.CallState(WarrantIssuer, "addChargeToken", ["MTT","addr:MTT","99000000000000000000","1000000000000000000"]);
        await ContractTool.CallState(WarrantIssuer, "setWarrantPrice", [1,"1000000000000000000"]);

        //setWarrantUpgradePrice
        return true;
    }
}     
