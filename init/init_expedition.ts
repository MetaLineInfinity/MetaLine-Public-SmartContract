
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { AddrTool } from "../utils/util_addrtool";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";

import { Expedition_config } from "./config_Expedition";

import { NFTAttrSource_V2_config } from "./config_NFTAttrSource_V2";
import { Shipyard_config_v3 } from "./config_Shipyard_v3";
import { eth_addr } from "./init_config";


export class Init_Expedition {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        let addrtool = await AddrTool.Init(hre);
        logtools.logblue("==Init_Expedition");


        const HeroNFT = ContractInfo.getContract("HeroNFT");
        const ShipNFT = ContractInfo.getContract("ShipNFT");

        const Expedition = ContractInfo.getContract("Expedition");
        const VMTTMinePool = ContractInfo.getContract("VMTTMinePool");
        const VeTokenPool = ContractInfo.getContract("VeTokenPool");
        const VMTT = ContractInfo.getContract("VMTT");

        const MINTER_ROLE = await ContractTool.CallView(HeroNFT, "MINTER_ROLE", []);

        // Expedition
        // --init
        await ContractTool.CallState(Expedition, "init", [
            "addr:WarrantNFT",
            "addr:HeroNFT",
            "addr:ShipNFT",
            "addr:VMTT",
            "addr:MTTGold",
            "addr:VMTTMinePool",
            "addr:GameService",
        ]);
        // --grantRole
        await ContractTool.CallState(VMTTMinePool, "grantRole", [MINTER_ROLE, "addr:Expedition"]);
        // --nftattr
        await ContractTool.CallState(HeroNFT,"setAttrSource",["addr:NFTAttrSource_V2"]);
        await ContractTool.CallState(ShipNFT,"setAttrSource",["addr:NFTAttrSource_V2"]);

        // VeTokenPool
        // --Init
        await ContractTool.CallState(VeTokenPool, "Init", ["addr:VMTT", eth_addr, 7200, 7200]);
        //await ContractTool.CallState(VeTokenPool, "Init", ["addr:VMTT", "addr:VMTT", 1, 1]);


        // VMTT
        // --addPoolAddr
        await ContractTool.CallState(VMTT, "addPoolAddr", ["addr:VeTokenPool"]);
        await ContractTool.CallState(VMTT, "addPoolAddr", ["addr:VMTTMinePool"]);

        return true;
    }

    static async init(): Promise<boolean> {
        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        
        const NFTAttrSource_V2 = ContractInfo.getContract("NFTAttrSource_V2");
        const Expedition = ContractInfo.getContract("Expedition");
        const Shipyard = ContractInfo.getContract("Shipyard");

        let define_configs: any = [];

        // NFTAttrSource_V2
        const NFTAttrSource_V2Config = {
            contract: NFTAttrSource_V2,
            name: "NFTAttrSource_V2",
            configs: NFTAttrSource_V2_config,
        };
        define_configs.push(NFTAttrSource_V2Config);

        // Expedition
        const ExpeditionConfig = {
            contract: Expedition,
            name: "Expedition",
            configs: Expedition_config,
        };
        define_configs.push(ExpeditionConfig);

        // Shipyard - battle ship
        const ShipyardConfig = {
            contract: Shipyard,
            name: "Shipyard",
            configs: Shipyard_config_v3,
        };
        define_configs.push(ShipyardConfig);


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
