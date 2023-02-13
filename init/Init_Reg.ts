
import { InitTool } from "../utils/util_inittool";
import { Init_MysteryBox } from "./init_mysterybox";
import { Init_MysteryBoxShop } from "./init_mysteryboxShop";

export function RegAll()
{  
    InitTool.RegForGroup("mysteryboxShop", Init_MysteryBoxShop.InitAll, undefined, Init_MysteryBoxShop.ConfigAll,[""]);
    InitTool.RegForGroup("mysterybox", Init_MysteryBox.InitAll, undefined, Init_MysteryBox.ConfigAll,["test_unusual/test_mysterybox.ts"]);
}