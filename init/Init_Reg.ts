
import { InitTool } from "../utils/util_inittool";
import { Init_MysteryBox } from "./init_mysterybox";
import { Init_MysteryBoxShop, Init_MysteryBoxShopV1 } from "./init_mysteryboxShop";

export function RegAll()
{  
    InitTool.RegForGroup("mysteryboxShop", Init_MysteryBoxShop.InitAll, undefined, Init_MysteryBoxShop.ConfigAll,["test_unusual/test_mysteryboxShop.ts"]);
    InitTool.RegForGroup("mysteryboxShopV1", Init_MysteryBoxShopV1.InitAll, undefined, Init_MysteryBoxShopV1.ConfigAll,["test_unusual/test_mysteryboxShopV1.ts"]);
    InitTool.RegForGroup("mysterybox", Init_MysteryBox.InitAll, undefined, Init_MysteryBox.ConfigAll,["test_unusual/test_mysterybox.ts"]);
}