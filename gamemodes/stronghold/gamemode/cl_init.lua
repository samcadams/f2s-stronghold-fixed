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
		cleaned code
]]--

--require( "datastream" )

--[[-------------------------------------------------------
  
  STRONGHOLD
  
---------------------------------------------------------]]

include( "glon.lua" ) -- Garry deleted glon - TODO: Use new File:WriteTable

include( "sh_compat.lua" )

include( "shared.lua" )
include( "cl_networking.lua" )
include( "entity_extension.lua" )
include( "player_extension.lua" )
include( "spawnmenu.lua" )
include( "playersounds.lua" )

include( "cl_skin.lua" )
include( "cl_hud.lua" )
include( "cl_hud_normal.lua" )
include( "cl_hud_slim.lua" )
include( "cl_deathnotice.lua" )
include( "cl_teams.lua" )
include( "cl_spawnmenu.lua" )
include( "cl_panels.lua" )
include( "cl_screeneffects.lua" )
include( "cl_hats.lua" )
include( "cl_mapmarkers.lua" )
include( "cl_weapons.lua" )
include( "sh_plugins.lua" )

include( "vgui/vgui_manifest.lua" )

-- Here we can add missing localization, Example: #worldspawn fix
language.Add( "worldspawn", "Gravity" )
language.Add( "env_explosion", "Explosion" )

-- Variables
-- Local client's info
GM.KillCam = {
	Active 		= false,
	StopTime 	= 0,
	Pos 		= Vector( 0, 0, 0 ),
	Killer 		= nil,
	LastKilled 	= 0
}

GM.Ragdolls = {}

function GM:Initialize()
	self:InitConVars()
	self:OptionsInit()
	self:TeamInit()
	self:LoadoutInit()
	self:HelpInit()
	self.LastAngles = 0

	self.Plugins:HandleHook( "Initialize" )
end

function GM:InitPostEntity()
	timer.Create(
		"sh_readyforinfo",
		5,
		0,
		function()
			if LocalPlayer():GetInitialized() == INITSTATE_ASKING then
				RunConsoleCommand( "sh_readyforinfo" )
			else
				timer.Remove( "sh_readyforinfo" )
			end
		end
	)
end

function GM.Reinitialize( ply, cmd, args )
	-- Why does this carry over
	GAMEMODE.GameOver = false

	Msg( "Reinitializing gamemode...\n" )
	GAMEMODE:Initialize()
	GAMEMODE:InitPostEntity()
end
concommand.Add( "gamemode_reinitialize_cl", GM.Reinitialize )
hook.Add( "OnReloaded", "Stronghold_AutoRefresh", GM.Reinitialize )

function GM:Think()
	local curtime = CurTime()
	
	-- Ragdolls
	--[[for i, tbl in ipairs( GAMEMODE.Ragdolls ) do
		if IsValid( tbl.ent ) then
			local scale = math.Clamp( (curtime - tbl.time), 0, 1 ) * -1 +1
			local alpha = 255 *scale
			tbl.ent:SetColor( Color(alpha,alpha,alpha,alpha) )
			tbl.ent:SetRenderMode( alpha < 255 and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL )
			
			if scale == 0 then
				table.remove( GAMEMODE.Ragdolls, i )
			end
		end
	end]]
	-- End Ragdolls
	self:WeaponsAttachedThink()
	-- Weapon switch
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if ply.LastWeapon != wep then
		self:PlayerSwitchWeapon( ply, wep )
		ply.LastWeapon = wep
	end
	-- End Weapon switch

	if self.CountDownEnd != -1 and curtime >= self.CountDownEnd then
		local lua_to_run = self.CountDownLua
		self.CountDownEnd = -1
		self.CountDownTitle = ""
		self.CountDownLua = ""
		
		if lua_to_run and lua_to_run != "" then
			RunString( lua_to_run )
		end
	end
	
	self:ScreenEffectsThink()
	self:HatEffectsThink()
	
	

	if LocalPlayer():KeyDown(IN_JUMP) and ply.JetPack then
		local effectdata = EffectData()
		effectdata:SetOrigin( ply:GetPos()+LocalPlayer():GetAngles():Up()*-30 )	
		effectdata:SetScale(1)
		effectdata:SetAngles(Angle(-90,0,0))
		--print(head:GetAngles())
		util.Effect( "silenced", effectdata )
	end
	--print(ply.JetPack)
end

function GM:CreateClientRagdoll(ply)
	local ragdoll = ClientsideRagdoll( ply:GetModel(),RENDERGROUP_OPAQUE )
	ragdoll:SetNoDraw( false )
	ragdoll:DrawShadow( true )
	ragdoll:SetModel( ply:GetModel() )
	ragdoll:SetColor(Color(255,255,255,255))
	ragdoll:SetPos( ply:GetPos() )
	ragdoll:SetAngles( ply:GetAngles() )
	ragdoll:Spawn()
	ragdoll:Activate()
	
	ragdoll:SetOwnerEnt( ply )
	
	ply:SetRagdollEntity( ragdoll )
	
	ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local vel = ply:GetVelocity()
	for index = 0, ragdoll:GetPhysicsObjectCount() do
		local pos, ang 		= ply:GetBonePosition( ragdoll:TranslatePhysBoneToBone(index) )
		local rd_physobj 	= ragdoll:GetPhysicsObjectNum( index )

		if IsValid( rd_physobj ) then
			rd_physobj:SetPos( pos )
			rd_physobj:SetAngles( ang )
			rd_physobj:SetVelocity( vel *(rd_physobj:GetMass() /85) *2 )
		end
	end
	
	for i = 1, ragdoll:GetPhysicsObjectCount() do
		ragdoll:GetPhysicsObjectNum( i -1 ):SetVelocity( ply:GetVelocity() )
	end
	
	--table.insert( GAMEMODE.Ragdolls, {ent = ragdoll, time = CurTime()} )
end

-- Various spawning functions
function GM:LimitHit( name )
	Msg( "You have hit the ".. name.. " limit!\n" )
	chat.AddText( Color(200,50,50,255), Localize("#SBoxLimit_"..name) )
	surface.PlaySound( "buttons/button10.wav" )
end

function GM:OnUndo( name, strCustomString )
	if self.GameOver then return end

	Msg( name.. " undone\n" )

	if !strCustomString then
		chat.AddText( Color(200,200,50,255), "#Undone_".. name )
	else	
		chat.AddText( Color(200,200,50,255), strCustomString )
	end

	surface.PlaySound( "buttons/button15.wav" )
end

function GM:RagdollThink()
	for _, pl in ipairs( player.GetAll() ) do
	if pl:Health() <=0 then
	pl.Dead = true
	else
	pl.Dead = false
	end
		if pl.Dead and !pl.Doll then
			self:CreateClientRagdoll(pl)
			pl.Doll = true
			timer.Simple(2, function() pl.JetPack = false end)
		elseif pl:GetRagdollEntity() != NULL and !pl.Dead  then
			pl:GetRagdollEntity():Remove()
			pl.Doll = false
		end
		if pl.JetPack and pl.Dead then
			local head=pl:GetRagdollEntity():GetPhysicsObjectNum( 1 )
			head:ApplyForceCenter( (head:GetAngles():Forward()*1200)*FrameTime()*100 )
			local BonePos, BoneAng 		= pl:GetRagdollEntity():GetBonePosition( pl:GetRagdollEntity():LookupBone("ValveBiped.Bip01_Spine2") )
			local effectdata = EffectData()
			effectdata:SetOrigin( BonePos+BoneAng:Right()*8 )	
			effectdata:SetScale(1)
			effectdata:SetAngles(head:GetAngles())
			--print(head:GetAngles())
			util.Effect( "silenced", effectdata )
		end
	end
end

-- Overly complex camera calculations
local WalkTimer 		= 0
local VelSmooth 		= 0
local LastStrafeRoll 	= 0
local BreathSmooth 		= 0
local BreathTimer 		= 0
local LastCalcView 		= 0
local LastOrigin 		= nil
local ZSmoothOn 		= false -- Experimental
local headfix			= 0
function GM:CalcView( ply, origin, angles, fov )

self:RagdollThink()
	if self.GameOver then
		return self.BaseClass:CalcView( ply, origin + Vector(0,0,36), angles, fov )
	end
	HType = {"ar2", "smg",}
	--Replaced complicated TehBigA cancer.
	if IsValid(ply:GetActiveWeapon()) then 
		if table.HasValue(HType,ply:GetActiveWeapon():GetHoldType()) then
			headfix = Lerp(FrameTime()*10,headfix,-5)
		else
			headfix = Lerp(FrameTime()*10,headfix,0)
		end
	end
	
	origin = origin + Vector(0,0,headfix)
	LastOrigin = origin

	if not ply:Alive() and IsValid( GAMEMODE.KillCam.Killer ) then
		if GAMEMODE.KillCam.Active then
			GAMEMODE.KillCam.StopTime 	= CurTime()
			GAMEMODE.KillCam.Pos 		= GAMEMODE.KillCam.Killer:LocalToWorld( GAMEMODE.KillCam.Killer:OBBCenter() )
		end
		
		if IsValid(ply:GetRagdollEntity()) then
			origin 		= ply:GetRagdollEntity():GetPos()+Vector(0,0,20)
			if GAMEMODE.KillCam.Killer != ply then
				angles 		= ( GAMEMODE.KillCam.Pos -ply:GetRagdollEntity():GetPos() ):Angle()
				fov 		= math.Max( 25, fov -((GAMEMODE.KillCam.StopTime-GAMEMODE.KillCam.LastKilled) *10) )
			end
		end
		local tr 	= util.TraceLine{start = origin, endpos = GAMEMODE.KillCam.Pos, filter = ply }
		if tr.Entity ~= GAMEMODE.KillCam.Killer and tr.HitWorld then
			GAMEMODE.KillCam.Active = false
		end
		
		return self.BaseClass:CalcView( ply, origin, angles, fov )
	elseif not ply:Alive() or IsValid( ply:GetVehicle() ) then
		return self.BaseClass:CalcView( ply, origin, angles, fov )
	end

	local vel 		= (ply:OnGround() and ply:GetVelocity() or Vector(1, 1, 1))
	local speed 	= vel:Length()
	local onground 	= 1
	local ang 		= ply:EyeAngles()
	local bob 		= Vector(10, 10, 10)	

	VelSmooth = (math.Clamp(VelSmooth *0.9 +speed *0.07, 0, 700 ))
	WalkTimer = (ply:OnGround() and (WalkTimer +VelSmooth *FrameTime() *0.04) or (WalkTimer +VelSmooth *FrameTime() *0.001))
	
	BreathSmooth = math.Clamp( BreathSmooth *0.9 +bob:Length() *0.07, 0, 700 )

	BreathTimer = 0--!ply:KeyDown(IN_ATTACK2) and BreathTimer +BreathSmooth *FrameTime() *0.04 or ply:KeyDown(IN_ATTACK2) and 0
	-- Roll on strafe (smoothed)
	LastStrafeRoll = (LastStrafeRoll *3) +(ang:Right():DotProduct( vel ) *0.0001 *VelSmooth *0.3 )
	LastStrafeRoll = LastStrafeRoll *0.18 -- Change this
	angles.roll = angles.roll +LastStrafeRoll
	
	local shakespeed, shakespeed2, violencescale, violencescale2

	if running then 
		shakespeed 		= 1.5
		shakespeed2 	= 6
		violencescale 	= 0.1
		violencescale2 	= 0.1
	else
		shakespeed 		= 1.2
		shakespeed2 	= 2.2
		violencescale 	= 0.5
		violencescale2 	= 0.2
	end

	if ply:GetGroundEntity() ~= NULL then	
		angles.roll 	= angles.roll +math.sin( WalkTimer *shakespeed ) *VelSmooth *(0.00006 *violencescale2) *VelSmooth
		angles.pitch 	= angles.pitch +math.cos( WalkTimer *shakespeed2 ) *VelSmooth *(0.000024 *violencescale) *VelSmooth
		angles.yaw 	 	= angles.yaw +math.cos( WalkTimer *shakespeed ) *VelSmooth *(0.000006 *violencescale) *VelSmooth
	end
	if !ply.DashDelta then ply.DashDelta = 0 end
	local RUNPOS 	= math.Clamp( ply:GetAimVector().z *30, -30, 50 )*ply.DashDelta
	local NEGRUNPOS = math.Clamp( ply:GetAimVector().z *-30, -30, 20 )*ply.DashDelta

	local ret 		= self.BaseClass:CalcView( ply, origin, angles, fov )
	local running 	= ply:KeyDown( IN_SPEED ) and ply:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) 	
	local scale 	= (running and 3 or 1) *0.01
	local wep 		= ply:GetActiveWeapon()
	--ply.LastAngles = vm_angles.yaw
	--ply.Output = ply.JerkStop
	return ret 
end

local SND_CHANNELCHANGE = Sound( "buttons/lightswitch2.wav" )
function GM:PlayerBindPress( ply, bind, pressed )

	if ply:Team() ~= 50 and string.find( string.lower(bind), "noclip" ) != nil then
		ply:EmitSound( SND_CHANNELCHANGE, 70, 100 )
		RunConsoleCommand( "sh_voice_channel", self.ConVars.VoiceChannel:GetInt() == 0 and 1 or 0 )
		
	end
end

function GM:EnableVotingSystem()
	g_MapVotingPanel:SetEnabled( true )
	GAMEMODE.HelpFrame.Sections:SetActiveTab( GAMEMODE.HelpFrame.Sections.Items[3].Tab )
	GAMEMODE.HelpFrame:Open()
	LocalPlayer():SendMessage( "Voting has begun!" )
end

hook.Add( "ChatText", "ChatTextHook", function( intPIndex, strName, strText, strMessageType )
	if string.find( strMessageType, "joinleave" ) then
		return true
	end
end )

local CHATHINT_MANDATORY, CHATHINT_MANDATORY_COUNT, CHATHINT_MANDATORY_PERCENT = { ["how"]=true, ["do"]=true, ["i"]=true, ["you"]=true, ["they"]=true }, 5, 0.40
local CHATHINT_TRIGGERS = { ["create"]=true, ["buy"]=true, ["get"]=true, ["make"]=true, ["place"]=true, ["play"]=true, ["spawn"]=true }
hook.Add( "OnPlayerChat", "ChatHook", function( ply, strText, bTeamOnly, bPlayerIsDead )
	if ply == LocalPlayer() then
		-- LocalPlayer stuff
		
		-- Hints
		local no_punc = string.gsub( strText, "[,.?!/]", "" )
		local mandatory, trigger = 0, false
		local explode = string.Explode( " ", no_punc )
		for _, v in ipairs(explode) do
			if CHATHINT_MANDATORY[v] then mandatory = mandatory + (1 / CHATHINT_MANDATORY_COUNT) end
			if CHATHINT_TRIGGERS[v] then trigger = true end
		end
		
		if trigger and mandatory >= CHATHINT_MANDATORY_PERCENT then
			timer.Simple(0.1, function()
				chat.AddText(Color(0,255,0),"Hint: ",Color(100,200,255),"Press F1 and view the tutorial if you don't know how to play.")
				chat.PlaySound()
			end )
		end
	end
end )