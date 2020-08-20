AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Use( ply )
	ply:PickupObject( self )
end

function ENT:Think()
	if CurTime() - self.Created >= self.dt.Duration then
		self:Explode()
		self:Remove()
	end
end

function ENT:Explode()
	local effectdata = EffectData()
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "shockwave", effectdata, true, true )
	util.Effect( "explosion_dust", effectdata, true, true )
	
	
	for _, v in ipairs(ents.FindInSphere( self:GetPos(), 25 )) do
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( self.GrenadeOwner )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( 150 )
		v:TakeDamageInfo( dmginfo )
	end

	local explo = ents.Create( "env_explosion" )
	explo:SetOwner( self.GrenadeOwner )
	explo:SetPos( self:GetPos() )
	explo:SetKeyValue( "iMagnitude", "150" )
	explo:Spawn()
	explo:Activate()
	explo:Fire( "Explode", "", 0 )

	local shake = ents.Create( "env_shake" )
	shake:SetOwner( self.GrenadeOwner )
	shake:SetPos( self:GetPos() )
	shake:SetKeyValue( "amplitude", "2000" )	-- Power of the shake
	shake:SetKeyValue( "radius", "900" )	-- Radius of the shake
	shake:SetKeyValue( "duration", "0.5" )	-- Time of shake
	shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
	shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
	shake:Spawn()
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )
end