
AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "RTXPhysics"
ENT.Editable = true

-- Custom drive mode
function ENT:GetEntityDriveMode()

	return "drive_noclip"

end

function ENT:Initialize()

	self:SetModel("models/props_junk/wood_crate001a.mdl")
	if ( SERVER ) then

		self:PhysicsInit( SOLID_VPHYSICS )
		self:DrawShadow( false )

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:Wake() end

	end

end

if ( SERVER ) then

	function ENT:Think()

		self.BaseClass.Think( self )
		print(self:GetMaterial())

	end
end