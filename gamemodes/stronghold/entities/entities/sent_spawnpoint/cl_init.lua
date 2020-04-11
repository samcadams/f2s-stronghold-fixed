include( "shared.lua" )

function ENT:Initialize()
end

local MAT_WHITE = Material( "vgui/white" )
local POLY_DISTANCE = 20
local POLY_COUNT = 6
local POLY_ANG = 2 * math.pi / POLY_COUNT
local POLY_CORNERS = {}
for i=0, POLY_COUNT-1 do
	local x, y = math.cos( POLY_ANG*i ), math.sin( POLY_ANG*i )
	local tbl = {
		x = x*POLY_DISTANCE,
		y = y*POLY_DISTANCE,
		u = x,
		v = y
	}
	table.insert( POLY_CORNERS, tbl )
end

function ENT:Draw()
	self:DrawModel()
	
	local teamcol = self:GetPlayerColor()
	local ang = self:GetAngles()
	cam.Start3D2D( self:GetPos()+10*self:GetUp(), ang, 0.25 )
		surface.SetMaterial( MAT_WHITE )
		surface.SetDrawColor( teamcol.x*255, teamcol.y*255, teamcol.z*255, 255 )
		surface.DrawPoly( POLY_CORNERS )
		--draw.RoundedBox( 16, -16, -16, 32, 32, col )
	cam.End3D2D()
end
