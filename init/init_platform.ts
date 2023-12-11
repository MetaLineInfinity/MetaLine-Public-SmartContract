
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";


import { Billing_config } from "./config_Billing";
import { PlatOnOffChainBridge_config } from "./config_PlatOnOffChainBridge";
import { ESportPool_V2_config } from "./config_ESportPool_V2";
import { TokenPrices_config_v2 } from "./config_TokenPrices_v2";

export class Init_Platform {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Platform");
        
//======init platform
        const Billing = ContractInfo.getContract("Billing");
        const PlatOnOffChainBridge = ContractInfo.getContract("PlatOnOffChainBridge");
        const ESportPool_V2 = ContractInfo.getContract("ESportPool_V2");
        const MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");
        const UniversalNFT = ContractInfo.getContract("UniversalNFT");

        let MINTER_ROLE = await ContractTool.CallView(MysteryBox1155, "MINTER_ROLE", []);

        // Billing
        // --TPO
        await ContractTool.CallState(Billing, "setTPOracleAddr", ["addr:TokenPrices"]);

        // PlatOnOffChainBridge
        await ContractTool.CallState(PlatOnOffChainBridge, "init", ["addr:UniversalNFT", "addr:MysteryBox1155"]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, "addr:PlatOnOffChainBridge"]);
        await ContractTool.CallState(UniversalNFT, "grantRole", [MINTER_ROLE, "addr:PlatOnOffChainBridge"]);

        // ESportPool_V2
        // --TPO
        await ContractTool.CallState(ESportPool_V2, "setTPOracleAddr", ["addr:TokenPrices"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_Platform");

        const Billing = ContractInfo.getContract("Billing");
        const PlatOnOffChainBridge = ContractInfo.getContract("PlatOnOffChainBridge");
        const ESportPool_V2 = ContractInfo.getContract("ESportPool_V2");
        const TokenPrices = ContractInfo.getContract("TokenPrices");

        let define_configs: any = [];

        // TokenPrices -- MTTGold
        const TokenPricesConfig = {
            contract: TokenPrices,
            name: "TokenPrices",
            configs: TokenPrices_config_v2,
        };
        define_configs.push(TokenPricesConfig);

        // Billing
        const BillingConfig = {
            contract: Billing,
            name: "Billing",
            configs: Billing_config,
        };
        define_configs.push(BillingConfig);
        
        // PlatOnOffChainBridge
        const PlatOnOffChainBridgeConfig = {
            contract: PlatOnOffChainBridge,
            name: "PlatOnOffChainBridge",
            configs: PlatOnOffChainBridge_config,
        };
        define_configs.push(PlatOnOffChainBridgeConfig);

        // ESportPool_V2
        const ESportPool_V2Config = {
            contract: ESportPool_V2,
            name: "ESportPool_V2",
            configs: ESportPool_V2_config,
        };
        define_configs.push(ESportPool_V2Config);

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
