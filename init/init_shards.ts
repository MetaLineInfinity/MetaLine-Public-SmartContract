import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

import { AddrTool } from "../utils/util_addrtool";
import { HeroNFTMysteryShard_config } from "./config_HeroNFTMysteryShard";
import { HeroNFTMSCombiner_config } from "./config_HeroNFTMSCombiner";
import { HeroNFTMysteryShardRandSource_config } from "./config_HeroNFTMysteryShardRandSource";
import { HeroPetNFTMysteryShardRandSource_config } from "./config_HeroPetNFTMysteryShardRandSource";

export class Init_Shards {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Shards");
        
//======init shards

        const HeroNFTMysteryShard = ContractInfo.getContract("HeroNFTMysteryShard");
        const HeroNFTMSCombiner = ContractInfo.getContract("HeroNFTMSCombiner");
        const HeroNFTMysteryShardRandSource = ContractInfo.getContract("HeroNFTMysteryShardRandSource");
        const HeroPetNFTMysteryShardRandSource = ContractInfo.getContract("HeroPetNFTMysteryShardRandSource");
        const MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");
        const HeroNFT = ContractInfo.getContract("HeroNFT");


        let oracle_rand_fee_addr = ContractTool.GetAddrInValues("oracle_rand_fee_addr");
        let RAND_ROLE = await ContractTool.CallView(HeroNFTMysteryShard, "RAND_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(MysteryBox1155, "MINTER_ROLE", []);

        // HeroNFTMysteryShard
        logtools.loggreen("--init HeroNFTMysteryShard contract");
        // --- open fee
        await ContractTool.CallState(HeroNFTMysteryShard, "setMethodExtraFee", [1, InitConfig.oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set HeroNFTMysteryShard oracle rand extra fee:${InitConfig.oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);
        await ContractTool.CallState(HeroNFTMysteryShard, "setMethodExtraFee", [2, InitConfig.batch10_oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set HeroNFTMysteryShard batch oracle rand extra fee:${InitConfig.batch10_oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);
        // --- nft / fue addr
        await ContractTool.CallState(HeroNFTMysteryShard, "setNftAddress", ["addr:MysteryBox1155"]);
        await ContractTool.CallState(HeroNFTMysteryShard, "setFuelToken", ["addr:MTTGold"]);

        await ContractTool.CallState(HeroNFTMysteryShard,"setRandomSource",[1,"addr:HeroNFTMysteryShardRandSource"]);
        await ContractTool.CallState(HeroNFTMysteryShard,"setRandomSource",[2,"addr:HeroPetNFTMysteryShardRandSource"]);
        await ContractTool.CallState(HeroNFTMysteryShard, "grantRole", [RAND_ROLE, "addr:Random"]);

        // HeroNFTMSCombiner
        logtools.loggreen("--init HeroNFTMSCombiner contract");
        await ContractTool.CallState(HeroNFTMSCombiner, "setHeroNftAddress", ["addr:HeroNFT"]);
        await ContractTool.CallState(HeroNFTMSCombiner, "setMB1155Address", ["addr:MysteryBox1155"]);
        await ContractTool.CallState(HeroNFTMSCombiner, "setFuelToken", ["addr:MTTGold"]);
        await ContractTool.CallState(HeroNFTMSCombiner, "grantRole", [RAND_ROLE, "addr:Random"]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, "addr:HeroNFTMSCombiner"]);
        
        // HeroNFTMysteryShardRandSource
        logtools.loggreen("--init HeroNFTMysteryShardRandSource contract");
        await ContractTool.CallState(HeroNFTMysteryShardRandSource, "setRandSource",["addr:Random"]);
        await ContractTool.CallState(HeroNFTMysteryShardRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryShard"]);
        await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryShardRandSource"]);

        // HeroPetNFTMysteryShardRandSource
        logtools.loggreen("--init HeroPetNFTMysteryShardRandSource contract");
        await ContractTool.CallState(HeroPetNFTMysteryShardRandSource, "setRandSource",["addr:Random"]);
        await ContractTool.CallState(HeroPetNFTMysteryShardRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryShard"]);
        await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:HeroPetNFTMysteryShardRandSource"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_Shards");

        const HeroNFTMysteryShard = ContractInfo.getContract("HeroNFTMysteryShard");
        const HeroNFTMSCombiner = ContractInfo.getContract("HeroNFTMSCombiner");
        const HeroNFTMysteryShardRandSource = ContractInfo.getContract("HeroNFTMysteryShardRandSource");
        const HeroPetNFTMysteryShardRandSource = ContractInfo.getContract("HeroPetNFTMysteryShardRandSource");

        let define_configs: any = [];

        // HeroNFTMysteryShard
        const HeroNFTMysteryShardConfig = {
            contract: HeroNFTMysteryShard,
            name: "HeroNFTMysteryShard",
            configs: HeroNFTMysteryShard_config,
        };
        define_configs.push(HeroNFTMysteryShardConfig);

        // HeroNFTMSCombiner
        const HeroNFTMSCombinerConfig = {
            contract: HeroNFTMSCombiner,
            name: "HeroNFTMSCombiner",
            configs: HeroNFTMSCombiner_config,
        };
        define_configs.push(HeroNFTMSCombinerConfig);
        
        // HeroNFTMysteryShardRandSource
        const HeroNFTMysteryShardRandSourceConfig = {
            contract: HeroNFTMysteryShardRandSource,
            name: "HeroNFTMysteryShardRandSource",
            configs: HeroNFTMysteryShardRandSource_config,
        };
        define_configs.push(HeroNFTMysteryShardRandSourceConfig);

        // HeroPetNFTMysteryShardRandSource
        const HeroPetNFTMysteryShardRandSourceConfig = {
            contract: HeroPetNFTMysteryShardRandSource,
            name: "HeroPetNFTMysteryShardRandSource",
            configs: HeroPetNFTMysteryShardRandSource_config,
        };
        define_configs.push(HeroPetNFTMysteryShardRandSourceConfig);

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
