import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

import * as InitConfig from "./init_config";

export class Init_MysteryBoxShop
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MysteryBoxShop");
        
        let MysteryBoxShop = ContractInfo.getContract("MysteryBoxShop");
        let MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");

        let DATA_ROLE = await ContractTool.CallView(MysteryBox1155, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(MysteryBox1155, "MINTER_ROLE", []);

        await ContractTool.CallState(MysteryBox1155, "grantRole", [DATA_ROLE, MysteryBoxShop.address]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, MysteryBoxShop.address]);

        let OPERATER_ROLE = await ContractTool.CallView(MysteryBoxShop, "OPERATER_ROLE", []);
        await ContractTool.CallState(MysteryBoxShop, "grantRole",[OPERATER_ROLE, "addr:operater_address"]);
        let operater_address = ContractTool.GetAddrInValues("operater_address");
        logtools.loggreen(`MysteryBoxShop grantRole OPERATER_ROLE to addr:${operater_address}`);

        await ContractTool.CallState(MysteryBoxShop, "setReceiveIncomeAddress",["addr:receive_mb_income_addr"]);
        let receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");
        logtools.loggreen(`MysteryBoxShop set income receiver to addr:${receive_mb_income_addr}`);

        return true;
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_MysteryBoxShop");
        
        let MysteryBoxShop = ContractInfo.getContract("MysteryBoxShop");

        let randomid =BigNumber.from(1);
        let mysterytype = 1;
    
        //tokenid = (uint64)(randomid)<<32 | (uint32)mysterytype
        let tokenId = randomid.shl(32).add(1);
    
        let zeroaddr = "0x0000000000000000000000000000000000000000";
        let isburn=0;
        let mb1155Addr = ContractInfo.getContractAddress("MysteryBox1155");

        let saleconfig1=[
            mb1155Addr, 
            '4294967297',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '32000000000000000', // price

            false, // isBurn
            '1676462400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1 // perLimit
        ];
        let saledata1=[
            0, // nextRenewTime
            1600 // countLeft
        ];
        
        let saleconfig2=[
            mb1155Addr, 
            '4294967298',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '65000000000000000', // price

            false, // isBurn
            '1676462400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1 // perLimit
        ];
        let saledata2=[
            0, // nextRenewTime
            1300 // countLeft
        ];
        
        let saleconfig3=[
            mb1155Addr, 
            '4294967299',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '131000000000000000', // price

            false, // isBurn
            '1676462400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1 // perLimit
        ];
        let saledata3=[
            0, // nextRenewTime
            600 // countLeft
        ];

        await ContractTool.CallState(MysteryBoxShop,"setOnSaleMysteryBox",["sale1",saleconfig1,saledata1]);
        await ContractTool.CallState(MysteryBoxShop,"setOnSaleMysteryBox",["sale2",saleconfig2,saledata2]);
        await ContractTool.CallState(MysteryBoxShop,"setOnSaleMysteryBox",["sale3",saleconfig3,saledata3]);

        return true;
    }
}

export class Init_MysteryBoxShopV1
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MysteryBoxShopV1");
        
        let MysteryBoxShopV1 = ContractInfo.getContract("MysteryBoxShopV1");
        let MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");

        let DATA_ROLE = await ContractTool.CallView(MysteryBox1155, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(MysteryBox1155, "MINTER_ROLE", []);

        await ContractTool.CallState(MysteryBox1155, "grantRole", [DATA_ROLE, MysteryBoxShopV1.address]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, MysteryBoxShopV1.address]);

        let OPERATER_ROLE = await ContractTool.CallView(MysteryBoxShopV1, "OPERATER_ROLE", []);
        await ContractTool.CallState(MysteryBoxShopV1, "grantRole",[OPERATER_ROLE, "addr:operater_address"]);
        let operater_address = ContractTool.GetAddrInValues("operater_address");
        logtools.loggreen(`MysteryBoxShop grantRole OPERATER_ROLE to addr:${operater_address}`);

        await ContractTool.CallState(MysteryBoxShopV1, "setReceiveIncomeAddress",["addr:receive_mb_income_addr"]);
        let receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");
        logtools.loggreen(`MysteryBoxShop set income receiver to addr:${receive_mb_income_addr}`);

        return true;
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_MysteryBoxShopV1");
        
        let MysteryBoxShopV1 = ContractInfo.getContract("MysteryBoxShopV1");

        let randomid = BigNumber.from(1);
        let mysterytype = 1;
    
        //tokenid = (uint64)(randomid)<<32 | (uint32)mysterytype
        let tokenId = randomid.shl(32).add(1);
    
        let zeroaddr = "0x0000000000000000000000000000000000000000";
        let isburn=0;
        let mb1155Addr = ContractInfo.getContractAddress("MysteryBox1155");

        let saleconfig1=[
            mb1155Addr, 
            '8589934603',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig2=[
            mb1155Addr, 
            '8589934604',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig3=[
            mb1155Addr, 
            '8589934605',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig4=[
            mb1155Addr, 
            '8589934606',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig5=[
            mb1155Addr, 
            '8589934607',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saledata1=[
            0, // nextRenewTime
            880 // countLeft
        ];

        
        let saleconfig6=[
            mb1155Addr, 
            '8589934603',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig7=[
            mb1155Addr, 
            '8589934604',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig8=[
            mb1155Addr, 
            '8589934605',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig9=[
            mb1155Addr, 
            '8589934606',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig10=[
            mb1155Addr, 
            '8589934607',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saledata2=[
            0, // nextRenewTime
            120 // countLeft
        ];

        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale1",saleconfig1,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale2",saleconfig2,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale3",saleconfig3,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale4",saleconfig4,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale5",saleconfig5,saledata1]);
        
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale6",saleconfig6,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale7",saleconfig7,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale8",saleconfig8,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale9",saleconfig9,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV1,"setOnSaleMysteryBox",["sale10",saleconfig10,saledata2]);

        return true;
    }
}


export class Init_MysteryBoxShopV2
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MysteryBoxShopV2");
        
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");
        let MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");

        let DATA_ROLE = await ContractTool.CallView(MysteryBox1155, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(MysteryBox1155, "MINTER_ROLE", []);

        await ContractTool.CallState(MysteryBox1155, "grantRole", [DATA_ROLE, MysteryBoxShopV2.address]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, MysteryBoxShopV2.address]);

        let OPERATER_ROLE = await ContractTool.CallView(MysteryBoxShopV2, "OPERATER_ROLE", []);
        await ContractTool.CallState(MysteryBoxShopV2, "grantRole",[OPERATER_ROLE, "addr:operater_address"]);
        let operater_address = ContractTool.GetAddrInValues("operater_address");
        logtools.loggreen(`MysteryBoxShop grantRole OPERATER_ROLE to addr:${operater_address}`);

        await ContractTool.CallState(MysteryBoxShopV2, "setReceiveIncomeAddress",["addr:receive_mb_income_addr"]);
        let receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");
        logtools.loggreen(`MysteryBoxShop set income receiver to addr:${receive_mb_income_addr}`);

        return true;
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_MysteryBoxShopV2");
        
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");

        let randomid = BigNumber.from(1);
        let mysterytype = 1;
    
        //tokenid = (uint64)(randomid)<<32 | (uint32)mysterytype
        let tokenId = randomid.shl(32).add(1);
    
        let zeroaddr = "0x0000000000000000000000000000000000000000";
        let isburn=0;
        let mb1155Addr = ContractInfo.getContractAddress("MysteryBox1155");

        let saleconfig1=[
            mb1155Addr, 
            '8589934603',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig2=[
            mb1155Addr, 
            '8589934604',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig3=[
            mb1155Addr, 
            '8589934605',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig4=[
            mb1155Addr, 
            '8589934606',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saleconfig5=[
            mb1155Addr, 
            '8589934607',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            1,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            1, // discountId
        ];
        let saledata1=[
            0, // nextRenewTime
            880 // countLeft
        ];

        
        let saleconfig6=[
            mb1155Addr, 
            '8589934603',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig7=[
            mb1155Addr, 
            '8589934604',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig8=[
            mb1155Addr, 
            '8589934605',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig9=[
            mb1155Addr, 
            '8589934606',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saleconfig10=[
            mb1155Addr, 
            '8589934607',  // mb token id

            zeroaddr,  // charge token id, 0:eth
            0,  // 1155 token id
            '33000000000000000', // price

            '1679918400', 0, 0, 0, // beginTime, endTime, renewTime, renewCount

            2,  // whiteListId
            zeroaddr, // nft holder check
            1, // perLimit
            2, // discountId
        ];
        let saledata2=[
            0, // nextRenewTime
            120 // countLeft
        ];

        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale1",saleconfig1,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale2",saleconfig2,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale3",saleconfig3,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale4",saleconfig4,saledata1]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale5",saleconfig5,saledata1]);
        
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale6",saleconfig6,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale7",saleconfig7,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale8",saleconfig8,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale9",saleconfig9,saledata2]);
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMysteryBox",["sale10",saleconfig10,saledata2]);

        return true;
    }
}