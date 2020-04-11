--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
--[[
	GM13 Changes

	usermessage - > net
	datastream - > net

	Cleaned Code
]]--

local VotingEnabled = false

local MAPLISTPATH = "stronghold/maplist.txt"
function GM:LoadMapList()
	if file.Exists( MAPLISTPATH, "DATA" ) then
		local data = file.Read( MAPLISTPATH, "DATA" )
		local tbl = string.Explode( "\n", data )
		for _, v in ipairs(tbl) do
			local sep = string.find( v, ";" )
			if sep and string.Left( v, 2 ) != "//" then
				local map = string.Left( v, sep-1 )
				self.MapList[map] = { map=map, name=string.sub(v,sep+1) }
			end
		end
	else
		file.Write( MAPLISTPATH, [[// Maplist Example:
// <map>;<display name>
//
// Console Command 'sh_reloadmaplist' reloads this file into the voting system.

sh_valley;Valley Compound [Twitch/RoaringCow]
sh_lockdown;Lockdown [Helio-G/RoaringCow]
]] )
		self.MapList["dm_lockdown"] 	= { map="dm_lockdown", 		name="Lockdown [VaLVE]" }
		self.MapList["dm_overwatch"] 	= { map="dm_overwatch", 	name="Overwatch [VaLVE]" }
		self.MapList["dm_powerhouse"] 	= { map="dm_powerhouse", 	name="Power House [VaLVE]" }
		self.MapList["dm_resistance"] 	= { map="dm_resistance", 	name="Resistance [VaLVE]" }
		self.MapList["dm_runoff"] 		= { map="dm_runoff", 		name="Runoff [VaLVE]" }
		self.MapList["dm_steamlab"] 	= { map="dm_steamlab", 		name="Steam Lab [VaLVE]" }
		self.MapList["dm_underpass"] 	= { map="dm_underpass", 	name="Underpass [VaLVE]" }
	end
end
concommand.Add( "sh_reloadmaplist", function() GAMEMODE:LoadMapList() end )

function GM:SendMapList()
	self.Net:BroadcastMapList( GAMEMODE.MapList )

	--See sv_networking.lua, GM.Net:SendWinningMap( strMap )
	--for _, v in ipairs( player.GetAll() ) do
	--	datastream.StreamToClients( v, "sh_maplist", GAMEMODE.MapList )
	--end
end

function GM:EnableVotingSystem()
	for _, v in ipairs( player.GetAll() ) do
		v:SetMapVote( "" )
	end

	VotingEnabled = true

	timer.Simple( GAMEMODE.ConVars.VoteTime:GetInt(), function()
		GAMEMODE:SetNextMap()
	end )
end

function GM:SetNextMap()
	if !VotingEnabled then return end
	
	GAMEMODE.WinningMap = GAMEMODE:GetNextMap( true )
	
	--See sv_networking.lua, GM.Net:SendWinningMap( strMap )
	-- local rf = RecipientFilter()
	-- rf:AddAllPlayers()
	-- umsg.Start( "sh_winningmap", rf )
		-- umsg.String( GAMEMODE.WinningMap )
	-- umsg.End()
	self.Net:SendWinningMap( GAMEMODE.WinningMap )
	
	for _, v in ipairs( player.GetHumans() ) do v:SaveData() end
	GAMEMODE:StartCountDown( 5, "Map change in", [[game.ConsoleCommand("changelevel "..GAMEMODE.WinningMap.."\n")]], "" ) 
end

function GM:GetNextMap( byvote )
	if !byvote then
		local current = game.GetMap()
		local next = false
		for _, v in pairs(GAMEMODE.MapList) do
			if next then return v.map end
			if v.map == current then next = true end
		end
		return table.Random( GAMEMODE.MapList ).map
	else
		local votes = {}
		for _, v in ipairs(player.GetAll()) do
			local vote = v:GetMapVote()
			if vote != "" and GAMEMODE.MapList[vote] then
				if !votes[vote] then votes[vote] = 0 end
				votes[vote] = votes[vote] + 1
			end
		end
		local highest = nil
		for k, v in pairs(votes) do
			if highest == nil or v > votes[highest] then
				highest = k
			end
		end
		if highest == nil then
			return GAMEMODE:GetNextMap( false )
		end
		return highest
	end
end

local function SH_VoteMap( ply, cmd, args )
	if !VotingEnabled then return end
	ply:SetMapVote( args and args[1] or "" )
end
concommand.Add( "sh_votemap", SH_VoteMap )