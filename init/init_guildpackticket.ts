import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

export class Init_GuildPackTicket
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_GuildPackTicket");
        
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");
        let GuildPackTicket1155 = ContractInfo.getContract("GuildPackTicket1155");

        let DATA_ROLE = await ContractTool.CallView(GuildPackTicket1155, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(GuildPackTicket1155, "MINTER_ROLE", []);

        await ContractTool.CallState(GuildPackTicket1155, "grantRole", [DATA_ROLE, MysteryBoxShopV2.address]);
        await ContractTool.CallState(GuildPackTicket1155, "grantRole", [MINTER_ROLE, MysteryBoxShopV2.address]);

        // TO DO : change income address
        // await ContractTool.CallState(MysteryBoxShopV2, "setReceiveIncomeAddress",["addr:receive_mb_income_addr"]);
        // let receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");
        // logtools.loggreen(`MysteryBoxShopV2 set income receiver to addr:${receive_mb_income_addr}`);

        return true;
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_GuildPackTicket");
        
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");

        let zeroaddr = "0x0000000000000000000000000000000000000000";
        let mb1155Addr = ContractInfo.getContractAddress("GuildPackTicket1155");

        // TO DO : change config
        let saleconfig=[
            mb1155Addr, 
            '1',  // guild package ticket token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '151300000000000000', // price

            '1729602000', '1729688400', 0, 0, // beginTime, endTime, renewTime, renewCount

            3,  // whiteListId
            zeroaddr, // nft holder check
            0, // perLimit
            0, // discountId
        ];
        let saledata=[
            0, // nextRenewTime
            500 // countLeft
        ];
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["saleGPT",saleconfig,saledata]);

        return true;
    }
}