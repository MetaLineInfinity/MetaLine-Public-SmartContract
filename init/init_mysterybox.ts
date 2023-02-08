import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { Contract, BigNumber } from "ethers";
import * as InitConfig from "./init_config";


export class Init_MysteryBox
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MysteryBox");

        let Random = ContractInfo.getContract("Random");
        let HeroNFT = ContractInfo.getContract("HeroNFT");
        let HeroNFTCodec_V1 = ContractInfo.getContract("HeroNFTCodec_V1");
        let HeroNFTMysteryBox = ContractInfo.getContract("HeroNFTMysteryBox");
        let HeroNFTMysteryBoxRandSource = ContractInfo.getContract("HeroNFTMysteryBoxRandSource");

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
        await ContractTool.CallState(HeroNFT,"setCodec",["addr:HeroNFTCodec_V1"]);
        await ContractTool.CallState(HeroNFT,"setAttrSource",["addr:HeroNFTAttrSource_V1"]);
       
        logtools.loggreen("--init hero nft mystery box contract");

        await ContractTool.CallState(HeroNFTMysteryBox, "setMethodExtraFee", [1, InitConfig.oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set HeroNFTMysteryBox oracle rand extra fee:${InitConfig.oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);
        await ContractTool.CallState(HeroNFTMysteryBox, "setMethodExtraFee", [2, InitConfig.batch10_oracle_rand_extra_fee, "addr:oracle_rand_fee_addr"]);
        logtools.loggreen(`set HeroNFTMysteryBox batch oracle rand extra fee:${InitConfig.batch10_oracle_rand_extra_fee}, to addr:${oracle_rand_fee_addr}`);

        await ContractTool.CallState(HeroNFTMysteryBox,"setNftAddress",["addr:MysteryBox1155"]);
        let addr= await ContractTool.CallView(HeroNFTMysteryBox,"getNftAddress",[]);
        logtools.loggreen("mystery box 1155 contract addr="+addr);
        await  ContractTool.CallState(HeroNFTMysteryBox,"setRandomSource",[1,"addr:HeroNFTMysteryBoxRandSource"]);

        let RAND_ROLE = await ContractTool.CallView(HeroNFTMysteryBox, "RAND_ROLE", []);
        await ContractTool.CallState(HeroNFTMysteryBox, "grantRole", [RAND_ROLE, "addr:Random"]);

        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "setRandSource",["addr:Random"]);
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "grantRole", [MINTER_ROLE, "addr:HeroNFTMysteryBox"]);
        await ContractTool.CallState(HeroNFTMysteryBoxRandSource, "setRandomSet", [1, [1,1,1,1,1,1,1
            ,1,1,1,1,1,1,1
            ,1,1,1]]);
    
        await Init_MysteryBox.HeroNFTMysteryBoxRandSource_AddPool(1,[[1000,0,2]]);

  


        logtools.loggreen("--init mystery box shop contract");

        let MysteryBoxShop = ContractInfo.getContract("MysteryBoxShop");
        let MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");
        await ContractTool.CallState(MysteryBox1155, "grantRole", [DATA_ROLE, MysteryBoxShop.address]);
        await ContractTool.CallState(MysteryBox1155, "grantRole", [MINTER_ROLE, MysteryBoxShop.address]);

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

        let MysteryBoxShop = ContractInfo.getContract("MysteryBoxShop");

        let randomid = BigNumber.from(1);
        let mysterytype = 1;
    
        //tokenid = (uint64)(randomid)<<32 | (uint32)mysterytype
        let tokenId = randomid.shl(32).add(1);
    
        let zeroadd = "0x0000000000000000000000000000000000000000";
        // struct OnSaleMysterBox{
        //     // config data --------------------------------------------------------
        //     address mysteryBox1155Addr; // mystery box address
        //     uint256 mbTokenId; // mystery box token id
    
        //     address tokenAddr; // charge token addr, could be 20 or 1155
        //     uint256 tokenId; // =0 means 20 token, else 1155 token
        //     uint256 price; // price value
    
        //     bool isBurn; // = ture means charge token will be burned, else charge token save in this contract
    
        //     uint256 beginBlock; // start sale block, =0 ignore this condition
        //     uint256 endBlock; // end sale block, =0 ignore this condition
    
        //     uint256 renewBlocks; // how many blocks for each renew
        //     uint256 renewCount; // how many count put on sale for each renew
    
        //     uint32 whitelistId; // = 0 means open sale, else will check if buyer address in white list
        //     address nftholderCheck; // = address(0) won't check, else will check if buyer hold some other nft
        // }
        let isburn=0;
        let saleconfig=[ContractInfo.getContractAddress("MysteryBox1155"),tokenId,ContractInfo.getContractAddress("MockERC20"),0,100,
        isburn,
        0,0,100,100,0,zeroadd];
        // struct OnSaleMysterBoxRunTime {
        //     // runtime data -------------------------------------------------------
        //     uint256 nextRenewBlock; // after this block num, will put at max [renewCount] on sale
    
        //     // config & runtime data ----------------------------------------------
        //     uint256 countLeft; // how many boxies left
        // }
        
        await ContractTool.CallState(MysteryBoxShop,"setOnSaleMysteryBox",["testpair",saleconfig,[100,10000]]);
        return true;
    }
}     