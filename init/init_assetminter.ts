import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

import { AddrTool } from "../utils/util_addrtool";

export class Init_AssetMinter {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_AssetMinter");

//======init asset minter
        let AssetMinter  = ContractInfo.getContract("AssetMinter");
        let ShipNFT  = ContractInfo.getContract("ShipNFT");
        let HeroNFT  = ContractInfo.getContract("HeroNFT");

        let MINTER_ROLE = await ContractTool.CallView(HeroNFT, "MINTER_ROLE", []);
        await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE,"addr:AssetMinter"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [MINTER_ROLE,"addr:AssetMinter"]);

        await ContractTool.CallState(AssetMinter, "grantRole", [MINTER_ROLE,"addr:operater_address"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_AssetMinter");

//======config asset minter
        let AssetMinter  = ContractInfo.getContract("AssetMinter");

        //function setPackage(uint32 packageId, uint32 totalCount, HeroNFTDataBase[] memory heros, ShipNFTData[] memory ships)

        // for Debug ...
        await ContractTool.CallState(AssetMinter, "setPackage", [1,10,[[0,1,1,1]], [[1,1,1,51,0,1,1]]]); 
        await ContractTool.CallState(AssetMinter, "setPackage", [2,10,[[0,1,1,1]], [[1,2,3,3,0,1,1]]]); 

        return true;
    }
}     
