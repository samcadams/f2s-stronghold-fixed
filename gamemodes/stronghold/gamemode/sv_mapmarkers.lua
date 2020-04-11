--[[
	File: sv_mapmarkers.lua
	For: FTS: Stronghold
	By: Ultra
]]--

GM.Map 						= {}
GM.Map.m_tMarkers 			= {}
GM.Map.m_iLastThink 		= 0
GM.Map.m_iThinkInterval 	= 0.5
GM.Map.MarkerTypes			= { --network function per type
	[1] = {
		LeaderCmd = true,
		net = function( pPlayer ) --Leader:Attack
			return pPlayer:GetEyeTrace().HitPos, -1 
		end,
	},
	[2] = {
		LeaderCmd = true,
		net = function( pPlayer ) --Leader:Rally
			return pPlayer, -1 
		end,
	},
	[3] = {
		LeaderCmd = true,
		net = function( pPlayer ) --Leader:Defend Base
			return pPlayer:GetEyeTrace().HitPos, -1 
		end,
	},
	[4] = {
		net = function( pPlayer ) --General:Under Fire
			return pPlayer, 10
		end,
	},
	[5] = {
		net = function( pPlayer ) --General:Enemy Spotted
			return pPlayer:GetEyeTrace().HitPos, 10
		end,
	}
}

function GM.Map:NewMarker( pPlayer, intMarkerType, vaPos, intDieTime )
	local typ, tem = self.MarkerTypes[intMarkerType], GAMEMODE.Teams[pPlayer:Team()]
	if not typ or not tem then return end
	if typ.LeaderCmd and tem.Leader ~= pPlayer then return end
	if not self.m_tMarkers[pPlayer] then
		self.m_tMarkers[pPlayer] = {}
	end

	local Marker 			= {}
	Marker.Owner 			= pPlayer
	Marker.Type 			= intMarkerType
	Marker.DieTime 			= intDieTime
	Marker.ID 				= #self.m_tMarkers[pPlayer] +1
	Marker.StartTime		= CurTime()

	if type( vaPos ) == "Vector" then
		Marker.Pos = vaPos
	elseif type( vaPos ) == "Player" or type( vaPos ) == "Entity" then
		Marker.FollowEnt = vaPos
	end

	table.insert( self.m_tMarkers[pPlayer], Marker )
	GAMEMODE.Net:BroadcastMarkerUpdate()

	return Marker
end

function GM.Map:RemoveMarker( pPlayer, intKey )
	if intKey then
		local v = self.m_tMarkers[pPlayer][intKey]
		if v then
			self.m_tMarkers[pPlayer][intKey] = nil
			GAMEMODE.Net:BroadcastMarkerUpdate()
			return
		end
	end
end

function GM.Map:PlayerRemoveMarker( pPlayer, intMarkerID, intKey )
	if not self.m_tMarkers[pPlayer] then return end

	if intKey then
		local v = self.m_tMarkers[pPlayer][intKey]
		if v then
			self:RemoveMarker( pPlayer, intKey )
			return
		end
	end

	for k, v in pairs( self.m_tMarkers[pPlayer] ) do
		if v.ID == intMarkerID then
			self:RemoveMarker( pPlayer, k )
		end
	end
end

function GM.Map:ClearPlayerMarkers( pPlayer )
	self.m_tMarkers[pPlayer] = nil
	GAMEMODE.Net:BroadcastMarkerUpdate()
end

function GM.Map:PlayerHasActiveMarker( pPlayer, intType )
	if not self.m_tMarkers[pPlayer] then return false end

	for k, v in pairs( self.m_tMarkers[pPlayer] ) do
		if v.Type == intType then
			return true
		end
	end

	return false
end

function GM.Map:CheckMarkers()
	if CurTime() < self.m_iLastThink then return end
	self.m_iLastThink = CurTime() +self.m_iThinkInterval

	for k, v in pairs( player.GetAll() ) do
		if not self.m_tMarkers[v] then continue end

		for k2, v2 in pairs( self.m_tMarkers[v] ) do
			if v2.DieTime == -1 then continue end

			if v2.StartTime +v2.DieTime < CurTime() then
				self:RemoveMarker( v, k2 )
			end
		end
	end
end