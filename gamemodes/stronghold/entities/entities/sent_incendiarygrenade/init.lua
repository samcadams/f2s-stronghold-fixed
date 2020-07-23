AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
--ENT.fireparams = {size=120, growth=1}

function ENT:Use( ply )
	ply:PickupObject( self )
end

function ENT:Think()
	if CurTime() - self.Created >= self.dt.Duration then
		local spos = self:GetPos()
		local tr = util.TraceLine(({start=spos, endpos=spos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=self.GrenadeOwner}))
		self:Explode(tr)
		--SpawnFire( self:GetPos(), self.fireparams.size, self.fireparams.growth, 999, self.GrenadeOwner, self)
		self:Remove()
	end
end



function StartFires(pos, tr, num, lifetime, explode, dmgowner)
   for i=1, num do
      local ang = Angle(-math.Rand(0, 180), math.Rand(0, 360), math.Rand(0, 360))

      local vstart = pos + tr.HitNormal * 64

      local flame = ents.Create("sent_flame")
      flame:SetPos(pos)
      flame:SetDamageParent(dmgowner)
      flame:SetOwner(dmgowner)
      flame:SetDieTime(CurTime() + lifetime + math.Rand(-2, 2))
      flame:SetExplodeOnDeath(explode)

      flame:Spawn()
      flame:PhysWake()

      local phys = flame:GetPhysicsObject()
      if IsValid(phys) then
         -- the balance between mass and force is subtle, be careful adjusting
         phys:SetMass(2)
         phys:ApplyForceCenter(ang:Forward() * 500)
         phys:AddAngleVelocity(Vector(ang.p, ang.r, ang.y))
      end

   end

end

function ENT:Explode(tr)

    self:SetNoDraw(true)
    self:SetSolid(SOLID_NONE)
	local effectdata = EffectData()
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "shockwave", effectdata, true, true )
	util.Effect( "explosion_dust", effectdata, true, true )
	
	
	for _, v in ipairs(ents.FindInSphere( self:GetPos(), 25 )) do
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( self.GrenadeOwner )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( 35 )
		v:TakeDamageInfo( dmginfo )
	end

	local explo = ents.Create( "env_explosion" )
	explo:SetOwner( self.GrenadeOwner )
	explo:SetPos( self:GetPos() )
	explo:SetKeyValue( "iMagnitude", "50" )
	explo:Spawn()
	explo:Activate()
	explo:Fire( "Explode", "", 0 )

	local shake = ents.Create( "env_shake" )
	shake:SetOwner( self.GrenadeOwner )
	shake:SetPos( self:GetPos() )
	shake:SetKeyValue( "amplitude", "500" )	-- Power of the shake
	shake:SetKeyValue( "radius", "300" )	-- Radius of the shake
	shake:SetKeyValue( "duration", "0.5" )	-- Time of shake
	shake:SetKeyValue( "frequency", "255" )	-- How hard should the screenshake be
	shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
	shake:Spawn()
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )
	
	--local flame  = ents.Create("sent_flame")
	StartFires( self:GetPos(), tr, 10, 20, false, self.GrenadeOwner )
end