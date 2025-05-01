--Add Playermodel
player_manager.AddValidModel( "Tda Hatsune Miku (v2)", "models/captainbigbutt/vocaloid/miku_classic.mdl" )
player_manager.AddValidHands( "Tda Hatsune Miku (v2)", "models/captainbigbutt/vocaloid/c_arms/miku_classic.mdl", 0, "00000000" )

--Add NPC
local NPC =
{
	Name = "Tda Hatsune Miku (v2)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/captainbigbutt/vocaloid/npc/miku_classic.mdl",
	Category = "Vocaloid"
}

list.Set( "NPC", "npc_cbb_miku2", NPC )


-- Send this to clients automatically so server hosts don't have to
if SERVER then
	resource.AddWorkshop("362803586")
end