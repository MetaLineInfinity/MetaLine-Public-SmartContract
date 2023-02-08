import { Signer } from "ethers";
import * as hre from "hardhat";
import { ContractInfo } from "./util_contractinfo";
import { ContractTool } from "./util_contracttool";

export class TestTool
{
    signer0: Signer;
    signer1: Signer;
    signer2: Signer;
    signer3: Signer;
    addr0: string;
    addr1: string;
    addr2: string;
    addr3: string;
    constructor(signer0: Signer,signer1: Signer,signer2: Signer,signer3: Signer)
    {
        this.signer0=signer0;
        this.signer1=signer1;
        this.signer2=signer2;
        this.signer3=signer3;
        this.addr0="";
        this.addr1="";
        this.addr2="";
        this.addr3="";
    }
    async InitAddr():Promise<void>
    {
        this.addr0 = await this.signer0.getAddress();
        this.addr1 = await this.signer1.getAddress();
        this.addr2 = await this.signer2.getAddress();
        this.addr3 = await this.signer3.getAddress();
    }
    static async Init(): Promise<TestTool>
    {
        await ContractTool.LoadDeployInfo(hre);
        await ContractInfo.LoadFromFile(hre);
        let signers = await hre.ethers.getSigners();
        let tool = new TestTool(signers[0],signers[1],signers[2],signers[3]);
    
        await tool.InitAddr();

        return tool;
    }
    static  IsLocal():boolean
    {
        if (hre.network.name == "hardhat")return true;
        if (hre.network.name == "localhost")return true;
        return false;
    }
}