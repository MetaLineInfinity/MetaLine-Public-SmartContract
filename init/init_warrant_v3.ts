import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

import { AddrTool } from "../utils/util_addrtool";

export class Init_WarrantV3 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_WarrantV3");
        
//======init warrant v3

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_WarrantV3");
        return true;
    }
}     
