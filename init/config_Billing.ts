import { addChargeToken_ESportPool_Billing } from "./init_config";

export const Billing_config = {
    addChargeToken: addChargeToken_ESportPool_Billing,
    setBillingApp:[
        ["1", "addr:receive_mb_income_addr"]
    ],
    setTokens:[
        ["gold", "addr:MTTGold"]
    ]
};
