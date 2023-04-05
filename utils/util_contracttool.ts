import { Contract, ContractReceipt, ethers, Signer } from "ethers/lib";

import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as fs from "fs";
import { ContractInfo } from "./util_contractinfo";
import { DeployOptions, Libraries } from "hardhat-deploy/types";

import "@nomiclabs/hardhat-etherscan";
import { logtools } from "./util_log";


export class ContractTool
{
    static async PassBlockOne(hre: HardhatRuntimeEnvironment)
    {
        await hre.network.provider.send("evm_mine");
    }
    static async PassBlock(hre: HardhatRuntimeEnvironment, blockcount: number)
    {

        let name = hre.network.name;
        if (name == "hardhat" || name == "localhost")
        {
            // let nowcount = await hre.ethers.provider.getBlockNumber();
            // if (nowcount < blockcount)
            // {
            //     //过块
            //     console.log("quick pass to block " + blockcount);
                for (let i = 0; i < blockcount; i++)
                {
                    await hre.network.provider.send("evm_mine");
                }
            //}
            console.log("==done block " + name + "=" + await hre.ethers.provider.getBlockNumber());
        }
    }
    static GetRawEvent(recipt:ContractReceipt,contract:Contract,eventname:string)
    {
        var topic= contract.interface.getEventTopic(eventname);
        if(topic==null)
            throw  "error get topic:" + eventname;
        for(var i in recipt.events)
        {
            if(recipt.events[i].topics[0]==topic)
            {
                return recipt.events[i];
            }
        }
        return null;
    }
    static GetEvent(recipt: ContractReceipt, eventname: string): any[]
    {
        let event = recipt.events?.find((d: any) => d.event == eventname);
        if (event == null || event.args == null)
            throw "error get event:" + eventname;
        return event.args as any[];
    }
    private static deployfile = "deployinfo.json";

    private static deploygroups: GroupDeployInfo[] = []
    private static values: ContractValues;
    private static namedaccounts: { [id: string]: string } = {};
    static GetAddrInValues(name: string): string | undefined
    {
        logtools.loggreen("values=" + JSON.stringify(ContractTool.values));
        if (this.values.addresses == undefined)
            return undefined;
        if (this.values.addresses[name] == undefined)
            return undefined;
        return this.GetString(this.values.addresses[name]);
    }
    static GetContractInValues(name: string): string | undefined
    {
        if (this.values.contracts == undefined)
            return undefined;
        return this.values.contracts[name];
    }

    static async LoadDeployInfo(hre: HardhatRuntimeEnvironment)
    {
        if (ContractTool.deploygroups.length > 0)
        {
            logtools.log("LoadDeployInfo skip");
        }
        logtools.log("LoadDeployInfo");
        for (var i = 0; i < 10; i++)
        {
            try
            {
                this.namedaccounts = await hre.getNamedAccounts();
                break;
            }
            catch
            {
                logtools.logred("time out");
            }
        }
        logtools.log("LoadDeployInfo getNamedAccounts")
        let buffer = fs.readFileSync(ContractTool.deployfile);
        let srcjson = JSON.parse(buffer.toString());
        ContractTool.deploygroups = srcjson["groups"] as GroupDeployInfo[];
        let vs = srcjson["values"];

        var name;
        for (var i = 0; i < 10; i++)
        {
            try
            {
                name = hre.network.name;
                break;
            }
            catch
            {
                logtools.logred("time out");
            }
        }
        for (var i = 0; i < vs.length; i++)
        {
            if (vs[i]["network"] == name)
            {
                ContractTool.values = vs[i];
            }
        }

        if (ContractTool.values == undefined)
            throw "no values in deployinfo";
        logtools.loggreen("values=" + JSON.stringify(ContractTool.values));
    }
    static async DeployAll(hre: HardhatRuntimeEnvironment)
    {
        //logtools.RemoveAppend();


        logtools.UpdateConfigFileName(hre);
        logtools.RemoveConfig();

        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }
        for (var key in ContractTool.deploygroups)
        {
            let group = ContractTool.deploygroups[key].group;
            if (ContractTool.deploygroups[key].gen > 0)
            {
                logtools.logcyan("==skip==" + group + " this is only deploy by xdeploy group [name] gen=" + ContractTool.deploygroups[key].gen);
                continue;
            }
            await ContractTool.DeployGroup(hre, group);
        }
    }
    static async DeployGenGroup(hre: HardhatRuntimeEnvironment, genid: number)
    {
        if (genid <= 0)
            throw "genid should >0";
        console.log("==DeployGenGroup:" + genid);
        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }
        await ContractInfo.LoadFromFile(hre);

        for (var key in ContractTool.deploygroups)
        {
            let _g = ContractTool.deploygroups[key];
            if (_g.gen == genid)
                await ContractTool.DeployGroup(hre, _g.group);
        }
    }
    static async DeployGroup(hre: HardhatRuntimeEnvironment, name: string)
    {
        console.log("==DeployGroup:" + name);
        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }
        await ContractInfo.LoadFromFile(hre);
        let group: GroupDeployInfo | null = null;
        for (var key in ContractTool.deploygroups)
        {
            let _g = ContractTool.deploygroups[key];
            if (_g.group == name)
                group = _g;
        }

        if (group == null)
        {
            throw "not found group:" + name;
        }
        for (var key in group.contracts)
        {
            await ContractTool.DeployOne(hre, group.contracts[key]);
        }
        console.log("==DeployGroup:" + name + " done.");
    }
    static GetGroupNames(hre: HardhatRuntimeEnvironment): string[]
    {

        let names: string[] = [];
        for (var key in ContractTool.deploygroups)
        {
            names.push(ContractTool.deploygroups[key].group);
        }
        return names;
    }
    static GetGroup(hre: HardhatRuntimeEnvironment, name: string): GroupDeployInfo | null
    {

        let group: GroupDeployInfo | null = null;
        for (var key in ContractTool.deploygroups)
        {
            let _g = ContractTool.deploygroups[key];
            if (_g.group == name)
                return _g;
        }
        return null;
    }
    static GetInfo(hre: HardhatRuntimeEnvironment, name: string): ContractDeployInfo | null
    {

        let group: GroupDeployInfo | null = null;
        for (var key in ContractTool.deploygroups)
        {
            let _g = ContractTool.deploygroups[key];

            for (var ik in _g.contracts)
            {
                if (_g.contracts[ik].name == name)
                    return _g.contracts[ik];
            }
        }
        return null;
    }
    static async DeployOne(hre: HardhatRuntimeEnvironment, info: ContractDeployInfo)
    {
        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }
        console.log("deployone:" + JSON.stringify(info));
        let deployer = (await hre.getNamedAccounts())[info.deployer];
        let _args: string[] = [];
        for (var key in info.args)
        {
            var arg = info.args[key];
            if(typeof arg === 'string')
            {
                _args.push(ContractTool.GetString(arg));
            }
            else
            {
                _args.push(arg);
            }
            
        }
        var op: DeployOptions =
        {
            from: deployer,
            args: _args,
            log: true,
            autoMine: true,
        };
        if (info.libraries != null)
        {
            op.libraries = {};
            for (var key in info.libraries)
            {
                op.libraries[key] = ContractTool.GetString(info.libraries[key]);
            }
        }
        await ContractInfo.Deploy(hre, info.name, op);
    }
    static async VerifyAll(hre: HardhatRuntimeEnvironment)
    {
        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }
        for (var key in ContractTool.deploygroups)
        {
            let group = ContractTool.deploygroups[key].group;
            if (ContractTool.deploygroups[key].gen > 0)
            {
                logtools.logcyan("==skip==" + group + " this is only verify by xdeploy group [name] gen=" + ContractTool.deploygroups[key].gen);
                continue;
            }
            await ContractTool.VerifyGroup(hre, ContractTool.deploygroups[key].group);
        }
    }
    static async VerifyGroup(hre: HardhatRuntimeEnvironment, name: string)
    {
        console.log("==VerifyGroup:" + name);
        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }

        let group: GroupDeployInfo | null = null;
        for (var key in ContractTool.deploygroups)
        {
            let _g = ContractTool.deploygroups[key];
            if (_g.group == name)
                group = _g;
        }

        if (group == null)
        {
            throw "not found group:" + name;
        }
        for (var key in group.contracts)
        {
            try
            {
                await ContractTool.VerifyOne(hre, group.contracts[key]);
            }
            catch (e: any)
            {
                console.log("verify with error:" + e);
            }
        }
        console.log("==VerifyGroup:" + name + " done.");
    }
    static async VerifyOne(hre: HardhatRuntimeEnvironment, info: ContractDeployInfo)
    {
        console.log("verify=" + info.name);
        if (ContractTool.deploygroups.length == 0)
        {
            await ContractTool.LoadDeployInfo(hre);
        }
        let addr = ContractInfo.getContractAddress(info.name);
        if (addr == undefined)
            throw "error addr";
        let _args: string[] = [];
        for (var key in info.args)
        {
            var arg =info.args[key];
            if(typeof arg === "string")
            {
                _args.push(ContractTool.GetString(arg));
            }
            else
            {
                _args.push(arg);
            }
        }
        let vargs: VerificationSubtaskArgs = { address: addr, constructorArguments: _args };
        if (info.verify != null)
            vargs.contract = info.verify;
        //from docs  { address: addr, constructorArguments: _args }
        let i = await hre.run("verify:verify", vargs);

    }
    static GetString(src: string): string
    {
        logtools.log("getstring="+src);
        if (src.indexOf("str:") == 0)
            return src.substring(4);
        if (src.indexOf("addr:") == 0)
        {
            let name = src.substring(5);
            console.log("get addr:" + name);
            let addr = ContractInfo.getContractAddress(name);
            if (addr != null)
                return addr;
            let addr2 = ContractTool.GetAddrInValues(name);
            if (addr2 != undefined)
                return addr2;
            let contract = ContractTool.GetContractInValues(name);
            if (contract != undefined)
                return contract;

            throw "get addr:" + name + " fail";
        }
        if (src.indexOf("namedaccount:") == 0)
        {
            let name = src.substring(13);
            console.log("get namedaccount:" + name);
            let addr = this.namedaccounts[name];
            if (addr != null)
                return addr;
            throw "get namedaccount:" + name + " fail";
        }
        return src;
    }
    static async ProxyUpdate(nameProxy: string, target: string): Promise<ContractReceipt>
    {
        return await ContractTool.CallState(ContractInfo.getContract(nameProxy), "upgradeTo", ["addr:" + target]);
    }
    static async GetProxyContract(nameProxy: string, nameAbi: string): Promise<Contract>
    {
        let cproxy = ContractInfo.getContract(nameProxy);
        let abi = await ContractInfo.getContractAbi(nameAbi);
        //console.log("abi="+abi);
        let c = new Contract(cproxy.address, abi);
        return c.connect(cproxy.signer);
    }

    static async GetVistualContract(signer:Signer, nameAbi: string,conaddr:string): Promise<Contract>
    {
        let addr = ContractTool.GetString(conaddr);
        let abi = await ContractInfo.getContractAbi(nameAbi);
        //console.log("abi="+abi);
        let c = new Contract(addr, abi);
        return c.connect(signer);
    }

    static async CallState(c: Contract, func: string, args: any[]): Promise<ContractReceipt>
    {
        for (var i = 0; i < args.length; i++)
        {
            if (typeof args[i] == "string")
            {
                args[i] = this.GetString(args[i]);
            }
            else if (typeof args[i] == "object") {
                for (var x = 0; x < args[i].length; x++) {
                    if (typeof args[i][x] == "string") {
                        args[i][x] = this.GetString(args[i][x]);
                    }
                }
            }
        }
        console.log("go<" + func + ">" + JSON.stringify(args));
        let funcabi: ethers.utils.FunctionFragment = c.interface.getFunction(func);

        if (funcabi.stateMutability.includes("view") == true || funcabi.stateMutability.includes("pure") == true)
            throw "not a state function:" + func;


        for (var i = 0; i < 3; i++)
        {
            try
            {
                let tran = await c.functions[func](...args);
                return tran.wait();
            }
            catch (err)
            {
                logtools.logred("error:" + err);
                console.log("retry:" + (i + 1).toString() + func + ":" + JSON.stringify(args));

                let delay = 5000;;
                await new Promise(res => setTimeout(() => res(null), delay));
            }
        }
        throw "final still error";
    }
    static async CallView(c: Contract, func: string, args: any[]): Promise<any>
    {
        for (var i = 0; i < args.length; i++)
        {
            if (typeof args[i] == "string")
            {
                args[i] = this.GetString(args[i]);
            }
            else if (typeof args[i] == "object") {
                for (var x = 0; x < args[i].length; x++) {
                    if (typeof args[i][x] == "string") {
                        args[i][x] = this.GetString(args[i][x]);
                    }
                }
            }
        }
        let funcabi: ethers.utils.FunctionFragment = c.interface.getFunction(func);
        if (funcabi.stateMutability.includes("view") || funcabi.stateMutability.includes("pure"))
        {

        }
        else
        {
            throw "not a view function:" + func;
        }
        for (var i = 0; i < 3; i++)
        {
            try
            {
                return c[func](...args);
            }
            catch
            {
                console.log("retry view:" + (i + 1).toString() + ":" + func + ":" + JSON.stringify(args));
                let delay = 5000;;
                await new Promise(res => setTimeout(() => res(null), delay));
            }
        }
        throw "final still error";
    }
    static async GetWalletAddr(hre: HardhatRuntimeEnvironment, name: string): Promise<string>
    {
        let accounds = await hre.getNamedAccounts();
        return accounds[name];
    }
}

interface VerificationSubtaskArgs
{
    address: string;
    constructorArguments: any[];
    // Fully qualified name of the contract
    contract?: string;
    libraries?: Libraries;
}

class ContractDeployInfo
{
    name: string = "";
    deployer: string = "";
    args: string[] = [];
    libraries?: { [id: string]: string };
    verify?: string;
}
class GroupDeployInfo
{
    group: string = "";
    gen: number = 0;
    depends: string[] = [];
    contracts: ContractDeployInfo[] = [];
}
class ContractValues
{
    network: string = "";
    addresses?: { [id: string]: string };
    contracts?: { [id: string]: string };
}