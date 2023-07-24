
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";


import { ESportPool_V2_config } from "./config_ESportPool_V2";

export class Init_ESPoolV2 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_ESPoolV2");
        
//======init espool v2
        const ESportPool_V2 = ContractInfo.getContract("ESportPool_V2");

        // ESportPool
        // --TPO
        await ContractTool.CallState(ESportPool_V2, "setTPOracleAddr", ["addr:TokenPrices"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_ESPoolV2");

        const ESportPool_V2 = ContractInfo.getContract("ESportPool_V2");

        let define_configs: any = [];

        // ESportPool_V2
        const ESportPoolConfig = {
            contract: ESportPool_V2,
            name: "ESportPool_V2",
            configs: ESportPool_V2_config,
        };
        define_configs.push(ESportPoolConfig);

        // set config
        for (let i = 0; i < define_configs.length; i++) {
            const contract = define_configs[i].contract;
            const name = define_configs[i].name;
            for (var func in define_configs[i].configs) {
                const configs = define_configs[i].configs[func];
                for (let j = 0; j < configs.length; j++) {
                    await ContractTool.CallState(contract, func, configs[j]);
                    logtools.logblue("SET Contract:" + name + ", func:" + func + ", args:" + configs[j].toString());
                }
            }
        }

        return true;
    }
}     
