import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from "../utils/util_testtool";
import * as hre from "hardhat";

describe("mystery box shop v2 Test", function () {
    before(inittest);
    it("should buy mb succ", buymb);
    it("should buy mb batch succ", buymb_batch);
});

var testtool: TestTool;
var MysteryBox1155: Contract;
var MysteryBoxShopV2: Contract;

async function inittest() {
    testtool = await TestTool.Init();

    MysteryBox1155 = ContractInfo.getContract("MysteryBox1155");
    MysteryBoxShopV2 = ContractInfo.getContract("MysteryBoxShopV2");

    await ContractTool.PassBlock(hre, 1000);
}

async function buymb() {
    logtools.loggreen("==buymb");

    await ContractTool.CallState(MysteryBoxShopV2, "buyMysteryBox", ["sale1", { value: "33000000000000" }]);
    await ContractTool.CallState(MysteryBoxShopV2, "buyMysteryBox", ["sale2", { value: "33000000000000" }]);
    await ContractTool.CallState(MysteryBoxShopV2, "buyMysteryBox", ["sale3", { value: "33000000000000" }]);
    await ContractTool.CallState(MysteryBoxShopV2, "buyMysteryBox", ["sale4", { value: "33000000000000" }]);
}

async function buymb_batch() {
    logtools.loggreen("==buymb_batch");

    await ContractTool.CallState(MysteryBoxShopV2, "batchBuyMysterBox", ["sale1", 10, { value: "330000000000000" }]);
    await ContractTool.CallState(MysteryBoxShopV2, "batchBuyMysterBox", ["sale2", 10, { value: "330000000000000" }]);
    await ContractTool.CallState(MysteryBoxShopV2, "batchBuyMysterBox", ["sale3", 10, { value: "330000000000000" }]);
    await ContractTool.CallState(MysteryBoxShopV2, "batchBuyMysterBox", ["sale4", 10, { value: "330000000000000" }]);
}
