
import { BigNumber, ContractReceipt, ethers } from "ethers";

import { task } from "hardhat/config";
import { ContractInfo } from "./utils/util_contractinfo";
import { ContractTool } from "./utils/util_contracttool";
import { InitTool } from "./utils/util_inittool";
import { logtools } from "./utils/util_log";

export module extTask {
    export function RegTasks() {

        task("xbalance", "blance of one addr")
            .addPositionalParam("addrname", "like 'deployer'")
            .setAction(async ({ addrname }, _hre) => {
                let name = addrname;
                console.log("name=" + name);
                let addr = (await _hre.getNamedAccounts())[name];
                console.log("addr=" + addr);
                let signer = await _hre.ethers.getSigner(addr);
                let blanceof: BigNumber = await signer.getBalance();
                console.log("balanceof=" + ethers.utils.formatEther(blanceof));
            });

        task("xdeploy", "deplay contracts")
            .addPositionalParam("type", "[all|group|one]")
            .addOptionalPositionalParam("name")
            .setAction(async ({ type, name }, _hre) => {
                let _name = name as string;
                console.log("xdeploy:" + type + "," + _name)
                if (type == "all") {
                    await ContractTool.DeployAll(_hre);
                }
                else if (type == "group") {
                    await ContractTool.DeployGroup(_hre, _name);
                }
                else if (type == "one") {

                    await ContractTool.LoadDeployInfo(_hre);
                    await ContractInfo.LoadFromFile(_hre);
                    let info = ContractTool.GetInfo(_hre, _name);
                    if (info == null) throw "not found contract.";
                    await ContractTool.DeployOne(_hre, info);
                }
                else {
                    throw "not support this type.";
                }
            });

        task("xverify", "verify contracts")
            .addPositionalParam("type", "[all|group|one]")
            .addOptionalPositionalParam("name")
            .setAction(async ({ type, name }, _hre) => {
                let _name = name as string;
                console.log("xverify:" + type + "," + _name)
                if (type == "all") {
                    await ContractTool.DeployAll(_hre);
                    await ContractTool.VerifyAll(_hre);
                }
                else if (type == "group") {
                    await ContractTool.DeployGroup(_hre, _name);
                    await ContractTool.VerifyGroup(_hre, _name);
                }
                else if (type == "one") {
                    await ContractTool.LoadDeployInfo(_hre);
                    await ContractInfo.LoadFromFile(_hre);
                    let info = ContractTool.GetInfo(_hre, _name);
                    if (info == null) throw "not found contract.";
                    await ContractTool.DeployOne(_hre, info);
                    await ContractTool.VerifyOne(_hre, info);
                }
                else {
                    throw "not support this type.";
                }
            });

        task("xcheck", "check contracts")
            .addPositionalParam("type", "[all|group|one]")
            .addOptionalPositionalParam("name")
            .setAction(async ({ type, name }, _hre) => {
                console.log("==xcheck");
                await ContractTool.LoadDeployInfo(_hre);
                await ContractInfo.LoadFromFile(_hre);
                InitTool.RegInitFuncs(_hre);

                let _name = name as string;
                console.log("xcheck:" + type + "," + _name)
                if (type == "all") {
                    await InitTool.CheckFunc_All(_hre);

                }
                else if (type == "group") {
                    await InitTool.CheckFunc_Group(_hre, _name);
                }
                else if (type == "one") {
                    await InitTool.CheckFunc_One(_hre, _name);
                }
                else {
                    throw "not support this type.";
                }
            });

        task("xinit", "init contracts")
            .addPositionalParam("type", "[all|group|one]")
            .addOptionalPositionalParam("name")
            .setAction(async ({ type, name }, _hre) => {
                console.log("==xinit");
                await ContractTool.LoadDeployInfo(_hre);
                if (_hre.network.name == "hardhat") {
                    //本地测试合约是没有的，必须跑一遍

                    await ContractTool.DeployAll(_hre);
                    InitTool.inittwice = true;
                }
                await ContractInfo.LoadFromFile(_hre);
                InitTool.RegInitFuncs(_hre);

                let _name = name as string;
                console.log("xinit:" + type + "," + _name)
                if (type == "all") {
                    await InitTool.InitFunc_All(_hre);

                }
                else if (type == "group") {
                    await InitTool.InitFunc_Group(_hre, _name);
                }
                else if (type == "one") {
                    await InitTool.InitFunc_One(_hre, _name);
                }
                else {
                    throw "not support this type.";
                }
            });
        task("xgen", "deploy and init a gen contracts")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                console.log("==xgen");
                await ContractTool.DeployGenGroup(_hre, genid);
                InitTool.RegInitFuncs(_hre);

                await InitTool.InitFunc_GenGroup(_hre, genid);
                await InitTool.ConfigFunc_GenGroup(_hre, genid);
            });
        task("xgeninitonly", "deploy and init a gen contracts")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                console.log("==xgen");
                await ContractTool.DeployGenGroup(_hre, genid);
                InitTool.RegInitFuncs(_hre);

                await InitTool.InitFunc_GenGroup(_hre, genid);
            });
        task("xgenconfigonly", "deploy and init a gen contracts")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                console.log("==xgen");
                await ContractTool.LoadDeployInfo(_hre);
                await ContractInfo.LoadFromFile(_hre);
                //await ContractTool.DeployGenGroup(_hre, genid);
                InitTool.RegInitFuncs(_hre);

                await InitTool.ConfigFunc_GenGroup(_hre, genid);
            });

        task("xgento", "deploy and init contracts to target gen")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                console.log("==xgento");
                await ContractTool.DeployAll(_hre);
                InitTool.RegInitFuncs(_hre);
                await InitTool.InitFunc_All(_hre);

                for (var i = 1; i <= genid; i++) {
                    logtools.loggreen("==xgen " + i);
                    await ContractTool.DeployGenGroup(_hre, i);
                    await InitTool.InitFunc_GenGroup(_hre, i);
                    await InitTool.ConfigFunc_GenGroup(_hre, i);
                }
            });
        task("xgento_initonly", "deploy and init contracts to target gen")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                console.log("==xgento");
                await ContractTool.DeployAll(_hre);
                InitTool.RegInitFuncs(_hre);
                await InitTool.InitFunc_All(_hre);

                for (var i = 1; i <= genid; i++) {
                    logtools.loggreen("==xgen " + i);
                    await ContractTool.DeployGenGroup(_hre, i);
                    await InitTool.InitFunc_GenGroup(_hre, i);
                }
            });
        task("xgento_configonly", "deploy and init contracts to target gen")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                console.log("==xgento");
                await ContractTool.LoadDeployInfo(_hre);
                await ContractInfo.LoadFromFile(_hre);
                //await ContractTool.DeployAll(_hre);
                InitTool.RegInitFuncs(_hre);
                //await InitTool.InitFunc_All(_hre);

                for (var i = 1; i <= genid; i++) {
                    logtools.loggreen("==xgen " + i);
                    //await ContractTool.DeployGenGroup(_hre, i);
                    await InitTool.ConfigFunc_GenGroup(_hre, i);
                }
            });
        task("xgentest", "run tests for target gen")
            .addPositionalParam("genid", "numbers for gen,like 4")
            .setAction(async ({ genid }, _hre) => {
                await ContractTool.LoadDeployInfo(_hre);
                await ContractInfo.LoadFromFile(_hre);
                console.log("==xgentest");
                InitTool.RegInitFuncs(_hre);
                await InitTool.InitFunc_Test(_hre, genid);

            });

        task("xtest", "run test")
            .addPositionalParam("testfile", "test file name")
            .setAction(async ({ testfile }, _hre) => {
                await ContractTool.LoadDeployInfo(_hre);
                await ContractInfo.LoadFromFile(_hre);
                console.log("==xtest");
                console.log("file:" + testfile);

                await _hre.run("test",{"testFiles":[testfile]});
            });

    }
}