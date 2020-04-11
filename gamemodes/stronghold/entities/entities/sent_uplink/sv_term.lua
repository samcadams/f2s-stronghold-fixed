--[[
	File: sv_term.lua
	For: FTS: Stronghold
	By: Ultra

	brought to you in part by methoxetamine and cannabis
]]--

g_UplinkTerm = {}
g_UplinkTerm.m_tCmds = {}

local keysounds = {
	key 		= { "stronghold/keys/key_1.mp3", 	"stronghold/keys/key_2.mp3" },
	enter 		= { "stronghold/keys/enter_1.mp3", 	"stronghold/keys/enter_2.mp3" },
	space 		= { "stronghold/keys/space_1.mp3", 	"stronghold/keys/space_2.mp3" },
}
local RandomMsgs = {
	"Counting bottles of beer on the wall... 972,443 bottles",
	"Cleaning khajiit hairballs...",
	"Sending bad packets to timeout corner...",
	"Eating co-workers lunch...",
}

function g_UplinkTerm:AddCommand( strCmd, funcCallback )
	self.m_tCmds[strCmd] = funcCallback
end

local meta = {}
function g_UplinkTerm:New()
	local ret 			= {}
	ret.m_tPlayers 		= {}
	ret.m_tLines		= {}
	ret.m_tCmds			= table.Copy( self.m_tCmds )
	ret.m_iMaxLines		= 28
	ret.m_iMaxLineLen	= 128
	ret.m_eUplink		= NULL
	ret.m_sAuthKey		= nil
	ret.m_bLocked 		= false

	setmetatable( ret, {__index = meta} )

	ret:Print( "<~~~~~~~~~~~~~~~~~~~|=======================================================|~~~~~~~~~~~~~~~~~~~>" )
	ret:Print( "<~~~~~~~~~~~~~~~~~~~| PIKA-WINK Industries LLC Incorporated Consolidations  |~~~~~~~~~~~~~~~~~~~>" )
	ret:Print( "<~~~~~~~~~~~~~~~~~~~| Uplink Command Interface Software Version 307.21.20.9 |~~~~~~~~~~~~~~~~~~~>" )
	ret:Print( "<~~~~~~~~~~~~~~~~~~~|=======================================================|~~~~~~~~~~~~~~~~~~~>" )

	for k, v in pairs( RandomMsgs ) do
		ret:Print( v )
	end

	ret:Print( "System Ready. For a list of commands type \"commands\", for help type \"help\"." )
	ret:Print( "Initial Setup: Please enter an authentication key by using the authkey command." )

	return ret
end

function meta:Print( strLine )
	if #self.m_tLines >= self.m_iMaxLines then
		table.remove( self.m_tLines, 1 )
	end

	table.insert( self.m_tLines, strLine or "" )
	self:OnNewLine( #self.m_tLines, strLine )
end

function meta:AddLine( strLine, pPlayer )
	if string.len( strLine ) > self.m_iMaxLineLen then return end
	if #self.m_tLines >= self.m_iMaxLines then
		table.remove( self.m_tLines, 1 )
	end

	table.insert( self.m_tLines, strLine or "" )
	self:OnNewLine( #self.m_tLines, strLine, pPlayer )
	self:ProcessNewLine( strLine, pPlayer )
end

function meta:RemoveLine( intIndex )
	if not self.m_tLines[intIndex] then return end

	table.remove( self.m_tLines, intIndex )
	self:OnRemoveLine( intIndex )
end

function meta:GetLine( intIndex )
	return self.m_tLines[intIndex]
end

function meta:GetLines()
	return self.m_tLines
end

function meta:SetLine( intIndex, strLine )
	if intIndex > self.m_iMaxLines then return end
	
	self.m_tLines[intIndex] = strLine
end

function meta:Clear()
	self.m_tLines = {}
	self:OnCleared()
end

function meta:Lock( bLock )
	self.m_bLocked = bLock and true or false

	if bLock then
		self:Clear()
		self:Print( "This terminal has been locked, please input authentication key to continue." )
	end
end

function meta:Locked()
	return self.m_bLocked and true or false
end

function meta:HasValidAuthKey()
	return type( self.m_sAuthKey ) == "string" and string.len( self.m_sAuthKey ) <= 16 and self.m_sAuthKey ~= ""
end

function meta:AddPlayer( pPlayer )
	self.m_tPlayers[pPlayer:EntIndex()] = pPlayer
	GAMEMODE.Net:OpenTerminalMenu( pPlayer )
	self:NetworkLines( pPlayer )
	pPlayer:Freeze( true )

	pPlayer.__cActiveTerminal = self
end

function meta:RemovePlayer( pPlayer )
	self.m_tPlayers[pPlayer:EntIndex()] = nil
	GAMEMODE.Net:CloseTerminalMenu( pPlayer )
	pPlayer:Freeze( false )

	pPlayer.__cActiveTerminal = nil
end

function meta:SetUplinkEntity( eUplink )
	self.m_eUplink = eUplink
end

function meta:GetUplinkEntity()
	return self.m_eUplink
end

function meta:DropAllPlayers()
	for k, pl in pairs( self.m_tPlayers ) do
		if IsValid( pl ) then
			self:RemovePlayer( pl )
		end
	end
end

function meta:ProcessNewLine( strLine, pPlayer )
	local parts = string.Explode( " ", strLine )
	local cmd = tostring( parts[1] or "" )

	if cmd == "" then return end

	if self:Locked() and cmd ~= "exit" then
		if strLine ~= self.m_sAuthKey then
			self:Print( "This terminal has been locked, please input valid authentication key to continue." )
		else
			self:Lock( false )
			self:RemoveLine( #self.m_tLines ) --remove password text
			self:Print( "Authentication validated, welcome back." )
		end

		return
	end

	if not self.m_tCmds[cmd] then
		self:Print( "'".. cmd.. "' is not recognized as an internal or external command, operable program or batch file." )
		return
	else
		self.m_tCmds[cmd]( self, pPlayer, unpack(parts, 2) )
	end
end

function meta:OnNewLine( intIndex, strLine, pPlayer )
	self:NetworkLine( intIndex )
end

function meta:OnRemoveLine( intIndex )
	self:NetworkLines()
end

function meta:OnCleared()
	self:NetworkLines()
end

function meta:KeyPress( pPlayer, intKey )
	if intKey == 64 then --Enter
		sound.Play( table.Random(keysounds.enter), pPlayer:GetPos(), 100, math.random(90, 100), 1 )
	elseif intKey == 66 or intKey == 65 then --backspace/space
		sound.Play( table.Random(keysounds.enter), pPlayer:GetPos(), 100, math.random(90, 100), 1 )
	else
		sound.Play( table.Random(keysounds.key), pPlayer:GetPos(), 100, math.random(90, 100), 1 )
	end
end

function meta:NetworkLine( intIndex, pPlayer )
	if pPlayer then
		GAMEMODE.Net:SendTerminalLine( pPlayer, self, self.m_tLines[intIndex] )
	else
		for k, pl in pairs( self.m_tPlayers ) do
			if not IsValid( pl ) then
				self.m_tPlayers[k] = nil
				continue
			end
			
			GAMEMODE.Net:SendTerminalLine( pl, self, self.m_tLines[intIndex] )
		end
	end
end

function meta:NetworkLines( pPlayer )
	if pPlayer then
		GAMEMODE.Net:SendTerminalLines( pPlayer, self )
	else
		for k, pl in pairs( self.m_tPlayers ) do
			if not IsValid( pl ) then
				self.m_tPlayers[k] = nil
				continue
			end
			
			GAMEMODE.Net:SendTerminalLines( pl, self )
		end
	end
end


--[[ Player meta functions ]]--
local pmeta = debug.getregistry().Player

function pmeta:GetActiveUplink()
	return self.__cActiveTerminal
end

function pmeta:IsUsingUplink()
	return self:GetActiveUplink() and true or false
end


--[[ Hooks ]]--
local function UplinkDropPlayer( pPlayer )
	if pPlayer:IsUsingUplink() then
		pPlayer:GetActiveUplink():RemovePlayer( pPlayer )
	end
end

hook.Add( "PlayerDeath", "UplinkDropPlayer", UplinkDropPlayer )
hook.Add( "PlayerSpawn", "UplinkDropPlayer", UplinkDropPlayer )

--[[ Commands ]]--

--Generic
g_UplinkTerm:AddCommand( "help", function( cTermInst, ... )
	cTermInst:Print( "Help:" )
	cTermInst:Print( "To see a list of commands, type \"commands\".")
	cTermInst:Print( "[Entering Commands].")
	cTermInst:Print( "    Type the name of the command and press enter. If the command you are entering takes additional" )
	cTermInst:Print( "    arguments, follow the command with a space and then your argument(s) seperated by spaces." )
	cTermInst:Print( "    Example 1: authkey 123456pls_go - will set your authentication key to \"123456pls_go\"." )
	cTermInst:Print( "    Example 2: cons ultra 50 - will consolidate 50% of all income to the player \"Ultra\"." )
end )

g_UplinkTerm:AddCommand( "commands", function( cTermInst, ... )
	cTermInst:Print( "Available Commands: " )

	for k, v in pairs( cTermInst.m_tCmds ) do
		cTermInst:Print( "    ".. k )
	end
end )

g_UplinkTerm:AddCommand( "authkey", function( cTermInst, pPlayer, strKey )
	strKey = tostring( strKey or "" )
	if strKey == "" then cTermInst:Print( "Invalid entry." ) return end
	if string.len( strKey ) > 16 then cTermInst:Print( "Auth key must be under 16 characters." ) return end
	if cTermInst.m_tCmds[strKey] then cTermInst:Print( "Auth key conflicts with a named command." ) return end

	cTermInst.m_sAuthKey = strKey
	cTermInst:RemoveLine( #cTermInst.m_tLines ) --remove password text
	cTermInst:Print( "Authentication key has been set." )
end )

g_UplinkTerm:AddCommand( "lock", function( cTermInst, ... )
	if not cTermInst:HasValidAuthKey() then
		cTermInst:Print( "No authentication key has been set, please set an authkey before locking terminal." )
	else
		cTermInst:Lock( not cTermInst:Locked() )
	end
end )

g_UplinkTerm:AddCommand( "clear", function( cTermInst, ... )
	cTermInst:Clear()
end )

g_UplinkTerm:AddCommand( "exit", function( cTermInst, pPlayer, ... )
	if IsValid( pPlayer ) then
		cTermInst:RemovePlayer( pPlayer )
	end
end )


--Uplink commands
g_UplinkTerm:AddCommand( "signal", function( cTermInst, ... )
	local ent = cTermInst:GetUplinkEntity()
	if not IsValid( ent ) then return end

	cTermInst:Print( ent:CanDishSeeSky() and "GOOD." or "BAD. Check for disk obstructions." )
end )

g_UplinkTerm:AddCommand( "drot_set", function( cTermInst, pPlayer, strRot )
	local ent = cTermInst:GetUplinkEntity()
	if not IsValid( ent ) or not strRot then return end

	strRot = tonumber(strRot)
	if strRot > 360 or strRot < 0 then
		cTermInst:Print( "Rotation must be within 0 to 360." )
		return
	end

	ent:LerpDisk( Angle(ent:GetDishAngle().p, ent:GetDishAngle().y, strRot), function()
		cTermInst:Print( "Rotation Complete. Signal Status:" )
		cTermInst:Print( ent:CanDishSeeSky() and "GOOD." or "BAD. Check for disk obstructions." )
	end )
end )

g_UplinkTerm:AddCommand( "dpit_set", function( cTermInst, pPlayer, strRot )
	local ent = cTermInst:GetUplinkEntity()
	if not IsValid( ent ) or not strRot then return end
	
	strRot = tonumber(strRot)
	if strRot > 120 or strRot < -20 then
		cTermInst:Print( "Pitch must be within -20 to 120." )
		return
	end

	ent:LerpDisk( Angle(ent:GetDishAngle().p, strRot, ent:GetDishAngle().r), function()
		cTermInst:Print( "Pitch Complete. Signal Status:" )
		cTermInst:Print( ent:CanDishSeeSky() and "GOOD." or "BAD. Check for disk obstructions." )
	end )
end )

g_UplinkTerm:AddCommand( "deposit", function( cTermInst, pPlayer, strAmount )
	local ent = cTermInst:GetUplinkEntity()
	if not IsValid( ent ) or not strAmount then return end
	strAmount = tonumber( strAmount )

	if (strAmount <= 0 or strAmount > 10000) or (ent:GetDeposit() +strAmount > 10000) then
		cTermInst:Print( "You may only deposit positive amounts up to $10,000" )
		cTermInst:Print( "Your current deposit is: $".. ent:GetDeposit() )
		return
	end

	if pPlayer:GetMoney() -strAmount < 0 then
		cTermInst:Print( "You cannot afford that deposit." )
		return
	end

	pPlayer:AddMoney( -strAmount )
	ent:Deposit( strAmount )

	cTermInst:Print( "Deposited $".. strAmount.. ". Current Deposit $".. ent:GetDeposit().. "." )
end )

g_UplinkTerm:AddCommand( "wdrw_dep", function( cTermInst, pPlayer, strAmount )
	local ent = cTermInst:GetUplinkEntity()
	if not IsValid( ent ) or not strAmount then return end
	strAmount = tonumber( strAmount )

	if (strAmount <= 0 or ent:GetDeposit() -strAmount < 0) then
		cTermInst:Print( "You may only with withdrawal amounts up to your current deposit." )
		cTermInst:Print( "Your current deposit is: $".. ent:GetDeposit() )
		return
	end

	pPlayer:AddMoney( strAmount )
	ent:Deposit( -strAmount )

	cTermInst:Print( "Withdrew $".. strAmount.. ". Current Deposit $".. ent:GetDeposit().. "." )
end )

g_UplinkTerm:AddCommand( "wdrw_amnt", function( cTermInst, pPlayer, ... )
end )
g_UplinkTerm:AddCommand( "wdrw_all", function( cTermInst, pPlayer, ... )
end )
g_UplinkTerm:AddCommand( "cons", function( cTermInst, ... )
end )
g_UplinkTerm:AddCommand( "run", function( cTermInst, ... )
end )

--Joke commands
g_UplinkTerm:AddCommand( "rm", function( cTermInst, pPlayer, ... )
	local args = {...}

	if not args[2] or type( args[1] ) ~= "string" or type( args[2] ) ~= "string" then
		cTermInst:Print( "The syntax of this command is:" )
		cTermInst:Print( "    ERROR: Invalid stro↔┘♦,ë☻5" )
		
		return
	end

	if #args > 2  or args[1] ~= "rf" or args[2] ~= "/*" then
		cTermInst:Print( "The syntax of this command is:" )
		cTermInst:Print( "    ERROR: Invalid stro↔┘♦,ë☻5" )
	else
		cTermInst:Print( "Nice try fatass." )
	end
end )