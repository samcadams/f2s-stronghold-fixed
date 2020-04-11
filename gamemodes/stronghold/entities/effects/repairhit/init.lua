function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local Scale = data:GetScale()
	local SurfaceColor = render.GetSurfaceColor( Pos+Norm, Pos-Norm*100 ) * 255
	SurfaceColor.r = math.Clamp( SurfaceColor.r+20, 0, 255 )
	SurfaceColor.g = math.Clamp( SurfaceColor.g+20, 0, 255 )
	SurfaceColor.b = math.Clamp( SurfaceColor.b+20, 0, 255 )
	local Dist = LocalPlayer():GetPos():Distance( Pos )
	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )	
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	emitter:SetNearClip( 0, 128 )
	if GetConVarNumber( "sh_fx_dynamicweldlight" ) == 1 then

					local dynamicflash = DynamicLight()
				if dynamicflash then
					dynamicflash.Pos = Pos + Norm * 2
					dynamicflash.r = 220
					dynamicflash.g = 220
					dynamicflash.b = 255
					dynamicflash.Brightness = math.Rand( 3, 5)
					dynamicflash.Size = 100
					dynamicflash.Decay = 0
					dynamicflash.DieTime = CurTime() + 0.01
				end 
	end
	
		for i=1, 2 do
			local particle = emitter:Add( "effects/dust", Pos + Norm * 1 )	
			particle:SetVelocity( Norm * math.Rand( 1, 3 ) + VectorRand() * 10 )
			particle:SetDieTime( math.Rand( 0.3, 1 ) )
			particle:SetStartAlpha( math.Rand ( 100, 200 ) )
			particle:SetStartSize( 0 )
			particle:SetEndSize( math.Rand (5, 10) )
			particle:SetRoll( math.Rand ( -180, 180) )
			particle:SetRollDelta(math.Rand(-2,2))
			particle:SetColor( 125, 125, 125 )
			particle:SetGravity( Vector( 0, 0, math.Rand( 50, 5 ) ) )
			particle:SetAirResistance( math.Rand (10, 20) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			end	
	
		for i=1, 2 do
			local particle = emitter:Add( "effects/dust2", Pos + Norm * 1 )	
			particle:SetVelocity( Norm * math.Rand( 1, 3 ) + VectorRand() * 10 )
			particle:SetDieTime( math.Rand( 1, 2 ) )
			particle:SetStartAlpha( math.Rand ( 25, 50 ) )
			particle:SetStartSize( 0 )
			particle:SetEndSize( math.Rand (1, 5) )
			particle:SetRoll( math.Rand ( -180, 180) )
			particle:SetRollDelta(math.Rand(-2,2))
			particle:SetColor( 75, 75, 75)
			particle:SetGravity( Vector( 0, 0, math.Rand( 50, 5 ) ) )
			particle:SetAirResistance( math.Rand (10,20) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			end				
			
					--[[for i=1, 5 do
			local particle = emitter:Add( "effects/spark", Pos - Norm * 1 )	
			local Vel = particle:GetVelocity()
			particle:SetVelocity( Norm * math.Rand( 10, 30 ) + VectorRand() * 50 )
			particle:SetDieTime( math.Rand(0, 4 ) )
			particle:SetStartAlpha( math.Rand ( 255, 255 ) )
			particle:SetStartLength( 5 )
			particle:SetEndLength( 0 )
			particle:SetStartSize( 1 )
			particle:SetEndSize( 1 )
			particle:SetRoll( math.Rand ( -180, 180) )
			particle:SetColor( 255, 255, 255)
			particle:SetGravity( Vector( 0, 0,-600) )
			particle:SetAirResistance( 0 )
			particle:SetCollide(true)
			particle:SetBounce(0.5)
			end]]
					for i=1, 10 do
			local particle = emitter:Add( "effects/stunstick", Pos + Norm * 1 )	
			particle:SetVelocity( Norm * math.Rand( 1, 3 ) + VectorRand() * 1 )
			particle:SetDieTime( 0.05 )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 3 )
			particle:SetEndSize( math.Rand (6, 8) )
			particle:SetRoll( math.Rand ( -180, 180) )
			particle:SetColor( 255, 255, 255)
			particle:SetGravity( Vector( 0, 0, math.Rand( 50, 0 ) ) )
			particle:SetAirResistance( math.Rand (10,20) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			end	
			emitter:Finish()
			
			
end

function EFFECT:Think( data )
return false
end

function EFFECT:Render()	
end



