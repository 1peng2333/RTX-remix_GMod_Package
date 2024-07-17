CreateConVar( "rtx_debug_pseudoplayer", 0,  FCVAR_ARCHIVE )
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= "lightupdater"
ENT.Author			= "Xenthio"
ENT.Information		= "update lights as fast as possible"
ENT.Category		= "RTX"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
 


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

function ENT:Initialize() 
    print("[RTX Fixes] - Lightupdater Initialised.")
    self:SetModel("models/hunter/plates/plate.mdl")
    --self:SetPos("LocalPlayer():GetPos()")
    self:SetRenderMode(2) 
    self:SetColor(Color(255,255,255,1))

end
function ENT:Think()
    self.RenderOverride = nil
--     --lights = NikNaks.CurrentMap:GetEntities()
--     lights = NikNaks.CurrentMap:FindByClass( "light" )
-- 	lights = TableConcat(lights,NikNaks.CurrentMap:FindByClass( "light_spot" ))
-- 	lights = TableConcat(lights,NikNaks.CurrentMap:FindByClass( "light_environment" ))
-- 	stash = shuffle(lights)
--     self:SetPos(stash[1].origin - (stash[1].angles:Forward() * 8)) 
--     self:SetRenderMode(2) 
--     self:SetColor(Color(255,255,255,1))
end

function ENT:Draw() 
	-- Draw the entity's model normally, this calls GetRenderMesh at some point
	self:DrawModel() 
end

function ENT:OnRemove() 
end
