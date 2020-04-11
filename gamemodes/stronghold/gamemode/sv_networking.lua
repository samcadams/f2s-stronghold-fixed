--[[
	File: sv_networking.lua
	For: FTS: Stronghold
	By: Ultra
]]--

GM.Net = {}

util.AddNetworkString "sh_maplist"
util.AddNetworkString "sh_winningmap"
util.AddNetworkString "sh_teamcreated"
util.AddNetworkString "sh_teamdisbanded"
util.AddNetworkString "sh_teamleaderchange"
util.AddNetworkString "sh_countdown"
util.AddNetworkString "sh_cancelcountdown"
util.AddNetworkString "PlayerSounds_PlayerDeath"
util.AddNetworkString "PlayerSounds_ScalePlayerDamage"
util.AddNetworkString "sh_statistics"
util.AddNetworkString "sh_moneyandmultiplier"
util.AddNetworkString "sh_hat"
util.AddNetworkString "sh_advert"
util.AddNetworkString "sh_gameending"
util.AddNetworkString "sh_gameover"
util.AddNetworkString "sh_spawned"
util.AddNetworkString "sh_spawnprotection"
util.AddNetworkString "sh_spawndelay"
util.AddNetworkString "sh_killed"
util.AddNetworkString "sh_hitdetection"
util.AddNetworkString "sh_loadouts"
util.AddNetworkString "sh_loadout"
util.AddNetworkString "sh_faderagdoll"
util.AddNetworkString "sh_items"
util.AddNetworkString "sh_item"
util.AddNetworkString "sh_licenses"
util.AddNetworkString "sh_license"
util.AddNetworkString "sh_flashed"
util.AddNetworkString "sh_admin_k"
util.AddNetworkString "sh_admin_b"
util.AddNetworkString "sh_admin_s"
util.AddNetworkString "sh_admin_ss"
util.AddNetworkString "sh_cmsg"
util.AddNetworkString "sh_mm_update"
util.AddNetworkString "sh_mm_add"
util.AddNetworkString "sh_mm_rem"
util.AddNetworkString "sh_etrm_om"
util.AddNetworkString "sh_etrm_cm"
util.AddNetworkString "sh_etrm_sl"
util.AddNetworkString "sh_etrm_ssl"
util.AddNetworkString "sh_etrm_gl"
util.AddNetworkString "sh_etrm_kp"
util.AddNetworkString "sh_etrm_rcm"
util.AddNetworkString "sh_wep_ba"
util.AddNetworkString "sh_wep_sa"

-- ----------------------------------------------------------------------------------------------------
--[[ voting.lua ]]--

function GM.Net:BroadcastMapList( tblMapList )
	net.Start( "sh_maplist" )
		net.WriteTable( tblMapList )
	net.Broadcast()
end

function GM.Net:SendWinningMap( strMap )
	net.Start( "sh_winningmap" )
		net.WriteString( strMap )
	net.Broadcast()
end

-- ----------------------------------------------------------------------------------------------------
--[[ teams.lua ]]--

function GM.Net:SendTeamToClient( pPlayer, intIndex, pLeader, strName, colColor )
	net.Start( "sh_teamcreated" )
		net.WriteInt( intIndex, 16 )
		net.WriteEntity( pLeader )
		net.WriteString( strName )
		net.WriteUInt( colColor.r, 8 )
		net.WriteUInt( colColor.g, 8 )
		net.WriteUInt( colColor.b, 8 )
	net.Send( pPlayer )
end

function GM.Net:SendDisbandToClients( intIndex )
	net.Start( "sh_teamdisbanded" )
		net.WriteInt( intIndex, 16 )
	net.Broadcast()
end

function GM.Net:SendLeaderToClients( intIndex, pleader )
	net.Start( "sh_teamleaderchange" )
		net.WriteInt( intIndex, 16 )
		net.WriteEntity( pleader )
	net.Broadcast()
end

-- ----------------------------------------------------------------------------------------------------
--[[ shared.lua ]]--

function GM.Net:BroadcastCountdown( intLen, strTitle, strLuaCL )
	net.Start( "sh_countdown" )
		net.WriteInt( intLen, 32 )
		net.WriteString( strTitle )
		net.WriteString( strLuaCL )
	net.Broadcast()
end	

function GM.Net:BroadcastCancelCountdown()
	net.Start( "sh_cancelcountdown" )
	net.Broadcast()
end

-- ----------------------------------------------------------------------------------------------------
--[[ playersounds.lua ]]--

function GM.Net:PlayerSoundsDeath( pl, pPlayer )
	net.Start( "PlayerSounds_PlayerDeath" )
		net.WriteEntity( pPlayer )
		net.WriteString( pPlayer:GetModel() )
	net.Send( pl )
end

function GM.Net:PlayerSoundsScalePlayerDamage( pl, pPlayer )
	net.Start( "PlayerSounds_ScalePlayerDamage" )
		net.WriteEntity( pPlayer )
		net.WriteString( pPlayer:GetModel() )
		net.WriteBit( pPlayer.LastHurtHead and true or false )
	net.Send( pl )
end

-- ----------------------------------------------------------------------------------------------------
--[[ player_extension.lua ]]--

function GM.Net:SendClientStats( pl, pPlayer )
	net.Start( "sh_statistics" )
		net.WriteEntity( pPlayer )
		net.WriteTable( pPlayer.Statistics )
	net.Send( pl )
end

function GM.Net:SendMoneyAndMultiplier( pPlayer )
	net.Start( "sh_moneyandmultiplier" )
		net.WriteFloat( pPlayer.Money or 0 )
		net.WriteFloat( pPlayer.Multiplier or 0 )
	net.Send( pPlayer )
end

function GM.Net:EnableHat( pPlayer, strHatName ) --does this sync with new players right?
	net.Start( "sh_hat" )
		net.WriteEntity( pPlayer )

		if not strHatName or strHatName == "" then
			net.WriteBit( false )
		else
			net.WriteBit( true )
			net.WriteString( strHatName )
		end
	net.Broadcast()
end

-- ----------------------------------------------------------------------------------------------------
--[[ player.lua ]]--

function GM.Net:SendAdvert( pPlayer, type, col, str )
	net.Start( "sh_advert" )
		net.WriteString( type )
		net.WriteInt( col, 8 )
		net.WriteString( str )
	net.Send( pPlayer )
end

function GM.Net:BroadcastGameEnding()
	net.Start( "sh_gameending" )
	net.Broadcast()
end

function GM.Net:SendGameOver( pPlayer, intTeamIndex, pWinner, tblModels )
	net.Start( "sh_gameover" )
		net.WriteInt( intTeamIndex or 0, 16 )
		net.WriteEntity( pWinner )
		net.WriteTable( tblModels )
	net.Send( pPlayer )
end

function GM.Net:BroadcastGameOver( intTeamIndex, pWinner, tblModels )
	net.Start( "sh_gameover" )
		net.WriteInt( intTeamIndex or 0, 16 )
		net.WriteEntity( pWinner )
		net.WriteTable( tblModels )
	net.Broadcast()
end

function GM.Net:SendPlayerSpawned( pPlayer )
	net.Start( "sh_spawned" )
	net.Send( pPlayer )
end

function GM.Net:SendSpawnProtection( pPlayer, bProt )
	net.Start( "sh_spawnprotection" )
		net.WriteBit( bProt and true or false )
	net.Send( pPlayer )
end

function GM.Net:SendSpawnDelay( pPlayer, bDelay )
	net.Start( "sh_spawndelay" )
		net.WriteFloat(bDelay)
	net.Send( pPlayer )
end

function GM.Net:SendPlayerKilled( pPlayer, pKiller )
	net.Start( "sh_killed" )
		net.WriteEntity( pKiller )
	net.Send( pPlayer )
end

function GM.Net:SendHitDetect( pPlayer, HS )
	net.Start( "sh_hitdetection" )
	net.WriteBool(HS)
	net.Send( pPlayer )
end

-- ----------------------------------------------------------------------------------------------------
--[[ loadout.lua ]]--

function GM.Net:SendClientLoadouts( pPlayer )
	if not IsValid( pPlayer ) then return end

	local loadouts = pPlayer:GetLoadouts()
	if not loadouts then return end

	net.Start( "sh_loadouts" )
		net.WriteTable( loadouts )
	net.Send( pPlayer )	
end

function GM.Net:SendClientLoadout( pPlayer, strName )
	if not IsValid( pPlayer ) then return end

	local loadout = pPlayer:GetLoadout( strName )
	if not loadout then return end

	net.Start( "sh_loadout" )
		net.WriteTable{ [strName] = loadout }
	net.Send( pPlayer )
end

-- ----------------------------------------------------------------------------------------------------
--[[ init.lua ]]--

function GM.Net:BroadcastFadeRagdoll( eRagdoll )
	net.Start( "sh_faderagdoll" )
		net.WriteEntity( eRagdoll )
	net.Broadcast()
end

-- ----------------------------------------------------------------------------------------------------
--[[ gbux.lua ]]--

function GM.Net:SendClientItems( pPlayer )
	local items = pPlayer:GetItems()
	if not items then return end

	net.Start( "sh_items" )
		net.WriteTable( items )
	net.Send( pPlayer )
end

function GM.Net:SendClientItem( pPlayer, strName )
	local item = pPlayer:GetItem( strName )
	if not item then return end

	net.Start( "sh_item" )
		net.WriteTable{ [strName] = item }
	net.Send( pPlayer )
end

function GM.Net:SendClientLicenses( pPlayer )
	if not IsValid( pPlayer ) then return end

	local licenses = pPlayer:GetLicenses()
	if not licenses then return end

	net.Start( "sh_licenses" )
		net.WriteTable( licenses )
	net.Send( pPlayer )
end

function GM.Net:SendClientLicense( pPlayer, strType, strClass )
	if not IsValid( pPlayer ) then return end

	local license = pPlayer:GetLicense( strType, strClass )
	if not license then return end

	net.Start( "sh_license" )
		net.WriteTable{ [strType] = {[strClass] = license} }
	net.Send( pPlayer )
end

-- ----------------------------------------------------------------------------------------------------
--[[ sh_scoreboard.lua ]]--

net.Receive( "sh_admin_k", function( intMsgLen, pPlayer )
	if not pPlayer:IsAdmin() then return end
	
	local pKick = net.ReadEntity()
	local strReason = "Kicked from game. Reason: ".. net.ReadString()

	pKick:Kick( strReason )
end )

net.Receive( "sh_admin_b", function( intMsgLen, pPlayer )
	if not pPlayer:IsAdmin() then return end
	
	local pBan = net.ReadEntity()
	local strReason = net.ReadString()
	local intLen = net.ReadDouble()
	local s2 = (intLen == 0) and "forever" or intLen.. " minutes"
	local str = "Banned for ".. s2.. ". Reason: ".. strReason
	
	pBan:Ban( intLen, str )
	pBan:Kick( str )
end )

function GM.Net:SendConfirmSpectate( bSpec, pPlayer, pSpec )
	pPlayer.__bInSpecMode = bSpec

	if bSpec then
		ServerLog( pPlayer:Name().. " [".. pPlayer:SteamID().. "] started spectating ".. pSpec:Name().. " [".. pSpec:SteamID().. "-".. pSpec:IPAddress().. "]" )
	end

	net.Start( "sh_admin_ss" )
		net.WriteBit( bSpec )
	net.Send( pPlayer )
end

net.Receive( "sh_admin_s", function( intMsgLen, pPlayer )
	if not pPlayer:IsAdmin() then return end
	
	local pToSpec = net.ReadEntity()
	if not IsValid( pToSpec ) or not pToSpec:IsPlayer() then return end
	
	pPlayer.__tPreSpecWeps = {}
	pPlayer.__vSpecSPos = pPlayer:GetPos()
	GAMEMODE:DoPlayerDeath( pPlayer, nil, nil, true )

	pPlayer:Spectate( OBS_MODE_IN_EYE )
	pPlayer:SpectateEntity( pToSpec )

	if IsValid( pPlayer:GetActiveWeapon() ) then
		pPlayer.__sActiveWeapon = pPlayer:GetActiveWeapon():GetClass()
	end

	for k, wep in pairs( pPlayer:GetWeapons() ) do
		pPlayer.__tPreSpecWeps[k] = wep:GetClass()
	end

	pPlayer:StripWeapons()

	GAMEMODE.Net:SendConfirmSpectate( true, pPlayer, pToSpec )
end )

hook.Add( "KeyPress", "sh_adminkp", function( pPlayer, intKey )
	if not pPlayer.__bInSpecMode then return end
	
	if intKey == IN_JUMP then
		pPlayer:UnSpectate()
		pPlayer:Spawn()

		if pPlayer.__vSpecSPos then
			pPlayer:SetPos( pPlayer.__vSpecSPos )
			pPlayer.__vSpecSPos = nil
		end

		if pPlayer.__tPreSpecWeps then
			local w, e
			for k, v in pairs( pPlayer.__tPreSpecWeps ) do
				e = pPlayer:Give( v )

				if pPlayer.__sActiveWeapon and pPlayer.__sActiveWeapon == v then
					w = e
				end
			end

			timer.Simple( 0.5, function()
				if IsValid( w ) and IsValid( pPlayer ) then
					pPlayer:SetActiveWeapon( w )
				end
			end )

			pPlayer.__sActiveWeapon = nil
			pPlayer.__tPreSpecWeps = nil
		end

		GAMEMODE.Net:SendConfirmSpectate( false, pPlayer )
	end
end )

-- ----------------------------------------------------------------------------------------------------
--[[ sv_donate_websync.lua ]]--

function GM.Net:SendOmitChatMessage( pPlayer, strMsg )
	ServerLog( strMsg.. " [".. pPlayer:SteamID().. "-".. pPlayer:IPAddress().. "]\n" )

	net.Start( "sh_cmsg" )
		net.WriteString( strMsg )
	net.SendOmit( pPlayer )
end


--[[ sh_mapmarkers.lua ]]--
function GM.Net:BroadcastMarkerUpdate()
	--for k, pl in pairs( player.GetAll() ) do
	--	local t = {}

	--	for k2, markers in pairs( GAMEMODE.Map.m_tMarkers ) do
	--		if not IsValid( k2 ) then continue end
	--		if pl:Team() ~= k2:Team() then continue end

	--		table.Merge( t, markers )
	--	end

	--	net.Start( 'sh_mm_update' )
	--		net.WriteTable( t )
	--	net.Send( pl )
	--end
end

net.Receive( "sh_mm_add", function( intMsgLen, pPlayer )
	--local iMarkerType = net.ReadInt( 8 )
	--if not iMarkerType or iMarkerType <= 0 then return end
	--local MarkerType = GAMEMODE.Map.MarkerTypes[iMarkerType]

	--if not MarkerType then return end
	--if GAMEMODE.Map:PlayerHasActiveMarker( pPlayer, iMarkerType ) then return end

	--local target, dietime = MarkerType.net( pPlayer )
	--if not target then return end

	--GAMEMODE.Map:NewMarker( pPlayer, iMarkerType, target, dietime )
end )

net.Receive( "sh_mm_rem", function( intMsgLen, pPlayer )
	--if not GAMEMODE.Map.m_tMarkers[pPlayer] then return end
	--for k, v in pairs( GAMEMODE.Map.m_tMarkers[pPlayer] ) do
	--	if GAMEMODE.Map.MarkerTypes[v.Type].LeaderCmd then
	--		GAMEMODE.Map:PlayerRemoveMarker( pPlayer, v.ID )
	--	end
	--end
end )


--[[ Entity: Uplink (shared.lua/sv_term.lua) ]]--
function GM.Net:OpenTerminalMenu( pPlayer )
	net.Start( "sh_etrm_om" )
	net.Send( pPlayer )
end

function GM.Net:CloseTerminalMenu( pPlayer )
	net.Start( "sh_etrm_cm" )
	net.Send( pPlayer )
end

function GM.Net:SendTerminalLines( pPlayer, cTermInst )
	net.Start( "sh_etrm_sl" )
		net.WriteTable( cTermInst:GetLines() )
	net.Send( pPlayer )
end

function GM.Net:SendTerminalLine( pPlayer, cTermInst, strLine )
	net.Start( "sh_etrm_ssl" )
		net.WriteString( strLine or "" )
	net.Send( pPlayer )
end

net.Receive( "sh_etrm_gl", function( intMsgLen, pPlayer ) --PlayerSendLine/GetLine
	--local NewLine = net.ReadString()
	--if not NewLine then return end
	--
	--if not pPlayer.__cActiveTerminal then return end
	--pPlayer.__cActiveTerminal:AddLine( NewLine, pPlayer )
end )

net.Receive( "sh_etrm_kp", function( intMsgLen, pPlayer ) --keypress
	--local key = net.ReadInt( 8 )
	--if not key then return end
	--
	--if not pPlayer.__cActiveTerminal then return end
	--pPlayer.__cActiveTerminal:KeyPress( pPlayer, key )
end )

net.Receive( "sh_etrm_rcm", function( intMsgLen, pPlayer ) --PlayerCloseMenu
	--if not pPlayer.__cActiveTerminal then return end
	--pPlayer.__cActiveTerminal:RemovePlayer( pPlayer )
end )


--[[ Weapon Attachments ]]--
net.Receive( "sh_wep_ba", function( intMsgLen, pPlayer ) --SendBuyAttachmentRequest
	local intType 		= net.ReadInt( 8 )
	local strWepClass 	= net.ReadString()
	local strAttachment = net.ReadString()

	if not intType or not strWepClass or not strAttachment then return end
	pPlayer:BuyAttachment( intType, strWepClass, strAttachment )
end )