import { eth_addr } from "./init_config";

export const TokenPrices_config = {
    setChainLinkTokenPriceSource: [
        [eth_addr, ""], // mainnet
    ],
    setDefiPoolSource: [
        // [eth_addr, [1, 1, "0x87425d8812f44726091831a9a109f4bdc3ea34b4"]] // for testnet , need modify TokenPrices contract
    ],
};
