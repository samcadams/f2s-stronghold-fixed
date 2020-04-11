include( "shared.lua" )

function ENT:Think()
	self:NextThink( 0 )

	if !self.Flashed then
		if CurTime() - self.Created >= self.dt.Duration + 0.20 then
			local dynamicflash = DynamicLight( self:EntIndex() )
			if dynamicflash then
				dynamicflash.Pos = self:GetPos()
				dynamicflash.r = 255
				dynamicflash.g = 255
				dynamicflash.b = 255
				dynamicflash.Brightness = 10
				dynamicflash.Size = 500
				dynamicflash.Decay = 500
				dynamicflash.DieTime = CurTime() + 0.20
			end
			self.Flashed = true
		end
	elseif self.SmokeTimer < CurTime() then
		local emitter = self.Emitter
		if !emitter then return end
	
		self.SmokeTimer = CurTime() + 0.05

		local vPos = Vector( 1, 1, 0 )
		local R = math.Rand( 0.8, 1 )
		local vOffset = self:LocalToWorld( Vector(0, 0, self:OBBMins().z) )

		local smoke = emitter:Add( "effects/dust", vOffset + vPos )
		smoke:SetVelocity( VectorRand() * math.Rand(5,10) )
		smoke:SetGravity( Vector(0,0,math.Rand(10,30)) )
		smoke:SetDieTime( 1 )
		smoke:SetStartAlpha( 255 )
		smoke:SetStartSize( 0 )
		smoke:SetEndSize( 10 )
		smoke:SetRoll( math.Rand(-180,180) )
		smoke:SetRollDelta( math.Rand(-0.2,0.2) )
		smoke:SetColor(100*R, 100*R, 100*R )
		smoke:SetAirResistance( 200 )		
		
		local smoke = emitter:Add( "effects/dust2", vOffset + vPos )
		smoke:SetVelocity( VectorRand() * math.Rand(10,30) )
		smoke:SetGravity( Vector(0,0,math.Rand(10,30)) )
		smoke:SetDieTime( 5 )
		smoke:SetStartAlpha( 255 )
		smoke:SetStartSize( 0 )
		smoke:SetEndSize( 10 )
		smoke:SetRoll( math.Rand(-180,180) )
		smoke:SetRollDelta( math.Rand(-0.2,0.2) )
		smoke:SetColor(100*R, 100*R, 100*R )
		smoke:SetAirResistance( 200 )

		--emitter:Finish()
	end
	
	return true
end

function ENT:Draw()
	self:DrawModel()
end