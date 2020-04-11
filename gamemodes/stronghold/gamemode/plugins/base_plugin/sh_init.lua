--[[
	File: sh_init.lua
	For: FTS: Stronghold
	By: Ultra
]]--

local PLUGIN 		= {}
PLUGIN.Name 		= "Base Plugin"
PLUGIN.Description 	= "Rainbows"

function PLUGIN:Init()
	--print( self.Name, "INIT", CLIENT and "CLIENT" or "SERVER" )
end

function PLUGIN:Think()
end

GM.Plugins:Register( PLUGIN )