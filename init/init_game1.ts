import { config } from "chai";
import { BigNumber } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { AddrTool } from "../utils/util_addrtool";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { AssetMinter_V2_config } from "./config_AssetMinter_V2";
import { DirectMysteryBox_config } from "./config_DirectMysteryBox";
import { HeroNFTMysteryBoxRandSource_config } from "./config_HeroNFTMysteryBoxRandSource";
import { HeroPetNFTMysteryBoxRandSource_config } from "./config_HeroPetNFTMysteryBoxRandSource";
import { HeroPetTrain_config } from "./config_HeroPetTrain";
import { OffOnChainBridge_config } from "./config_OffOnChainBridge";
import { Shipyard_config } from "./config_Shipyard";
import { TokenPrices_config } from "./config_TokenPrices";
import { WarrantIssuer_V3_config } from "./config_WarrantIssuer_V3";
import * as InitConfig from "./init_config";

export class Init_Game1 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        let addrtool = await AddrTool.Init(hre);
        logtools.logblue("==Init_Game1");

        const HeroNFT = ContractInfo.getContract("HeroNFT");
        const WarrantNFT = ContractInfo.getContract("WarrantNFT");
        const ShipNFT = ContractInfo.getContract("ShipNFT");
        const MTTGold = ContractInfo.getContract("MTTGold");

        const WarrantIssuer_V3 = ContractInfo.getContract("WarrantIssuer_V3");
        const GameService = ContractInfo.getContract("GameService");
        const Shipyard = ContractInfo.getContract("Shipyard");
        const DirectMysteryBox = ContractInfo.getContract("DirectMysteryBox");
        const Random = ContractInfo.getContract("Random");
        const HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        const OffOnChainBridge = ContractInfo.getContract("OffOnChainBridge");
        const AssetMinter_V2 = ContractInfo.getContract("AssetMinter_V2");
        const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");

        const MINTER_ROLE = await ContractTool.CallView(WarrantNFT, "MINTER_ROLE", []);
        const DATA_ROLE = await ContractTool.CallView(WarrantNFT, "DATA_ROLE", []);
        const FREEZE_ROLE = await ContractTool.CallView(WarrantNFT, "FREEZE_ROLE", []);
        const ORACLE_ROLE = await ContractTool.CallView(Random, "ORACLE_ROLE", []);
        const RAND_ROLE = await ContractTool.CallView(DirectMysteryBox, "RAND_ROLE", []);
        const SERVICE_ROLE = await ContractTool.CallView(GameService, "SERVICE_ROLE", []);

        const oracle_rand_fee_addr = ContractTool.GetAddrInValues("oracle_rand_fee_addr");
        const receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");

        // WarrantIssuer_V3
        {
            //--income
            await ContractTool.CallState(WarrantIssuer_V3, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
            logtools.loggreen(`WarrantIssuer set income receiver to addr:${receive_mb_income_addr}`);
            // --TPO
            await ContractTool.CallState(WarrantIssuer_V3, "setTPOracleAddr", ["addr:TokenPrices"]);
            // --init
            await ContractTool.CallState(WarrantIssuer_V3, "init", ["addr:WarrantNFT"]);
            // --grantRole
            await ContractTool.CallState(WarrantNFT, "grantRole", [MINTER_ROLE, "addr:WarrantIssuer_V3"]);
            await ContractTool.CallState(WarrantNFT, "grantRole", [DATA_ROLE, "addr:WarrantIssuer_V3"]);
            // -- extendNftData
            await ContractTool.CallState(WarrantNFT, "extendNftData", ["ext1"]);
        }

        // GameService
        {
            // --init
            await ContractTool.CallState(GameService, "init", [
                "addr:HeroNFT",
                "addr:ShipNFT",
                "addr:WarrantNFT",
                InitConfig.eth_addr,
                "addr:MTTGold",
            ]);
            // --grantRole
            await ContractTool.CallState(WarrantNFT, "grantRole", [FREEZE_ROLE, "addr:GameService"]);
            await ContractTool.CallState(ShipNFT, "grantRole", [FREEZE_ROLE, "addr:GameService"]);
            await ContractTool.CallState(ShipNFT, "grantRole", [DATA_ROLE, "addr:GameService"]);
            await ContractTool.CallState(HeroNFT, "grantRole", [FREEZE_ROLE, "addr:GameService"]);
            await ContractTool.CallState(GameService, "grantRole", [SERVICE_ROLE, "addr:operater_address"]);
        }

        // Shipyard
        {
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
            await ContractTool.CallState(ShipNFT, "setAttrSource", ["addr:NFTAttrSource_V2"]);
            await ContractTool.CallState(Shipyard, "grantRole", [MINTER_ROLE, "addr:operater_address"]);
        }

        // DirectMysteryBox
        {
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
        }

        // HeroNFTMysteryBox

        // OffOnChainBridge
        {
            await ContractTool.CallState(OffOnChainBridge, "init", ["addr:WarrantNFT", InitConfig.eth_addr, "addr:MTTGold"]);
            await ContractTool.CallState(OffOnChainBridge, "grantRole", [MINTER_ROLE, "addr:operater_address"]);
        }

        // AssetMinter_V2
        {
            await ContractTool.CallState(AssetMinter_V2, "init", ["addr:HeroNFT", "addr:ShipNFT", "addr:WarrantIssuer_V3"]);
            await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:AssetMinter_V2"]);
            await ContractTool.CallState(ShipNFT, "grantRole", [MINTER_ROLE, "addr:AssetMinter_V2"]);
            await ContractTool.CallState(WarrantNFT, "grantRole", [MINTER_ROLE, "addr:AssetMinter_V2"]);
            await ContractTool.CallState(WarrantIssuer_V3, "grantRole", [MINTER_ROLE, "addr:AssetMinter_V2"]);
            await ContractTool.CallState(AssetMinter_V2, "grantRole", [MINTER_ROLE, "addr:operater_address"]);
        }

        // HeroPetTrain
        {
            // --income
            await ContractTool.CallState(HeroPetTrain, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
            logtools.loggreen(`HeroPetTrain set income receiver to addr:${receive_mb_income_addr}`);
            // --TPO
            await ContractTool.CallState(HeroPetTrain, "setTPOracleAddr", ["addr:TokenPrices"]);
            // --init
            await ContractTool.CallState(HeroPetTrain, "init", ["addr:WarrantNFT", "addr:HeroNFT", "addr:MTTGold"]);
            // --grantRole
            await ContractTool.CallState(HeroNFT, "grantRole", [DATA_ROLE, "addr:HeroPetTrain"]);
        }

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        const TokenPrices = ContractInfo.getContract("TokenPrices");
        const WarrantIssuer_V3 = ContractInfo.getContract("WarrantIssuer_V3");
        const GameService = ContractInfo.getContract("GameService");
        const Shipyard = ContractInfo.getContract("Shipyard");
        const DirectMysteryBox = ContractInfo.getContract("DirectMysteryBox");
        const OffOnChainBridge = ContractInfo.getContract("OffOnChainBridge");
        const AssetMinter_V2 = ContractInfo.getContract("AssetMinter_V2");
        const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");

        let define_configs: any = [];

        // TokenPrices
        const TokenPricesConfig = {
            contract: TokenPrices,
            name: "TokenPrices",
            configs: TokenPrices_config,
        };
        define_configs.push(TokenPricesConfig);

        // WarrantIssuer_V3
        const WarrantIssuer_V3Config = {
            contract: WarrantIssuer_V3,
            name: "WarrantIssuer_V3",
            configs: WarrantIssuer_V3_config,
        };
        define_configs.push(WarrantIssuer_V3Config);

        // Shipyard
        const ShipyardConfig = {
            contract: Shipyard,
            name: "Shipyard",
            configs: Shipyard_config,
        };
        define_configs.push(ShipyardConfig);

        // DirectMysteryBox
        const DirectMysteryBoxConfig = {
            contract: DirectMysteryBox,
            name: "DirectMysteryBox",
            configs: DirectMysteryBox_config,
        };
        define_configs.push(DirectMysteryBoxConfig);

        // HeroNFTMysteryBox

        // OffOnChainBridge
        const OffOnChainBridgeConfig = {
            contract: OffOnChainBridge,
            name: "OffOnChainBridge",
            configs: OffOnChainBridge_config,
        };
        define_configs.push(OffOnChainBridgeConfig);

        // AssetMinter_V2
        const AssetMinter_V2Config = {
            contract: AssetMinter_V2,
            name: "AssetMinter_V2",
            configs: AssetMinter_V2_config,
        };
        define_configs.push(AssetMinter_V2Config);

        // HeroPetTrain
        const HeroPetTrainConfig = {
            contract: HeroPetTrain,
            name: "HeroPetTrain",
            configs: HeroPetTrain_config,
        };
        define_configs.push(HeroPetTrainConfig);



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
