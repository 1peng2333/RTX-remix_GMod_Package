-- Shitty solution to have a shadow for the player
CreateConVar( "rtx_allowrtxflashlight", 1, FCVAR_ARCHIVE )
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= "RTX Flashlight"
ENT.Author			= "Xenthio"
ENT.Information		= "For firstperson self shadows and body reflections with RTX"
ENT.Category		= "RTX"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

local updater 
local lightent 
function ENT:Initialize() 
    print("[RTX Fixes] - Flashlight Initialised.")
    if (SERVER) then

        self.updater = ents.Create("prop_dynamic")
        
        self.updater:SetRenderMode(2) 
        self.updater:SetColor(Color(255,255,255,1))
        self.updater:SetModel("models/hunter/plates/plate.mdl") 
        self.updater:SetPos( self:GetPos() + (self:GetOwner():GetAimVector()* 90) )
        self.updater:SetParent( self )

        self.lightent = ents.Create( "light_dynamic" )
        self.lightent:SetPos( self:GetPos() )
        self.lightent:SetAngles( self:GetAngles() )

        self.lightent:SetParent( self )

        self.lightent:SetKeyValue( "distance", 256 )
        self.lightent:SetKeyValue( "_inner_cone", 15 )
        self.lightent:SetKeyValue( "_cone", 100 )
        self.lightent:SetKeyValue( "brightness", 0.5 )
        self.lightent:SetKeyValue( "spotlight_radius", 5 )
        --SetSpawnflags( L, self:GetLightModels(), self:GetLightWorld() )
        self:SetRenderMode(2) 
        self:SetColor(Color(255,255,255,0))
        self.lightent:Spawn()
    end

end
function ENT:Think()
 
    if self:GetOwner() then
        

        self:SetPos( self:GetOwner():GetPos() + self:GetOwner():GetViewOffset() + (self:GetOwner():GetAimVector() * (16)) )
        --self:SetPos(self:GetOwner():GetEyeTrace().HitPos)
        self:SetAngles( self:GetOwner():GetAngles() )
        if (self:GetOwner():FlashlightIsOn()) then
            if (self.lightent) then 
                self.lightent:SetKeyValue( "brightness", 0.5 ) 
                self.lightent:SetKeyValue( "distance", 256 )
            end
            if (self.updater) then
                self.updater:SetColor(Color(255,255,255,1))
            end
        else 
            if (self.lightent) then 
                self.lightent:SetKeyValue( "brightness", 0 ) 
                self.lightent:SetKeyValue( "distance", 0 )
            end
            if (self.updater) then
                self.updater:SetColor(Color(255,255,255,1))
            end
        end
    end
    
end

function ENT:OnRemove() 

end
