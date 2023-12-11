import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from "../utils/util_testtool";
import * as hre from "hardhat";
import { getMysterybox1155Id } from "../init/config_MysteryBoxShopV2";
import { batch10_oracle_rand_extra_fee, oracle_rand_extra_fee } from "../init/init_config";

//gen5
describe("mystery box Test", function () {
    before(inittest);
    it("should openmb succ", openmb);
    it("should openmb batch succ", openmb_batch);
    it("should daily sign succ", daily_sign);
});

var testtool: TestTool;

var Random: Contract;
var MysteryBox1155: Contract;
var HeroNFTMysteryBox: Contract;
var VMTTMinePool: Contract;
var VMTT: Contract;
var DailySign: Contract;

async function inittest() {
    testtool = await TestTool.Init();

    MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");
    HeroNFTMysteryBox = ContractInfo.getContract("HeroNFTMysteryBox");
    Random = ContractInfo.getContract("Random");

    VMTTMinePool = ContractInfo.getContract("VMTTMinePool");
    VMTT = ContractInfo.getContract("VMTT");

    DailySign = ContractInfo.getContract("DailySign");

    // transfer vmtt to VMTTMinePool (1000w)
    let res = await ContractTool.CallView(VMTT, "balanceOf", ["addr:VMTTMinePool"]);
    let balance = BigNumber.from(res).toString();
    console.log("VMTTMinePool VMTT balance:", balance);
    if (BigInt(balance) <= 0) {
        await ContractTool.CallState(VMTT, "transfer", ["addr:VMTTMinePool", "10000000000000000000000000"]);
    }

    // transfer vmtt to DailySign (100w)
    const d_res = await ContractTool.CallView(VMTT, "balanceOf", ["addr:DailySign"]);
    const d_balance = BigNumber.from(d_res).toBigInt();
    logtools.loggreen("DailySign VMTT Balance: " + d_balance);
    if (d_balance <= 0) {
        await ContractTool.CallState(VMTT, "transfer", ["addr:DailySign", "1000000000000000000000000"]);
    }
}

async function openmb() {
    logtools.loggreen("==openmb");

    const mysteryboxIds = [
        [1, 10001],
        [1, 10002],
        [2, 10001],
        [2, 10002],
    ];

    for (let i = 0; i < mysteryboxIds.length; i++) {
        const randomType = mysteryboxIds[i][0];
        const mysteryType = mysteryboxIds[i][1];
        const tokenId = getMysterybox1155Id(randomType, mysteryType);
        console.log(`randomType:${randomType}, mysteryType:${mysteryType}, tokenid:${tokenId}`);

        //await ContractTool.CallState(MysteryBox1155, "mint", [testtool.addr0, tokenId, 1, []]);
        await ContractTool.CallState(MysteryBox1155, "setApprovalForAll", [HeroNFTMysteryBox.address, true]);

        // balance
        let balance_res = await ContractTool.CallView(MysteryBox1155, "balanceOf", [testtool.addr0, tokenId]);
        console.log(`balance: ` + BigNumber.from(balance_res).toString());

        //oracleOpenMysteryBox need to take fee
        var fee = { value: oracle_rand_extra_fee };
        let rc = await ContractTool.CallState(HeroNFTMysteryBox, "oracleOpenMysteryBox", [tokenId, fee]);
        let ev = ContractTool.GetEvent(rc, "OracleOpenMysteryBox");
        logtools.loggreen("openmb=" + ev);

        let reqid = BigNumber.from(ev[0]).toString();
        let pinfo = {
            gasLimit: 5000000,
            gasPrice: BigNumber.from(await testtool.provider.getGasPrice()).toString(),
        };
        await ContractTool.CallState(Random, "fulfillOracleRand", [reqid, 0, pinfo]);
    }

    logtools.loggreen("test succ");
}

async function openmb_batch() {

    logtools.loggreen("==openmb_batch");

    const mysteryboxIds = [
        [1, 10001],
        [1, 10002],
        [2, 10001],
        [2, 10002],
    ];

    for (let i = 0; i < mysteryboxIds.length; i++) {
        const randomType = mysteryboxIds[i][0];
        const mysteryType = mysteryboxIds[i][1];
        const tokenId = getMysterybox1155Id(randomType, mysteryType);
        console.log(`randomType:${randomType}, mysteryType:${mysteryType}, tokenid:${tokenId}`);

        //await ContractTool.CallState(MysteryBox1155, "mint", [testtool.addr0, tokenId, 10, []]);
        await ContractTool.CallState(MysteryBox1155, "setApprovalForAll", [HeroNFTMysteryBox.address, true]);

        //oracleOpenMysteryBox need to take fee
        var fee = { value: batch10_oracle_rand_extra_fee };
        let rc = await ContractTool.CallState(HeroNFTMysteryBox, "batchOracleOpenMysteryBox", [tokenId, 10, fee]);
        let ev = ContractTool.GetEvent(rc, "BatchOracleOpenMysteryBox");
        logtools.loggreen("openmb=" + ev);

        let reqid = BigNumber.from(ev[0]).toString();
        let pinfo = {
            gasLimit: 5000000,
            gasPrice: BigNumber.from(await testtool.provider.getGasPrice()).toString(),
        };
        await ContractTool.CallState(Random, "fulfillOracleRand", [reqid, 0, pinfo]);
    }
    
    logtools.loggreen("test succ");
}

async function daily_sign() {
    logtools.loggreen("==daily_sign");

    await getVMTTBalance();
    
    let sign_res = await ContractTool.CallView(DailySign, "_lastSignTime", [testtool.addr0]);
    let lastTIme = BigNumber.from(sign_res).toNumber();
    logtools.loggreen("my sign lastTime: " + lastTIme);
    
    let timeSlice = 86400;

    let currTs = Math.floor(new Date().getTime() / 1000);

    if (currTs + timeSlice > lastTIme) {
        await ContractTool.CallState(DailySign, "sign", []);

        let sign_res = await ContractTool.CallView(DailySign, "_lastSignTime", [testtool.addr0]);
        let lastTIme = BigNumber.from(sign_res).toNumber();
        logtools.loggreen("after sign lastTime: " + lastTIme);
    }

    await getVMTTBalance();

}

async function getVMTTBalance() {
    const d_res = await ContractTool.CallView(VMTT, "balanceOf", ["addr:DailySign"]);
    const d_balance = BigNumber.from(d_res).toBigInt();
    logtools.loggreen("DailySign VMTT Balance: " + d_balance);
    return d_balance;
}

