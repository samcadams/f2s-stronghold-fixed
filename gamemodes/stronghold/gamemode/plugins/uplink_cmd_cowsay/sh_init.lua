--[[
	File: sh_init.lua
	For: FTS: Stronghold
	By: Ultra
]]--

local PLUGIN 		= {}
PLUGIN.Name 		= "Uplink command: cowsay"
PLUGIN.Description 	= "cowsay command"
PLUGIN.m_iMaxMsgLen = 90

function PLUGIN:Init()
end

function PLUGIN:InitPostEntity()
	if not SERVER then return end
	if not g_UplinkTerm then error( "uplink interface not found." ) end

	g_UplinkTerm:AddCommand( "cowsay", function( ... )
		self:CommandCallback( ... )
	end )
end

function PLUGIN:CommandCallback( cTermInst, pPlayer, ... )
	local str = " "

	for k, a in pairs( {...} ) do
		str = str.. tostring( a ).. " "
	end

	local msglen = string.len( str )
	if msglen == 0 or msglen > self.m_iMaxMsgLen then return end

	local border, bborder 	= "_", "-"
	border 					= string.rep( border, msglen )
	bborder 				= string.rep( bborder, msglen )

	cTermInst:Print( " ".. border.. " " )
	cTermInst:Print( "<".. str.. ">" )
	cTermInst:Print( " ".. bborder.. " " )
	cTermInst:Print( "        \\   ^__^" )
	cTermInst:Print( "         \\  (oo)\\_______" )
	cTermInst:Print( "            (__)\\       )\\/\\" )
	cTermInst:Print( "                ||----w |" )
	cTermInst:Print( "                ||     ||" )
end

GM.Plugins:Register( PLUGIN )