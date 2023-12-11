const zeroaddr = "0x0000000000000000000000000000000000000000";

export const getMysterybox1155Id = (randomType, mysteryType) => {
    let r = (BigInt(randomType) << BigInt(32)) | BigInt(mysteryType);
    return r.toString();
};

export const MysteryBoxShopV2_config = {
    // setOnSaleMysteryBox(string pairName, tuple(address mysteryBox1155Addr, uint256 mbTokenId, address tokenAddr, uint256 tokenId, uint256 price, uint64 beginTime, uint64 endTime, uint64 renewTime, uint256 renewCount, uint32 whitelistId, address nftholderCheck, uint32 perAddrLimit, uint32 discountId) saleConfig, tuple(uint64 nextRenewTime, uint256 countLeft) saleData)
    setOnSaleMysteryBox: [

        ["sale1", ["addr:MysteryBox1155", getMysterybox1155Id(1, 10001), zeroaddr, 0, "180000000000000", "0", 0, 3600, 99999, 0, zeroaddr, 0, 0], [0, 99999]],
        ["sale2", ["addr:MysteryBox1155", getMysterybox1155Id(1, 10002), zeroaddr, 0, "180000000000000", "0", 0, 3600, 99999, 0, zeroaddr, 0, 0], [0, 99999]],

        ["sale3", ["addr:MysteryBox1155", getMysterybox1155Id(2, 10001), zeroaddr, 0, "180000000000000", "0", 0, 3600, 99999, 0, zeroaddr, 0, 0], [0, 99999]],
        ["sale4", ["addr:MysteryBox1155", getMysterybox1155Id(2, 10002), zeroaddr, 0, "180000000000000", "0", 0, 3600, 99999, 0, zeroaddr, 0, 0], [0, 99999]],
    ],
};
