
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";


import { Billing_config } from "./config_Billing";
import { PlatOnOffChainBridge_config } from "./config_PlatOnOffChainBridge";
import { ESportPool_config } from "./config_ESportPool";
import { TokenPrices_config_v2 } from "./config_TokenPrices_v2";

export class Init_ESPoolV2 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_ESPoolV2");
        
//======init espool v2

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_ESPoolV2");

        return true;
    }
}     
