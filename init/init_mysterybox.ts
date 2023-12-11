import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { Contract, BigNumber } from "ethers/lib";
import * as InitConfig from "./init_config";
import { DailySign_config } from "./config_DailySign";
import { HeroNFTMysteryBoxRandSource_config } from "./config_HeroNFTMysteryBoxRandSource";
import { HeroPetNFTMysteryBoxRandSource_config } from "./config_HeroPetNFTMysteryBoxRandSource";

export class Init_MysteryBox {
    //gen5
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_MysteryBox");

        let Random = ContractInfo.getContract("Random");
        let HeroNFT = ContractInfo.getContract("HeroNFT");
        let HeroNFTCodec_V1 = ContractInfo.getContract("HeroNFTCodec_V1");
        let HeroNFTMysteryBox = ContractInfo.getContract("HeroNFTMysteryBox");
        let HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        let HeroPetNFTMysteryBoxRandSource = ContractInfo.getContract("HeroPetNFTMysteryBoxRandSource");
        const VMTT = ContractInfo.getContract("VMTT");
        let VMTTMinePool = ContractInfo.getContract("VMTTMinePool");

        let ORACLE_ROLE = await ContractTool.CallView(Random, "ORACLE_ROLE", []);
        let DATA_ROLE = await ContractTool.CallView(HeroNFT, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(HeroNFT, "MINTER_ROLE", []);
        let RAND_ROLE = await ContractTool.CallView(HeroNFTMysteryBox, "RAND_ROLE", []);

        // Random
        {
            logtools.loggreen("--init random contract");
            await ContractTool.CallState(Random, "grantRole", [ORACLE_ROLE, "addr:oracle_rand_fee_addr"]);
        }

        // HeroNFT
        {
            logtools.loggreen("--init hero nft contract");
            await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBoxRandSource"]);
            await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:HeroPetNFTMysteryBoxRandSource"]);
            await ContractTool.CallState(HeroNFT, "setCodec", ["addr:HeroNFTCodec_V1"]);
            await ContractTool.CallState(HeroNFT, "setAttrSource", ["addr:NFTAttrSource_V2"]);
        }

        // HeroNFTMysteryBox
        {
            logtools.loggreen("--init hero nft mystery box contract");

            await ContractTool.CallState(HeroNFTMysteryBox, "setMethodExtraFee", [1, InitConfig.oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
            await ContractTool.CallState(HeroNFTMysteryBox, "setMethodExtraFee", [
                2,
                InitConfig.batch10_oracle_rand_extra_fee,
                "addr:oracle_rand_fee_addr",
            ]);

            await ContractTool.CallState(HeroNFTMysteryBox, "setNftAddress", ["addr:MysteryBox1155"]);
            await ContractTool.CallState(HeroNFTMysteryBox, "setRandomSource", [1, "addr:HeroNFTMysteryBoxRandSource"]);
            await ContractTool.CallState(HeroNFTMysteryBox, "setRandomSource", [2, "addr:HeroPetNFTMysteryBoxRandSource"]);
            await ContractTool.CallState(HeroNFTMysteryBox, "grantRole", [RAND_ROLE, "addr:Random"]);
        }

        // VMTT
        {
            await ContractTool.CallState(VMTT, "addPoolAddr", ["addr:VMTTMinePool"]);
            await ContractTool.CallState(VMTT, "addPoolAddr", ["addr:DailySign"]);
        }

        // HeroNFTMysteryBoxRandSource
        {
            await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "setRandSource", ["addr:Random"]);
            await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBox"]);
            await ContractTool.CallState(VMTTMinePool, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBoxRandSource"]);
        }

        // HeroPetNFTMysteryBoxRandSource
        {
            await ContractTool.CallState(HeroPetNFTMysteryBoxRandSource, "setRandSource", ["addr:Random"]);
            await ContractTool.CallState(HeroPetNFTMysteryBoxRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBox"]);
            await ContractTool.CallState(VMTTMinePool, "grantRole", [MINTER_ROLE, "addr:HeroPetNFTMysteryBoxRandSource"]);
        }

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_MysteryBox");

        const HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        const HeroPetNFTMysteryBoxRandSource = ContractInfo.getContract("HeroPetNFTMysteryBoxRandSource");
        const DailySign = ContractInfo.getContract("DailySign");

        let define_configs: any = [];

        // HeroNFTMysteryBoxRandSource
        const HeroNFTMysteryBoxRandSourceConfig = {
            contract: HeroNFTMysteryBoxRandSource,
            name: "HeroNFTMysteryBoxRandSource",
            configs: HeroNFTMysteryBoxRandSource_config,
        };
        //define_configs.push(HeroNFTMysteryBoxRandSourceConfig);

        // HeroPetNFTMysteryBoxRandSource
        const HeroPetNFTMysteryBoxRandSourceConfig = {
            contract: HeroPetNFTMysteryBoxRandSource,
            name: "HeroPetNFTMysteryBoxRandSource",
            configs: HeroPetNFTMysteryBoxRandSource_config,
        };
        define_configs.push(HeroPetNFTMysteryBoxRandSourceConfig);

        // DailySign
        const DailySignConfig = {
            contract: DailySign,
            name: "DailySign",
            configs: DailySign_config,
        };
        //define_configs.push(DailySignConfig);

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
