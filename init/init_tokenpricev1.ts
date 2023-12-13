
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";


import { Billing_config } from "./config_Billing";
import { PlatOnOffChainBridge_config } from "./config_PlatOnOffChainBridge";
import { ESportPool_V2_config } from "./config_ESportPool_V2";
import { TokenPrices_config } from "./config_TokenPrices";

export class Init_TokenPriceV1 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_TokenPriceV1");
        
//======init platform
        const WarrantIssuer_V3 = ContractInfo.getContract("WarrantIssuer_V3");
        const Shipyard = ContractInfo.getContract("Shipyard");
        const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");

        // set all tpo
        await ContractTool.CallState(WarrantIssuer_V3, "setTPOracleAddr", ["addr:TokenPrices_V1"]);
        await ContractTool.CallState(Shipyard, "setTPOracleAddr", ["addr:TokenPrices_V1"]);
        await ContractTool.CallState(HeroPetTrain, "setTPOracleAddr", ["addr:TokenPrices_V1"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_Platform");

        const TokenPrices_V1 = ContractInfo.getContract("TokenPrices_V1");

        let define_configs: any = [];

        // TokenPrices
        const TokenPricesConfig = {
            contract: TokenPrices_V1,
            name: "TokenPrices_V1",
            configs: TokenPrices_config,
        };
        define_configs.push(TokenPricesConfig);

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
