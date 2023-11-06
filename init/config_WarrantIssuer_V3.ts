import { addChargeToken } from "./init_config";

export const WarrantIssuer_V3_config = {
    addChargeToken: addChargeToken,
    setWarrantPrice: [
        ["1", "500000000"],
        ["2", "550000000"],
        ["3", "600000000"],
        ["4", "1000000000"],
        ["5", "1050000000"],
        ["6", "1100000000"],
        ["7", "1500000000"],
        ["8", "1550000000"],
        ["9", "1600000000"],
        ["10", "2000000000"],
    ],
    setWarrantUpgradePrice: [
        ["1", "1", "1", "70000000"],
        ["1", "1", "2", "105000000"],
        ["1", "1", "3", "157500000"],
        ["1", "1", "4", "236200000"],
        ["1", "1", "5", "354300000"],
        ["1", "1", "6", "531500000"],
        ["1", "1", "7", "797300000"],
        ["1", "1", "8", "1196000000"],
        ["1", "1", "9", "1794000000"],
        ["1", "2", "1", "100000000"],
        ["1", "2", "2", "130000000"],
        ["1", "2", "3", "169000000"],
        ["1", "2", "4", "217900000"],
        ["1", "2", "5", "285600000"],
        ["1", "2", "6", "371200000"],
        ["1", "2", "7", "482600000"],
        ["1", "2", "8", "627400000"],
        ["1", "2", "9", "815700000"],
        ["1", "3", "1", "700000000"],
        ["1", "3", "2", "840000000"],
        ["1", "3", "3", "1008000000"],
        ["1", "3", "4", "1209600000"],
        ["1", "3", "5", "1451500000"],
        ["1", "3", "6", "1741800000"],
        ["1", "3", "7", "2090100000"],
        ["1", "3", "8", "2508200000"],
        ["1", "3", "9", "3098700000"],
        ["1", "4", "0", "500000000"],
        ["1", "4", "1", "100000000"],
        ["1", "4", "2", "130000000"],
        ["1", "4", "3", "169000000"],
        ["1", "4", "4", "217900000"],
        ["1", "4", "5", "285600000"],
        ["1", "4", "6", "371200000"],
        ["1", "4", "7", "482600000"],
        ["1", "4", "8", "627400000"],
        ["1", "4", "9", "815700000"],
        ["2", "1", "1", "70000000"],
        ["2", "1", "2", "105000000"],
        ["2", "1", "3", "157500000"],
        ["2", "1", "4", "236200000"],
        ["2", "1", "5", "354300000"],
        ["2", "1", "6", "531500000"],
        ["2", "1", "7", "797300000"],
        ["2", "1", "8", "1196000000"],
        ["2", "1", "9", "1794000000"],
        ["2", "2", "1", "120000000"],
        ["2", "2", "2", "156000000"],
        ["2", "2", "3", "202800000"],
        ["2", "2", "4", "263600000"],
        ["2", "2", "5", "342700000"],
        ["2", "2", "6", "445500000"],
        ["2", "2", "7", "579200000"],
        ["2", "2", "8", "752900000"],
        ["2", "2", "9", "978800000"],
        ["2", "3", "1", "840000000"],
        ["2", "3", "2", "1008000000"],
        ["2", "3", "3", "1209600000"],
        ["2", "3", "4", "1451500000"],
        ["2", "3", "5", "1741800000"],
        ["2", "3", "6", "2090100000"],
        ["2", "3", "7", "2508200000"],
        ["2", "3", "8", "3009800000"],
        ["2", "3", "9", "3611800000"],
        ["2", "4", "0", "600000000"],
        ["2", "4", "1", "120000000"],
        ["2", "4", "2", "156000000"],
        ["2", "4", "3", "202800000"],
        ["2", "4", "4", "263600000"],
        ["2", "4", "5", "342700000"],
        ["2", "4", "6", "445500000"],
        ["2", "4", "7", "579200000"],
        ["2", "4", "8", "752900000"],
        ["2", "4", "9", "978800000"],
    ],
    setWarrantExpireConf: [
        // setWarrantExpireConf(uint16 portID, uint8 expireType, tuple(uint32 time, uint256 usdPrice) conf)
        ["1", "1", ["2592000", "100000000"]],
        ["1", "2", ["5184000", "180000000"]],
        ["1", "3", ["7776000", "240000000"]],
        ["2", "1", ["2592000", "100000000"]],
        ["2", "2", ["5184000", "180000000"]],
        ["2", "3", ["7776000", "240000000"]],
    ],
};
