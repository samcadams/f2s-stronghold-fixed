ENT.Type = "anim"

ENT.PrintName		= "INCENDIARY GRENADE"
ENT.Author			= "RoaringCow"

function ENT:Initialize()
	self:SetModel( "models/weapons/w_eq_flashbang.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( true )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	if SERVER then
		self:SetUseType( SIMPLE_USE )
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
		end
	end
	
	self.Created = CurTime()
end

-- THIS IS FOR NETWORK SYNCRONIZATION OF COOK TIMES --
-- You get/set the current value with ENTITY:Get/SetDuration()
function ENT:SetupDataTables()
	self:DTVar( "Float", 0, "Duration" )
end

function ENT:GetDuration()
	return self.dt.Duration
end

function ENT:SetDuration( duration )
	self.dt.Duration = duration
end

local BounceSnd = Sound( "HEGrenade.Bounce" )
function ENT:PhysicsCollide( data, phys )
	if data.Speed > 200 then
		self:EmitSound( BounceSnd )
	end
	--[[local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter( impulse )]]
end
