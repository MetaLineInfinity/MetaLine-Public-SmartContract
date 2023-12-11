import { eth_addr } from "./init_config";

export const DirectMysteryBox_config = {
    // setOnSaleDirectMB(uint32 directMBID, tuple(address randsource, uint32 mysteryType, address tokenAddr, uint256 tokenId, uint256 price, uint64 beginTime, uint64 endTime, uint64 renewTime, uint256 renewCount) saleConfig, tuple(uint64 nextRenewTime, uint256 countLeft) saleData)
    setOnSaleDirectMB: [
        [
            "1",
            [
                "addr:HeroNFTMysteryBoxRandSource",
                "4",
                eth_addr,
                "0",
                "2700000000000000",
                "0",
                "0",
                "86400",
                "100",
            ],
            ["0", "100"],
        ],
        [
            "2",
            [
                "addr:HeroNFTMysteryBoxRandSource",
                "5",
                eth_addr,
                "0",
                "6500000000000000",
                "0",
                "0",
                "86400",
                "100",
            ],
            ["0", "100"],
        ],
        [
            "3",
            [
                "addr:HeroNFTMysteryBoxRandSource",
                "6",
                eth_addr,
                "0",
                "2700000000000000",
                "0",
                "0",
                "86400",
                "100",
            ],
            ["0", "100"],
        ],
        [
            "4",
            [
                "addr:HeroNFTMysteryBoxRandSource",
                "7",
                eth_addr,
                "0",
                "6500000000000000",
                "0",
                "0",
                "86400",
                "100",
            ],
            ["0", "100"],
        ],
    ],
};
