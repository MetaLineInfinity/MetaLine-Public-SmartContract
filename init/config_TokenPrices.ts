import { eth_addr } from "./init_config";

export const TokenPrices_config = {
    setChainLinkTokenPriceSource: [
        // [eth_addr, ""], // mainnet
    ],
    setDefiPoolSource: [
        [eth_addr, [1, 0, "0xcD52cbc975fbB802F82A1F92112b1250b5a997Df"]] // for zksync, need modify TokenPrices contract
    ],
};
