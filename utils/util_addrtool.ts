import { ethers, Signer } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "./util_contractinfo";
import { ContractTool } from "./util_contracttool";

export class AddrTool
{
    signer0: Signer;
    signer1: Signer;
    signer2: Signer;
    signer3: Signer;
    addr0: string;
    addr1: string;
    addr2: string;
    addr3: string;
    provider: ethers.providers.JsonRpcProvider;
    constructor(signer0: Signer, signer1: Signer, signer2: Signer, signer3: Signer, provider: ethers.providers.JsonRpcProvider)
    {
        this.signer0 = signer0;
        this.signer1 = signer1;
        this.signer2 = signer2;
        this.signer3 = signer3;
        this.addr0 = "";
        this.addr1 = "";
        this.addr2 = "";
        this.addr3 = "";
        this.provider = provider;
    }
    async InitInstance(): Promise<void>
    {
        this.addr0 = await this.signer0.getAddress();
        this.addr1 = await this.signer1.getAddress();
        this.addr2 = await this.signer2.getAddress();
        this.addr3 = await this.signer3.getAddress();

    }
    static async Init(hre:HardhatRuntimeEnvironment): Promise<AddrTool>
    {
        let signers = await hre.ethers.getSigners();
        let tool = new AddrTool(signers[0], signers[1], signers[2], signers[3],hre.ethers.provider);

        await tool.InitInstance();

        return tool;
    }
    static async Test_Init(hre:HardhatRuntimeEnvironment): Promise<AddrTool>
    {
        await ContractTool.LoadDeployInfo(hre);
        await ContractInfo.LoadFromFile(hre);
    
        return await AddrTool.Init(hre);

    }
}