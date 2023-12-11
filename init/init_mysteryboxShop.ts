import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { MysteryBoxShopV2_config } from "./config_MysteryBoxShopV2";


export class Init_MysteryBoxShop
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MysteryBoxShop");
        
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");
        let MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");

        let DATA_ROLE = await ContractTool.CallView(MysteryBox1155, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(MysteryBox1155, "MINTER_ROLE", []);
        let OPERATER_ROLE = await ContractTool.CallView(MysteryBoxShopV2, "OPERATER_ROLE", []);

        await ContractTool.CallState(MysteryBox1155, "grantRole", [DATA_ROLE, MysteryBoxShopV2.address]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, MysteryBoxShopV2.address]);
        await ContractTool.CallState(MysteryBoxShopV2, "grantRole",[OPERATER_ROLE, "addr:operater_address"]);
        await ContractTool.CallState(MysteryBoxShopV2, "setReceiveIncomeAddress",["addr:receive_mb_income_addr"]);

        return true;
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_MysteryBoxShop");
        
        
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");


        let define_configs: any = [];

        // MysteryBoxShopV2
        const MysteryBoxShopV2Config = {
            contract: MysteryBoxShopV2,
            name: "MysteryBoxShopV2",
            configs: MysteryBoxShopV2_config,
        };
        define_configs.push(MysteryBoxShopV2Config);

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