import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

import { AddrTool } from "../utils/util_addrtool";
import { WarrantIssuer_V2_config } from "./config_WarrantIssuer_V2";
import { AssetMinter_V2_config } from "./config_AssetMinter_V2";
import { OffOnChainBridge_v2_config } from "./config_OffOnChainBridge_v2";

export class Init_WarrantV2 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_WarrantV2");
        
//======init warrant v2
        
        const WarrantIssuer_V2 = ContractInfo.getContract("WarrantIssuer_V2");
        const AssetMinter_V2  = ContractInfo.getContract("AssetMinter_V2");
        
        const WarrantNFT = ContractInfo.getContract("WarrantNFT");
        const ShipNFT  = ContractInfo.getContract("ShipNFT");
        const HeroNFT  = ContractInfo.getContract("HeroNFT");

        const receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");

        let MINTER_ROLE = await ContractTool.CallView(WarrantNFT, "MINTER_ROLE", []);
        let DATA_ROLE = await ContractTool.CallView(WarrantNFT, "DATA_ROLE", []);

        
        //======init WarrantIssuer_V2
        //--income
        await ContractTool.CallState(WarrantIssuer_V2, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
        logtools.loggreen(`WarrantIssuer set income receiver to addr:${receive_mb_income_addr}`);
        // --TPO
        await ContractTool.CallState(WarrantIssuer_V2, "setTPOracleAddr", ["addr:TokenPrices"]);
        // --init
        await ContractTool.CallState(WarrantIssuer_V2, "init", ["addr:WarrantNFT"]);
        // --grantRole
        await ContractTool.CallState(WarrantNFT, "grantRole", [MINTER_ROLE, "addr:WarrantIssuer_V2"]);
        await ContractTool.CallState(WarrantNFT, "grantRole", [DATA_ROLE, "addr:WarrantIssuer_V2"]);
        // -- extendNftData
        await ContractTool.CallState(WarrantNFT, "extendNftData", ["ext1"]);

        //======init AssetMinter_V2
        await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE,"addr:AssetMinter_V2"]);
        await ContractTool.CallState(ShipNFT, "grantRole", [MINTER_ROLE,"addr:AssetMinter_V2"]);
        await ContractTool.CallState(WarrantNFT, "grantRole", [MINTER_ROLE,"addr:AssetMinter_V2"]);

        await ContractTool.CallState(AssetMinter_V2, "grantRole", [MINTER_ROLE,"addr:operater_address"]);
        await ContractTool.CallState(WarrantIssuer_V2, "grantRole", [MINTER_ROLE,"addr:AssetMinter_V2"]);
        await ContractTool.CallState(AssetMinter_V2, "init", ["addr:HeroNFT","addr:ShipNFT","addr:WarrantIssuer_V2"]);


        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_WarrantV2");

        const WarrantIssuer_V2 = ContractInfo.getContract("WarrantIssuer_V2");
        const AssetMinter_V2 = ContractInfo.getContract("AssetMinter_V2");
        const OffOnChainBridge = ContractInfo.getContract("OffOnChainBridge");

        let define_configs: any = [];

        // WarrantIssuer_V2
        const WarrantIssuer_V2Config = {
            contract: WarrantIssuer_V2,
            name: "WarrantIssuer_V2",
            configs: WarrantIssuer_V2_config,
        };
        define_configs.push(WarrantIssuer_V2Config);

        // AssetMinter_V2
        const AssetMinter_V2Config = {
            contract: AssetMinter_V2,
            name: "AssetMinter_V2",
            configs: AssetMinter_V2_config,
        };
        define_configs.push(AssetMinter_V2Config);

        // OffOnChainBridge
        const OffOnChainBridge_v2Config = {
            contract: OffOnChainBridge,
            name: "OffOnChainBridge",
            configs: OffOnChainBridge_v2_config,
        };
        define_configs.push(OffOnChainBridge_v2Config);

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
