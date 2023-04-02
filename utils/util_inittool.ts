import { Contract, ContractReceipt } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "./util_contractinfo";
import { ContractTool } from "./util_contracttool";

import { RegAll } from "../init/Init_Reg";
import { logtools } from "./util_log";
import { execSync } from "child_process";

export class InitTool
{
    static RegInitFuncs(hre: HardhatRuntimeEnvironment)
    {
        //init all names;
        InitTool.mapInitFunc = {};
        InitTool.mapInitFuncGroup = {};
        try
        {
            let names = ContractTool.GetGroupNames(hre);
            for (var d in names)
            {
                console.log("group=" + names[d]);
                InitTool.mapInitFuncGroup[names[d]] = new InitFunc();
                let group = ContractTool.GetGroup(hre, names[d]);
                if (group != null)
                {
                  
                    for (var i = 0; i < group?.contracts.length; i++)
                    {
                        let name = group.contracts[i].name;
                        InitTool.mapInitFunc[name] = new InitFunc();
                    }
                }
            }
        }
        catch (e: any)
        {
            console.log("error:" + e);
        }

        RegAll();


        console.log("reg end.");
    }
    static async InitFunc_Test(hre: HardhatRuntimeEnvironment, genid: number)
    {
        let groupnames = ContractTool.GetGroupNames(hre);
        for (var i = 0; i < groupnames.length; i++)
        {
            let name = groupnames[i];
            let group = ContractTool.GetGroup(hre, name);
            if (group != null)
            {
                if (group.gen == genid)
                    await InitTool.InitFunc_TestGroup(hre, name);
            }
        }
    }
    static async CheckFunc_All(hre: HardhatRuntimeEnvironment)
    {
        let names = ContractTool.GetGroupNames(hre);
        for (var d in names)
        {
            let group = ContractTool.GetGroup(hre, names[d]);
            if (group != null && group.gen > 0)
            {
                logtools.logcyan("==skip==" + group?.group + " this is only check by xdeploy group [name] gen=" + group.gen);
                continue;
            }
            await InitTool.CheckFunc_Group(hre, names[d]);
        }
    }
    static async CheckFunc_Group(hre: HardhatRuntimeEnvironment, name: string)
    {
        logtools.logcyan("==InitFunc_Group:" + name)
        let group = ContractTool.GetGroup(hre, name);
        if (group != null)
        {
            for (var i = 0; i < group?.contracts.length; i++)
            {
                let name = group.contracts[i].name;
                await InitTool.CheckFunc_One(hre, name);
            }
        }
        logtools.logcyan("==InitFunc_Group:" + name + " End");
    }

    static async CheckFunc_One(hre: HardhatRuntimeEnvironment, name: string)
    {
        if (InitTool.mapInitFunc[name] == undefined)
        {
            logtools.logred("..not have contract init func:" + name);
            return false;
        }
        let func = InitTool.mapInitFunc[name];
        if (func.checkcall == null)
        {
            logtools.logyellow("..no check call:" + name);
            return false;
        }
        else
        {
            let result = false;
            logtools.logcyan("  --check:" + name + "{")
            try
            {
                result = await func.checkcall(hre);
            }
            catch (e: any)
            {
                console.log("..error:" + e);
                result = false;
            }
            if (result)
                logtools.logcyan("  }end check:" + name + " result=" + result);
            else
                logtools.logred("  }end check:" + name + " result=" + result);

        }
    }
    static async InitFunc_All(hre: HardhatRuntimeEnvironment)
    {
        let names = ContractTool.GetGroupNames(hre);
        for (var d in names)
        {
            let group = ContractTool.GetGroup(hre, names[d]);
            if (group != null && group.gen > 0)
            {
                logtools.logcyan("==skip==" + group?.group + " this is only init by xdeploy group [name] gen=" + group.gen);
                continue;
            }
            await InitTool.InitFunc_Group(hre, names[d]);
        }
    }
    static async InitFunc_GenGroup(hre: HardhatRuntimeEnvironment, genid: number)
    {
        let groupnames = ContractTool.GetGroupNames(hre);
        for (var i = 0; i < groupnames.length; i++)
        {
            let name = groupnames[i];
            let group = ContractTool.GetGroup(hre, name);
            if (group != null)
            {
                if (group.gen == genid)
                    await InitTool.InitFunc_Group(hre, name);
            }
        }
    }
    static async ConfigFunc_GenGroup(hre: HardhatRuntimeEnvironment, genid: number)
    {
        let groupnames = ContractTool.GetGroupNames(hre);
        for (var i = 0; i < groupnames.length; i++)
        {
            let name = groupnames[i];
            let group = ContractTool.GetGroup(hre, name);
            if (group != null)
            {
                if (group.gen == genid)
                    await InitTool.ConfigFunc_Group(hre, name);
            }
        }
    }
    static async InitFunc_Group(hre: HardhatRuntimeEnvironment, name: string)
    {
        logtools.logcyan("==InitFunc_Group:" + name + "{")
        let group = ContractTool.GetGroup(hre, name);
        if (group != null)
        {
            for (var i = 0; i < group?.contracts.length; i++)
            {
                let name = group.contracts[i].name;
                await InitTool.InitFunc_One(hre, name);
            }
        }
        let func = InitTool.mapInitFuncGroup[name];
        if (func.initcall == null)
        {
            logtools.logyellow("..no init call:" + name);
        }
        else
        {
            let result = false;

            logtools.logcyan("  --init:" + name + "{")
            // try {

            result = await func.initcall(hre);
            // }
            // catch (e: any) {
            //     console.log("error:" + e);
            //     result = false;
            // }
            if (InitTool.inittwice)
            {
                // try {
                result = await func.initcall(hre);
                // }
                // catch (e: any) {
                //     console.log("error:" + e);
                //     result = false;
                // }
            }

            if (result)
                logtools.logcyan("  }end init:" + name + " result=" + result);
            else
                logtools.logred("  }end init:" + name + " result=" + result);
        }
        logtools.logcyan("}InitFunc_Group:" + name + " End");
    }
    static async InitFunc_TestGroup(hre: HardhatRuntimeEnvironment, name: string)
    {
        var test = hre.tasks["test"];
        console.log("tt="+JSON.stringify(test));
        let files = InitTool.mapTestGroup[name];
        if (files != null)
        {
            for (var i = 0; i < files.length; i++)
            {
                var file = files[i];
                console.log("TestGroup call:" + file);

                await hre.run("test",{"testFiles":[file]});
            }
        }
    }

    static inittwice: boolean = false;
    static async InitFunc_One(hre: HardhatRuntimeEnvironment, name: string)
    {
        if (InitTool.mapInitFunc[name] == undefined || InitTool.mapInitFunc[name].hadreg == false)
        {
            logtools.logred("..not reg init call:" + name);
            return false;
        }
        let func = InitTool.mapInitFunc[name];
        if (func.initcall == null)
        {
            logtools.logyellow("..no init call:" + name);
            return false;
        }
        else
        {
            let result = false;

            logtools.logcyan("  --init:" + name + "{")
            // try {

            result = await func.initcall(hre);
            // }
            // catch (e: any) {
            //     console.log("error:" + e);
            //     result = false;
            // }
            if (InitTool.inittwice)
            {
                // try {
                result = await func.initcall(hre);
                // }
                // catch (e: any) {
                //     console.log("error:" + e);
                //     result = false;
                // }
            }

            if (result)
                logtools.logcyan("  }end init:" + name + " result=" + result);
            else
                logtools.logred("  }end init:" + name + " result=" + result);
        }
    }
    static async ConfigFunc_Group(hre: HardhatRuntimeEnvironment, name: string)
    {
        logtools.logcyan("==ConfigFunc_Group:" + name + "{")
        let group = ContractTool.GetGroup(hre, name);
        if (group != null)
        {
            for (var i = 0; i < group?.contracts.length; i++)
            {
                let name = group.contracts[i].name;
                await InitTool.ConfigFunc_One(hre, name);
            }
        }
        let func = InitTool.mapInitFuncGroup[name];
        if (func.configcall == null)
        {
            logtools.logyellow("..no config call:" + name);
        }
        else
        {
            let result = false;

            logtools.logcyan("  --init:" + name + "{")
            // try {

            result = await func.configcall(hre);
            // }
            // catch (e: any) {
            //     console.log("error:" + e);
            //     result = false;
            // }
            if (InitTool.inittwice)
            {
                // try {
                result = await func.configcall(hre);
                // }
                // catch (e: any) {
                //     console.log("error:" + e);
                //     result = false;
                // }
            }

            if (result)
                logtools.logcyan("  }end init:" + name + " result=" + result);
            else
                logtools.logred("  }end init:" + name + " result=" + result);
        }
        logtools.logcyan("}InitFunc_Group:" + name + " End");
    }
    static async ConfigFunc_One(hre: HardhatRuntimeEnvironment, name: string)
    {
        if (InitTool.mapInitFunc[name] == undefined || InitTool.mapInitFunc[name].hadreg == false)
        {
            logtools.logred("..not reg init call:" + name);
            return false;
        }
        let func = InitTool.mapInitFunc[name];
        if (func.configcall == null)
        {
            logtools.logyellow("..no config call:" + name);
            return false;
        }
        else
        {
            let result = false;

            logtools.logcyan("  --init:" + name + "{")
            // try {

            result = await func.configcall(hre);
            // }
            // catch (e: any) {
            //     console.log("error:" + e);
            //     result = false;
            // }
            if (InitTool.inittwice)
            {
                // try {
                result = await func.configcall(hre);
                // }
                // catch (e: any) {
                //     console.log("error:" + e);
                //     result = false;
                // }
            }

            if (result)
                logtools.logcyan("  }end init:" + name + " result=" + result);
            else
                logtools.logred("  }end init:" + name + " result=" + result);
        }
    }

    private static mapInitFunc: { [id: string]: InitFunc } = {}
    public static Reg(name: string
        , init?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>
        , check?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>
        , config?:  (hre: HardhatRuntimeEnvironment) => Promise<boolean>)
    {

        if (InitTool.mapInitFunc[name] == undefined)
            throw "do not have this contract." + name;

        InitTool.mapInitFunc[name].initcall = init;
        InitTool.mapInitFunc[name].checkcall = check;
        InitTool.mapInitFunc[name].configcall = check;
        InitTool.mapInitFunc[name].hadreg = true;
    }

    //this will not called by init all
    private static mapInitFuncGroup: { [id: string]: InitFunc } = {}
    private static mapTestGroup: { [id: string]: string[] } = {}
    public static RegForGroup(name: string
        , init?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>
        , check?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>
        , config?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>
        , testfiles?: string[]
    )
    {

        if (InitTool.mapInitFuncGroup[name] == undefined)
            throw "do not have this contract group.";

        InitTool.mapInitFuncGroup[name].initcall = init;
        InitTool.mapInitFuncGroup[name].checkcall = check;
        InitTool.mapInitFuncGroup[name].configcall = config;
        InitTool.mapInitFuncGroup[name].hadreg = true;
        if (testfiles != null)
            InitTool.mapTestGroup[name] = testfiles;
    }


}

class InitFunc
{
    initcall?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>;
    checkcall?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>;
    configcall?: (hre: HardhatRuntimeEnvironment) => Promise<boolean>;
    hadreg: boolean = false;
}