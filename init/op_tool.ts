import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { addChargeToken_ESportPool_Billing, eth_addr } from "./init_config";

import * as InitConfig from "./init_config";

export class OP_Tools
{
    static airdrop_address = [ 
    ]

    static async AirDropShip(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==AriDropShip");

        const ShipNFT = ContractInfo.getContract("ShipNFT");

        for(let i=0; i<this.airdrop_address.length; ++i){
            let rc= await ContractTool.CallState(ShipNFT, 
                "mint", 
                [this.airdrop_address[i], 
                [1,10,4,44,0,1,2]]
                );
            //when a tran got many events, GetEvent cound not work.
            let topic =ContractTool.GetRawEvent(rc,ShipNFT,"ShipNFTMint");
            let shipnftid =BigNumber.from(topic.topics[2]);
            logtools.loggreen(`mint ship id[${shipnftid}] to addr[${this.airdrop_address[i]}]`);
        }

        return true;
    }
    
    static async AddChargeToken(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        const ESportPool_V2 = ContractInfo.getContract("ESportPool_V2");
        const Billing = ContractInfo.getContract("Billing");

        await ContractTool.CallState(ESportPool_V2, "addChargeToken", addChargeToken_ESportPool_Billing[0]);
        await ContractTool.CallState(Billing, "addChargeToken", addChargeToken_ESportPool_Billing[0]);
        
        return true;
    }

    static async PlatOnOffChainBridgeMintRole(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        const PlatOnOffChainBridge = ContractInfo.getContract("PlatOnOffChainBridge");

        await ContractTool.CallState(PlatOnOffChainBridge, "grantRole", ["0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", "0xE7EFAcb6F9A8C85bea83455eD6AA8822e34F8e2B"]);
        
        return true;
    }

    static async UniversalNFTDataRole_VeTokenPool(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        const UniversalNFT = ContractInfo.getContract("UniversalNFT");
        const VeTokenPool = ContractInfo.getContract("VeTokenPool");

        await ContractTool.CallState(UniversalNFT, "grantRole", ["0xa5b103c755210dd1215ce1308341380ccede082cd9202427c960290e230cba78", "0xE7EFAcb6F9A8C85bea83455eD6AA8822e34F8e2B"]);

        await ContractTool.CallState(VeTokenPool, "Init", ["addr:VMTT", eth_addr, 7200, 216000]);
        
        return true;
    }

    static async PlatOnOffChainBridgeServiceRole(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        const PlatOnOffChainBridge = ContractInfo.getContract("PlatOnOffChainBridge");
        await ContractTool.CallState(PlatOnOffChainBridge, "grantRole", ["0xd8a7a79547af723ee3e12b59a480111268d8969c634e1a34a144d2c8b91d635b", "0xE7EFAcb6F9A8C85bea83455eD6AA8822e34F8e2B"]);
        return true;
    }

    static async ESportPoolV2_Expedition_20230725(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        const ESportPool_V2 = ContractInfo.getContract("ESportPool_V2");
        await ContractTool.CallState(ESportPool_V2, "setPoolConfig", [1, [100000000, 10000, 100, [2000, 800, 400, 200, 200, 80, 80, 80, 80, 80, 1000], "gold", "addr:MTTGold"]]);

        const Expedition = ContractInfo.getContract("Expedition");
        await ContractTool.CallState(Expedition, "setPortHeroExpedConf", ["1",["36","718","7200","7958615200955030000","1927500","25511969005119700","255119690051197000","7540"]]);
        await ContractTool.CallState(Expedition, "setPortHeroExpedConf", ["2",["719","1077","7200","9550338241146040000","2120250","28063165905631600","280631659056316000","17960"]]);

        await ContractTool.CallState(Expedition, "setPortShipExpedConf", ["1",["42","1425","7200","11937922801432500000","5782500","229607721046077000","2296077210460770000","73350"]]);
        await ContractTool.CallState(Expedition, "setPortShipExpedConf", ["2",["1426","2815","7200","14325507361719100000","6360750","252568493150685000","2525684931506850000","212050"]]);

        return true;
    }

    

    static async AddAssetMinterTotalCount(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==AddAssetMinterTotalCount");

        const AssetMinter = ContractInfo.getContract("AssetMinter");
        let rc= await ContractTool.CallState(AssetMinter, 
            "setPackageTotalCount", 
            [1, 200]
            );
        rc= await ContractTool.CallState(AssetMinter, 
            "setPackageTotalCount", 
            [2, 200]
            );
        rc= await ContractTool.CallState(AssetMinter, 
            "setPackageTotalCount", 
            [3, 200]
            );
        rc= await ContractTool.CallState(AssetMinter, 
            "setPackageTotalCount", 
            [4, 200]
            );
        rc= await ContractTool.CallState(AssetMinter, 
            "setPackageTotalCount", 
            [5, 200]
            );
        return true;
    }

    static async guildSecond(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        let MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");

        let zeroaddr = "0x0000000000000000000000000000000000000000";

        // setOnSaleMBCheckCondition(string pairName, uint256 price, uint32 whitelistId, address nftholderCheck, uint32 perAddrLimit, uint32 discountId)
        await ContractTool.CallState(MysteryBoxShopV2,"setOnSaleMBCheckCondition",
        [
            "saleGPT",
            "168400000000000000", // price
            0,                  // whitelistId
            zeroaddr,
            0,
            0
        ]);

        return true;
    }
    
}     
