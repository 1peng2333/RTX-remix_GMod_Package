player_manager.AddValidModel( "Varesa", "models/sheepylord/genshin_impact/genshin_impact_varesa.mdl" );
player_manager.AddValidHands( "Varesa", "models/sheepylord/genshin_impact/genshin_impact_varesa_arms.mdl", 0, "00000000" )

local Category = "Genshin Impact"

local NPC = {
    Name = "Varesa (Friendly)",
    Class = "npc_citizen",
    Model = "models/sheepylord/genshin_impact/genshin_impact_varesa.mdl",
    Health = "100",
    KeyValues = { citizentype = 4 },
    Weapons = { "weapon_smg1" },
    Category = Category
}

list.Set("NPC", "Varesa_F", NPC)

local NPC = {
    Name = "Varesa (Enemy)",
    Class = "npc_combine_s",
    Model = "models/sheepylord/genshin_impact/genshin_impact_varesa.mdl",
    Health = "100",
    Numgrenades = "4",
    Weapons = { "weapon_ar2" },
    Category = Category
}

list.Set("NPC", "Varesa_E", NPC)
