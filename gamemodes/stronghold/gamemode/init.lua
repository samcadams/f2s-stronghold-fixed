--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	GM13 Changes
	
	Added:
	Removed:
	Updated:
		net code
	Changed:
		cleaned Code
]]--

-- Create file structure
if !file.Exists( "Stronghold", "DATA" ) then
	file.CreateDir( "Stronghold" )
end
if !file.Exists( "stronghold/playerinfo", "DATA" ) then
	file.CreateDir( "stronghold/playerinfo" )
end

-- Move old files to new spots
-- TODO: Delete later maybe - this was to make sure the update didn't require a lot of manual changes
local OLD_MOVES = string.Explode( "\n", file.Read("Stronghold/confirmed_update_moves.txt") or "" )
local MOVES = {
	--[old] = "new",
	["sh_maplist.txt"] = "stronghold/maplist.txt",
	["chat_adverts.txt"] = "stronghold/chat_adverts.txt",
	["hint_adverts.txt"] = "stronghold/hint_adverts.txt",
}

-- Move files that haven't been moved yet
for path_old, path_new in pairs(MOVES) do
	if not table.HasValue( OLD_MOVES, path_old ) and file.Exists( path_old, "DATA" ) then
		local old = file.Open( path_old, "rb", "DATA" )
		if old then
			local new = file.Open( path_new, "wb", "DATA" )
			if new then
				new:Write( old:Read(old:Size()) )
				new:Close()
			end
			old:Close()
		end
		
		file.Delete( path_old )
		table.insert( OLD_MOVES, path_old )
	end
end

-- Save confirmed moves
file.Write( "stronghold/confirmed_update_moves.txt", table.concat(OLD_MOVES,"\n") )

-- ----------------------------------------------------------------------------------------------------

include( "glon.lua" ) -- Garry deleted glon - TODO: Use new File:WriteTable
AddCSLuaFile( "glon.lua" )

--require( "datastream" )

include( "sh_compat.lua" )
include( "resources.lua" )

include( "shared.lua" )
include( "sv_networking.lua" )
include( "entity_extension.lua" )
include( "player_extension.lua" )
include( "player.lua" )
include( "teams.lua" )
include( "loadout.lua" )
include( "spawnmenu.lua" )
include( "playersounds.lua" )
include( "voting.lua" )
include( "gbux.lua" )
include( "sv_adverts.lua" )
include( "sv_userwebsync.lua" )
include( "sv_mapmarkers.lua" )
include( "sh_plugins.lua" )

AddCSLuaFile( "sh_compat.lua" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "entity_extension.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "spawnmenu.lua" )
AddCSLuaFile( "playersounds.lua" )
AddCSLuaFile( "sh_plugins.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_networking.lua" )
AddCSLuaFile( "cl_skin.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_hud_normal.lua" )
AddCSLuaFile( "cl_hud_slim.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_teams.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "cl_screeneffects.lua" )
AddCSLuaFile( "cl_hats.lua" )
AddCSLuaFile( "cl_mapmarkers.lua" )
AddCSLuaFile( "cl_weapons.lua" )

include( "vgui/vgui_manifest.lua" )
AddCSLuaFile( "vgui/vgui_manifest.lua" )

cvars.AddChangeCallback( "mp_fraglimit", function(_,_,new) SetGlobalInt("mp_fraglimit",tonumber(new)) end )
cvars.AddChangeCallback( "mp_timelimit",
	function(_,_,new)
		if GAMEMODE.GameOver then return end
		new = tonumber( new )
		if new > 0 then
			GAMEMODE:StartCountDown( (new*60)-(CurTime()-(GAMEMODE.LastGameReset or 0)), "Timelimit is up in", "", "" )
		else
			GAMEMODE:CancelCountDown()
		end
	end )

-- Breakable Entities Info | Most of this is from FTS 1
local BreakableEntities = { 
	"prop_physics", 
	"prop_magnet", 
	"gmod_turret", 
	"gmod_thruster", 
	"gmod_wheel", 
	"gmod_spawner", 
	"prop_vehicle_jeep", 
	"prop_vehicle_airboat", 
	"prop_vehicle_jeep_old", 
	"sent_spawnpoint", 
	"gmod_cameraprop", 
	"sent_turret_base", 
	"sent_turret_mount", 
	"sent_turret_mountable",
	"sent_basemarker",
	"sent_weaponcrate" }
local DefaultHealths = { 
	prop_physics=1000, 
	prop_dynamic=1000, 
	prop_magnet=1000, 
	prop_vehicle_jeep=1500, 
	prop_vehicle_jeep_old=1500, 
	prop_vehicle_airboat=1500, 
	sent_spawnpoint=20, 
	sent_turret_base=50, 
	sent_turret_mount=50, 
	sent_turret_mountable=50,
	sent_basemarker=2500,
	sent_weaponcrate=250 }
local PropBuildingSound = Sound( "ambient/energy/electric_loop.wav" )
GM.BuildingProps = {}

-- Ragdoll Info
GM.Ragdolls = {}

function GM.Reinitialize( ply, cmd, args, no_clients )
	if !IsValid( ply ) or ply:IsSuperAdmin() then
		-- Why does this carry over
		GAMEMODE.GameOver = false
		
		for _, v in ipairs(player.GetAll()) do
			v:SetFrags( 0 )
			v:SetDeaths( 0 )
			if GAMEMODE.ConVars.ReinitRespawn:GetBool() and not v:Alive() then
				timer.Simple( 0.1, function() if IsValid( v ) then v:Spawn() end end )
			end
		end
		
		-- Reinit
		Msg( "Reinitializing gamemode...\n" )
		GAMEMODE:Initialize()
		GAMEMODE:InitPostEntity()
		
		if !no_clients then
			for _, v in ipairs(player.GetAll()) do
				v:ConCommand( "gamemode_reinitialize_cl" )
			end
		end
	end
end
concommand.Add( "gamemode_reinitialize", function(p,c,a) GAMEMODE.Reinitialize(p,c,a,false) end )
hook.Add( "OnReloaded", "Stronghold_AutoRefresh", function() GAMEMODE.Reinitialize(_,_,_,true) end )

function GM:Initialize()
	self:InitConVars()
	self:LoadAdverts()
	self:LoadMapList()

	self.Plugins:HandleHook( "Initialize" )
end

function GM:Shutdown()
	for _, v in ipairs(player.GetHumans()) do
		ply:SaveData()
	end
end

local HealthRegenLast = 0
local HealthRegenDelay = 0.15
local DataSaveLast = 0
local DataSaveDelay = 300
local GBuxSendLast = 0
local GBuxSendDelay = 1
local RagdollTime = 5 -- Time not including 1 second fade
local RagdollMax = 5
local PropBuildTime = 10
local PropBuildLast = 0
local FileInit = false
local START, PRINTED = 0, false
function GM:Think()
	if !FileInit then
		self:InitConVars()
		self:LoadAdverts()
		self:LoadMapList()
		FileInit = true
	end
	if lprof then lprof.PushScope( "SH - Think" ) end
	local curtime = CurTime()
	
	-- Data Save
	if curtime - DataSaveLast >= DataSaveDelay then
		if lprof then lprof.PushScope( "SH - Save Data" ) end
		
		for _, v in ipairs( player.GetHumans() ) do
			v:SaveData()
		end
		DataSaveLast = curtime
		
		if lprof then lprof.PopScope() end
	end
	-- End Data Save

	-- Counter
	if self.CountDownEnd != -1 and curtime >= self.CountDownEnd then
		local lua_to_run 	= self.CountDownLua
		self.CountDownEnd 	= -1
		self.CountDownTitle = ""
		self.CountDownLua 	= ""
		if lua_to_run and lua_to_run != "" then
			RunString( lua_to_run )
		end
	end
	-- End Counter

	-- Game already over
	if self.GameOverRealTime ~= 0 and not self.GameOver then
		if RealTime() - self.GameOverRealTime >= GAMEMODE.GameOverGraceTime then
			game.SetTimeScale( 1 )
			self:DoGameOver()
		else
			local scale = 0.1 + 0.9 * (1-math.Clamp((RealTime()-self.GameOverRealTime) / (GAMEMODE.GameOverGraceTime * 0.75), 0, 1 ))
			game.SetTimeScale( scale )
		end
	end
	if self.GameOver then
		local timelimit = GAMEMODE.ConVars.TimeLimit:GetFloat()
		local votingenabled = GAMEMODE.ConVars.VoteEnabled:GetBool()
		
		local timepassed = (CurTime() - self.LastGameReset) / 60
		if timelimit > 0 then
			if votingenabled then
				if timepassed >= timelimit + ((GAMEMODE.ConVars.VoteDelay:GetInt()+GAMEMODE.ConVars.VoteTime:GetInt())/60) + 0.50 then
					game.ConsoleCommand("changelevel "..GAMEMODE:GetNextMap(false).."\n")
					for _, v in ipairs(player.GetHumans()) do v:SaveData() end
				end
			else
				if timepassed >= timelimit + 0.50 then
					game.ConsoleCommand("changelevel "..GAMEMODE:GetNextMap(false).."\n")
					for _, v in ipairs(player.GetHumans()) do v:SaveData() end
				end
			end
		end
		return
	end
	-- End Game already over

	-- Ragdolls
	--[[local instant_fade_count = #GAMEMODE.Ragdolls - RagdollMax
	for i, tbl in ipairs(GAMEMODE.Ragdolls) do
		local deltatime = curtime - tbl.time
	
		if instant_fade_count > 0 and deltatime < (RagdollTime-1) then
			tbl.time = curtime - RagdollTime + 1
		end
		instant_fade_count = instant_fade_count - 1
	
		if deltatime >= RagdollTime then
			if IsValid( tbl.ent ) then tbl.ent:Remove() end
			table.remove( GAMEMODE.Ragdolls, i )
		elseif deltatime >= (RagdollTime-1) and !tbl.fading then
			tbl.fading = true
			GAMEMODE.Net:BroadcastFadeRagdoll( tbl.ent )
		end
	end]]
	-- End Ragdolls
	
	-- Building Props
	for ent, time in pairs(GAMEMODE.BuildingProps) do
		if !IsValid( ent ) then
			GAMEMODE.BuildingProps[ent] = nil
		else
			local hp = ent:Health()
			local hpmax = ent:GetMaxHealth()
			hp = hp + ((curtime-PropBuildLast) / ent.BuildTime) * hpmax
			local scale = hp / hpmax
		
			if scale >= 1 then
				GAMEMODE.BuildingProps[ent] = nil
				ent:SetHealth( ent:GetMaxHealth() )
				ent:SetColor( Color(255,255,255,255) )
				if ent.BuildSound then ent.BuildSound:Stop() ent.BuildSound = nil end
				ent:BuildingSolidify()
				ent.CanRepair = true
				ent:SetRenderMode(RENDERMODE_NORMAL )
			else
				ent:SetHealth( hp )
				ent:SetColor( Color(255,255,255,55+200*scale) )
				ent:SetRenderMode( (55+200*scale) < 255 and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL )
			end
		end
	end
	PropBuildLast = curtime
	-- End Building Props 
	
	-- Weapon switch
	for _, v in ipairs( player.GetAll() ) do
		local wep = v:GetActiveWeapon()
		if v.LastWeapon != wep then
			self:PlayerSwitchWeapon( v, wep )
			v.LastWeapon = wep
		end
	end
	-- End Weapon switch
	
	-- GBux Send
	for _, v in ipairs( player.GetHumans() ) do
		v:SetLastKill( v:GetLastKill() or 0 )
		if curtime - v:GetLastKill() >= 60 then
			v:AddMultiplier( -1 )
			v:SetLastKill( curtime )
		end
	end
	
	if curtime - GBuxSendLast >= GBuxSendDelay then
		for _, v in ipairs( player.GetHumans() ) do
			local amt = GAMEMODE.ConVars.GBuxMPM:GetFloat() / 60 * GBuxSendDelay * v:GetMultiplier()
			v:AddMoney( amt )
			v:SendMoneyAndMultiplier()
			v:AddStatistic( "gbuxmoneyearned", amt )
		end
		GBuxSendLast = curtime
	end
	-- End GBux Send
	
	-- Regen
	if curtime - HealthRegenLast >= HealthRegenDelay then
		for _, v in ipairs( player.GetAll() ) do
			if v:Alive() and v:Health() < 100 and (v:GetNextHealthRegen() or 0) < CurTime() then
				v:SetHealth( v:Health()+1 )
			end
		end
		HealthRegenLast = curtime
	end
	-- End Regen
	
	-- Check endgame
	if self.GameOverTime == 0 then
		local gameover, team_index, winner = self:IsGameOver()
		if gameover then
			self.GameOverTeam 	= team_index
			self.GameOverWinner = winner
			self.GameOverTime = CurTime()
			self.GameOverRealTime = RealTime()
			GAMEMODE.Net:BroadcastGameEnding()
		end
	end
	-- End Check endgame

	self.Map:CheckMarkers()
end

function GM:Tick()
	--[[for _, v in ipairs( player.GetAll() ) do
		v:SetBloodColor(-1)
	end

	for _, v in ipairs( ents.FindByClass("prop_ragdoll") ) do
		v:SetBloodColor(-1)
	end]]
	
	for _, v in ipairs( ents.GetAll() ) do
		if v.IsOnFire and v.Extinguish and v:IsOnFire() then
			local mat = v:GetMaterialType()
			if mat != MAT_WOOD then
				v:Extinguish()
			end
		end
	end
end

function GM:IsGameOver()
	local players = player.GetAll()
	if #players == 0 then return false, 0, nil end

	-- Find winner
	local curtime = CurTime()
	local winner, frags, deaths = nil
	for _, v in ipairs(players) do
		if not IsValid( winner ) or v:Frags() > frags or (v:Frags() == frags and v:Deaths() < deaths) or (v:Frags() == frags and v:Deaths() == deaths and curtime-winner:GetCreationTime() > curtime-v:GetCreationTime()) then
			winner, frags, deaths = v, v:Frags(), v:Deaths()
		end
	end

	-- Check fraglimit
	local fraglimit = GAMEMODE.ConVars.FragLimit:GetFloat()
	if fraglimit > 0 and frags >= fraglimit then
		return true, IsValid(winner) and winner:Team() or 0, winner
	end

	-- Otherwise check the timelimit
	local timelimit = GAMEMODE.ConVars.TimeLimit:GetFloat()
	if timelimit > 0 and (CurTime()-self.LastGameReset)/60 >= timelimit then
		return true, IsValid(winner) and winner:Team() or 0, winner
	end
	
	-- Not over
	return false, 0, nil
end

-- If winner is 0 then it was a timelimit end
function GM:DoGameOver()
	self.GameOver = true
	
	self.GameOverModels = {}
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() then
			-- Clone player
			local ent = ents.Create( "prop_physics" )
			
			ent:SetPos( ply:GetPos() )
			ent:SetAngles( Angle(0,ply:GetAngles().y,0) )
			ent:SetModel( ply:GetModel() )
			ent:Spawn()
			ent:Activate()
			
			ent:SetMoveType( MOVETYPE_NONE )
			ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			ent:SetNotSolid( true )
			
			ent:SetSequence( ply:GetSequence() )
			ent:SetCycle( ply:GetCycle() )
			ent:SetPlaybackRate( 0 )
			
			for i=0, ply:GetNumPoseParameters()-1 do
				local name = ply:GetPoseParameterName( i )
				ent:SetPoseParameter( name, ply:GetPoseParameter(name) )
			end
			
			-- Attach weapon
			if IsValid( ply:GetActiveWeapon() ) then
				local weapon = ents.Create( "prop_physics" )
				weapon:SetModel( ply:GetActiveWeapon():GetModel() )
				weapon:Spawn()
				weapon:Activate()

				weapon:SetMoveType( MOVETYPE_NONE )
				weapon:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
				weapon:SetNotSolid( true )
				
				weapon:SetParent( ent )
				weapon:AddEffects( EF_BONEMERGE )
			end
			
			self.GameOverModels[ent] = { ply=ply, clone=ent, name=ply:GetName(), kills=ply:Frags(), deaths=ply:Deaths(), team=ply:Team() }
			self.GameOverModels[ply] = self.GameOverModels[ent]
		elseif IsValid( ply:GetRagdollEntity() ) then
			local ragdoll = ply:GetRagdollEntity()
			self.GameOverModels[ragdoll] = { ply=ply, clone=ragdoll, name=ply:GetName(), kills=ply:Frags(), deaths=ply:Deaths(), team=ply:Team() }
			self.GameOverModels[ply] = self.GameOverModels[ragdoll]
		end
	end

	GAMEMODE.Net:BroadcastGameOver( self.GameOverTeam, self.GameOverWinner, self.GameOverModels )
	
	GAMEMODE.StripPlayers()
	GAMEMODE.SpectatePlayers( true, self.GameOverModels[self.GameOverWinner].clone )

	-- Start vote timer
	if GAMEMODE.ConVars.VoteEnabled:GetBool() then
		GAMEMODE:SendMapList()
		GAMEMODE:StartCountDown( GAMEMODE.ConVars.VoteDelay:GetInt(), "Voting will begin in", "GAMEMODE:EnableVotingSystem()", "GAMEMODE:EnableVotingSystem()" )
	else
		GAMEMODE:StartCountDown( GAMEMODE.ConVars.VoteDelay:GetInt()*2, "Map change in", [[game.ConsoleCommand("changelevel "..GAMEMODE:GetNextMap().."\n")]], "" )
		for _, v in ipairs(player.GetHumans()) do v:SaveData() end
	end
end

function GM:GetFallDamage( ply, vel )
	return (vel-480)*(100/(1024-580))
end

function GM:GetDefaultHealth( ent )
	return IsValid( ent ) and (DefaultHealths[ent:GetClass()] or 100) or 100
end

function GM:SetEntHealth( ent )
	local newhp = (DefaultHealths[ent:GetClass()] or 100)
	
	if getmodelproperties then
		local surfaceprop, _ = getmodelproperties( ent:GetModel() )
		if string.find( string.lower(surfaceprop), "wood" ) then newhp = newhp/4 end
	elseif string.find( ent:GetModel(), "wood" ) then
		newhp = newhp/4
	end
	
	ent:SetMaxHealth( newhp )
	
	if ent:GetClass() == "prop_physics" then
		ent:SetHealth( 1 )
		
		-- If this prop was built by a player add it to the build over time table
		if ent.BuildTime ~= nil then
			GAMEMODE.BuildingProps[ent] = CurTime()
		end
		
		ent.BuildSound = CreateSound( ent, PropBuildingSound )
		ent.BuildSound:PlayEx( 0.25, 100 )
		ent:CallOnRemove( "StopBuildSound",
			function( ent )
				if ent and ent.BuildSound then ent.BuildSound:Stop() ent.BuildSound = nil end
			end
		)
	else
		ent:SetHealth( newhp )
	end
end

function GM:EntityTakeDamage( ent, dmginfo )
	local attacker, inflictor, amount = dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()
	if attacker:IsPlayer() and attacker:GetGod() then
		dmginfo:ScaleDamage( 0 )
		return
	end
	if ent:IsPlayer() then return end
	
	if GAMEMODE.BuildingProps[ent] then
		GAMEMODE.BuildingProps[ent] = nil
		ent:SetHealth( ent:Health() - 500 )
		if ent.BuildSound then ent.BuildSound:Stop() ent.BuildSound = nil end
		ent:BuildingSolidify()
		ent.CanRepair = true
		ent:SetRenderMode(RENDERMODE_NORMAL )
	end
	
	local class = ent:GetClass()
	if IsValid( inflictor ) then
		if inflictor:GetClass() == "sent_turret_mountable" or inflictor:GetClass() == "gmod_turret" or !table.HasValue( BreakableEntities, class ) then return end

		if inflictor:GetClass() == "sent_c4" or inflictor:GetClass() == "sent_rocket" or dmginfo:GetAmmoType() == 7 then
			amount = math.min( 2500, amount )
			
		elseif inflictor:GetClass() == "sent_explosivegrenade" then
			amount = math.min( 150, amount )
		else
			amount = math.min( 5, amount )
		end
	else
		amount = math.min( 5, amount )
	end

	if ent:GetMaxHealth() == 0 then
		self:SetEntHealth( ent )
	end

	local hp, max 	= ent:Health(), ent:GetMaxHealth()
	hp 				= hp -amount
	local c 		= 255 *(hp / max)
	ent:SetColor( Color(c,c,c,255) )

	if hp <= 0 then
		local pos = ent:LocalToWorld( ent:OBBCenter() )
		local gibs = ent:PrecacheGibs()
		
		if gibs > 0 then
			ent:Fire( "Break", "", 0 )
		else
			ent:Remove()
		end

		if gibs == 0 then
			if class == "prop_physics" then
				util.ScreenShake( pos, 5, 5, 1.5, 250 )
				local ed = EffectData()
					ed:SetStart( pos )
					ed:SetOrigin( pos )
					ed:SetScale( 1 )
				util.Effect( "HelicopterMegaBomb", ed ) 
				sound.Play( "ambient/explosions/explode_7.wav", pos, 100, 100, 1 )
			else
				local ed = EffectData()
					ed:SetStart( pos )
					ed:SetOrigin( pos )
					ed:SetScale( 1 )
				util.Effect( "cball_explode", ed )
				util.Effect( "ImpactJeep", ed )
				sound.Play( "physics/metal/metal_box_break1.wav", pos, 100, 100, 1 )
			end
		end

		if attacker:IsPlayer() then
			attacker:AddStatistic( "propsdestroyed", 1 )
		end

		return
	end

	ent:SetHealth( hp )
end

function GM:KeyPress( ply, key )
	if key == IN_JUMP then
		ply:AddStatistic( "jumps", 1 )
	elseif key == IN_DUCK then
		ply:AddStatistic( "crouches", 1 )
	end
end

function GM:ShowHelp( ply )
	if ply:GetInitialized() != INITSTATE_OK then return end
	ply:ConCommand( "sh_help" )
end

function GM:ShowTeam( ply )
	if ply:GetInitialized() != INITSTATE_OK then return end
	ply:ConCommand( "sh_teams" )
end

function GM:ShowSpare1( ply )
	if ply:GetInitialized() != INITSTATE_OK then return end
	ply:ConCommand( "sh_loadout" )
end

function GM:ShowSpare2( ply )
	ply:ConCommand( "sh_options" )
end

local function ForceSave( ply )
	if !IsValid( ply ) or ply:IsAdmin() then
		for _, v in ipairs( player.GetHumans() ) do
			v:SaveData()
		end

		MsgAll( "All player data saved.\n" )
	end
end
concommand.Add( "sh_forcesave", ForceSave )