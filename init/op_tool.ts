import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { addChargeToken_ESportPool_Billing } from "./init_config";

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
}     
