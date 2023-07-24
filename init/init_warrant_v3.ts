
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";


import { WarrantIssuer_V3_config } from "./config_WarrantIssuer_V3";

export class Init_WarrantV3 {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_WarrantV3");
        
//======init warrant v3

        const WarrantIssuer_V3 = ContractInfo.getContract("WarrantIssuer_V3");
        const AssetMinter_V2  = ContractInfo.getContract("AssetMinter_V2");
        
        const WarrantNFT = ContractInfo.getContract("WarrantNFT");

        const receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");

        let MINTER_ROLE = await ContractTool.CallView(WarrantNFT, "MINTER_ROLE", []);
        let DATA_ROLE = await ContractTool.CallView(WarrantNFT, "DATA_ROLE", []);

        
        //======init WarrantIssuer_V3
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

        // -- AssetMinter_V2
        await ContractTool.CallState(WarrantIssuer_V3, "grantRole", [MINTER_ROLE,"addr:AssetMinter_V2"]);
        await ContractTool.CallState(AssetMinter_V2, "init", ["addr:HeroNFT","addr:ShipNFT","addr:WarrantIssuer_V3"]);

        const WarrantIssuer = ContractInfo.getContract("WarrantIssuer");
        const WarrantIssuer_V2 = ContractInfo.getContract("WarrantIssuer_V2");

        // pause old warrant issuer
        await ContractTool.CallState(WarrantIssuer, "pause", []);
        await ContractTool.CallState(WarrantIssuer_V2, "pause", []);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_WarrantV3");

        const WarrantIssuer_V3 = ContractInfo.getContract("WarrantIssuer_V3");

        let define_configs: any = [];

        // WarrantIssuer_V3
        const WarrantIssuer_V3Config = {
            contract: WarrantIssuer_V3,
            name: "WarrantIssuer_V3",
            configs: WarrantIssuer_V3_config,
        };
        define_configs.push(WarrantIssuer_V3Config);

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
