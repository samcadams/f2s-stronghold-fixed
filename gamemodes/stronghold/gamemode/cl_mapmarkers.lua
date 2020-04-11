--[[
	File: cl_mapmarkers.lua
	For: FTS: Stronghold
	By: Ultra
]]--

GM.Map 						= {}
GM.Map.m_tMarkers 			= {}
GM.Map.MARKER_LATTACK		= 1
GM.Map.MARKER_LRALLY		= 2
GM.Map.MARKER_LDEFENDBASE 	= 3
GM.Map.MARKER_GUNDERFIRE	= 4
GM.Map.MARKER_GENEMYSPOTTED = 5

local PaintPoint = function( tblMarkerData )
	local pos = tblMarkerData.Pos:ToScreen()

	surface.SetDrawColor( 220, 220, 220, 255 )
	surface.SetFont( "BudgetLabel" )
	surface.SetTextPos( pos.x, pos.y )
	surface.DrawText( tblMarkerData.Owner:Name().. ": ".. GAMEMODE.Map.MarkerTypes[tblMarkerData.Type].text )

end

local PaintEntity = function( tblMarkerData )
	if not IsValid( tblMarkerData.FollowEnt ) then return end
	--if tblMarkerData.FollowEnt == LocalPlayer() then return end

	local a = tblMarkerData.FollowEnt:LookupAttachment( "eyes" )
	local pos = tblMarkerData.FollowEnt:GetAttachment( a )
	pos = ((pos and pos.Pos or tblMarkerData.FollowEnt:GetPos()) +Vector(0, 0, 16) ):ToScreen()

	surface.SetDrawColor( 220, 220, 220, 255 )
	surface.SetFont( "BudgetLabel" )
	surface.SetTextPos( pos.x, pos.y )
	surface.DrawText( tblMarkerData.Owner:Name().. ": ".. GAMEMODE.Map.MarkerTypes[tblMarkerData.Type].text )
end

GM.Map.MarkerTypes			= {
	[1] = {
		net = function() --Leader:Attack
		end,
		draw = PaintPoint,
		text = "Attack This Point!",
	},
	[2] = {
		net = function() --Leader:Rally
		end,
		draw = PaintEntity,
		text = "Rally On Me!",
	},
	[3] = { 
		net = function( vecPos ) --Leader:Defend Base
		end,
		draw = PaintPoint,
		text = "Defend Our Base!",
	},
	[4] = { 
		net = function() --General:Under Fire
		end,
		draw = PaintEntity,
		text = "I'm Under Fire!",
	},
	[5] = { 
		net = function() --General:Enemy Spotted
		end,
		draw = PaintPoint,
		text = "Enemy Spotted!",
	},
}

function GM.Map:PlaceMarker( intType )
	GAMEMODE.Net:RequestPlaceMarker( intType, self.MarkerTypes[intType].net )
end

function GM.Map:SetMarkerData( tblMarkers )
	self.m_tMarkers = tblMarkers
end

function GM.Map:PaintMarkers()
	--for k, v in pairs( self.m_tMarkers ) do
	--	if not IsValid( v.Owner ) then continue end
	--	
	--	if self.MarkerTypes[v.Type] then
	--		self.MarkerTypes[v.Type].draw( v )
	--	end
	--end
end