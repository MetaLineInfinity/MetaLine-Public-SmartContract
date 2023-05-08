import { eth_addr } from "./init_config";

export const TokenPrices_config = {
    setChainLinkTokenPriceSource: [
        [eth_addr, "0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612"], // mainnet
        //[eth_addr, "0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08"], // testnet
    ],
    setDefiPoolSource: [
        // ["addr:MockERC20", "addr:MockERC20"], // test
        //["addr:MTT", "addr:MTT"], // test
        //["addr:MTT", [1, 1, "0x87425d8812f44726091831a9a109f4bdc3ea34b4"]] // mainnet
    ],
};
