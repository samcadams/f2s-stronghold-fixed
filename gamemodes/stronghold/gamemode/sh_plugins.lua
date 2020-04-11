--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	File: sh_plugins.lua
	For: FTS: Stronghold
	By: Ultra

	Basic plugin system for mod support

	TODO:
	abstract gamemode stuff (weapons, hats, other stuff)
	build client and server hook list
	make example plugin
	document
]]--

GM.Plugins					= {}
GM.Plugins.m_sPluginPrefix	= "stronghold/gamemode/"
GM.Plugins.m_sPluginDir		= "plugins"
GM.Plugins.m_tPlugins 		= {}
GM.Plugins.m_tHooks			= {
	Client = {
		Hooked = {},
		Hooks = { "Think", "HUDPaint" }
	},

	Server = {
		Hooked = {},
		Hooks = { "Think", "Tick", "InitPostEntity" }
	},
}

local type 		= type 
local pairs 	= pairs 
local unpack 	= unpack 
local pcall 	= pcall 
local tostring 	= tostring 
local Error 	= Error 
local ret 		= nil

function GM.Plugins:Init()
	self:AddHooks()
	self:Load()
end

function GM.Plugins:HandleHook( strHook, ... )
	for strName, PLUGIN in pairs( self.m_tPlugins ) do
		if type( PLUGIN[strHook] ) == "function" then
			ret = { pcall( PLUGIN[strHook], PLUGIN, ... ) }

			if ret[1] and ret[2] ~= nil then
				return unpack( ret, 2 )
			elseif not ret[1] then
				ret[2] = tostring( ret[2] or "" )
				Error( "ERROR! Plugin <".. strName.. "> ".. ret[2].. "\n" )
			end
		end
	end

	return nil
end

function GM.Plugins:AddHooks()
	local tbl = (CLIENT and self.m_tHooks.Client) or self.m_tHooks.Server

	for _, strHook in pairs( tbl.Hooks ) do
		local hret
		tbl.Hooked[strHook] = function( ... )
			hret = self:HandleHook( strHook, ... )

			if hret then
				return hret
			end
		end

		hook.Add( strHook, "GAMEMODE.PluginSystem", tbl.Hooked[strHook] )
	end
end

function GM.Plugins:Register( PLUGIN )
	self.m_tPlugins[PLUGIN.Name] = PLUGIN
	self.m_tPlugins[PLUGIN.Name]:Init()
end

function GM.Plugins:Load()
	local _, folders = file.Find( self.m_sPluginPrefix.. self.m_sPluginDir.. "/*", "LUA" )

	local fullpath, luapath, b
	for k, folder in pairs( folders ) do
		fullpath = self.m_sPluginPrefix.. self.m_sPluginDir.. "/".. folder.. "/sh_init.lua"

		if file.Exists( fullpath, "LUA" ) then
			path = self.m_sPluginDir.. "/".. folder.. "/sh_init.lua"

			if SERVER then AddCSLuaFile( path ) end
			local code = CompileFile( fullpath )

			if not code then
				Error( "ERROR! Plugin failed to load <".. folder.. "> CompileFile:file not found \n" )
			else
				b = { pcall( code ) }
				if not b[1] then
					Error( "ERROR! Plugin failed to load <".. folder.. "> ".. b[2].. "\n" )
				end
			end
		end
	end
end

GM.Plugins:Init()