
if (SERVER) then
	util.AddNetworkString( "RTXPlayerSpawnedFully" )
end
hook.Add( "PlayerInitialSpawn", "RTXFullLoadSetup", function( ply )
	hook.Add( "SetupMove", ply, function( self, mvply, _, cmd )
		if self == mvply and not cmd:IsForced() then
			hook.Run( "RTXPlayerFullLoad", self )
			hook.Remove( "SetupMove", self )
			if (SERVER) then
				net.Start( "RTXPlayerSpawnedFully" )
				net.Send( mvply )
			end
		end
	end )
end )