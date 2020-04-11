AddCSLuaFile("init.lua")
function EFFECT:Init( ed )
	local vOrig = ed:GetOrigin()
	local pe 	= ParticleEmitter( vOrig  )
	
	local Angles = ed:GetAngles():Right()*3.8
	for i = 1, 6 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/muzzleflash".. math.random(1, 4), vOrig+Angles )
		
			part:SetColor( 100, 100, 255 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.03 )
			part:SetStartSize( 1 )
			part:SetEndSize( 1 )
            part:SetCollide( false )
			part:SetStartAlpha( 250 )
			part:SetAirResistance( 1000 )
	end
	
	Angles = ed:GetAngles():Right()*-4.5
	for i = 1, 6 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/muzzleflash".. math.random(1, 4), vOrig-Angles )
		
			part:SetColor( 100, 100, 255 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.03 )
			part:SetStartSize( 1 )
			part:SetEndSize( 1 )
            part:SetCollide( false )
			part:SetStartAlpha( 250 )
			part:SetAirResistance( 1000 )
	end
	
	Angles = ed:GetAngles():Right()*3.8
	for i = 1, 6 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/stunstick", vOrig+Angles )
		
			part:SetColor( 255, 255, 255 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.01 )
			part:SetLifeTime( 0 )
			part:SetStartSize( 1 )
			part:SetEndSize( 1 )
            part:SetCollide( false )
			part:SetStartAlpha( 100 )
			part:SetAirResistance( 500 )
	end
	
	Angles = ed:GetAngles():Right()*-4.5
	for i = 1, 6 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/stunstick", vOrig-Angles )
		
			part:SetColor( 255, 255, 255 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.01 )
			part:SetLifeTime( 0 )
			part:SetStartSize( 1 )
			part:SetEndSize( 1 )
            part:SetCollide( false )
			part:SetStartAlpha( 100 )
			part:SetAirResistance( 500 )
	end
	
	pe:Finish()	
	local effectdata = EffectData()
	effectdata:SetOrigin( vOrig )

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end