function EFFECT:Init( data )
if GetConVarNumber( "sh_fx_detailedimpacteffects" ) == 0 then
return end
	 
	local eyepos = LocalPlayer():EyePos()
	local aim = LocalPlayer():GetAimVector()
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal() 
	local Scale = data:GetScale()* math.random( 10, 20 )
	local SurfaceColor = render.GetSurfaceColor( Pos+Norm, Pos-Norm*100 ) * 255
	SurfaceColor.r = math.Clamp( SurfaceColor.r+20, 0, 255 )
	SurfaceColor.g = math.Clamp( SurfaceColor.g+20, 0, 255 )
	SurfaceColor.b = math.Clamp( SurfaceColor.b+20, 0, 255 )
	local Dist = LocalPlayer():GetPos():Distance( Pos )
	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )	
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	emitter:SetNearClip( 0, 128 )
	
	if GetConVarNumber( "sh_fx_smokeyimpacteffects" ) == 1 then
		if math.random( 1, 4 ) == 1 then
			for i=1, 1 do
			
				local particle = emitter:Add( "effects/dust", Pos + Norm * 1 )
				particle:SetVelocity( Norm * math.random( 4, 8 ) + VectorRand() * (math.random( 1, 5 )*1) )
				particle:SetDieTime( math.random( 30, 50 ) )
				particle:SetStartAlpha(math.random( 100, 150 ))
				particle:SetStartSize( math.random( 10, 15 ) )
				particle:SetEndSize( math.random (100, 150) )
				particle:SetRoll( math.random ( -1000, 1000) )
				particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
				particle:SetGravity( Vector( 0, 0, 0 ) )
				particle:SetAirResistance( math.random (5, 10) )
				particle:SetCollide(true)
				particle:SetBounce(0.1)
			end
		end
	end	
		for i=1, 2 do
		
			local particle = emitter:Add( "effects/dust", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.random( 50, 100 ) + VectorRand() * (math.random( 1, 5 )*1) )
			particle:SetDieTime( math.random( 0.05, 0.2 ) )
			particle:SetStartAlpha(255)
			particle:SetStartSize( math.random( 10, 15 ) )
			particle:SetEndSize( math.random (30, 40) )
			particle:SetRoll( math.random ( -1000, 1000) )
			particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
			particle:SetGravity( Vector( 0, 0, math.random( 300, 0 ) ) )
			particle:SetAirResistance( math.random (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
		
		for i=1, 2 do
		
			local particle = emitter:Add( "effects/dust", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.random( 50, 100 ) + VectorRand() * (math.random( 1, 5 )*1) )
			particle:SetDieTime( math.random( 0.1, 0.5 ) )
			particle:SetStartAlpha(255)
			particle:SetStartSize( math.random( 1, 5 ) )
			particle:SetEndSize( math.random (10, 15) )
			particle:SetRoll( math.random ( -1000, 1000) )
			particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
			particle:SetGravity( Vector( 0, 0, math.random( 300, 0 ) ) )
			particle:SetAirResistance( math.random (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
		
		for i=1, 5 do
		
			local particle = emitter:Add( "effects/dust2", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.random( 300, 600 ) + VectorRand() * (math.random( 1, 5 )*1) )
			particle:SetDieTime( math.random( 0.2, 0.5 ) )
			particle:SetStartAlpha(math.random(150,255))
			particle:SetStartSize( math.random( 1, 5 ) )
			particle:SetEndSize( math.random (10, 15) )
			particle:SetRoll( math.random ( -1000, 1000) )
			particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
			particle:SetGravity( Vector( 0, 0, math.random( 300, 0 ) ) )
			particle:SetAirResistance( math.random (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
		
		for i=1, 5 do
		
			local particle = emitter:Add( "effects/dust2", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.random( 300, 600 ) + VectorRand() * (math.random( 1, 5 )*100) )
			particle:SetDieTime( math.random( 0.2, 0.5 ) )
			particle:SetStartAlpha(255)
			particle:SetStartSize( math.random( 1, 5 ) )
			particle:SetEndSize( math.random (5, 10) )
			particle:SetRoll( math.random ( -1000, 1000) )
			particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
			particle:SetGravity( Vector( 0, 0, math.random( 300, 0 ) ) )
			particle:SetAirResistance( math.random (1000, 1200) )
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end

		
		if math.random( 1, 10 ) == 1 then
		timer.Simple(math.random(0.5,1), function()
		for i=1, 1 do
		
			local particle = emitter:Add( "effects/fleck_cement2", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.random( 2, 4 ) + VectorRand() * (math.random( 1, 5 )*1) )
			particle:SetDieTime( math.random( 5, 10 ) )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 2 )
			particle:SetEndSize( 2 )
			particle:SetRoll( math.random ( -100, 100) )
			particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
			particle:SetGravity( Vector( 0, 0, -600 ))
			particle:SetAirResistance( 0 )
			particle:SetCollide(true)
			particle:SetBounce(0.3)
		end
		end)
		
		timer.Simple(math.random(1.2,2), function()
		for i=1, 1 do
		
			local particle = emitter:Add( "effects/fleck_cement1", Pos + Norm * 1 )
			particle:SetVelocity( Norm * math.random( 2, 4 ) + VectorRand() * (math.random( 1, 5 )*1) )
			particle:SetDieTime( math.random( 5, 10 ) )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 1 )
			particle:SetEndSize( 1 )
			particle:SetRoll( math.random ( -100, 100) )
			particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
			particle:SetGravity( Vector( 0, 0, -600 ))
			particle:SetAirResistance( 0 )
			particle:SetCollide(true)
			particle:SetBounce(0.3)
		end
		end)
		end
		
	

			--emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()	
end



