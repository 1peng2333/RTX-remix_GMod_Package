-- Note to anyone reading: Try to do things on the client if you can!!!
if (SERVER) then
	function RTXLoadServer( ply )  
		print("[RTX Fixes] - Initalising Server") 
		
	end 
	hook.Add( "PlayerInitialSpawn", "RTXReadyServer", RTXLoadServer)  

end