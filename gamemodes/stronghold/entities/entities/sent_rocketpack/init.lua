AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

local RocketLoop = "weapons/rpg/rocket1.wav"
function ENT:Initialize()
	self:SetModel( "models/weapons/W_missile_launch.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( true )
	self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

	if SERVER then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
		end
	end

	if CLIENT then
		local vOffset = self:LocalToWorld( Vector(0, 0, self:OBBMins().z) )
		self.Emitter = ParticleEmitter( vOffset )
	end

	--self:EmitSound("weapons/rpg/rocket1.wav", self:GetPos(), 100, math.random(80, 100))
	self.Created = CurTime()
	--self:Explode()
end

function ENT:Think()

end

function ENT:Explode()
	local explo = ents.Create( "env_explosion" )
	explo:SetOwner( self.RocketOwner )
	explo:SetPos( self:GetPos() )
	explo:SetKeyValue( "iMagnitude", "80" )
	explo:Spawn()
	explo:Activate()
	explo:Fire( "Explode", "", 0 )
	
	for _, v in ipairs(ents.FindInSphere( self:GetPos(), 75 )) do
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( self:GetOwner() )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( 200 )
		v:TakeDamageInfo( dmginfo )
	end

	local shake = ents.Create( "env_shake" )
	shake:SetOwner( self.Owner )
	shake:SetPos( self:GetPos() )
	shake:SetKeyValue( "amplitude", "2000" )	-- Power of the shake
	shake:SetKeyValue( "radius", "900" )	-- Radius of the shake
	shake:SetKeyValue( "duration", "0.50" )	-- Time of shake
	shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
	shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
	shake:Spawn()
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )
end

function ENT:PhysicsCollide( data, phys )
end

function ENT:PhysicsUpdate()	
	local phys 			= self:GetPhysicsObject()
	local Owner 		= self:GetOwner()
	local tracestart 	= self:LocalToWorld( self:OBBCenter() )
	local endpos 		= tracestart +(self:GetForward() *50)
	local filter		= {self, self:GetOwner()}
	
	local tracedata = {}
	tracedata.start = tracestart
	tracedata.endpos = endpos
	tracedata.filter = filter
	local trace = util.TraceLine(tracedata)

	local vecOrigin= self:GetPos()
	local vecWorld = Owner:GetEyeTrace().HitPos
	local angAim = ( vecWorld +vecWorld:Angle():Forward() -vecOrigin ):Angle()
	angAim = LerpAngle( 0.9 , angAim, self.m_aLastAim or angAim )
	self.m_aLastAim = angAim
	
	if !trace.Hit then
		self:SetPos(self:GetPos()+(self:GetForward()*trace.HitPos:Distance(tracestart)))	
		self:SetAngles(self:GetAngles()+Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1)))
		--self:SetAngles(Owner:GetEyeTrace().HitPos)
	elseif trace.Hit then
		self:SetPos(self:GetPos()+(self:GetForward()*(trace.HitPos:Distance(tracestart)-1)))
		self:Explode()
		self:Remove()
	end
	--ErrorNoHalt(Owner)
	--ErrorNoHalt(traceres.Entity)
end

function ENT:OnRemove()
	--self:StopSound("weapons/rpg/rocket1.wav")
end