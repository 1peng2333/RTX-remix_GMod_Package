CreateClientConVar(	"rtx_pseudoplayer", 1,  true, false)
CreateClientConVar(	"rtx_pseudoweapon", 1,  true, false)

CreateClientConVar(	"rtx_disablevertexlighting", 1,  true, false) 
CreateClientConVar(	"rtx_disablevertexlighting_old", 0,  true, false) 

CreateClientConVar(	"rtx_fixmaterials", 1,  true, false) 

CreateClientConVar(	"rtx_lightupdater", 1,  true, false) 

CreateClientConVar(	"rtx_experimental_manuallight", 0,  true, false) 
CreateClientConVar(	"rtx_experimental_mightcrash_combinedlightingmode", 0,  false, false) 

CreateClientConVar(	"rtx_disable_when_unsupported", 1,  false, false) 

require("niknaks")

local WantsMaterialFixup = false 
local flashlightent
local PrevCombinedLightingMode = false
if (CLIENT) then
	function RTXLoad()
		print("[RTX Fixes] - Initalising Client")
	// todo: add manual disable 
		if (render.SupportsVertexShaders_2_0() && GetConVar( "rtx_disable_when_unsupported" ):GetBool()) then
			print("[RTX Fixes] - No RTX Remix Detected! Disabling! (You can force enable by changing rtx_disable_when_unsupported to 0 and reloading)")
			return
		end
		RunConsoleCommand("r_radiosity", "0")
		RunConsoleCommand("r_PhysPropStaticLighting", "1")
		RunConsoleCommand("r_colorstaticprops", "0")
		RunConsoleCommand("r_lightinterp", "0")
		RunConsoleCommand("mat_fullbright", GetConVar( "rtx_experimental_manuallight" ):GetBool())
		concommand.Add( "rtx_fixmaterials_fixnow", MaterialFixups)
		concommand.Add( "rtx_force_no_fullbright", ForceLighting)
		-- cvars.AddChangeCallback("mat_fullbright", function(convar_name, value_old, value_new)
		-- 	print(convar_name, value_old, value_new)
		-- 	if (value_new == "1") then 
		-- 		print("no >:(")
		-- 		RunConsoleCommand("mat_fullbright", "0")
		-- 	end
		-- end)

		pseudoply = ents.CreateClientside( "rtx_pseudoplayer" ) 
		
		flashlightent = ents.CreateClientside( "rtx_flashlight_ent" )
		flashlightent:SetOwner(ply)
		flashlightent:Spawn()

		-- the definition of insanity
		if (GetConVar( "rtx_lightupdater" ):GetBool()) then local b = ents.CreateClientside( "rtx_lightupdatermanager" ) b:Spawn() end  
		pseudoply:Spawn() 

		FixupEntities()

		halo.Add = function() end

		-- start fixing up materials, can freeze the game :(
		if (GetConVar( "rtx_fixmaterials" ):GetBool()) then MaterialFixups() end
		--WantsMaterialFixup = true
	end 
	function ForceLighting() 
		render.SetLightingMode( 0 )
	end
	
	concommand.Add( "rtx_fixnow", RTXLoad)

	function PreRender()   
		
		if (render.SupportsVertexShaders_2_0()) then 
			return
		end
		render.SuppressEngineLighting( GetConVar( "rtx_disablevertexlighting_old" ):GetBool() || GetConVar( "rtx_experimental_manuallight" ):GetBool())  
		if (GetConVar( "rtx_experimental_mightcrash_combinedlightingmode" ):GetBool()) then 
			render.SuppressEngineLighting(false)
		end   
		if (GetConVar( "rtx_experimental_manuallight" ):GetBool()) then DoCustomLights() end  
		
	end 
	function PreRenderOpaque()  
		if (render.SupportsVertexShaders_2_0()) then 
			return
		end
		if (GetConVar( "rtx_experimental_manuallight" ):GetBool()) then DoCustomLights() end 
	end 
	function RTXPreRenderTranslucent()  
		if (render.SupportsVertexShaders_2_0()) then 
			return
		end
		if (GetConVar( "rtx_experimental_manuallight" ):GetBool()) then DoCustomLights() end 
	end 
	 
	-- function RTXThink() 
	-- 	if (WantsMaterialFixup) then
	-- 		if not matfixco or not coroutine.resume( matfixco ) then
	-- 			matfixco = coroutine.create( MaterialFixups )
	-- 			coroutine.resume( matfixco )
	-- 		end
	-- 	end
	-- end

	hook.Add( "InitPostEntity", "RTXReady", RTXLoad)  
	hook.Add( "PreRender", "RTXPreRender", PreRender) 
	--hook.Add( "Think", "RTXThink", RTXThink) 
	hook.Add( "PreDrawOpaqueRenderables", "RTXPreRenderOpaque", PreRenderOpaque) 
	hook.Add( "PreDrawTranslucentRenderables", "RTXPreRenderTranslucent", RTXPreRenderTranslucent) 

	
	--function SupressLighting() 
		--render.SuppressEngineLighting(true)
		--render.SetAmbientLight( 0, 0, 0 )
		--render.ResetModelLighting( 0, 0, 0 )
	--end
	--hook.Add( "PreDrawOpaqueRenderables", "RTXSupress1", SupressLighting) 
	--hook.Add( "PreDrawTranslucentRenderables", "RTXSupress2", SupressLighting) 
	--hook.Add( "PostDrawOpaqueRenderables", "RTXSupress3", SupressLighting) 
	--hook.Add( "PostDrawTranslucentRenderables", "RTXSupress4", SupressLighting) 

	hook.Add( "PopulateToolMenu", "RTXOptionsClient", function()
		spawnmenu.AddToolMenuOption( "Utilities", "User", "RTX_Client", "#RTX", "", "", function( panel )
			panel:ClearControls()
			
			panel:ControlHelp( "Thanks for using RTX Remix Fixes! In order to allow me to continue to fix and support this addon while keeping it free, it would be nice if you could PLEASE consider donating to my patreon!" )
			panel:ControlHelp("https://www.patreon.com/xenthio")
	
			panel:CheckBox( "Fix Materials on Load.", "rtx_fixmaterials" )
			panel:ControlHelp( "Fixup broken and unsupported materials, this fixes things from UI to particles." )

			--panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "presetRTX", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
	
			panel:CheckBox( "Pseudoplayer Enabled", "rtx_pseudoplayer" )
			panel:ControlHelp( "Pseudoplayer allows you to see your own playermodel, this when marked as a 'Playermodel Texture' in remix allows you to see your own shadow and reflection." )
			panel:CheckBox( "Pseudoweapon Enabled", "rtx_pseudoweapon" )
			panel:ControlHelp( "Similar to above, but for the weapon you're holding." )

			panel:CheckBox( "Disable Vertex Lighting.", "rtx_disablevertexlighting" )
			panel:ControlHelp( "Disables vertex lighting on models and props, these look incorrect with rtx and aren't needed when lightupdaters are enabled." )

			panel:CheckBox( "Light Updaters", "rtx_lightupdater")
			panel:ControlHelp( "Prevent lights from disappearing in remix, works well when high and 'Supress Light Keeping' in remix settings is on.") 

			qualityslider = panel:NumSlider( "Light Updater Count", "rtx_lightupdater_count", 0, 2048, 0 )
			panel:ControlHelp( "The amount of light updaters to use, this can be as low as 8 when 'Supress Light Keeping' is off." )
			panel:ControlHelp( "Requires map reload to take affect!" )
		end )
	end )
end


function values(t)
	local i = 0
	return function() i = i + 1; return t[i] end
end
function shuffle(tbl)
	for i = #tbl, 2, -1 do
	  local j = math.random(i)
	  tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end
function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end
function mysplit (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end
--function MaterialFixupsAsync() 
	--print("[RTX Fixes] - Requesting Fixup")
	--WantsMaterialFixup = true
--end

function MaterialFixups()
	MaterialFixupInDir("materials/particle/")
	MaterialFixupInDir("materials/effects/")

	FixupWater()

	-- giving things a real texture makes remix less confused
	FixupGUIMaterial(Material("vgui/white"), "materials/vgui/white.vmt")
	FixupGUIMaterial(Material("vgui/white_additive"), "materials/vgui/white_additive.vmt") 
	FixupGUIMaterial(Material("vgui/black"), "materials/vgui/black.vmt")
	FixupGUIMaterial(Material("white"), "white")
	FixupGUIMaterial(Material("VGUI_White"), "VGUI_White")
	FixupGUIMaterial(Material("!VGUI_White"), "VGUI_White") -- Dynamically created in vgui2.dll I think.
	FixupGUIMaterial(Material("!white"), "white")
	--WantsMaterialFixup = false
end
function FixupWater() 
	-- todo, find all water brushes and swap their texture.
	-- sorry this is tirning into note taking area, but here's what needs to be done
	-- fetch water, somehow (not a brush entity as far as i know)
	-- replace the water (replacement method doesnt seem to like dx fallbacks)
end
function MaterialFixupInDir(dir) 
	
	print("[RTX Fixes] - Starting root material fixup in " .. dir)
	local _, allfolders = file.Find( dir .. "*" , "GAME" )
	MaterialFixupInSubDir(dir)
	for k, v in pairs(allfolders) do
		MaterialFixupInSubDir(dir .. v .. "/")
	end
end

function MaterialFixupInSubDir(dir)
	--print("[RTX Fixes] - Fixing materials in " .. dir)

	local allfiles, _ = file.Find( dir .. "*.vmt", "GAME" )
	for k, v in pairs(allfiles) do
		FixupMaterial(dir .. v)
	end
end

-- Trying to fix these crash the game 
local bannedmaterials = {
	"materials/particle/warp3_warp_noz.vmt",
	"materials/particle/warp4_warp.vmt",
	"materials/particle/warp4_warp_noz.vmt",
	"materials/particle/warp5_warp.vmt",
	"materials/particle/warp5_explosion.vmt",
	"materials/particle/warp_ripple.vmt"
}
function FixupMaterial(filepath)
	
	for k, v in pairs(bannedmaterials) do
		if (v == filepath) then 
			--print("[RTX Fixes] - Skipping material " .. filepath)
			return 
		end
	end

	--print("[RTX Fixes] - Fixing material " .. filepath)
	local mattrim = (filepath:sub(0, #"materials/") == "materials/") and filepath:sub(#"materials/"+1) or filepath
	local matname = mattrim:gsub(".vmt".."$", "");
	local mat = Material(matname)
	--print("[RTX Fixes] - (Shader: " .. mat:GetShader() .. ")")
	--print("[RTX Fixes] - (Texture: " .. mat:GetString("$basetexture") .. ")")

	--coroutine.wait( 0.01 )
	if (mat:IsError()) then
		print("[RTX Fixes] - This texture loaded as an error? Trying to fix anyways but this shouldn't happen.")
	end

	-- TODO: How to fetch water in a level?
	-- if (mat:GetString("$basetexture") == "dev/water" || mat:GetShader() == "Water_DX60" ) then -- this is water, make it water
	-- 	FixupWaterMaterial(mat, filepath)
	-- end
	if (mat:GetString("$addself") != nil) then
		FixupParticleMaterial(mat, filepath)
	end
	if (mat:GetString("$basetexture") == nil) then
		FixupBlankMaterial(mat, filepath)
	end
end

-- function FixupWaterMaterial(mat, filepath)
-- 	print("[RTX Fixes] - Found and fixing water material in " .. filepath)
-- 	if (string.find(filepath, "beneath")) then
-- 		local waterbeneath = Material("rtx/water_beneath")
-- 		mat:SetTexture( "$basetexture", waterbeneath:GetTexture("$basetexture") )
-- 		mat:SetString("$fallbackmaterial", "rtx/water_beneath")
-- 	else
-- 		local water = Material("rtx/water")
-- 		mat:SetTexture( "$basetexture", water:GetTexture("$basetexture") )
-- 		mat:SetString("$fallbackmaterial", "rtx/water")
-- 		mat:SetString("$bottommaterial", "rtx/water_beneath")
-- 	end
-- 	mat:SetInt( "$additive", 1 )
-- 	mat:SetInt( "$nocull", 1 )
-- 	mat:SetFloat( "$texscale", 0.25 )
-- end
function FixupParticleMaterial(mat, filepath)
	print("[RTX Fixes] - Found and fixing particle material in " .. filepath)
	mat:SetInt( "$additive", 1 )
end
function FixupBlankMaterial(mat, filepath)
	print("[RTX Fixes] - Found and fixing blank material in " .. filepath)
	local blankmat = Material("debug/particleerror")
	mat:SetTexture( "$basetexture", blankmat:GetTexture("$basetexture") )
end
function FixupGUIMaterial(mat, filepath)
	print("[RTX Fixes] - Found and fixing vgui material in " .. filepath)
	local blankmat = Material("rtx/guiwhite")
	mat:SetTexture( "$basetexture", blankmat:GetTexture("$basetexture") )
end

function DrawFix( self, flags )
    if (GetConVar( "mat_fullbright" ):GetBool()) then return end
    render.SuppressEngineLighting( GetConVar( "rtx_disablevertexlighting" ):GetBool() )

	if (self:GetMaterial() != "") then -- Fixes material tool and lua SetMaterial
		render.MaterialOverride(Material(self:GetMaterial()))
	end

	for k, v in pairs(self:GetMaterials()) do -- Fixes submaterial tool and lua SetSubMaterial
		if (self:GetSubMaterial( k-1 ) != "") then
			render.MaterialOverrideByIndex(k-1, Material(self:GetSubMaterial( k-1 )))
		end
	end

	self:DrawModel(flags + STUDIO_STATIC_LIGHTING) -- Fix hash instability
	render.MaterialOverride(nil)
    render.SuppressEngineLighting( false )

end
function ApplyRenderOverride(ent)
	ent.RenderOverride = DrawFix 
end
function TryDoReplacements(ent)
	-- We can replace or add onto entities we need to change here.
end
function FixupEntities() 

	hook.Add( "OnEntityCreated", "RTXEntityFixups", FixupEntity)
	for k, v in pairs(ents.GetAll()) do
		FixupEntity(v)
	end

end
function FixupEntity(ent)
	TryDoReplacements(ent)
	if (ent:GetClass() != "procedural_shard") then ApplyRenderOverride(ent) end
end

function convertlight(v) 
	if (!v) then return end
	local lighttype = MATERIAL_LIGHT_DISABLE
	if (v.classname == "point_spotlight")  then return end

	-- spawnflag 1 means the light will start off
	if (v.spawnflags == 1)  then return end

	if (v.classname == "light")  then lighttype = MATERIAL_LIGHT_POINT end
	if (v.classname == "light_environment")  then lighttype = MATERIAL_LIGHT_DIRECTIONAL end
	if (v.classname == "light_spot")  then lighttype = MATERIAL_LIGHT_SPOT end
	if (v.classname == "light_dynamic")  then lighttype = MATERIAL_LIGHT_POINT end

	local lightcolour = Vector(0,0,0)
	if (v._light) then
		local splitcolour = mysplit(v._light)
		local r1 = tonumber(splitcolour[1])
		local g1 = tonumber(splitcolour[2])
		local b1 = tonumber(splitcolour[3])
		local a1 = tonumber(splitcolour[4])
		if (!a1) then a1 = 200 end
		-- /60000 looks about right lol
		lightcolour = Vector( r1, g1, b1  ) * (a1/60000) 
	end 
	local newlight = {}
	newlight.type = lighttype
	newlight.color = lightcolour
	newlight.pos = v.origin
	newlight.innerAngle = v._inner_cone
	newlight.outerAngle = v._cone
	newlight.angularFalloff = v._exponent
	newlight.quadraticFalloff = v._quadratic_attn
	newlight.linearFalloff = v._linear_attn
	newlight.constantFalloff = v._constant_attn
	if (v._fifty_percent_distance && v._fifty_percent_distance > 0) then newlight.fiftyPercentDistance = v._fifty_percent_distance end
	if (v._zero_percent_distance && v._zero_percent_distance > 0) then newlight.zeroPercentDistance = v._zero_percent_distance end
	
	
	if (!v.pitch) then newlight.dir = Angle( -90, v.angles.yaw, v.angles.roll ):Forward() else
	newlight.dir = Angle( v.pitch * -1, v.angles.yaw, v.angles.roll ):Forward() end
 
	if (v.classname == "light_environment")  then newlight.dir = Angle( v.pitch * -1, v.angles.yaw, v.angles.roll ):Forward()  end
	if (v.classname == "light_environment")  then newlight.pos = Vector(0,0,0) end

	newlight.range = v.distance
	if (!newlight.range || newlight.range <= 0) then newlight.range = 512 end
	if (!newlight.innerAngle) then newlight.innerAngle = 30 end
	if (!newlight.outerAngle) then newlight.outerAngle = 45 end 

	if (newlight.innerAngle) then newlight.innerAngle = newlight.innerAngle * 2 end
	if (newlight.outerAngle) then newlight.outerAngle = newlight.outerAngle * 2 end 
	if (v.classname == "light_environment")  then
		--print(v.pitch)
		--print(v.angles)
		--PrintTable(v);
	end
	--if (v.targetname) then
		--local realents = ents.GetAll()
		--print(realents])
		--PrintTable(realents)
	--end
	--print(type(v._cone))
	--PrintTable(v);
	return newlight
end

function DoCustomLights() 
	render.ResetModelLighting(0,0,0) 
	--PrintTable(NikNaks.CurrentMap:GetEntities());
	--for value in values(NikNaks.CurrentMap:GetEntities()) do
		--print(value.classname.."\n"..tostring(value.origin))
	--end
	lights = NikNaks.CurrentMap:FindByClass( "light" )
	lights = TableConcat(lights,NikNaks.CurrentMap:FindByClass( "light_spot" ))
	lights = TableConcat(lights,NikNaks.CurrentMap:FindByClass( "light_environment" ))
	stash = shuffle(lights)
	render.SetLocalModelLights({
		convertlight(stash[1]),
		convertlight(stash[2]),
		convertlight(stash[3]),
		convertlight(stash[4]),  
	}) 
end
