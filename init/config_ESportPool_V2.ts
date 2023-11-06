import { addChargeToken_ESportPool_Billing, eth_addr } from "./init_config";

export const ESportPool_V2_config = {
    addChargeToken: addChargeToken_ESportPool_Billing,
    // setPoolConfig(uint32 poolId, tuple(uint256 ticketUsdPrice, uint32 priceGrowPer, uint32 priceGrowCount, uint16[] winnerShares, string tokenName, address tokenAddr) conf)
    setPoolConfig: [[1, [20000000, 10000, 100, [2000, 800, 400, 200, 200, 80, 80, 80, 80, 80, 1000], "gold", "addr:MTTGold"]]],
};
