EFFECT.Glow = Material( "effects/strider_muzzle" )
EFFECT.Glow2 = Material( "effects/energyball" )
EFFECT.Mat = Material( "effects/tool_tracer" )
EFFECT.Mat2 = Material( "sprites/physbeam" )
EFFECT.Mat3 = Material( "sprites/bluelaser1" )

function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment ) + data:GetNormal()
	self.EndPos = data:GetOrigin()
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	
	
	self.Alpha = 255
end

function EFFECT:Think()
	self.Alpha = self.Alpha - FrameTime() * 2048

	--self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment ) + Vector( math.Rand(-.25,.25), math.Rand(-.25,.25), math.Rand(-.25,.25) )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )

	if self.Alpha < 0 then return false end
	return true
end

function EFFECT:Render( )
	if self.Alpha < 1 then return end

	local norm = (self.StartPos - self.EndPos)
	self.Length = norm:Length()
	norm:Normalize()

	local col = Color( 255, 255, 255, self.Alpha )
	local texcoord = math.Rand( 0, 1 )

	render.SetMaterial( self.Glow )
	for i=1, 2 do
		render.DrawSprite( self.StartPos, math.Rand(6,8), math.Rand(6,8), col )
	end
	
	render.SetMaterial( self.Glow2  )
	for i=1, 2 do
		render.DrawSprite( self.StartPos, math.Rand(6,8), math.Rand(6,8), col )
	end
	
	render.SetMaterial( self.Mat )
	for i=1, 3 do
		local rand = math.Rand( 0, i )
		render.DrawBeam( self.StartPos, self.EndPos, rand, texcoord+rand, texcoord+rand + self.Length/128, col )
	end

	render.SetMaterial( self.Mat2 )
	render.DrawBeam( self.StartPos, self.EndPos, 2+texcoord-0.5, texcoord, texcoord + self.Length/128, col )
	
	render.SetMaterial( self.Mat3 )
	for i=1, 3 do
		render.DrawBeam( self.StartPos, self.EndPos, 1+texcoord-0.5, texcoord, texcoord + self.Length/128, Color( 255, 0, 0, self.Alpha ) )
	end
end
