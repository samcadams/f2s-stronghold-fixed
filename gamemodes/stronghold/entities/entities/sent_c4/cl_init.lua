include( 'shared.lua' )


local font_data = {
	["BombText3"] = {
		font 	= "coolvetica",
		size 	= 18,
		weight 	= 500
	},
}

surface.CreateFont( "BombText3", font_data.BombText3 )

function ENT:Initialize()
	self.timer = CurTime()+5.5
end

local function round( x )
	return (x-math.floor(x) >= 0.50 and math.ceil(x) or math.floor(x))
end

function ENT:Draw()
	self.Entity:DrawModel()

	local FixAngles 	= self.Entity:GetAngles()
	local FixRotation 	= Vector(0, 270, 0)

	FixAngles:RotateAroundAxis(FixAngles:Right(), 	FixRotation.x)
	FixAngles:RotateAroundAxis(FixAngles:Up(), 		FixRotation.y)
	FixAngles:RotateAroundAxis(FixAngles:Forward(), FixRotation.z)
 	
 	local TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 9)
	local TIME 		= round(self.timer - CurTime())

	cam.Start3D2D(TargetPos, FixAngles, 0.15)
		if self.timer < CurTime() then
			draw.SimpleText("   ERROR", "BombText3", 25, -18, Color(255,0,0,255),1,1)
		else
			draw.SimpleText(TIME, "BombText3", 25, -18, Color(255,0,0,255),1,1)
		end
	cam.End3D2D() 
end

function ENT:Think()
	self.SmokeTimer = self.SmokeTimer or 0

	if ( self.SmokeTimer > CurTime() ) then return end
	
	self.SmokeTimer = CurTime() + 0.15
	local vPos 		= self:LocalToWorld( self:OBBCenter() );
	local R 		= math.Rand( 0.8, 1)
	local vOffset 	= Vector(0, 0, 0) 
	local emitter 	= ParticleEmitter( vOffset )
	
	if self.timer < CurTime() then
		local smoke = emitter:Add( "particle/particle_smokegrenade", vOffset + vPos )
		smoke:SetVelocity(VectorRand() * math.Rand(5, 10))
		smoke:SetGravity( Vector( 0, 0, math.Rand( 10, 50 ) ) )
		smoke:SetDieTime(2.5)
		smoke:SetStartAlpha(math.Rand (105, 200))
		smoke:SetStartSize( 0 )
		smoke:SetEndSize(20)
		smoke:SetRoll(math.Rand(-180, 180))
		smoke:SetRollDelta(math.Rand(-0.2,0.2))
		smoke:SetColor(20, 20, 20)
		smoke:SetAirResistance(100)
	end
	
	if self.timer < CurTime() then
		local smoke = emitter:Add( "particles/smokey", vOffset + vPos )
		smoke:SetVelocity(VectorRand() * math.Rand(5, 10))
		smoke:SetGravity( Vector( 0, 0, math.Rand( 10, 50 ) ) )
		smoke:SetDieTime(2.5)
		smoke:SetStartAlpha(math.Rand (50, 100))
		smoke:SetStartSize( 0 )
		smoke:SetEndSize(20)
		smoke:SetRoll(math.Rand(-180, 180))
		smoke:SetRollDelta(math.Rand(-0.2,0.2))
		smoke:SetColor(50*R, 50*R, 50*R)
		smoke:SetAirResistance(200)
	end

	emitter:Finish()
end
