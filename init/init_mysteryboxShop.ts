import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { Contract, BigNumber } from "ethers";
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
        logtools.logblue("==Config_MysteryBoxShop");
        
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
    
        //     uint64 beginTime; // start sale timeStamp in seconds since unix epoch, =0 ignore this condition
        //     uint64 endTime; // end sale timeStamp in seconds since unix epoch, =0 ignore this condition
    
        //     uint64 renewTime; // how long in seconds for each renew
        //     uint256 renewCount; // how many count put on sale for each renew
    
        //     uint32 whitelistId; // = 0 means open sale, else will check if buyer address in white list
        //     address nftholderCheck; // = address(0) won't check, else will check if buyer hold some other nft
    
        //     uint32 perAddrLimit; // = 0 means no limit, else means each user address max buying count
        // }
        let isburn=0;
        let saleconfig=[ContractInfo.getContractAddress("MysteryBox1155"),tokenId,ContractInfo.getContractAddress("MockERC20"),0,100,
        isburn,
        0,0,100,100,0,zeroadd,0];
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