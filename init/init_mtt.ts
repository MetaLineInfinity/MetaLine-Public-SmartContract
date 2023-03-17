import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";
import { Contract, BigNumber } from "ethers";
import * as InitConfig from "./init_config";

export class Init_MTT
{
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean>
    {
        logtools.logblue("==Init_MTT");

        let MTT = ContractInfo.getContract("MTT");

        let signerAddr = await MTT.signer.getAddress();

        logtools.loggreen("--mint all");
        await ContractTool.CallState(MTT, "mint", [signerAddr, "300000000000000000000000000"]);

        // test address
        let mine_pool_addr = "0x9812752121fb9eBEc49A4B8153240866156E87C5";
        let investor_pool_addr = "0x261e31A67032032b2e788e6b2337e4c3800b2673";
        let community_pool_addr = "0x3E803AC553aE650Ee8B61b80A1DEaE2fb6a99607";
        let team_pool_addr = "0x0BcFbd673630d04883625Ac8bdbe5F646da16cBE";

        // test share
        let mine_pool_share = "180000000000000000000000000";
        let investor_pool_share = "40000000000000000000000000";
        let community_pool_share = "40000000000000000000000000";
        let team_pool_share = "40000000000000000000000000";

        logtools.loggreen("--distribute");
        await ContractTool.CallState(MTT, "transfer", [mine_pool_addr, mine_pool_share]);
        await ContractTool.CallState(MTT, "transfer", [investor_pool_addr, investor_pool_share]);
        await ContractTool.CallState(MTT, "transfer", [community_pool_addr, community_pool_share]);
        await ContractTool.CallState(MTT, "transfer", [team_pool_addr, team_pool_share]);

        return true;
    }
    static async  ConfigAll(hre:HardhatRuntimeEnvironment):Promise<boolean>
    {
        logtools.logblue("==Config_MTT");

        return true;
    }
}     
