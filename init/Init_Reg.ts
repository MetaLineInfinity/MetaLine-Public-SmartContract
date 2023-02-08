
import { InitTool } from "../utils/util_inittool";
import { Init_MysteryBox } from "./init_mysterybox";

export function RegAll()
{  
    InitTool.RegForGroup("mysterybox", Init_MysteryBox.InitAll, undefined, Init_MysteryBox.ConfigAll,["test_unusual/test_mysterybox.ts"]);
}