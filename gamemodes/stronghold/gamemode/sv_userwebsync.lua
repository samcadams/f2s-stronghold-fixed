--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	File: sv_userwebsync.lua
	For: FTS: Stronghold
	By: Ultra

	Fetch donor info from a webserver via http (easy cross-server donor info)
	
	File format:
	EX: http://roaringcow.com/PDT/76561197993104777.txt -> (SteamID64)|(tier number)|(join message)|(disconnect message)
]]--

local Verbose = false --debug info
local _R = debug.getregistry() --why did you remove _R i don't even

GM.DWeb 				= {}
GM.DWeb.Players 		= {}
GM.DWeb.FetchTimeout	= 10
GM.DWeb.SeparatorChar 	= "|"
GM.DWeb.MasterListURL 	= "http://roaringcow.com/PDT/" --url to fetch user data from
GM.DWeb.TypeLookup		= { str = tostring, num = tonumber }
GM.DWeb.DataFormat		= {
	[1] = { "SteamID64",		"str" },
	[2] = { "Tier", 			"num" },
	[3] = { "JoinMsg", 			"str" },
	[4] = { "DisconnectMsg", 	"str" },
}
--[[GM.DWeb.TierLicense 	= {
	[1] = {
		{ typ = 1, class = "weapon_sh_scout", len = -1 },
	},
	[2] = {
		{ typ = 1, class = "weapon_sh_awp", len = -1 },
	},
}]]

function GM.DWeb:ToType( strType, vaVar )
	if self.TypeLookup[strType] then
		return self.TypeLookup[strType]( vaVar )
	end 

	return vaVar
end

function GM.DWeb:SetupTierLicense( pPlayer ) --called in GM:ReadyForInfo
	local dinfo = pPlayer:GetDonorInfo()
	if not dinfo then return end

	--[[for i = 1, dinfo.Tier do
		if not self.TierLicense[i] then continue end
		
		for k, v in pairs( self.TierLicense[i] ) do
			if Verbose then print( i, k, v, v.typ, v.class, v.len ) end
			
			pPlayer:SetLicenseTime( v.typ, v.class, v.len )
		end
	end]]
end

--[[function GM.DWeb:ClenupTierRewards( pPlayer ) --called in GM:ReadyForInfo
	local ret

	for i = 1, #self.TierLicense do
		for k, v in pairs( self.TierLicense[i] ) do
			ret = nil; ret = pPlayer:GetLicenseTimeLeft( v.typ, v.class ) 
			if Verbose then print( i, k, v, ret ) end
			
			if ret and ret == -1 then
				pPlayer:RemoveLicense( v.typ, v.class )
			end
		end
	end
end]]

function GM.DWeb:FetchPlayerInfo( pPlayer, funcCallback )
	if not IsValid( pPlayer ) then return end

	if Verbose then print( "DonorWebSync: Attempting to fetch user info for ".. pPlayer:Name().. "." ) end
	local id64 = pPlayer:SteamID64()
	local GetInfo, FailedGetInfo

	GetInfo = function( strBody, intLen, tblHeaders, intCode )
		if not IsValid( pPlayer ) then return end
		if Verbose then print( "DonorWebSync:httpFetch:GetInfo->", intLen, intCode ) end

		if intCode ~= 200 then
			FailedGetInfo( intCode, true, "Bad response code" )
			return
		end

		if not strBody or string.len( strBody ) < 1 then --um
			FailedGetInfo( intCode, true, "Invalid body len" )
			return
		end
		
		local data 	= string.Explode( self.SeparatorChar, strBody )
		local sid 	= data[1]
		local fdata = {}

		if #self.DataFormat ~= #data then --wat
			FailedGetInfo( intCode, true, "Data entry mismatch" )
			return
		end

		if id64 ~= sid then --what the hell
			FailedGetInfo( intCode, true, "SteamID64 mismatch" )
			return
		end
	
		for k, v in pairs( data ) do
			fdata[self.DataFormat[k][1]] = self:ToType( self.DataFormat[k][2], v )
		end
	
		self.Players[sid] = fdata
		pPlayer.__bFetchedUserInfo = true

		if funcCallback then funcCallback( pPlayer, true ) end
		if Verbose then print( "DonorWebSync:httpFetch: Fetched user info for ".. pPlayer:Name().. "." ) end
	end

	FailedGetInfo = function( intCode, bGotInvalidInfo, strWhat )
		if not IsValid( pPlayer ) then return end
	
		if Verbose then print( "DonorWebSync:httpFetch:FailedGetInfo->", intCode, bGotInvalidInfo, strWhat ) end
		self.Players[id64] = nil
		pPlayer.__bFetchedUserInfo = true

		if funcCallback then funcCallback( pPlayer, false ) end
	end

	http.Fetch( self.MasterListURL.. id64.. ".txt", GetInfo, FailedGetInfo )
	
	timer.Simple( self.FetchTimeout, function()
		if not IsValid( pPlayer ) then return end
		if not pPlayer:HasFetchedInfo() then
			FailedGetInfo()
		end
	end )
end

function _R.Player:HasFetchedInfo()
	return self.__bFetchedUserInfo and true or false
end

function _R.Player:GetDonorInfo()
	return GAMEMODE.DWeb.Players[self:SteamID64()] or nil
end

function _R.Player:IsDonor()
	return (self:HasFetchedInfo() and self:GetDonorInfo()) and true or false
end

function GM:CheckBans(pPlayer, strSteamID, strUID) -- Returns true if banned
	if not IsValid( pPlayer ) then return end

	local SID = pPlayer:SteamID()

	local LoadBanFile = function( strBody, intLen, tblHeaders, intCode )
		local banned = string.find(strBody,SID)
		local Start, End = string.find(strBody,"{",banned), string.find(strBody,"}",banned)
		local reason = string.sub(strBody, Start+1, End-1)
		
		if banned then
			PrintMessage(HUD_PRINTTALK, "Kicking "..pPlayer:Name()..". Player is globally banned for "..reason..".")
			pPlayer:Kick("You are globally banned for "..reason..". Appeal your ban @ forums.roaringcow.com")
			pPlayer.Banned = true
		end
	end
	
	local Fail = function(intCode)
		print( "GM:CheckBans() - Failed to fetch" )
	end
	
	http.Fetch("http://www.roaringcow.com/PDT/Bans.txt", LoadBanFile, Fail )
end

--User join/leave messages
hook.Add( "PlayerAuthed", "sh_playerauth", function( pPlayer, strSteamID, strUID )
	if game.SinglePlayer() then return end
	
	GAMEMODE:CheckBans(pPlayer, strSteamID, strUID)
	
	GAMEMODE.DWeb:FetchPlayerInfo( pPlayer, function( pl, bInfo )
		if not IsValid( pPlayer ) then return end
		if !pPlayer.Banned then
			local dinfo = pPlayer:GetDonorInfo()
			if bInfo and dinfo then
				GAMEMODE.Net:SendOmitChatMessage( pPlayer, string.format(dinfo.JoinMsg, pPlayer:Name()) )
			else
				GAMEMODE.Net:SendOmitChatMessage( pPlayer, pPlayer:Name().. " has joined the game." )
			end
		end
	end )
end )

hook.Add( "PlayerDisconnected", "sh_playerdisconnect", function( pPlayer, strSteamID, strUID )
	if !pPlayer.Banned then
		local dinfo = pPlayer:GetDonorInfo()
		if not dinfo then 
			GAMEMODE.Net:SendOmitChatMessage( pPlayer, pPlayer:Name().. " has left the game." )
		else
			GAMEMODE.Net:SendOmitChatMessage( pPlayer, string.format(dinfo.DisconnectMsg, pPlayer:Name()) )
		end
	end
end )