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

team.SetUp( 50, "No Team", Color(250,250,0,255) )

GM.Teams = {}
GM.Teams[50] = { Leader=nil, Name="No Team", Password="", Color=Color(250,250,0,255) }
GM.TeamCount = 50 -- 50 is the default "No Team" team
GM.TeamRestrictions = { "no team", "<no team>", "<enter name here>", "admin", "admins", "moderator", "moderators", "superadmin", "superadmins", "operator", "operators" } -- Add them all LOWER CASED

local function MessageTeam( index, msg, ignore )
	for _, v in ipairs(player.GetAll()) do
		if (!ignore or ignore != v) and v:Team() == index then
			v:SendMessage( msg )
		end
	end
end

--[[function SendTeamToClient( ply, index, leader, name, color )
	GAMEMODE.Net:SendTeamToClient( ply, index, leader, name, color )
	--See sv_networking.lua, GAMEMODE.Net:SendTeamToClient
	-- umsg.Start( "sh_teamcreated", ply )
	-- 	umsg.Short( index )
	-- 	umsg.Entity( leader )
	-- 	umsg.String( name )
	-- 	umsg.Short( color.r )
	-- 	umsg.Short( color.g )
	-- 	umsg.Short( color.b )
	-- umsg.End()
end]]

function SendTeamsToClient( ply )
	for i=51, GAMEMODE.TeamCount do
		if GAMEMODE.Teams[i] then
			GAMEMODE.Net:SendTeamToClient( ply, i, GAMEMODE.Teams[i].Leader, GAMEMODE.Teams[i].Name, GAMEMODE.Teams[i].Color )
		end
	end
end
hook.Add( "PlayerInitialSpawn", "SendTeamsToClient", SendTeamsToClient )

function SendDisbandToClients( index )
	GAMEMODE.Net:SendDisbandToClients( index )
	--See sv_networking.lua, GAMEMODE.Net:SendDisbandToClients
	-- local rf = RecipientFilter()
	-- rf:AddAllPlayers()
	-- umsg.Start( "sh_teamdisbanded", rf )
	-- 	umsg.Short( index )
	-- umsg.End()
end

function SendLeaderToClients( index, leader )
	GAMEMODE.Net:SendLeaderToClients( index, leader )
	--See sv_networking.lua, GAMEMODE.Net:SendLeaderToClients
	-- local rf = RecipientFilter()
	-- rf:AddAllPlayers()
	-- umsg.Start( "sh_teamleaderchange", rf )
	-- 	umsg.Short( index )
	-- 	umsg.Entity( leader )
	-- umsg.End()
end

function GM:TeamExists( name )
	name = string.lower( name )
	
	for i, v in pairs(self.Teams) do
		if string.lower( v.Name ) == name then
			return i
		end
	end

	return false
end

function GM:CreateTeam( ply, name, pass, color )
	if !name or name == "" then
		ply:SendMessage( "You need to at least enter a team name!" )
		return
	end
	
	name = string.Left( name, 50 )
	pass = (pass or "")
	color = (color or Color( math.random(50,255), math.random(50,255), math.random(50,255), 255 ))

	if table.HasValue( self.TeamRestrictions, string.lower(name) ) then
		ply:SendMessage( "'"..name.."' is a restricted team name!", _, false )
		return
	end
	
	local exists = self:TeamExists( name )
	if exists then
		local name = self.Teams[exists].Name
		local color = self.Teams[exists].Color
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"That team alread exists! [",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"]")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
		return
	end
	
	if ply:Team() != 50 then
		CCLeaveTeam( ply, _, {true} )
	end
	
	self.TeamCount = self.TeamCount + 1
	self.Teams[self.TeamCount] = { Leader=ply, Name=name, Password=pass, Color=color, LeaderOnlyPasswordSending=false }
	team.SetUp( self.TeamCount, name, color )
	
	for _, v in ipairs(player.GetAll()) do
		GAMEMODE.Net:SendTeamToClient( v, self.TeamCount, ply, name, color )
	end
	
	ply:SetTeam( self.TeamCount )
		
	ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have created a new team [",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"]")]] )
	ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
end

local function CCCreateTeam( ply, cmd, args )
	local name = args[1]
	local pass = args[2]
	local r, g, b = args[3], args[4], args[5]
	local color = nil
	if r != nil and g != nil and b != nil then
		color = Color( r, g, b, 255 )
	end
	GAMEMODE:CreateTeam( ply, name, pass, color )
end

local function AutoCompleteCreateTeam( commandName, args )
	return { "sh_createteam \"Team Name\" [Password] [#Red] [#Green] [#Blue]" }
end
concommand.Add( "sh_createteam", CCCreateTeam, AutoCompleteCreateTeam )

local function CCChangeTeamLeader( ply, cmd, args )
	local index = ply:Team()
	if index > 50 and GAMEMODE.Teams[index].Leader == ply then
		local newleader = Entity( tonumber(args[1]) )
		if IsValid( newleader ) and newleader:IsPlayer() and newleader:Team() == index then
			GAMEMODE.Teams[index].Leader = newleader
			SendLeaderToClients( index, newleader )
			MessageTeam( index, newleader:GetName().." has become the new team leader.", ply )
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"New leader successfully changed.")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		else
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"New leader either does not exist or is not in the team!")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
		end
	elseif index == 50 then
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You can not modify the default team!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	elseif GAMEMODE.Teams[index].Leader != ply then
		local name = GAMEMODE.Teams[index].Name
		local color = GAMEMODE.Teams[index].Color
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You are not the leader of ",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	end
end

local function AutoCompleteChangeTeamLeader( commandName, args )
	return { "sh_changeteamleader <Entity ID of new leader>" }
end
concommand.Add( "sh_changeteamleader", CCChangeTeamLeader, AutoCompleteChangeTeamLeader )

local function CCChangeTeamPassword( ply, cmd, args )
	local index = ply:Team()
	if index > 50 and GAMEMODE.Teams[index].Leader == ply then
		GAMEMODE.Teams[index].Password = args and args[1] or ""
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"Password changed successfully.")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
	elseif index == 50 then
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You can not modify the default team!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	elseif GAMEMODE.Teams[index].Leader != ply then
		local name = GAMEMODE.Teams[index].Name
		local color = GAMEMODE.Teams[index].Color
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You are not the leader of ",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	end
end

local function AutoCompleteChangeTeamPassword( commandName, args )
	return { "sh_changeteampassword \"New Password\"" }
end
concommand.Add( "sh_changeteampassword", CCChangeTeamPassword, AutoCompleteChangeTeamPassword )

local function CCSendTeamPassword( ply, cmd, args )
	local index = ply:Team()
	if index > 50 then
		local member = Entity( tonumber(args[1]) )
		if IsValid( member ) and member:IsPlayer() then
			if !GAMEMODE.Teams[index].LeaderOnlyPasswordSending then
				local name = GAMEMODE.Teams[index].Name
				local color = GAMEMODE.Teams[index].Color
				local pass = GAMEMODE.Teams[index].Password
				member:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"The password to join ",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255)," is ']]..sql.SQLStr(pass,true)..[['")]] )
				member:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
				ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"]]..sql.SQLStr(member:GetName(),true)..[[".." has been sent your team's password.")]] )
				ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
			else
				ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"The team leader is not allow you to send out the password.")]] )
				ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
			end
		else
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"Member either does not exist or is not in the team!")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
		end
	elseif index == 50 then
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"Default team does not have a password!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	end
end

local function AutoCompleteSendTeamPassword( commandName, args )
	return { "sh_sendteampassword <Entity ID of member>" }
end
concommand.Add( "sh_sendteampassword", CCSendTeamPassword, AutoCompleteSendTeamPassword )

local function CCLeaderOnlyPasswordSending( ply, cmd, args )
	local index = ply:Team()
	if index > 50 and GAMEMODE.Teams[index].Leader == ply then
		local leaderonly = tonumber(args[1]) == 1 and true or false
		GAMEMODE.Teams[index].LeaderOnlyPasswordSending = leaderonly
		if leaderonly then
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"The team password can only be sent by you.")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		else
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"The team password can be sent by any member.")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		end
	elseif index == 50 then
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"Default team does not have a password!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	end
end

local function AutoCompleteLeaderOnlyPasswordSending( commandName, args )
	return { "sh_leaderonlypasswordsending 0/1" }
end
concommand.Add( "sh_leaderonlypasswordsending", CCLeaderOnlyPasswordSending, AutoCompleteLeaderOnlyPasswordSending )

local function CCKickTeamMember( ply, cmd, args )
	local index = ply:Team()
	if index > 50 and GAMEMODE.Teams[index].Leader == ply then
		local member = Entity( tonumber(args[1]) )
		if IsValid( member ) and member:IsPlayer() and member:Team() == index then
		local name = GAMEMODE.Teams[index].Name
		local color = GAMEMODE.Teams[index].Color
			CCLeaveTeam( member )
			member:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have been kicked out of ",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"!")]] )
			member:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"]]..sql.SQLStr(member:GetName(),true)..[[".." has been kicked from the team.")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		else
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"Member either does not exist or is not in the team!")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
		end
	elseif index == 50 then
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You can not modify the default team!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	elseif GAMEMODE.Teams[index].Leader != ply then
		local name = GAMEMODE.Teams[index].Name
		local color = GAMEMODE.Teams[index].Color
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You are not the leader of ",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	end
end

local function AutoCompleteKickTeamMember( commandName, args )
	return { "sh_kickteammember <Entity ID of member>" }
end
concommand.Add( "sh_kickteammember", CCKickTeamMember, AutoCompleteKickTeamMember )

function GM:DisbandTeam( index )
	local name = self.Teams[index].Name
	local color = self.Teams[index].Color
	for _, v in ipairs(player.GetAll()) do
		if v:Team() == index then
			v:SetTeam( 50 )
		
			v:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"Your team has disbanded! [",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"]")]] )
			v:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		end
	end
	self.Teams[index] = nil
	team.GetAllTeams()[index] = nil
	SendDisbandToClients( index )
end

local function CCDisband( ply, cmd, args )
	local index = ply:Team()
	if index > 50 and GAMEMODE.Teams[index].Leader == ply then
		GAMEMODE:DisbandTeam( index )
	else
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You can not modify the default team!")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button16.wav" )]] )
	end
end

local function AutoCompleteDisbandTeam( commandName, args )
	return { "sh_disbandteam" }
end
concommand.Add( "sh_disbandteam", CCDisband, AutoCompleteDisbandTeam )

-- NEEDS TO BE GLOBAL
function CCLeaveTeam( ply, cmd, args )
	local index = ply:Team()
	if !GAMEMODE.Teams[index] then
		ply:SetTeam( 50 )
		
		ply:SendMessage( "How did you leave a non-existant team?!" )
	elseif index > 50 then
		ply:SetTeam( 50 )
		
		if !args or !args[1] then
			local name = GAMEMODE.Teams[index].Name
			local color = GAMEMODE.Teams[index].Color
			ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have left the team [",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"]")]] )
			ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		end
		MessageTeam( index, ply:GetName().." has left your team.", ply )
		
		if ply == GAMEMODE.Teams[index].Leader then
			local members = team.GetPlayers( index )
			if table.Count( members ) == 0 then
				-- No players left, disband
				GAMEMODE:DisbandTeam( index )
				return
			end
			
			local random = table.Random( members )
			GAMEMODE.Teams[index].Leader = random
			SendLeaderToClients( index, random )
			
			MessageTeam( index, random:GetName().." has become the new team leader.", ply )
		end
	else
		ply:SendMessage( "You are not on a team." )
	end
end

local function AutoCompleteLeaveTeam( commandName, args )
	return { "sh_leaveteam" }
end
concommand.Add( "sh_leaveteam", CCLeaveTeam, AutoCompleteLeaveTeam )

local function CCJoinTeam( ply, cmd, args )
	local name = string.lower( args[1] )
	local pass = args[2] or ""
	
	local index = 50
	for k, v in pairs(GAMEMODE.Teams) do
		if string.lower( v.Name ) == name then
			index = k
		end
	end
	
	if ply:Team() == index then
		ply:SendMessage( "You are already on that team." )
		return
	end
	
	if GAMEMODE.Teams[index].Password == pass then
		if ply:Team() != 50 then
			CCLeaveTeam( ply, _, {true} )
		end
	
		ply:SetTeam( index )
		
		local name = GAMEMODE.Teams[index].Name
		local color = GAMEMODE.Teams[index].Color
		ply:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have joined the team [",Color(]]..color.r..[[,]]..color.g..[[,]]..color.b..[[,255),"]]..sql.SQLStr(name,true)..[[",Color(200,50,50,255),"]")]] )
		ply:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		MessageTeam( index, ply:GetName().." has joined your team.", ply )
	else
		ply:SendMessage( "Invalid team / Wrong password!" )
	end
end

local function AutoCompleteJoinTeam( commandName, args )
	return { "sh_jointeam \"Team Name\" [\"Password\"]" }
end
concommand.Add( "sh_jointeam", CCJoinTeam, AutoCompleteJoinTeam )

local function TeamDamage( ply, dmginfo )
	local attacker = dmginfo:GetAttacker()
	if ply != attacker and ply:IsPlayer() and attacker:IsPlayer()then
		local index = attacker:Team()
		if index != 50 and ply:Team() == index then
			if !GAMEMODE.ConVars.FriendlyFire:GetBool() then
				dmginfo:ScaleDamage( 0 )
			else
				dmginfo:ScaleDamage( 0.30 )
				attacker:SendLua( [[surface.PlaySound("npc/attack_helicopter/aheli_damaged_alarm1.wav")]] )
				attacker:SendMessage( "DON'T ATTACK TEAMMATES!", "Friendly Fire" )
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "TeamDamage", TeamDamage )

function GM:OnPlayerChangedTeam( ply, old, new )
	-- Fix voice channel
	if new == 50 then
		ply:ConCommand( "sh_voice_channel 0" )
	end
end