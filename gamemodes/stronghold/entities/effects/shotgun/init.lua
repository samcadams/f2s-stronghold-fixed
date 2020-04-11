function EFFECT:Init(data)

if GetConVarNumber( "sh_fx_muzzleeffects" ) == 0 then
return end

	
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	if !IsValid( self.WeaponEnt ) then return end

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.Up = self.Angle:Up()
	
	local emitter = ParticleEmitter(self.Position)
	
	if self.WeaponEnt:IsWeapon() then
	if self.WeaponEnt:GetOwner():KeyDown(IN_ATTACK2) then return end
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
		for i = 1,10 do
			local particle = emitter:Add( "particle/particle_smokegrenade", self.Position )

				particle:SetVelocity( 50 * i * self.Forward + 8 * VectorRand() )
				particle:SetAirResistance( 400 )
				particle:SetGravity( Vector(0, 0, math.Rand(10, -10) ) )
				particle:SetDieTime( math.Rand( 0.2, 0.5 ) )
				particle:SetStartAlpha( math.Rand( 50, 140 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 0, 0 ) )
				particle:SetEndSize( math.Rand( 5, 9 ) )
				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )
				particle:SetColor( 150, 150, 150 )
				particle:SetLighting(1)
				particle:SetCollide(true)
		end
		
		for i = 1,2 do 
	
			local particle = emitter:Add( "effects/muzzleflash" .. math.Rand(1,4), self.Position )
	
				particle:SetVelocity( 100 * self.Forward + 1.1 * AddVel )
				particle:SetAirResistance( 160 )
				particle:SetDieTime( 0.03 )
				particle:SetStartAlpha( 200 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 2 )
				particle:SetEndSize( 4 )
				particle:SetRoll( math.Rand( 180, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1) )
		end
	end
	
	if self.WeaponEnt:IsWeapon() then return end
	local AddVel2 = LocalPlayer():GetVelocity()
		for i = 1,10 do
			local particle = emitter:Add( "particle/particle_smokegrenade", self.Position + 20 * self.Forward - 3 * self.Up)

				particle:SetVelocity( 50 * i * self.Forward + 8 * VectorRand() )
				particle:SetAirResistance( 400 )
				particle:SetGravity( Vector(0, 0, math.Rand(10, -10) ) )
				particle:SetDieTime( math.Rand( 0.2, 0.5 ) )
				particle:SetStartAlpha( math.Rand( 50, 140 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 0, 0 ) )
				particle:SetEndSize( math.Rand( 5, 9 ) )
				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )
				particle:SetLighting(1)
				particle:SetCollide(true)
		end
		
		for i = 1,2 do 
	
			local particle = emitter:Add( "effects/muzzleflash" .. math.Rand(1,4), self.Position + 20 * self.Forward - 3 * self.Up)
	
				particle:SetVelocity( 100 * self.Forward + 1.1 * AddVel2 )
				particle:SetAirResistance( 160 )
				particle:SetDieTime( 0.03 )
				particle:SetStartAlpha( 200 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 2 )
				particle:SetEndSize( 4 )
				particle:SetRoll( math.Rand( 180, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1) )	
		end


	emitter:Finish()
	
end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end