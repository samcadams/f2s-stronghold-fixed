AddCSLuaFile("init.lua")
function EFFECT:Init( ed )
	local vOrig = ed:GetOrigin()
	local pe 	= ParticleEmitter( vOrig  )
	
	local Angles = ed:GetAngles():Right()*3.8
	for i = 1, 6 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/muzzleflash1", vOrig+Angles )
		
			part:SetColor( 255, 255, 255 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.03 )
			part:SetStartSize( 1 )
			part:SetEndSize( 10 )
            part:SetCollide( false )
			part:SetStartAlpha( 255 )
			part:SetAirResistance( 1000 )
	end
	
	Angles = ed:GetAngles():Right()*-4.5
	for i = 1, 6 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/muzzleflash1", vOrig-Angles )
		
			part:SetColor( 255, 255, 255 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.03 )
			part:SetStartSize( 1 )
			part:SetEndSize( 10 )
            part:SetCollide( false )
			part:SetStartAlpha( 255 )
			part:SetAirResistance( 1000 )
	end
	
	Angles = ed:GetAngles():Right()*3.8
	for i = 1, 2 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/dust2", vOrig+Angles )
		
			part:SetColor( 50, 50, 50 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.3 )
			part:SetLifeTime( 0 )
			part:SetStartSize( 10 )
			part:SetEndSize( 15 )
            part:SetCollide( false )
			part:SetStartAlpha( 50 )
			part:SetAirResistance( 500 )
	end
	
	Angles = ed:GetAngles():Right()*-4.5
	for i = 1, 2 do
		Angles = Angles - ed:GetAngles():Right()*0.56
		local part = pe:Add( "effects/dust2", vOrig-Angles )
		
			part:SetColor( 50, 50, 50 )
			part:SetVelocity( ed:GetAngles():Forward()*math.Rand(-10,10) )
			part:SetRoll( math.Rand(0, 360) )
			part:SetDieTime( 0.3 )
			part:SetLifeTime( 0 )
			part:SetStartSize( 10 )
			part:SetEndSize( 15 )
            part:SetCollide( false )
			part:SetStartAlpha( 50 )
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