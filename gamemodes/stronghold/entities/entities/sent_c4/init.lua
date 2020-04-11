AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_c4_planted.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetTrigger( false )
	self.timer = CurTime() + 5

	timer.Simple( 1,
			function()
			if !IsValid( self ) then return end
			self:EmitSound( "buttons/button17.wav", self:GetPos(), 110, 110 )
		end )
	timer.Simple( 2,
			function()
			if !IsValid( self ) then return end
			self:EmitSound( "buttons/button17.wav", self:GetPos(), 120, 120 )
		end )
	timer.Simple( 3,
			function()
			if !IsValid( self ) then return end
			self:EmitSound( "buttons/button17.wav", self:GetPos(), 130, 130 )
		end )
	timer.Simple( 4,
			function()
			if !IsValid( self ) then return end
			self:EmitSound( "buttons/button17.wav", self:GetPos(), 140, 140 )
		end )
	timer.Simple( 5,
			function()
			if !IsValid( self ) then return end
			self:EmitSound( "buttons/button17.wav", self:GetPos(), 150, 150 )
		end )
end

function ENT:Think()
	if self.timer < CurTime()  then
		self:Explosion()
	end
end

function ENT:Explosion()
	if self.Busted == 1 then 
		local effectdata = EffectData( )
		effectdata:SetNormal( Vector(0,0,1) )
		effectdata:SetOrigin( self:GetPos( ) )
		
		timer.Simple( 10,
			function()
				if IsValid( self ) then 
					local effectdata = EffectData( )
						effectdata:SetNormal( Vector(0,0,1) )
						effectdata:SetOrigin( self:GetPos( ) )
						util.Effect( "ImpactJeep", effectdata )
						util.Effect( "cball_explode", effectdata )
						self:EmitSound( "physics/metal/metal_box_break1.wav", pos, 100, 100 )
					self:Remove()
				end
			end )

		if self.timer < CurTime() - 0.25 then return end			
		self:EmitSound( "weapons/stunstick/spark"..math.random(1,3)..".wav", effectpos, 60, 90+math.random(0,20) )
		util.Effect( "hitsparks", effectdata, true, true )
		
		return
	end

	if GetConVarNumber( "sh_fx_explosiveeffects" ) == 1 then
		local effectdata = EffectData( )
		effectdata:SetNormal( Vector(0,0,1) )
		effectdata:SetOrigin( self:GetPos( ) )
		util.Effect( "shockwave", effectdata, true, true )
		util.Effect( "impactdust_explosive", effectdata, true, true )
	end

	for _, v in ipairs(ents.FindInSphere( self:GetPos(), 20 )) do
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( self.Owner )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( 2500 )
		v:TakeDamageInfo( dmginfo )
	end
	
	for _, v in ipairs(ents.FindInSphere( self:GetPos(), 100 )) do
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( self.Owner )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( 500 )
		v:TakeDamageInfo( dmginfo )
	end
	
	local explo = ents.Create( "env_explosion" )
	explo:SetOwner( self.Owner )
	explo:SetPos( self:GetPos() )
	explo:SetKeyValue( "iMagnitude", "150" )
	explo:Spawn()
	explo:Activate()
	explo:Fire( "Explode", "", 0 )

	local shake = ents.Create( "env_shake" )
	shake:SetOwner( self.Owner )
	shake:SetPos( self:GetPos() )
	shake:SetKeyValue( "amplitude", "2000" )	-- Power of the shake
	shake:SetKeyValue( "radius", "900" )	-- Radius of the shake
	shake:SetKeyValue( "duration", "0.5" )	-- Time of shake
	shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
	shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
	shake:Spawn()
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )
		
	self:Remove()
end

function ENT:WallPlant(hitpos, forward)
	if self.Busted then return end
	if (hitpos) then self.Entity:SetPos( hitpos ) end
    self.Entity:SetAngles( forward:Angle() + Angle( -90, 0, 180 ) )
end

function ENT:PhysicsCollide( data, phys ) 
	if self.Busted then return end
	--if ( !data.HitEntity:IsWorld() ) then return end
	phys:EnableMotion( false )
	phys:Sleep()
	self:WallPlant( nil, data.HitNormal:GetNormal() * 1 )
end

--[[---------------------------------------------------------
OnTakeDamage
---------------------------------------------------------]]--
function ENT:OnTakeDamage( dmginfo )
	local phys = self.Entity:GetPhysicsObject()
	self:SetColor( Color(50,50,50,255) )
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Busted = 1
end

function ENT:Touch(  )
	local phys = self.Entity:GetPhysicsObject()
	phys:EnableMotion( false )
	if self.Busted then 
		phys:EnableMotion( true )
	end
end