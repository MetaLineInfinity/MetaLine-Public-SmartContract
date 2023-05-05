import { config } from "chai";
import { BigNumber } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { AddrTool } from "../utils/util_addrtool";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { DirectMysteryBox_config } from "./config_DirectMysteryBox";
import { Expedition_config } from "./config_Expedition";
import { HeroPetNFTMysteryBoxRandSource_config } from "./config_HeroNFTMysteryBoxRandSource";
import { HeroPetTrain_config } from "./config_HeroPetTrain";
import { NFTAttrSource_V1_config } from "./config_NFTAttrSource_V1";
import { OffOnChainBridge_config } from "./config_OffOnChainBridge";
import { Shipyard_config } from "./config_Shipyard";
import { TokenPrices_config } from "./config_TokenPrices";
import { WarrantIssuer_config } from "./config_WarrantIssuer";
import * as InitConfig from "./init_config";

export class Init_LglTest {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        let addrtool = await AddrTool.Init(hre);
        logtools.logblue("==Init_LglTest");

        const HeroNFT = ContractInfo.getContract("HeroNFT");
        const WarrantNFT = ContractInfo.getContract("WarrantNFT");
        const ShipNFT = ContractInfo.getContract("ShipNFT");
        const MTT = ContractInfo.getContract("MTT");
        const MTTGold = ContractInfo.getContract("MTTGold");

        const WarrantIssuer = ContractInfo.getContract("WarrantIssuer");
        const GameService = ContractInfo.getContract("GameService");
        const Shipyard = ContractInfo.getContract("Shipyard");
        const DirectMysteryBox = ContractInfo.getContract("DirectMysteryBox");
        const Random = ContractInfo.getContract("Random");
        const HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        const OffOnChainBridge = ContractInfo.getContract("OffOnChainBridge");
        // const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");
        // const Expedition = ContractInfo.getContract("Expedition");
        // const MTTMinePool = ContractInfo.getContract("MTTMinePool");

        const MINTER_ROLE = await ContractTool.CallView(WarrantNFT, "MINTER_ROLE", []);
        const DATA_ROLE = await ContractTool.CallView(WarrantNFT, "DATA_ROLE", []);
        const FREEZE_ROLE = await ContractTool.CallView(WarrantNFT, "FREEZE_ROLE", []);
        const ORACLE_ROLE = await ContractTool.CallView(Random, "ORACLE_ROLE", []);
        const RAND_ROLE = await ContractTool.CallView(DirectMysteryBox, "RAND_ROLE", []);
        const SERVICE_ROLE = await ContractTool.CallView(GameService, "SERVICE_ROLE", []);

        const oracle_rand_fee_addr = ContractTool.GetAddrInValues("oracle_rand_fee_addr");
        const receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");

        // WarrantIssuer
        // --income
        await ContractTool.CallState(WarrantIssuer, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
        logtools.loggreen(`WarrantIssuer set income receiver to addr:${receive_mb_income_addr}`);
        // --TPO
        await ContractTool.CallState(WarrantIssuer, "setTPOracleAddr", ["addr:TokenPrices"]);
        // --init
        await ContractTool.CallState(WarrantIssuer, "init", ["addr:WarrantNFT"]);
        // --grantRole
        await ContractTool.CallState(WarrantNFT, "grantRole", [MINTER_ROLE, "addr:WarrantIssuer"]);
        await ContractTool.CallState(WarrantNFT, "grantRole", [DATA_ROLE, "addr:WarrantIssuer"]);

        // GameService
        // --init
        await ContractTool.CallState(GameService, "init", ["addr:HeroNFT", "addr:ShipNFT", "addr:WarrantNFT", "addr:MTT", "addr:MTTGold"]);
        // --grantRole
        await ContractTool.CallState(WarrantNFT, "grantRole", [FREEZE_ROLE, "addr:GameService"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [FREEZE_ROLE, "addr:GameService"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [DATA_ROLE, "addr:GameService"]);
        await ContractTool.CallState(HeroNFT, "grantRole", [FREEZE_ROLE, "addr:GameService"]);
        await ContractTool.CallState(GameService, "grantRole", [SERVICE_ROLE, "addr:operater_address"]);

        // Shipyard
        // --income
        await ContractTool.CallState(Shipyard, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
        logtools.loggreen(`Shipyard set income receiver to addr:${receive_mb_income_addr}`);
        // --TPO
        await ContractTool.CallState(Shipyard, "setTPOracleAddr", ["addr:TokenPrices"]);
        // --init
        await ContractTool.CallState(Shipyard, "init", ["addr:WarrantNFT", "addr:ShipNFT"]);
        // --grantRole
        await ContractTool.CallState(ShipNFT, "grantRole", [MINTER_ROLE, "addr:Shipyard"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [DATA_ROLE, "addr:Shipyard"]);
        await ContractTool.CallState(ShipNFT, "setAttrSource", ["addr:NFTAttrSource_V1"]);
        await ContractTool.CallState(Shipyard, "grantRole", [MINTER_ROLE, "addr:operater_address"]);

        // DirectMysteryBox
        // --income
        await ContractTool.CallState(DirectMysteryBox, "setReceiveIncomeAddress", ["addr:receive_mb_income_addr"]);
        logtools.loggreen(`DirectMysteryBox set income receiver to addr:${receive_mb_income_addr}`);
        // --ExtraFee
        await ContractTool.CallState(DirectMysteryBox, "setMethodExtraFee", [1, InitConfig.oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set DirectMysteryBox oracle rand extra fee:${InitConfig.oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);
        // --ExtraFee10
        await ContractTool.CallState(DirectMysteryBox, "setMethodExtraFee", [
            2,
            InitConfig.batch10_oracle_rand_extra_fee,
            "addr:oracle_rand_fee_addr",
        ]);
        logtools.loggreen(
            `set DirectMysteryBox batch oracle rand extra fee:${InitConfig.batch10_oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`
        );
        // --grantRole
        await ContractTool.CallState(DirectMysteryBox, "grantRole", [RAND_ROLE, "addr:Random"]);
        await ContractTool.CallState(Random, "grantRole", [ORACLE_ROLE, "addr:operater_address"]);
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "grantRole", [MINTER_ROLE, "addr:DirectMysteryBox"]);

        // HeroNFTMysteryBox

        // OffOnChainBridge
        await ContractTool.CallState(OffOnChainBridge, "init", ["addr:WarrantNFT", "addr:MTT", "addr:MTTGold"]);
        await ContractTool.CallState(OffOnChainBridge, "grantRole", [MINTER_ROLE, "addr:operater_address"]);
        
        // // HeroPetTrain
        // // --income
        // await ContractTool.CallState(HeroPetTrain, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
        // logtools.loggreen(`HeroPetTrain set income receiver to addr:${receive_mb_income_addr}`);
        // // --TPO
        // await ContractTool.CallState(HeroPetTrain, "setTPOracleAddr", ["addr:TokenPrices"]);
        // // --init
        // await ContractTool.CallState(HeroPetTrain, "init", ["addr:WarrantNFT", "addr:HeroNFT", "addr:MTTGold"]);
        // // --grantRole
        // await ContractTool.CallState(HeroNFT, "grantRole", [DATA_ROLE, "addr:HeroPetTrain"]);

        // // Expedition
        // // --init
        // await ContractTool.CallState(Expedition, "init", [
        //     "addr:WarrantNFT",
        //     "addr:HeroNFT",
        //     "addr:ShipNFT",
        //     "addr:MTT",
        //     "addr:MTTGold",
        //     "addr:MTTMinePool",
        // ]);
        // // --grantRole
        // await ContractTool.CallState(MTTMinePool, "grantRole", [MINTER_ROLE, "addr:Expedition"]);

        return true;
    }

    static async init(): Promise<boolean> {
        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        const TokenPrices = ContractInfo.getContract("TokenPrices");
        const WarrantIssuer = ContractInfo.getContract("WarrantIssuer");
        const GameService = ContractInfo.getContract("GameService");
        const Shipyard = ContractInfo.getContract("Shipyard");
        const DirectMysteryBox = ContractInfo.getContract("DirectMysteryBox");
        const HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        const HeroPetNFTMysteryBoxRandSource = ContractInfo.getContract("HeroPetNFTMysteryBoxRandSource");
        const NFTAttrSource_V1 = ContractInfo.getContract("NFTAttrSource_V1");
        const OffOnChainBridge = ContractInfo.getContract("OffOnChainBridge");
        
        // const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");
        // const Expedition = ContractInfo.getContract("Expedition");

        let define_configs: any = [];

        // TokenPrices
        const TokenPricesConfig = {
            contract: TokenPrices,
            name: "TokenPrices",
            configs: TokenPrices_config,
        };
        define_configs.push(TokenPricesConfig);

        // WarrantIssuer
        const WarrantIssuerConfig = {
            contract: WarrantIssuer,
            name: "WarrantIssuer",
            configs: WarrantIssuer_config,
        };
        define_configs.push(WarrantIssuerConfig);

        // Shipyard
        const ShipyardConfig = {
            contract: Shipyard,
            name: "Shipyard",
            configs: Shipyard_config,
        };
        define_configs.push(ShipyardConfig);

        // HeroNFTMysteryBoxRandSource
        const HeroNFTMysteryBoxRandSourceConfig = {
            contract: HeroNFTMysteryBoxRandSource,
            name: "HeroNFTMysteryBoxRandSource",
            configs: HeroPetNFTMysteryBoxRandSource_config,
        };
        define_configs.push(HeroNFTMysteryBoxRandSourceConfig);

        // HeroPetNFTMysteryBoxRandSource
        const HeroPetNFTMysteryBoxRandSourceConfig = {
            contract: HeroPetNFTMysteryBoxRandSource,
            name: "HeroPetNFTMysteryBoxRandSource",
            configs: HeroPetNFTMysteryBoxRandSource_config,
        };
        define_configs.push(HeroPetNFTMysteryBoxRandSourceConfig);

        // DirectMysteryBox
        const DirectMysteryBoxConfig = {
            contract: DirectMysteryBox,
            name: "DirectMysteryBox",
            configs: DirectMysteryBox_config,
        };
        define_configs.push(DirectMysteryBoxConfig);

        // NFTAttrSource_V1
        const NFTAttrSource_V1Config = {
            contract: NFTAttrSource_V1,
            name: "NFTAttrSource_V1",
            configs: NFTAttrSource_V1_config,
        };
        define_configs.push(NFTAttrSource_V1Config);

        // HeroNFTMysteryBox

        // OffOnChainBridge
        const OffOnChainBridgeConfig = {
            contract: OffOnChainBridge,
            name: "OffOnChainBridge",
            configs: OffOnChainBridge_config,
        };
        define_configs.push(OffOnChainBridgeConfig);
        
        // // HeroPetTrain
        // const HeroPetTrainConfig = {
        //     contract: HeroPetTrain,
        //     name: "HeroPetTrain",
        //     configs: HeroPetTrain_config,
        // };
        // define_configs.push(HeroPetTrainConfig);

        // // Expedition
        // const ExpeditionConfig = {
        //     contract: Expedition,
        //     name: "Expedition",
        //     configs: Expedition_config,
        // };
        // define_configs.push(ExpeditionConfig);

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
