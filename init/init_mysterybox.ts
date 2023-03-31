import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { Contract, BigNumber } from "ethers/lib";
import * as InitConfig from "./init_config";

export class Init_MysteryBox
{
    //gen5
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MysteryBox");

        let Random = ContractInfo.getContract("Random");
        let HeroNFT = ContractInfo.getContract("HeroNFT");
        let HeroNFTCodec_V1 = ContractInfo.getContract("HeroNFTCodec_V1");
        let HeroNFTMysteryBox = ContractInfo.getContract("HeroNFTMysteryBox");
        let HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        let HeroPetNFTMysteryBoxRandSource = ContractInfo.getContract("HeroPetNFTMysteryBoxRandSource");

        logtools.loggreen("--init random contract");
        let ORACLE_ROLE = await ContractTool.CallView(Random, "ORACLE_ROLE", []);
        await ContractTool.CallState(Random, "grantRole", [ORACLE_ROLE, "addr:oracle_rand_fee_addr"]);
        let oracle_rand_fee_addr = ContractTool.GetAddrInValues("oracle_rand_fee_addr");
        logtools.loggreen(`HeroNFT grantRole ORACLE_ROLE to addr:${oracle_rand_fee_addr}`);
        
        logtools.loggreen("--init hero nft contract");
        let DATA_ROLE = await ContractTool.CallView(HeroNFT, "DATA_ROLE", []);
        let MINTER_ROLE = await ContractTool.CallView(HeroNFT, "MINTER_ROLE", []);

        //await ContractTool.CallState(HeroNFT, "grantRole", [DATA_ROLE, addrtool.addr0]);
        await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBoxRandSource"]);
        await ContractTool.CallState(HeroNFT, "grantRole", [MINTER_ROLE, "addr:HeroPetNFTMysteryBoxRandSource"]);
        await ContractTool.CallState(HeroNFT,"setCodec",["addr:HeroNFTCodec_V1"]);
        await ContractTool.CallState(HeroNFT,"setAttrSource",["addr:NFTAttrSource_V1"]);
       
        logtools.loggreen("--init hero nft mystery box contract");

        await ContractTool.CallState(HeroNFTMysteryBox, "setMethodExtraFee", [1, InitConfig.oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set HeroNFTMysteryBox oracle rand extra fee:${InitConfig.oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);
        await ContractTool.CallState(HeroNFTMysteryBox, "setMethodExtraFee", [2, InitConfig.batch10_oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set HeroNFTMysteryBox batch oracle rand extra fee:${InitConfig.batch10_oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);

        await ContractTool.CallState(HeroNFTMysteryBox,"setNftAddress",["addr:MysteryBox1155"]);
        let addr= await ContractTool.CallView(HeroNFTMysteryBox,"getNftAddress",[]);
        logtools.loggreen("mystery box 1155 contract addr="+addr);
        await  ContractTool.CallState(HeroNFTMysteryBox,"setRandomSource",[1,"addr:HeroNFTMysteryBoxRandSource"]);
        await  ContractTool.CallState(HeroNFTMysteryBox,"setRandomSource",[2,"addr:HeroPetNFTMysteryBoxRandSource"]);

        let RAND_ROLE = await ContractTool.CallView(HeroNFTMysteryBox, "RAND_ROLE", []);
        await ContractTool.CallState(HeroNFTMysteryBox, "grantRole", [RAND_ROLE, "addr:Random"]);
        
        // pause mystery box
        //await ContractTool.CallState(HeroNFTMysteryBox, "pause", []);

        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "setRandSource",["addr:Random"]);
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBox"]);
        
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "setRandSource",["addr:Random"]);
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBox"]);

        return true;
    }
    static async HeroNFTMysteryBoxRandSource_AddPool(poolid:number,pooldata:any[])
    {
        let HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        let b= await ContractTool.CallView(HeroNFTMysteryBoxRandSource,"hasPool",[poolid]);
        if(b==0)
        {
            await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "addPool", [poolid, pooldata]);
        }
        else
        {
            await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "modifyPool", [poolid, pooldata]);
        }
        
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_MysteryBox");
        
        // config random source
        let HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "setRandomSet", [1, [1,1,1,1,1,1,1
            ,1,1,1,1,1,1,1
            ,1,1,1]]);
    
        await Init_MysteryBox.HeroNFTMysteryBoxRandSource_AddPool(1,[[1000,0,2]]);

        return true;
    }
}     
