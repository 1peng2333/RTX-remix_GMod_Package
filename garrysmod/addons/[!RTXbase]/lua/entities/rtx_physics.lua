
AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "RTXPhysics"
ENT.Editable = true

-- Custom drive mode
function ENT:GetEntityDriveMode()

	return "drive_noclip"

end

function ENT:Initialize()

	self:SetModel("models/alyx.mdl")
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

	end

	function ENT:OnTakeDamage( dmginfo )

		self:TakePhysicsDamage( dmginfo )

	end

	function ENT:OnSwitch( bOn )

		if ( bOn && IsValid( self.flashlight ) ) then return end

		if ( !bOn ) then

			--SafeRemoveEntity( self.flashlight )
			--self.flashlight = nil
			return

		end

		--self.flashlight = ents.Create( "env_projectedtexture" )
		--self.flashlight:SetParent( self )

		-- The local positions are the offsets from parent..
		--self.flashlight:SetLocalPos( vector_origin )
		--self.flashlight:SetLocalAngles( angle_zero )

		--self.flashlight:SetKeyValue( "enableshadows", 1 )
		--self.flashlight:SetKeyValue( "nearz", 12 )
		--self.flashlight:SetKeyValue( "lightfov", math.Clamp( self:GetLightFOV(), 10, 170 ) )

		local dist = self:GetDistance()
		if ( !game.SinglePlayer() ) then dist = math.Clamp( dist, 64, 2048 ) end
		--self.flashlight:SetKeyValue( "farz", dist )

		local c = self:GetColor()
		local b = self:GetBrightness()
		if ( !game.SinglePlayer() ) then b = math.Clamp( b, 0, 8 ) end
		--self.flashlight:SetKeyValue( "lightcolor", Format( "%i %i %i 255", c.r * b, c.g * b, c.b * b ) )

		--self.flashlight:Spawn()

		--self.flashlight:Input( "SpotlightTexture", NULL, NULL, self:GetFlashlightTexture() )

	end
end

--function ENT:Draw()

	--self:DrawModel(STUDIO_RENDER + STUDIO_STATIC_LIGHTING)

--end
-- The default material to render with in case we for some reason don't have one
local myMaterial = Material( "models/wireframe" ) -- models/debug/debugwhite

function ENT:CreateMesh()
	-- Destroy any previous meshes
	if ( self.Mesh ) then self.Mesh:Destroy() end

	-- Get a list of all meshes of a model
	local visualMeshes = util.GetModelMeshes( self:GetModel() )

	-- Check if the model even exists
	if ( !visualMeshes ) then return end

	-- Select the first mesh
	local visualMesh = visualMeshes[ 1 ]

	-- Set the material to draw the mesh with from the model data
	myMaterial = Material( visualMesh.material )

	-- You can apply any changes to visualMesh.verticies table here, distorting the mesh
	-- or any other changes you can come up with

	-- Create and build the mesh
	self.Mesh = Mesh()
	self.Mesh:BuildFromTriangles( visualMesh.triangles )
end

-- A special hook to override the normal mesh for rendering
function ENT:GetRenderMesh()
	-- If the mesh doesn't exist, create it!
	if ( !self.Mesh ) then return self:CreateMesh() end

	return { Mesh = self.Mesh, Material = myMaterial }
end

function ENT:Draw()
	-- Draw the entity's model normally, this calls GetRenderMesh at some point
	self:DrawModel()
end