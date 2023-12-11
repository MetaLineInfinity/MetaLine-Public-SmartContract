import { InitTool } from "../utils/util_inittool";
import { Init_MysteryBox } from "./init_mysterybox";
import { Init_MysteryBoxShop } from "./init_mysteryboxShop";
import { Init_Game1 } from "./Init_game1";
import { Init_Market } from "./init_market";
import { Init_Platform } from "./init_platform";
import { Init_Shards } from "./init_shards";
import { Init_Expedition } from "./init_expedition";
import { Init_Guild } from "./init_guild";

export function RegAll() {
    InitTool.RegForGroup("mysteryboxShop", Init_MysteryBoxShop.InitAll, undefined, Init_MysteryBoxShop.ConfigAll, [
        "test_unusual/test_mysteryboxShop.ts",
    ]);
    InitTool.RegForGroup("mysterybox", Init_MysteryBox.InitAll, undefined, Init_MysteryBox.ConfigAll, ["test_unusual/test_mysterybox.ts"]);

    InitTool.RegForGroup("game1", Init_Game1.InitAll, undefined, Init_Game1.ConfigAll, ["test_unusual/test_game1.ts"]);
    InitTool.RegForGroup("market", Init_Market.InitAll, undefined, Init_Market.ConfigAll, ["test_unusual/test_market.ts"]);
    InitTool.RegForGroup("platform", Init_Platform.InitAll, undefined, Init_Platform.ConfigAll, ["test_unusual/test_platform.ts"]);
    InitTool.RegForGroup("shards", Init_Shards.InitAll, undefined, Init_Shards.ConfigAll, ["test_unusual/test_shards.ts"]);
    InitTool.RegForGroup("expedition", Init_Expedition.InitAll, undefined, Init_Expedition.ConfigAll, ["test_unusual/test_expedition.ts"]);

    InitTool.RegForGroup("guild", Init_Guild.InitAll, undefined, Init_Guild.ConfigAll, ["test_unusual/test_guild.ts"]);
}
