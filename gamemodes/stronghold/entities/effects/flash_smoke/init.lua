function EFFECT:Init( data )

	if GetConVarNumber( "sh_fx_explosiveeffects" ) == 0 then return end
	
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
	
	if GetConVarNumber( "bfgm_lowimpacteffects" ) == 0 then
	
			for i=0, 25 do
			local particle = emitter:Add( "particle/particle_smokegrenade", Pos + Norm * 1 )	
				particle:SetVelocity( Norm * math.Rand( 50, 150) + VectorRand() * 500)
				particle:SetDieTime( math.Rand( 5, 10 ) )
				particle:SetStartAlpha( math.Rand ( 10, 50 ) )
				particle:SetStartSize( math.Rand( 10, 30 ) )
				particle:SetEndSize( math.Rand (100, 200) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 200, 200, 200 )
				particle:SetGravity( Vector( 0, 0, math.Rand( -100, 0 ) ) )
				particle:SetAirResistance( math.Rand (200, 500) )
				particle:SetCollide(true)
				particle:SetBounce(0.1)
			end
			for i=1, 25 do
			local particle = emitter:Add( "particle/particle_smokegrenade", Pos + Norm * 1 )	
				particle:SetVelocity( Norm * math.Rand( 150, 50) + VectorRand() * 500)
				particle:SetDieTime( math.Rand( 0.5, 2 ) )
				particle:SetStartAlpha( math.Rand ( 10, 50 ) )
				particle:SetStartSize( math.Rand( 10, 30 ) )
				particle:SetEndSize( math.Rand (50, 100) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 200, 200, 200 )
				particle:SetGravity( Vector( 0, 0, math.Rand( -100, 0 ) ) )
				particle:SetAirResistance( math.Rand (200, 500) )
				particle:SetCollide(true)
				particle:SetBounce(0.1)
			end
			for i=1, 25 do
			local particle = emitter:Add( "effects/dust", Pos + Norm * 1 )	
				particle:SetVelocity( Norm * math.Rand( 150, 50) + VectorRand() * 500)
				particle:SetDieTime( math.Rand( 0.5, 2 ) )
				particle:SetStartAlpha( math.Rand ( 10, 50 ) )
				particle:SetStartSize( math.Rand( 10, 30 ) )
				particle:SetEndSize( math.Rand (50, 100) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 200, 200, 200 )
				particle:SetGravity( Vector( 0, 0, math.Rand( -100, 0 ) ) )
				particle:SetAirResistance( math.Rand (200, 500) )
				particle:SetCollide(true)
				particle:SetBounce(0.1)
			end
			for i=1, 25 do
			local particle = emitter:Add( "effects/dust2", Pos + Norm * 1 )	
				particle:SetVelocity( Norm * math.Rand( 150, 50) + VectorRand() * 500)
				particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
				particle:SetStartAlpha( math.Rand ( 200, 255 ) )
				particle:SetStartSize( math.Rand( 5, 15 ) )
				particle:SetEndSize( math.Rand (30, 50) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 200, 200, 200 )
				particle:SetGravity( Vector( 0, 0, math.Rand( -100, 0 ) ) )
				particle:SetAirResistance( math.Rand (200, 500) )
				particle:SetCollide(true)
				particle:SetBounce(0.1)
			end
			
			for i=0, 20 do
		
			local particle = emitter:Add( "effects/fire_embers1", Pos + Norm * 0 )
			
				particle:SetVelocity( Norm * 200 + VectorRand() * 500 )
				particle:SetDieTime( math.Rand(1, 1.5) )
				particle:SetStartAlpha( math.Rand ( 255, 255 ))
				particle:SetStartSize( math.Rand( 0, 1 ) )
				particle:SetEndSize( 15 )
				particle:SetRoll( math.Rand ( 180, -180) )
				particle:SetColor( 135, 255, 255 )
				particle:SetGravity( Vector( 0, 0, math.Rand( -50, -100 ) ) )
				particle:SetAirResistance( 200 )
				
		end
		
		----------------------------LOW-------------------------------------------
		for i=1, 2 do
			
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 1 )	
			particle:SetDieTime( math.Rand( 0.1, 0.3 ) )
			particle:SetStartAlpha( math.Rand ( 100, 50 ) )
			particle:SetStartSize( math.Rand( 0, 1 ) )
			particle:SetEndSize( math.Rand (50, 100) )
			particle:SetRoll( math.Rand ( -180, 180) )
			particle:SetColor( 255, 255, 255 )
			particle:SetGravity( Vector( 0, 0, math.Rand( -200, 0 ) ) )
			particle:SetAirResistance( math.Rand (500, 1000) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
			emitter:Finish()
	end
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()	
end



