function EFFECT:Init(data)
	if GetConVarNumber( "sh_fx_muzzleeffects" ) == 0 then return end
	
	--if !IsValid( self.WeaponEnt ) then return end

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.Up = self.Angle:Up()
	
	
	
	local emitter = ParticleEmitter(self.Position)		
		for i = 1,2 do
			local particle = emitter:Add( "effects/dust2", self.Position )
				
				particle:SetVelocity( data:GetAngles():Forward()*-math.random(500,800) )
				particle:SetAirResistance( 200 )
				particle:SetGravity( Vector(0, 0, math.random(-10, 10) ) )
				particle:SetDieTime( math.random( 0.5, 0.8 ) )
				particle:SetStartAlpha( 150 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 5, 10 ) )
				particle:SetEndSize( math.random( 50, 100 ) )
				particle:SetRoll( math.random( -25, 25 ) )
				particle:SetRollDelta( math.random( -0.05, 0.05 ) )
				particle:SetLighting(0)
				particle:SetColor( 255, 255, 255 )
				particle:SetCollide(true)
		end
	emitter:Finish()
end


function EFFECT:Think()

	return false
end


function EFFECT:Render()
end