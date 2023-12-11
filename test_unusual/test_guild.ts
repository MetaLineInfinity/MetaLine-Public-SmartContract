
import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from '../utils/util_testtool';

//gen5
describe("guild Test", function () {
    before(inittest);
    it("should guild succ", test);
});

var testtool: TestTool;

import * as hre from "hardhat";

var GuildFactory: Contract;
var Guild: Contract;
var GuildConfig: Contract;
var GuildCodec: Contract;

async function inittest() {
    testtool = await TestTool.Init();

    GuildFactory = ContractInfo.getContract("GuildFactory");
    Guild = ContractInfo.getContract("Guild");
    GuildConfig = ContractInfo.getContract("GuildConfig");
}

async function test() {

    // 10000
    // createGuild(string guildName, string tokenName, uint256 usdValue) payable returns (address guildAddr)
    let guildName = "guild10000";
    let createRecp = await ContractTool.CallState(GuildFactory, "createGuild", [guildName, "eth", "1000000000", {value: "100000000000000"}]);
    let createEvent = ContractTool.GetEvent(createRecp, "GuildCreated");
    logtools.logblue("guild name:"+ createEvent[0].hash);
    logtools.logblue("guild addr:" + createEvent[1]);

    let guildNameHash = createEvent[0].hash;
    let guildAddr = createEvent[1];

    // let guildNameHash = "0x4ab4375f06b1b6d83a6d0bf9261e19d2207a07d906a78824deb635a9c0b61644";
    // let guildAddr = "0x965a161fCC25EFa81FbcF845e5370A49217a7A73";

    let guildPorxy = await ContractTool.GetVistualContract(Guild.signer, "Guild", guildAddr);

    // ownerTokenID = 0;
    
    // mint(address to, uint256 invitorTokenID) returns (uint256)
    let mintRecp = await ContractTool.CallState(guildPorxy, "mint", [testtool.addr1, 0]);
    let mintEvent = ContractTool.GetEvent(mintRecp, "GuildMemberNFTMint");
    let tokenId = mintEvent[1];
    console.log("mint member tokenId:" + tokenId);

    let mintRecp2 = await ContractTool.CallState(guildPorxy, "mint", [testtool.addr2, 0]);
    let mintEvent2 = ContractTool.GetEvent(mintRecp2, "GuildMemberNFTMint");
    let tokenId2 = mintEvent2[1];
    console.log("mint member tokenId2:" + tokenId2);

    let mintRecp3 = await ContractTool.CallState(guildPorxy, "mint", [testtool.addr3, 0]);
    let mintEvent3 = ContractTool.GetEvent(mintRecp3, "GuildMemberNFTMint");
    let tokenId3 = mintEvent3[1];
    console.log("mint member tokenId3:" + tokenId3);
    
    logtools.loggreen("test succ");
}
