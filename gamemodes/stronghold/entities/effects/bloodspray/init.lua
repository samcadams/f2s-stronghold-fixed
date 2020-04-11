

--[[---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------]]--
function EFFECT:Init( data )
	if GetConVarNumber( "sh_fx_impacteffects" ) == 0 then return end

	local ply = LocalPlayer()

	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local Scale = data:GetScale()
	
	local Dist = ply:GetPos():Distance( Pos )

	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )
		
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	
	emitter:SetNearClip( 0, 128 )

	local splatdist = (ply:EyePos()-Pos):Length()
	if splatdist <= 70 and ply != data:GetEntity() then AddBloodSplatter() end
	
		for i=1, 5 do    --MIST
		
			local particle = emitter:Add( "effects/dust", Pos + Norm * -5 )
				particle:SetVelocity( Norm * math.Rand( -300, -400 ) + VectorRand() * 10 )
				particle:SetDieTime( math.Rand (0.25, 0.4) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand( 0, 0 ) )
				particle:SetEndSize( math.Rand( 5, 20) )
				particle:SetRoll( math.Rand( -180, 180) )
				particle:SetColor( math.Rand (255,100), 0, 0 )
				particle:SetGravity( Vector( 0, 0, math.Rand( 100, -150 ) ) )
				particle:SetAirResistance( math.Rand(100 ,200 ))
				particle:SetLighting(1)
				particle:SetCollide( true )
				particle:SetBounce(0)
		
		end
		
		for i=1, 5 do   --JET
		
			local particle = emitter:Add( "effects/blood_core", Pos + Norm * -5 )
				particle:SetVelocity( Norm * math.Rand( -150, -400 ) + VectorRand() * 8 )
				particle:SetDieTime( math.Rand (0.2, 0.25) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand( 0, 0 ) )
				particle:SetEndSize( math.Rand( 5, 12) )
				particle:SetRoll( math.Rand( -180, 180) )
				particle:SetColor( math.Rand (255,100), 0, 0 )
				particle:SetGravity( Vector( 0, 0, math.Rand( 100, -150 ) ) )
				particle:SetAirResistance( math.Rand(350 ,650 ))
				particle:SetLighting(1)
				particle:SetCollide( true )
				particle:SetBounce(0)
		
		end
		
		for i=1, 5 do     --EXIT PUFF DETAIL
		
			local particle = emitter:Add( "effects/dust", Pos + Norm * -5 )
				particle:SetVelocity( Norm * math.Rand( -150, -250 ) + VectorRand() * 10 )
				particle:SetDieTime( math.Rand (0.15, 0.2) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand( 0, 0 ) )
				particle:SetEndSize( math.Rand( 1, 2) )
				particle:SetRoll( math.Rand( -180, 180) )
				particle:SetColor( math.Rand (55,200), 0, 0 )
				particle:SetGravity( Vector( 0, 0, math.Rand( 100, -150 ) ) )
				particle:SetAirResistance( math.Rand(300 ,600 ))
				particle:SetLighting(1)
				particle:SetCollide( true )
				particle:SetBounce(0)
		
		end
		
		for i=1, 5 do   --EXIT PUFF
		
			local particle = emitter:Add( "effects/blood_puff", Pos + Norm * -5 )
				particle:SetVelocity( Norm * math.Rand( -150, -100 ) + VectorRand() * 2 )
				particle:SetDieTime( math.Rand (0.1, 0.15) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand( 0, 0 ) )
				particle:SetEndSize( math.Rand( 2, 4) )
				particle:SetRoll( math.Rand( -180, 180) )
				particle:SetColor( math.Rand (255,55), 0, 0 )
				particle:SetGravity( Vector( 0, 0, math.Rand( 100, -150 ) ) )
				particle:SetAirResistance( math.Rand(300 ,600 ))
				particle:SetLighting(1)
				particle:SetCollide( true )
				particle:SetBounce(0)
		
		end	
		if math.random(1,2) == 1 then
		for i=1, 2 do   --DEBRIS
		
			local particle = emitter:Add( "effects/fleck_cement2", Pos + Norm * -5 )
				particle:SetVelocity( Norm * math.Rand( -150, -400 ) + VectorRand() * 80 )
				particle:SetDieTime( math.Rand (0.5, 1) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand(0.5, 1) )
				particle:SetRoll( math.Rand( -180, 180) )
				particle:SetColor( math.Rand (255,100), 0, 0 )
				particle:SetGravity( Vector( 0, 0, -600 ) ) 
				particle:SetAirResistance( 0 )
				particle:SetLighting(1)
				particle:SetCollide( true )
				particle:SetBounce(0)
		
		end
		end
		if math.random(1,2) == 1 then
		for i=1, 2 do   --DEBRIS
		
			local particle = emitter:Add( "effects/fleck_cement1", Pos + Norm * -5 )
				particle:SetVelocity( Norm * math.Rand( -150, -400 ) + VectorRand() * 80 )
				particle:SetDieTime( math.Rand (0.5, 1) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand(0.5, 1) )
				particle:SetRoll( math.Rand( -180, 180) )
				particle:SetColor( math.Rand (255,100), 0, 0 )
				particle:SetGravity( Vector( 0, 0, -600 ) ) 
				particle:SetAirResistance( 0 )
				particle:SetLighting(1)
				particle:SetCollide( true )
				particle:SetBounce(0)
		
		end
		end
		
		for i=1, 1 do
		
			local particle = emitter:Add( "effects/blood_puff", Pos + Norm * 3 )
			particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * (math.Rand( 1, 5 )*1) )
			particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
			particle:SetStartAlpha(255)
			particle:SetStartSize( math.Rand( 1, 5 ) )
			particle:SetEndSize( math.Rand (10, 15) )
			particle:SetRoll( math.Rand ( -1000, 1000) )
			particle:SetColor( math.Rand (100,50), 0, 0 )
			particle:SetGravity( Vector( 0, 0, math.Rand( 300, 0 ) ) )
			particle:SetAirResistance( math.Rand (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
		
		for i=1, 1 do
		
			local particle = emitter:Add( "effects/dust", Pos + Norm * 3 )
			particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * (math.Rand( 1, 5 )*1) )
			particle:SetDieTime( math.Rand( 0.2, 0.4 ) )
			particle:SetStartAlpha(255)
			particle:SetStartSize( math.Rand( 5, 10 ) )
			particle:SetEndSize( math.Rand (15, 20) )
			particle:SetRoll( math.Rand ( -1000, 1000) )
			particle:SetColor( math.Rand (125,50), 0, 0 )
			particle:SetGravity( Vector( 0, 0, math.Rand( 300, 0 ) ) )
			particle:SetAirResistance( math.Rand (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
		
		for i=1, 1 do
		
			local particle = emitter:Add( "effects/blood_core", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * (math.Rand( 1, 5 )*1) )
			particle:SetDieTime( 0.07 )
			particle:SetStartAlpha(255)
			particle:SetStartSize( math.Rand( 1, 5 ) )
			particle:SetEndSize( math.Rand (10, 15) )
			particle:SetRoll( math.Rand ( -1000, 1000) )
			particle:SetColor( math.Rand (100,55), 0, 0 )
			particle:SetGravity( Vector( 0, 0, math.Rand( 300, 0 ) ) )
			particle:SetAirResistance( math.Rand (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
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



