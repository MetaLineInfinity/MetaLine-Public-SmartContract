
import * as fs from "fs";
import { Address } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
export class logtools {
    static log(text:string):void
    {
        console.log(text);
    }
    static logred(text:string):void
    {
        console.log('\x1b[31m%s\x1b[0m',text);
    }
    static loggreen(text:string):void
    {
        console.log('\x1b[32m%s\x1b[0m',text);
    }
    static logyellow(text:string):void
    {
        console.log('\x1b[33m%s\x1b[0m',text);
    }
    static logblue(text:string):void
    {
        console.log('\x1b[34m%s\x1b[0m',text);
    }
    static logmagenta(text:string):void
    {
        console.log('\x1b[35m%s\x1b[0m',text);
    }
    static logcyan(text:string):void
    {
        console.log('\x1b[36m%s\x1b[0m',text);
    }
    static configfile: string = "";
    static appendfile: string = "contractinfo.txt";
    static UpdateConfigFileName(hre: HardhatRuntimeEnvironment): void {
        logtools.configfile = "deployresult_" + hre.network.name + ".json";
        console.log("configfile=" + logtools.configfile);
    }
    static RemoveConfig() {
        fs.rm(this.configfile, () => { });
    }
    static RemoveAppend() {
        fs.rm(this.appendfile, () => { });
    }
    static SetContract(name: string, deployer: string, addr: Address, abireadable: string[], bytecode: string) {

        var srcjson: any = null;
        try {
            let buffer = fs.readFileSync(logtools.configfile);
            srcjson = JSON.parse(buffer.toString());
        }
        catch
        {
            logtools.logred("--error read file:"+logtools.configfile);
            srcjson = {};
        }

        if (srcjson["contracts"] == undefined)
            srcjson["contracts"] = {};

        srcjson["contracts"][name] = { "deployer": deployer, "addr": addr, "abi": abireadable};

        fs.writeFileSync(logtools.configfile, JSON.stringify(srcjson, null, 1));

    }
    static Append(line: string) {
        fs.appendFile(logtools.appendfile, line + "\r\n", () => { });
    }
    static SetAccounts(addrrs: string[]) {

        var srcjson: any = null;
        try {
            let buffer = fs.readFileSync(logtools.configfile);
            srcjson = JSON.parse(buffer.toString());
        }
        catch
        { 
            logtools.logred("--error read file:"+logtools.configfile);
            srcjson = {};
        }



        srcjson["accounts"] = addrrs;

        fs.writeFileSync(logtools.configfile, JSON.stringify(srcjson, null, 1));
    }
    static SetNamedAccounts(addrrs: { [name: string]: string }) {

        var srcjson: any = null;
        try {
            let buffer = fs.readFileSync(logtools.configfile);
            srcjson = JSON.parse(buffer.toString());
        }
        catch
        {
            logtools.logred("--error read file:"+logtools.configfile);
            srcjson = {};
        }



        srcjson["namedaccounts"] = addrrs;

        fs.writeFileSync(logtools.configfile, JSON.stringify(srcjson, null, 1));
    }
}
