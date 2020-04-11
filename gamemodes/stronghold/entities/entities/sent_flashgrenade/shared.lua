ENT.Type = "anim"

function ENT:Initialize()
	self:SetModel( "models/weapons/w_eq_flashbang_thrown.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( true )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	if SERVER then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
		end
	elseif CLIENT then
		self.SmokeTimer = 0
		local vOffset = self:LocalToWorld( Vector(0, 0, self:OBBMins().z) )
		self.Emitter = ParticleEmitter( vOffset )
	end
	
	self.Created = CurTime()
	self.Flashed = false
end

-- THIS IS FOR NETWORK SYNCRONIZATION OF COOK TIMES --
-- You get/set the current value with self.dt.Duration
function ENT:SetupDataTables()
	self:DTVar( "Float", 0, "Duration" )
end

function ENT:GetDuration()
	return self.dt.Duration
end

function ENT:SetDuration( duration )
	self.dt.Duration = duration
end

local BounceSnd = Sound( "Flashbang.Bounce" )
function ENT:PhysicsCollide( data, phys )
	if data.Speed > 50 then
		self:EmitSound( BounceSnd )
	end
	local impulse = -data.Speed * data.HitNormal * .4 + data.OurOldVelocity * -0.6
	phys:ApplyForceCenter( impulse )
end