
import { InitTool } from "../utils/util_inittool";
import { Init_MTT } from "./init_mtt";
import { Init_MysteryBox } from "./init_mysterybox";
import { Init_MysteryBoxShop, Init_MysteryBoxShopV1, Init_MysteryBoxShopV2 } from "./init_mysteryboxShop";
import { Init_Game1 } from "./init_game1";
import { Init_LglTest } from "./Init_LglTest";
import { Init_Market } from "./init_market";
import { Init_AssetMinter } from "./init_assetminter";
import { Init_Platform } from "./init_platform";
import { Init_Shards } from "./init_shards";

export function RegAll() {
    InitTool.RegForGroup("mysteryboxShop", Init_MysteryBoxShop.InitAll, undefined, Init_MysteryBoxShop.ConfigAll, ["test_unusual/test_mysteryboxShop.ts"]);
    InitTool.RegForGroup("MTT", Init_MTT.InitAll, undefined, Init_MTT.ConfigAll, ["test_unusual/test_MTT.ts"]);
    InitTool.RegForGroup("mysteryboxShopV1", Init_MysteryBoxShopV1.InitAll, undefined, Init_MysteryBoxShopV1.ConfigAll, ["test_unusual/test_mysteryboxShopV1.ts"]);
    InitTool.RegForGroup("mysteryboxShopV2", Init_MysteryBoxShopV2.InitAll, undefined, Init_MysteryBoxShopV2.ConfigAll, ["test_unusual/test_mysteryboxShopV2.ts"]);
    InitTool.RegForGroup("mysterybox", Init_MysteryBox.InitAll, undefined, Init_MysteryBox.ConfigAll, ["test_unusual/test_mysterybox.ts"]);
    InitTool.RegForGroup("game1", Init_LglTest.InitAll, undefined, Init_LglTest.ConfigAll, ["test_unusual/test_WarrantIssuer.ts", "test_unusual/test_Shipyard.ts"]);
    InitTool.RegForGroup("assetminter", Init_AssetMinter.InitAll, undefined, Init_AssetMinter.ConfigAll, ["test_unusual/test_assetminter.ts"]);
    InitTool.RegForGroup("market", Init_Market.InitAll, undefined, Init_Market.ConfigAll, ["test_unusual/test_market.ts"]);
    InitTool.RegForGroup("platform", Init_Platform.InitAll, undefined, Init_Platform.ConfigAll, ["test_unusual/test_platform.ts"]);
    InitTool.RegForGroup("shards", Init_Shards.InitAll, undefined, Init_Shards.ConfigAll, ["test_unusual/test_shards.ts"]);
}