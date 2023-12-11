import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

export class Init_Market {
    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Market");

        // TO DO : init HeroPetTrain/NFTAttrSource_V2

//======init market

        let PortMarketFactory  = ContractInfo.getContract("PortMarketFactory");

        const HeroNFT = ContractInfo.getContract("HeroNFT");
        const WarrantNFT = ContractInfo.getContract("WarrantNFT");
        const ShipNFT = ContractInfo.getContract("ShipNFT");

        const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");

        const DATA_ROLE = await ContractTool.CallView(WarrantNFT, "DATA_ROLE", []);

        const receive_mb_income_addr = ContractTool.GetAddrInValues("receive_mb_income_addr");


        // HeroPetTrain
        // --income
        await ContractTool.CallState(HeroPetTrain, "setReceiveIncomeAddr", ["addr:receive_mb_income_addr"]);
        logtools.loggreen(`HeroPetTrain set income receiver to addr:${receive_mb_income_addr}`);
        // --TPO
        await ContractTool.CallState(HeroPetTrain, "setTPOracleAddr", ["addr:TokenPrices"]);
        // --init
        await ContractTool.CallState(HeroPetTrain, "init", ["addr:WarrantNFT", "addr:HeroNFT", "addr:MTTGold"]);
        // --grantRole
        await ContractTool.CallState(HeroNFT, "grantRole", [DATA_ROLE, "addr:HeroPetTrain"]);

        // // NFTAttrSource_V2 ?? next update ?
        // await ContractTool.CallState(ShipNFT, "setAttrSource", ["addr:NFTAttrSource_V2"]);
        // await ContractTool.CallState(HeroNFT,"setAttrSource",["addr:NFTAttrSource_V2"]);

        // PortMarket

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_Market");

        //const NFTAttrSource_V2 = ContractInfo.getContract("NFTAttrSource_V2");        
        const HeroPetTrain = ContractInfo.getContract("HeroPetTrain");
        const PortMarketFactory = ContractInfo.getContract("PortMarketFactory");
        const Shipyard = ContractInfo.getContract("Shipyard");

        let define_configs: any = [];
        

        // // set config
        // for (let i = 0; i < define_configs.length; i++) {
        //     const contract = define_configs[i].contract;
        //     const name = define_configs[i].name;
        //     for (var func in define_configs[i].configs) {
        //         const configs = define_configs[i].configs[func];
        //         for (let j = 0; j < configs.length; j++) {
        //             await ContractTool.CallState(contract, func, configs[j]);
        //             logtools.logblue("SET Contract:" + name + ", func:" + func + ", args:" + configs[j].toString());
        //         }
        //     }
        // }

        // PortMarket NEXT2
        for (let portid=1; portid<=2; portid++) {
            let pmAddr = await ContractTool.CallView(PortMarketFactory, "portMarkets", [portid]);
            if(pmAddr == undefined || pmAddr == "0x0000000000000000000000000000000000000000"){
                let recpt = await ContractTool.CallState(PortMarketFactory, "createPortMarket", [portid]);
                let event = ContractTool.GetEvent(recpt, "PortMarketCreated");
                logtools.loggreen(`create port[${portid}] market=` + event);
                pmAddr = event[1];
            }
            else {
                logtools.loggreen(`port[${portid}] market already created`);
            }
            
            // create succ
            logtools.logcyan(`port ${portid} market addr=` + pmAddr);

            // setServiceOp
            let portMarketPorxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarket", pmAddr);
            await ContractTool.CallState(portMarketPorxy, "setServiceOp", ["addr:operater_address"]);

            // create pair: createSwapPair(address token0, uint32 itemid) returns (address swapAddr)
            let itemids = [1000001, 1000002, 1000003, 1000004, 1000005, 1000006, 1000007, 1000008, 1000009, 1000010, 2000001, 2000002, 2000003, 2000004, 2000005, 2000006, 2000007, 2000008, 2000009, 2000010, 1200001, 1200002, 1200003, 1200004, 1200005, 1200006, 1200007, 1200008, 1200009, 1200010, 2200001, 2200002, 2200003, 2200004, 2200005, 2000011 ];
            for (let j = 0; j < itemids.length; j++) {
                let itemid = itemids[j];

                let pmpairAddr = await ContractTool.CallView(portMarketPorxy, "getSwapPair", ["addr:MTTGold", itemid]);
                if (pmpairAddr == undefined || pmpairAddr == "0x0000000000000000000000000000000000000000") {
                    let recpt = await ContractTool.CallState(portMarketPorxy, "createSwapPair", ["addr:MTTGold", itemid]);
                    let event = ContractTool.GetEvent(recpt, "Pair_Created");
                    logtools.loggreen(`create port[${portid}] itemid[${itemid}] market pair=` + event);
                    pmpairAddr = event[3];
                }
                else {
                    logtools.loggreen(`port[${portid}] itemid[${itemid}] market already created`);
                }
            }
        }

        // let pm1Addr = await ContractTool.CallView(PortMarketFactory, "portMarkets", [1]);
        // let portMarket1Porxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarket", pm1Addr);
        // await ContractTool.CallState(portMarket1Porxy, "setServiceOp", [PortMarketFactory.signer.getAddress()]);
        // for(const key in items_p1){
        //     await ContractTool.CallState(portMarket1Porxy, "off2onChain_item", [key, "0xB70FEaA31d51e5873653f58f92070273f98934d9", items_p1[key]]);
        // }
        // await ContractTool.CallState(portMarket1Porxy, "setServiceOp", ["addr:operater_address"]);

        // let pm2Addr = await ContractTool.CallView(PortMarketFactory, "portMarkets", [2]);
        // let portMarket2Porxy = await ContractTool.GetVistualContract(PortMarketFactory.signer, "PortMarket", pm2Addr);
        // await ContractTool.CallState(portMarket2Porxy, "setServiceOp", [PortMarketFactory.signer.getAddress()]);
        // for(const key in items_p2){
        //     await ContractTool.CallState(portMarket2Porxy, "off2onChain_item", [key, "0xB70FEaA31d51e5873653f58f92070273f98934d9", items_p2[key]]);
        // }
        // await ContractTool.CallState(portMarket2Porxy, "setServiceOp", ["addr:operater_address"]);

        return true;
    }
}     