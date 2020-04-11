--[[
	File: cl_networking.lua
	For: FTS: Stronghold
	By: Ultra
]]--

GM.Net = {}


--[[ player_extension.lua ]]--

--[[
--local function RecieveStatistics( _, _, _, decoded )
--	if IsValid( decoded.ply ) then 
--		decoded.ply.Statistics = decoded.tbl or {}
--		decoded.ply.StatisticsUpdated = os.date( "%I:%M:%S %p" )
--		if ValidPanel( GAMEMODE.HelpFrame ) and ValidPanel( GAMEMODE.HelpFrame.StatsPanel ) then
--			GAMEMODE.HelpFrame.StatsPanel:PlayerSelected( decoded.ply )
--		end
--	end
--end
--datastream.Hook( "sh_statistics", RecieveStatistics )
]]
net.Receive( "sh_statistics", function( intMsgLen )
	local pPlayer	= net.ReadEntity()
	local tblStats 	= net.ReadTable()

	if not IsValid( pPlayer ) or not pPlayer:IsPlayer() then return end
	pPlayer.Statistics 			= tblStats
	pPlayer.StatisticsUpdated 	= os.date( "%I:%M:%S %p" )
	
	if ValidPanel( GAMEMODE.HelpFrame ) and ValidPanel( GAMEMODE.HelpFrame.StatsPanel ) then
		GAMEMODE.HelpFrame.StatsPanel:PlayerSelected( pPlayer )
	end
end )

net.Receive( "sh_loadout", function( intMsgLen )
	local ply = LocalPlayer()
	ply.Loadouts = ply.Loadouts or {}
	table.Merge( ply.Loadouts[k], net.ReadTable() )
	GAMEMODE.LoadoutFrame:RefreshLoadouts()
end )

net.Receive( "sh_licenses", function( intMsgLen )
	local ply = LocalPlayer()
	ply.Licenses = nil
	ply.Licenses = net.ReadTable()

	GAMEMODE.LoadoutFrame:RefreshLicenses()
	GAMEMODE.LoadoutFrame:RefreshHats()
end )

net.Receive( "sh_license", function( intMsgLen )
	local ply = LocalPlayer()
	ply.Licenses = ply.Licenses or { [1]={}, [2]={} }
	table.Merge( ply.Licenses, net.ReadTable() )

	GAMEMODE.LoadoutFrame:RefreshLicenses()
	GAMEMODE.LoadoutFrame:RefreshHats()
end )

net.Receive( "sh_moneyandmultiplier", function( intMsgLen )
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	ply:SetMoney( net.ReadFloat() )
	ply:SetMultiplier( net.ReadFloat() )	
end )

net.Receive( "sh_items", function( intMsgLen )
	local ply = LocalPlayer()
	ply.Items = nil
	ply.Items = net.ReadTable()
	GAMEMODE.LoadoutFrame:RefreshLicenses()
end )

net.Receive( "sh_item", function( intMsgLen )
	local ply = LocalPlayer()
	ply.Items = ply.Items or {}
	table.Merge( ply.Items, net.ReadTable() )
	GAMEMODE.LoadoutFrame:RefreshLicenses()
end )


--[[ cl_hud.lua ]]--

local SND_HITDETECTION = { Sound("hit1.wav"), Sound("hit2.wav"), Sound("hit3.wav") }
local SND_HITDETECTIONHEAD = { Sound("/player/headshot1.wav"),Sound("/player/headshot2.wav") }
net.Receive( "sh_hitdetection", function( intMsgLen )
	GAMEMODE.HitDetection.HitTime = CurTime()
	
	if GAMEMODE.ConVars.HitSound:GetBool() then
		local snd = table.Random( SND_HITDETECTION )
		local hssnd = table.Random( SND_HITDETECTIONHEAD )
		local plywep = LocalPlayer():GetActiveWeapon()
		local loudness = plywep.VElements and plywep.VElements.suppressor and 1 or 3
		local HS = net.ReadBool("sh_hitdetection")
		if HS then
			for i=1, loudness do surface.PlaySound( hssnd ) end
		else
			for i=1, loudness do surface.PlaySound( snd ) end	
		end
	end
end )


--[[ cl_init.lua ]]--

net.Receive( "sh_killed", function( intMsgLen )
	GAMEMODE.KillCam.Killer 	= net.ReadEntity()
	GAMEMODE.KillCam.LastKilled = CurTime()
	GAMEMODE.KillCam.Active 	= true
end )

net.Receive( "sh_spawned", function( intMsgLen )
 	GAMEMODE.KillCam.Killer = nil
 	GAMEMODE.KillCam.Active = false
end )

net.Receive( "sh_advert", function( intMsgLen )
	local type, col, str = net.ReadString(), net.ReadInt( 8 ), net.ReadString()
	if type == "hint" then
		GAMEMODE.HintBar.LastColor 	= GAMEMODE.HintBar.CurColor
		GAMEMODE.HintBar.LastMsg 	= GAMEMODE.HintBar.CurMsg
		GAMEMODE.HintBar.CurColor 	= col
		GAMEMODE.HintBar.CurMsg 	= str
		GAMEMODE.HintBar.LastChange	= CurTime()
	elseif type == "chatvert" then
		chat.AddText( GAMEMODE.CachedColors[col], str )
	end
end )

net.Receive( "sh_gameending", function( intMsgLen )
	GAMEMODE.GameOverTime = CurTime()
	GAMEMODE.GameOverRealTime = RealTime()
	LocalPlayer():SendMessage( "Game over!" )
end )

net.Receive( "sh_gameover", function( intMsgLen )
	GAMEMODE.GameOver			= true
	GAMEMODE.GameOverTeam 		= net.ReadInt( 16 )
	GAMEMODE.GameOverWinner		= net.ReadEntity()
	GAMEMODE.GameOverModels		= net.ReadTable()
end )

net.Receive( "sh_maplist", function( intMsgLen )
	GAMEMODE.MapList = net.ReadTable()

	for k, v in pairs( GAMEMODE.MapList ) do
		if file.Exists( "materials/maps/".. v.map.. ".vmt", "GAME" ) then
			GAMEMODE.MapList[k].texture = surface.GetTextureID( "maps/".. v.map )
		end
	end
end )

net.Receive( "sh_winningmap", function( intMsgLen )
	GAMEMODE.WinningMap = net.ReadString()
	LocalPlayer():SendMessage( "Map '".. GAMEMODE.WinningMap.. "' has won the vote!" )
end )

net.Receive( "sh_faderagdoll", function( intMsgLen )
	local ragdoll = net.ReadEntity()

	if IsValid( ragdoll ) then
		table.insert( GAMEMODE.Ragdolls, {ent = ragdoll, time = CurTime()} )
	end
end )


--[[ shared.lua ]]--

net.Receive( "sh_countdown", function( intMsgLen )
	GAMEMODE:CancelCountDown( true )
	GAMEMODE:StartCountDown( net.ReadInt(32), net.ReadString(), net.ReadString() )
end )

net.Receive( "sh_cancelcountdown", function( intMsgLen )
	GAMEMODE:CancelCountDown()
end )


--[[ playersounds.lua ]]--

net.Receive( "PlayerSounds_PlayerDeath", function( intMsgLen )
	PlayerSounds.PlayerDeath( net.ReadEntity(), net.ReadString() )
end )

net.Receive( "PlayerSounds_ScalePlayerDamage", function( intMsgLen )
	PlayerSounds.ScalePlayerDamage( net.ReadEntity(), net.ReadString(), net.ReadBit() == 1 )
end )


--[[ cl_teams.lua ]]--

net.Receive( "sh_teamcreated", function( intMsgLen )
	local intIndex 	= net.ReadInt( 16 )
	local entLeader = net.ReadEntity()
	local strName 	= net.ReadString() or "<No Name>"
	local colColor 	= Color( net.ReadUInt(8) or math.random(50,255), net.ReadUInt(8) or math.random(50,255), net.ReadUInt(8) or math.random(50,255), 255 )
	
	GAMEMODE.Team:TeamCreated( intIndex, entLeader, strName, colColor )
end )

net.Receive( "sh_teamdisbanded", function( intMsgLen )
	local intIndex 	= net.ReadInt( 16 )

	GAMEMODE.Team:TeamDisbanded( intIndex )
	hook.Call( "sh_teamdisbanded", {}, intIndex )
end )

net.Receive( "sh_teamleaderchange", function( intMsgLen )
	local intIndex 	= net.ReadInt( 16 )
	local entLeader = net.ReadEntity()

	GAMEMODE.Team:TeamLeaderChange( intIndex, entLeader )
end )


--[[ cl_screeneffects.lua ]]--

net.Receive( "sh_spawnprotection", function( intMsgLen )
	hook.Call( "sh_spawnprotection", {}, net.ReadBit() == 1 )
end )

net.Receive( "sh_spawndelay", function( intMsgLen )
	hook.Call( "sh_spawndelay", {}, net.ReadFloat() )
end )

net.Receive( "sh_flashed", function( intMsgLen )
	hook.Call( "sh_flashed", {}, net.ReadFloat() )
end )


--[[ cl_hats.lua ]]--

net.Receive( "sh_hat", function( intMsgLen )
	local pPlayer 	= net.ReadEntity()
	local bEnable 	= net.ReadBit() == 1
	local strHat 	= bEnable and net.ReadString() or nil

	hook.Call( "sh_hat", {}, pPlayer, bEnable, strHat )
end )


--[[ sh_scoreboard.lua ]]--

function GM.Net:RequestKickUser( pPlayer, strReason )
	if not LocalPlayer():IsAdmin() or not LocalPlayer():IsSuperAdmin() then return end
	
	net.Start( "sh_admin_k" )
		net.WriteEntity( pPlayer )
		net.WriteString( strReason )
	net.SendToServer()
end

function GM.Net:RequestBanUser( pPlayer, strReason, intLen )
	if not LocalPlayer():IsAdmin() or not LocalPlayer():IsSuperAdmin() then return end
	
	net.Start( "sh_admin_b" )
		net.WriteEntity( pPlayer )
		net.WriteString( strReason )
		net.WriteDouble( intLen )
	net.SendToServer()
end

function GM.Net:RequestSpectateUser( pPlayer )
	net.Start( "sh_admin_s" )
		net.WriteEntity( pPlayer )
	net.SendToServer()
end

net.Receive( "sh_admin_ss", function( intMsgLen )
	if net.ReadBit() == 1 then
		chat.AddText( Color(220, 220, 220, 255), "To leave spectate, push your jump key." )
		chat.PlaySound()
	
		LocalPlayer().__bInSpecMode = true
	else
		LocalPlayer().__bInSpecMode = false
	end
end )


--[[ sv_donate_websync.lua ]]--

net.Receive( "sh_cmsg", function( intMsgLen )
	chat.AddText( Color(220, 220, 220, 255), net.ReadString() )
	chat.PlaySound()
end )


--[[ sh_mapmarkers.lua ]]--

net.Receive( "sh_mm_update", function( intMsgLen )
	GAMEMODE.Map:SetMarkerData( net.ReadTable() )
end )

function GM.Net:RequestPlaceMarker( intType, funcWriteData )
	net.Start( "sh_mm_add" )
		net.WriteInt( intType, 8 )
		funcWriteData()
	net.SendToServer()
end

function GM.Net:RequestClearTeamMarkers()
	net.Start( "sh_mm_rem" )
	net.SendToServer()
end


--[[ Entity: Uplink (shared.lua/sv_term.lua) ]]--

net.Receive( "sh_etrm_om", function( pPlayer ) --OpenMenu
	GAMEMODE:ShowUplinkTerm( true )
end )

net.Receive( "sh_etrm_cm", function( pPlayer ) --CloseMenu
	if ValidPanel( GAMEMODE.m_pUplinkTerm ) then
		GAMEMODE.m_pUplinkTerm:SetVisible( false )
	end
end )

net.Receive( "sh_etrm_sl", function( pPlayer ) --SendTerminalLines
	local Lines = net.ReadTable()

	if ValidPanel( GAMEMODE.m_pUplinkTerm ) then
		GAMEMODE.m_pUplinkTerm:Clear()

		for k, v in pairs( Lines ) do
			GAMEMODE.m_pUplinkTerm:AddLine( v )
		end
	end
end )

net.Receive( "sh_etrm_ssl", function( pPlayer ) --SendTerminalLine
	local Line = net.ReadString()

	if ValidPanel( GAMEMODE.m_pUplinkTerm ) then
		GAMEMODE.m_pUplinkTerm:AddLine( Line )
	end
end )

function GM.Net:PlayerSendTermLine( strLine )
	net.Start( "sh_etrm_gl" )
		net.WriteString( strLine )
	net.SendToServer()
end

function GM.Net:PlayerKeyPress( intKey )
	net.Start( "sh_etrm_kp" )
		net.WriteInt( intKey, 8 )
	net.SendToServer()
end

function GM.Net:PlayerCloseTermMenu()
	net.Start( "sh_etrm_rcm" )
	net.SendToServer()
end

--[[ Weapon Attachments ]]--

function GM.Net:SendBuyAttachmentRequest( intType, strWepClass, strAttachment )
	net.Start( "sh_wep_ba" )
		net.WriteInt( intType, 8 )
		net.WriteString( strWepClass )
		net.WriteString( strAttachment )
	net.SendToServer()
end