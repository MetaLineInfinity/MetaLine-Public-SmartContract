
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";


import { GuildConfig_config } from "./config_GuildConfig";
import { GuildFactory_config } from "./config_GuildFactory";

export class Init_Guild {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Guild");

        
        const GuildFactory = ContractInfo.getContract("GuildFactory");
        const GuildConfig = ContractInfo.getContract("GuildConfig");

        // GuildFactory
        await ContractTool.CallState(GuildFactory, "setOp", ["addr:operater_address"]);
        await ContractTool.CallState(GuildFactory, "setGuildConfig", ["addr:GuildConfig"]);
        await ContractTool.CallState(GuildFactory, "setTPOracleAddr", ["addr:TokenPrices"]);
        await ContractTool.CallState(GuildFactory, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);

        // GuildConfig
        await ContractTool.CallState(GuildConfig, "setCodec", ["addr:GuildCodec"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_Guild");

        const GuildFactory = ContractInfo.getContract("GuildFactory");
        const GuildConfig = ContractInfo.getContract("GuildConfig");

        let define_configs: any = [];

        // GuildFactory
        const GuildFactoryConfig = {
            contract: GuildFactory,
            name: "GuildFactory",
            configs: GuildFactory_config,
        };
        define_configs.push(GuildFactoryConfig);

        // GuildConfig
        const GuildConfigConfig = {
            contract: GuildConfig,
            name: "GuildConfig",
            configs: GuildConfig_config,
        };
        define_configs.push(GuildConfigConfig);

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
