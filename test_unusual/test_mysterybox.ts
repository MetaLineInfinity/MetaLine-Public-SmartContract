
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';

//gen5
describe("mystery box Test", function () {
    before(inittest);
    it("should openmb succ", openmb);
    it("should openmb batch succ", openmb_batch);
});

var testtool: TestTool;

import * as hre from "hardhat";

var MockERC20: Contract;

var MockERC721_V1: Contract;
var MockERC1155_V1: Contract;
var Random: Contract;
var HeroNFT: Contract;
var HeroNFTCodec_V1: Contract;
var MysteryBox1155: Contract;
var HeroNFTMysteryBox: Contract;
var MysteryBoxShop: Contract;
async function inittest() {
    testtool = await TestTool.Init();
    MockERC20 = await ContractTool.GetVistualContract(testtool.signer0, "MockERC20", "addr:MockERC20");
    MockERC721_V1 = ContractInfo.getContract("MockERC721_V1");
    MockERC1155_V1 = ContractInfo.getContract("MockERC1155_V1");
    HeroNFT = ContractInfo.getContract("HeroNFT");
    HeroNFTCodec_V1 = ContractInfo.getContract("HeroNFTCodec_V1");
    MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");
    HeroNFTMysteryBox = ContractInfo.getContract("HeroNFTMysteryBox");
    Random = ContractInfo.getContract("Random");
    MysteryBoxShop = ContractInfo.getContract("MysteryBoxShop");
    ContractTool.PassBlock(hre, 1000);

}

async function openmb() {

    let randomid = BigNumber.from(1);
    let mysterytype = 1;

    //tokenid = (uint64)(randomid)<<32 | (uint32)mysterytype
    let tokenId = randomid.shl(32).add(1);

    console.log("tokenid=" + tokenId);


    await ContractTool.CallState(MysteryBox1155, "mint", [testtool.addr0, tokenId, 1, []]);
    await ContractTool.CallState(MysteryBox1155, "setApprovalForAll", [HeroNFTMysteryBox.address, true]);

    //open succ
    logtools.logcyan("item 1 tokenId=" + tokenId);

    //oracleOpenMysteryBox need to take fee
    var fee = {
        value: "13000000000000000"
    }
    let rc = await ContractTool.CallState(HeroNFTMysteryBox, "oracleOpenMysteryBox", [tokenId, fee]);
    let ev = ContractTool.GetEvent(rc, "OracleOpenMysteryBox");
    logtools.loggreen("openmb=" + ev);
    let reqid = ev[0];


    let pinfo = {
        gasLimit: 5000000,
        gasPrice: await testtool.provider.getGasPrice(),
    };
    await ContractTool.CallState(Random, "fulfillOracleRand", [reqid, 0, pinfo]);
    logtools.loggreen("test succ");
}
async function openmb_batch() {

    let randomid = BigNumber.from(1);
    let mysterytype = 1;

    //tokenid = (uint64)(randomid)<<32 | (uint32)mysterytype
    let tokenId = randomid.shl(32).add(1);

    console.log("tokenid=" + tokenId);


    await ContractTool.CallState(MysteryBox1155, "mint", [testtool.addr0, tokenId, 10, []]);
    await ContractTool.CallState(MysteryBox1155, "setApprovalForAll", [HeroNFTMysteryBox.address, true]);

    //open succ
    logtools.logcyan("item 1 tokenId=" + tokenId);

    //oracleOpenMysteryBox need to take fee
    var fee = {
        value: "13000000000000000"
    }
    let rc = await ContractTool.CallState(HeroNFTMysteryBox, "batchOracleOpenMysteryBox", [tokenId, 10, fee]);
    let ev = ContractTool.GetEvent(rc, "BatchOracleOpenMysteryBox");
    logtools.loggreen("openmb=" + ev);
    let reqid = ev[0];


    let pinfo = {
        gasLimit: 5000000,
        gasPrice: await testtool.provider.getGasPrice(),
    };

    await ContractTool.CallState(Random, "fulfillOracleRand", [reqid, 0, pinfo]);
    logtools.loggreen("test succ");

}
