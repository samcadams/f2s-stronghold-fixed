function EFFECT:Init( data )
if GetConVarNumber( "sh_fx_detailedimpacteffects" ) == 0 then
return end

	
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local Scale = data:GetScale()
	local R = math.Rand(0.6, 1)
	
	local SurfaceColor = render.GetSurfaceColor( Pos+Norm, Pos-Norm*100 ) * 255
	
		SurfaceColor.r = math.Clamp( SurfaceColor.r+20, 0, 255 )
		SurfaceColor.g = math.Clamp( SurfaceColor.g+20, 0, 255 )
		SurfaceColor.b = math.Clamp( SurfaceColor.b+20, 0, 255 )
	
	local Dist = LocalPlayer():GetPos():Distance( Pos )

	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )
		
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	
	emitter:SetNearClip( 0, 128 )
	
		for i=0, 1 do
		
			local particle = emitter:Add( "effects/blood_core", Pos + Norm * 2 )
				particle:SetVelocity( Norm * math.Rand( 20, 10 ) + VectorRand() * 1 )
				particle:SetDieTime( math.Rand( 0.02, 0.10 ) )
				particle:SetStartAlpha( math.Rand ( 50, 155 ) )
				particle:SetStartSize( math.Rand( 0, 1 ) )
				particle:SetEndSize( math.Rand (5, 20 ) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 150* R, 150* R, 150* R )
				particle:SetGravity( Vector( 0, 0, math.Rand( -100, 200 ) ) )
				particle:SetAirResistance( math.Rand (1750, 1800) )
		
		end
		
		for i=0, 1 do
		
			local particle = emitter:Add( "blood/blood_spray", Pos + Norm * 2 )
				particle:SetVelocity( Norm * math.Rand( 20, 10 ) + VectorRand() * 1 )
				particle:SetDieTime( math.Rand( 0.03, 0.15 ) )
				particle:SetStartAlpha( math.Rand ( 50, 155 ) )
				particle:SetStartSize( math.Rand( 0, 1 ) )
				particle:SetEndSize( math.Rand (5, 15 ) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 125* R, 125* R, 125* R )
				particle:SetGravity( Vector( 0, 0, math.Rand( -100, 200 ) ) )
				particle:SetAirResistance( math.Rand (1750, 1800) )
		
		end


		for i=1, 2 do
		
			local particle = emitter:Add( "particle/particle_smokegrenade", Pos + Norm * 1 )
			
				particle:SetVelocity( Norm * math.Rand( 20, 10 ) + VectorRand() * 25 )
				particle:SetDieTime( math.Rand( 0.5, 1 ) )
				particle:SetStartAlpha( math.Rand ( 50, 200 ) )
				particle:SetStartSize( math.Rand( 0, 1 ) )
				particle:SetEndSize( math.Rand (5, 8) )
				particle:SetRoll( math.Rand ( -180, 180) )
				particle:SetColor( 200 * R, 200* R, 200* R )
				particle:SetGravity( Vector( 0, 0, math.Rand( -50, 0 ) ) )
				particle:SetAirResistance( math.Rand (500, 1000) )
				
		end
				
		
	emitter:Finish()
		
end

--[[---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------]]--
function EFFECT:Think( )
	return false
end


--[[---------------------------------------------------------
   Draw the effect
---------------------------------------------------------]]--
function EFFECT:Render()	
end



