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
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
		
		for i = 1,1 do 

			local particle = emitter:Add( "effects/combinemuzzle"..math.random( 1, 2 ), self.Position + 1 * self.Forward )

				particle:SetVelocity( AddVel )
				particle:SetAirResistance( 0 )
				particle:SetDieTime( 0.175 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 1.5  )
				particle:SetEndSize( 10  )
				particle:SetRoll( math.Rand( 180, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1) )
				particle:SetColor( 255, 255, 255 )	
		end
		
		for i = 1,1 do 

			local particle = emitter:Add( "effects/energyball", self.Position + 1 * self.Forward )

				particle:SetVelocity( AddVel )
				particle:SetAirResistance( 0 )
				particle:SetDieTime( 0.175 )
				particle:SetStartAlpha( 100 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 1.5 )
				particle:SetEndSize( 7.5 )
				particle:SetRoll( math.Rand( 180, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1) )
				particle:SetColor( 255, 255, 255 )	
		end

	emitter:Finish()
	
end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end