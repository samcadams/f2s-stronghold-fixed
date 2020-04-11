local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED, "Amount of time to show death notice" )

-- These are our kill icons
local Color_Icon = Color( 255, 80, 0, 255 ) 
local NPC_Color = Color( 250, 50, 50, 255 ) 
local Deaths = {}

local font_data = {
	["gbux_bigbold"] = {
		font 	= "DermaDefault",
		size 	= 14,
		weight 	= 700
	},
	["gbux_defaultbold"] = {
		font 	= "DermaDefault",
		size 	= 12,
		weight 	= 700
	},
	["gbux_default"] = {
		font 	= "DermaDefault",
		size 	= 12,
		weight 	= 500
	},
	["DeathCamera"] = {
		font 	= "calibri",
		size 	= 30,
		weight 	= 200
	},
}

local function PlayerIDOrNameToString( var )
	if type( var ) == "string" then 
		if var == "" then return "" end
		return "#"..var 
	end
	
	local ply = Entity( var )
	
	if ply == NULL then return "NULL!" end
	
	return ply:Name()
end

local function RecvPlayerKilledByPlayer( message )
	local victim 	= message:ReadEntity();
	local inflictor	= message:ReadString();
	local attacker 	= message:ReadEntity();
	local headshot 	= message:ReadBool();

	if !IsValid( attacker ) then return end
	if !IsValid( victim ) then return end
			
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team(), headshot )
end
usermessage.Hook( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )

local function RecvPlayerKilledSelf( message )
	local victim = message:ReadEntity();
	if !IsValid( victim ) then return end
	GAMEMODE:AddDeathNotice( nil, 0, "suicide", victim:Name(), victim:Team() )
end
usermessage.Hook( "PlayerKilledSelf", RecvPlayerKilledSelf )

local function RecvPlayerKilled( message )
	local victim 	= message:ReadEntity();
	if !IsValid( victim ) then return end
	local inflictor	= message:ReadString();
	local attacker 	= "#" .. message:ReadString();
			
	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim:Name(), victim:Team() )
end
usermessage.Hook( "PlayerKilled", RecvPlayerKilled )

local function RecvPlayerKilledNPC( message )
	local victimtype = message:ReadString();
	local victim 	= "#" .. victimtype;
	local inflictor	= message:ReadString();
	local attacker 	= message:ReadEntity();

	--
	-- For some reason the killer isn't known to us, so don't proceed.
	--
	if !IsValid( attacker ) then return end
			
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1 )
	
	local bIsLocalPlayer = (IsValid(attacker) && attacker == LocalPlayer())
	
	local bIsEnemy = IsEnemyEntityName( victimtype )
	local bIsFriend = IsFriendEntityName( victimtype )
	
	if bIsLocalPlayer && bIsEnemy then
		achievements.IncBaddies();
	end
	
	if bIsLocalPlayer && bIsFriend then
		achievements.IncGoodies();
	end
	
	if bIsLocalPlayer && (!bIsFriend && !bIsEnemy) then
		achievements.IncBystander();
	end
end
usermessage.Hook( "PlayerKilledNPC", RecvPlayerKilledNPC )

local function RecvNPCKilledNPC( message )
	local victim 	= "#" .. message:ReadString();
	local inflictor	= message:ReadString();
	local attacker 	= "#" .. message:ReadString();
			
	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1 )
end
usermessage.Hook( "NPCKilledNPC", RecvNPCKilledNPC )

--[[---------------------------------------------------------
   Name: gamemode:AddDeathNotice( Victim, Attacker, Weapon )
   Desc: Adds an death notice entry
-----------------------------------------------------------]]
function GM:AddDeathNotice( Victim, team1, Inflictor, Attacker, team2, headshot )
	local Death = {}
	Death.victim 	= 	Victim
	Death.attacker	=	Attacker
	Death.time		=	CurTime()
	
	Death.left		= 	Victim
	Death.right		= 	Attacker
	Death.icon		=	Inflictor
	Death.headshot	=	headshot or false
	
	if team1 == -1 then Death.color1 = table.Copy( NPC_Color ) 
	else Death.color1 = table.Copy( team.GetColor( team1 ) ) end
		
	if team2 == -1 then Death.color2 = table.Copy( NPC_Color ) 
	else Death.color2 = table.Copy( team.GetColor( team2 ) ) end
	
	if Death.left == Death.right then
		Death.left = nil
		Death.icon = "suicide"
	end
	
	table.insert( Deaths, Death )
end

local function DrawDeath( x, y, death, hud_deathnotice_time )
	local fadeout = ( death.time + hud_deathnotice_time ) - CurTime()
	
	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	death.color1.a = alpha
	death.color2.a = alpha
	
	surface.SetFont( "DeathCamera" )
	local weapon = weapons.Get( death.icon )
	local printname = "["..(weapon and weapon.PrintName or "Killed")..(death.headshot and " - HEAD]" or "]")
	local w, h = surface.GetTextSize( printname )
	
	-- Draw KILLER
	if death.left then
		draw.SimpleText( death.left, 	"DeathCamera", x - (w/2) - 15, y+1, 		Color(0,0,0,death.color1.a), 	TEXT_ALIGN_RIGHT )
		draw.SimpleText( death.left, 	"DeathCamera", x - (w/2) - 16, y, 		death.color1, 	TEXT_ALIGN_RIGHT )
	end
	
	-- Draw Weapon
	draw.SimpleText( printname, 	"DeathCamera", x+1, y+1, 						Color(0,0,0,death.color1.a), 	TEXT_ALIGN_CENTER )
	draw.SimpleText( printname, 	"DeathCamera", x, y, 						Color(180,180,180,death.color1.a), 	TEXT_ALIGN_CENTER )
	
	-- Draw VICTIM
	draw.SimpleText( death.right, 		"DeathCamera", x + (w/2) + 17, y+1, 		Color(0,0,0,death.color1.a), 	TEXT_ALIGN_LEFT )
	draw.SimpleText( death.right, 		"DeathCamera", x + (w/2) + 16, y, 		death.color2, 	TEXT_ALIGN_LEFT )
	
	return y + h * 1.20
end

function GM:DrawDeathNotice( x, y )

	local hud_deathnotice_time = hud_deathnotice_time:GetFloat()

	x = x * ScrW()
	y = y * ScrH()
	
	-- Draw
	for k, Death in pairs( Deaths ) do

		if (Death.time + hud_deathnotice_time > CurTime()) then
	
			if (Death.lerp) then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end
			
			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y
		
			y = DrawDeath( x, y, Death, hud_deathnotice_time )
		
		end
		
	end
	
	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for k, Death in pairs( Deaths ) do
		if (Death.time + hud_deathnotice_time > CurTime()) then
			return
		end
	end
	
	Deaths = {}

end
