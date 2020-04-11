--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	GM13 Changes
	
	Added:
		hook sh_hitdetection(nil)
	Removed:
	Updated:
		net code
		surface.CreateFont now uses font data
	Changed:
		cleaned code
]]--

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
	["Large"] = {
		font 	= "calibri",
		size 	= 100,
		weight 	= 200
	},
}

surface.CreateFont( "gbux_bigbold", 	font_data.gbux_bigbold )
surface.CreateFont( "gbux_defaultbold", font_data.gbux_defaultbold )
surface.CreateFont( "gbux_default", 	font_data.gbux_default )
surface.CreateFont( "DeathCamera", 		font_data.DeathCamera )
surface.CreateFont( "Large", 		font_data.Large )

local TEX_GRADIENT_TOP		= surface.GetTextureID( "vgui/gradient-u" )
local TEX_GRADIENT_BOTTOM	= surface.GetTextureID( "vgui/gradient-d" )
local TEX_HITDETECTION		= surface.GetTextureID( "hitdetection2" )

-- Hint stuff
GM.HintBar				= {}
GM.HintBar.CurColor		= 1 -- Using a color index for cached colors above
GM.HintBar.CurMsg		= ""
GM.HintBar.LastColor	= 1 -- ^
GM.HintBar.LastMsg		= ""
GM.HintBar.LastChange	= 0
GM.HintBar.FadeTime		= 2.00

-- Cached colors
GM.CachedColors 	= {}
GM.CachedColors[1] 	= Color( 255, 255, 255, 255 ) -- White
GM.CachedColors[2] 	= Color( 127, 127, 127, 255 ) -- Grey
GM.CachedColors[3] 	= Color( 255,   0,   0, 255 ) -- Red
GM.CachedColors[4] 	= Color(   0, 255,   0, 255 ) -- Green
GM.CachedColors[5] 	= Color(   0,   0, 255, 255 ) -- Blue
GM.CachedColors[6] 	= Color( 255, 255,   0, 255 ) -- Yellow
GM.CachedColors[7] 	= Color( 255, 128,   0, 255 ) -- Orange
GM.CachedColors[8] 	= Color(   0, 128, 255, 255 ) -- Teal
GM.CachedColors[9] 	= Color(   0, 255, 255, 255 ) -- Aqua
GM.CachedColors[10]	= Color( 255,   0, 255, 255 ) -- Violet

-- Hit detection stuff
GM.HitDetection					= {}
GM.HitDetection.HitTime			= 0
GM.HitDetection.HitTimeDuration	= 0.10

-- --------------------------------------------------------------------------------------------------------------
--[[ Hide things we don't want ]]--

local BlockedHUDElements = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudCrosshair" }
function GM:HUDShouldDraw( element )
	return !table.HasValue( BlockedHUDElements, element )
end

function GM:HUDDrawTargetID() end

-- --------------------------------------------------------------------------------------------------------------
--[[ Things that always draw ]]--

function GM:HUDPaint()
	if self.GameOver then return end
	local x, y = 5, 100

	self.BaseClass:HUDPaint()
	
	if not IsValid( LocalPlayer() ) then return end

	local initstate = LocalPlayer():GetInitialized()
	if initstate == INITSTATE_OK then
		if GAMEMODE.ConVars.HUDEnabled:GetBool() then
			if GAMEMODE.ConVars.HUDMinimal:GetInt() == 2 then
				self.Huds.Slim:Paint( self )
			elseif GAMEMODE.ConVars.HUDMinimal == 3 then
				--self.Huds.Minimum:Paint( self )
			else
				self.Huds.Normal:Paint( self )
			end
		end
		self:DrawHitIndicator()
		self:DrawKillCam()
	end
	self:DrawWaitingInfo( initstate )
	self.Map:PaintMarkers()
	self:GetVersion()
	self:Compass()
end

function GM:Compass()
	if !GAMEMODE.ConVars.HUDCompass:GetBool() then return end
	local colComp = Color(
		self.ConVars.HUDComRed:GetFloat(), 
		self.ConVars.HUDComGreen:GetFloat(),
		self.ConVars.HUDComBlue:GetFloat(),
		255
	)
	local Speed = GAMEMODE.ConVars.HUDComSpeed:GetFloat()
	local TickDist = GAMEMODE.ConVars.HUDComTD:GetFloat()
	local Hight = GAMEMODE.ConVars.HUDComPosY:GetFloat()
	local Width = GAMEMODE.ConVars.HUDComPosX:GetFloat()
	local EyeAngle = LocalPlayer():EyeAngles().yaw*Speed
	local Alpha = 1-math.abs((EyeAngle)/180)
	local addline, addline2, encircle, longtick = 0,0,0,0
	local Degrees = math.Round(180-(EyeAngle/Speed))
	local Center = Degrees > 99 and 10 or Degrees > 9 and 6 or 3
	draw.SimpleText("^","DebugFixed",ScrW()*Width-3,ScrH()*(Hight),Color( colComp.r, colComp.g, colComp.b, 255 ))
	draw.SimpleText(Degrees,"DebugFixed",ScrW()*Width-Center,ScrH()*Hight+5,Color( colComp.r, colComp.g, colComp.b, 255 ))
	surface.SetDrawColor( colComp.r, colComp.g, colComp.b, 255 *Alpha )--255, 255, 255, 255*Alpha )
	draw.SimpleText("S","DebugFixed",(EyeAngle-4)+ScrW()*Width,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
	surface.DrawLine(EyeAngle+ScrW()*Width, ScrH()*Hight, EyeAngle+ScrW()*Width, ScrH()*(Hight-0.01))
	
	for i=1, 36*Speed do
		addline = math.Round(addline + 10/(Speed/TickDist))
		encircle = EyeAngle + addline*Speed
		Alpha = 1-math.abs((encircle)/(180))
		
		if addline == 90 or addline == 180 or addline == 270 then 
			longtick = 0.01
			if addline == 90 then 
				draw.SimpleText("E","DebugFixed",(EyeAngle-4)+ScrW()*Width+addline*Speed,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
			elseif addline == 180 then
				draw.SimpleText("N","DebugFixed",(EyeAngle-4)+ScrW()*Width+addline*Speed,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
			elseif addline == 270 then
				draw.SimpleText("W","DebugFixed",(EyeAngle-4)+ScrW()*Width+addline*Speed,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
			end
		else 
			longtick = 0.005 
		end
		
		surface.SetDrawColor( colComp.r, colComp.g, colComp.b, 255 *Alpha )--255, 255, 255, 255*Alpha )
		surface.DrawLine(EyeAngle+ScrW()*Width+addline*Speed, ScrH()*Hight, EyeAngle+ScrW()*Width+addline*Speed, ScrH()*(Hight-longtick))
	end

	for i=1, 36*Speed do
		addline2 = math.Round(addline2 - 10/(Speed/TickDist))
		encircle = EyeAngle + addline2*Speed
		Alpha = 1-math.abs((encircle)/(180))
		
		if addline2 == -90 or addline2 == -180 or addline2 == -270 then 
			longtick = 0.01
			if addline2 == -90 then 
				draw.SimpleText("W","DebugFixed",(EyeAngle-4)+ScrW()*Width+addline2*Speed,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
			elseif addline2 == -180 then
				draw.SimpleText("N","DebugFixed",(EyeAngle-4)+ScrW()*Width+addline2*Speed,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
			elseif addline2 == -270 then
				draw.SimpleText("E","DebugFixed",(EyeAngle-4)+ScrW()*Width+addline2*Speed,ScrH()*(Hight-0.024),Color( colComp.r, colComp.g, colComp.b, 255*Alpha ))
			end
		else 
			longtick = 0.005 
		end
		
		surface.SetDrawColor( colComp.r, colComp.g, colComp.b, 255 *Alpha )--255, 255, 255, 255*Alpha )
		surface.DrawLine(EyeAngle+ScrW()*Width+addline2*Speed, ScrH()*Hight, EyeAngle+ScrW()*Width+addline2*Speed, ScrH()*(Hight-longtick))
	end
end

local Fetched
local Recieved
function GM:GetVersion()
	--if !LocalPlayer():IsAdmin() then return end
		local Compare = function( strBody, intLen, tblHeaders, intCode )
		self.CurVersion = strBody
	end
		local Changes = function( strBody, intLen, tblHeaders, intCode )
		self.Changes = strBody
	end
	local x,y = 5,50
	if self.CurVersion != self.Version and self.CurVersion then
	local pulse = math.sin(RealTime()*10)+1
	--print(pulse)
		draw.SimpleText("Server out of date!","Default",GAMEMODE.ConVars.GBux_Offset:GetInt()+x+1,y+1,Color(0,0,0))
		draw.SimpleText("Server out of date!","Default",GAMEMODE.ConVars.GBux_Offset:GetInt()+x,y,Color(255,255*pulse,255*pulse))
		
		draw.SimpleText("This version:       " .. self.Version,"Default",GAMEMODE.ConVars.GBux_Offset:GetInt()+x+1,y+11,Color(0,0,0))
		draw.SimpleText("This version:       " .. self.Version,"Default",GAMEMODE.ConVars.GBux_Offset:GetInt()+x,y+10,Color(255,0,0))
		
		draw.SimpleText("Current Version: " .. self.CurVersion,"Default",GAMEMODE.ConVars.GBux_Offset:GetInt()+x+1,y+21,Color(0,0,0))
		draw.SimpleText("Current Version: " .. self.CurVersion,"Default",GAMEMODE.ConVars.GBux_Offset:GetInt()+x,y+20,Color(0,150,0))
		
	
	
		local ply = LocalPlayer()
		if !self.Checked then 
			chat.AddText( Color(200,0,0),"Server out of date!")
			chat.AddText( Color(0,200,0),self.CurVersion .." Changes: ",Color(200,200,200), self.Changes )
			self.Checked = true
		end
	end
	
	local Fail = function(intCode)
		print(intCode)
	end
	
	if !Fetched then
		http.Fetch("http://www.roaringcow.com/PDT/F2S_Version.txt", Compare, Fail )
		http.Fetch("http://www.roaringcow.com/PDT/F2S_Changes.txt", Changes, Fail )
		Fetched = true
	end
end
concommand.Add("sh_getversion", GM.GetVersion)
local InfoFade = 255
local headbob = 0
local headturn = 0
local blink = 0
local blinktimer = 0
function GM:DrawWaitingInfo( state )
	headbob = (headbob+(FrameTime()*5))
	headturn = (headturn+(FrameTime()*2.5))
	local str
	if state == INITSTATE_WAITING then
		str = "Receiving Information"
	else
		str = "Requesting Information"
	end
	
	if state == INITSTATE_OK then
		InfoFade = Lerp(FrameTime()*2,InfoFade,0)
		str = "Information Received"
	end
	blinktimer = blinktimer+(FrameTime()*math.Rand(0,1))
	if blinktimer >1 then
		blink = 1
	end
	if blinktimer >1.1 then
		blink = 0
		blinktimer = 0
	end
	surface.SetFont( "Large" )
	local tw, th = surface.GetTextSize( str )
	if not tw then return end --!!!!!!
	
	local sw, sh = ScrW(), ScrH()
	local x, y, w, h = 0, math.floor(sh*0.50-th*0.50-10), sw, th+30
	surface.SetDrawColor( 255, 255, 255, InfoFade ) 
	surface.DrawRect( 0, 0, sw, sh )
	
	surface.SetTextColor( 0, 0, 0, InfoFade )
	surface.SetTextPos( sw*0.50-tw*0.50, sh*0.1 )
	surface.DrawText( str ) 
	
	
	
	surface.SetDrawColor( 255, 255, 255, InfoFade*0.5 )
	surface.SetTexture(surface.GetTextureID("vignette") )
	surface.DrawTexturedRectRotated(
		ScrW()*0.50,
		ScrH()*0.50, 
		ScrW(),
		ScrH(), 
		0
	)
	surface.SetDrawColor( 255, 255, 255, InfoFade )	
	surface.SetTexture(surface.GetTextureID("stronghold/cowbody") )
	surface.DrawTexturedRectRotated(
		ScrW()*0.50,
		ScrH()*0.50, 
		ScrH()/3,
		ScrH()/3,
		0
	)
	surface.SetTexture(surface.GetTextureID("stronghold/cowhead") )
	surface.DrawTexturedRectRotated(
		ScrW()*0.50,
		(ScrH()/2)+math.sin(headbob)*0,
		ScrH()/3,
		ScrH()/3,
		math.sin(headturn)
	)
	surface.SetDrawColor( 255, 255, 255, InfoFade*blink )
	surface.SetTexture(surface.GetTextureID("stronghold/cowblink") )
	surface.DrawTexturedRectRotated(
		ScrW()*0.50,
		(ScrH()/2)+math.sin(headbob),
		ScrH()/3,
		ScrH()/3,
		math.sin(headturn)
	)
	--print(blinktimer) 
end

function GM:DrawHitIndicator()
	local delta = CurTime() - GAMEMODE.HitDetection.HitTime
	if delta > GAMEMODE.HitDetection.HitTimeDuration or not GAMEMODE.ConVars.HitIndicator:GetBool() then return end
	
	surface.SetTexture( TEX_HITDETECTION )
	surface.SetDrawColor(
		GAMEMODE.ConVars.HitRed:GetInt(),
		GAMEMODE.ConVars.HitGreen:GetInt(),
		GAMEMODE.ConVars.HitBlue:GetInt(),
		( (-delta/GAMEMODE.HitDetection.HitTimeDuration) + 1 ) * 255
	)
	surface.DrawTexturedRect(
		ScrW()*0.50-math.Clamp(16+(delta*300),16,32),
		ScrH()*0.50-math.Clamp(16+(delta*300),16,32),
		math.Clamp(32+(delta*600),32,64),
		math.Clamp(32+(delta*600),32,64)
	)
end

local SpawnDelay = 0
hook.Add( "sh_spawndelay", "cl_hud", function( bDelay )
	SpawnDelay = bDelay
end )
hook.Add( "HUDShouldDraw", "RemoveRedScreenOnDeath", function( name ) 
    if ( name == "CHudDamageIndicator" ) then 
        return false 
    end 
end )
local killerwep = nil
function GM:DrawKillCam()
	local killer = GAMEMODE.KillCam.Killer
	local sw, sh = ScrW(), ScrH()
	local x, y, w, h = math.floor(sw*0.50)-400, math.floor(sh*0.65)+30, 800, 30
	if !IsValid( killer ) then killerwep = nil return end
	if !killerwep then
	killerwep = killer:GetActiveWeapon().PrintName
	end
	if killer == LocalPlayer() then
		killerwep = "Suicide"
	end
	
	local RespawnTime = GAMEMODE.KillCam.LastKilled + SpawnDelay
	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( 0, sh*0.65, sw, 50 )
	if RespawnTime > CurTime() then
		local str = "Respawn in: "..math.floor(RespawnTime - CurTime() + 1).." Seconds"
		surface.SetFont( "DeathCamera" )
		local tw, th = surface.GetTextSize( str )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( sw*0.50-tw*0.50, sh*0.80-th*0.50 )  
		surface.DrawText( str )
		surface.SetTextColor( 255, 50, 50, 255 )
		surface.SetTextPos( sw*0.50-tw*0.50-1, sh*0.80-th*0.50-1 )
		surface.DrawText( str )
	else
		local str = "Click or press Spacebar to spawn."
		surface.SetFont( "DeathCamera" )
		local tw, th = surface.GetTextSize( str )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( sw*0.50-tw*0.50, sh*0.80-th*0.50 )
		surface.DrawText( str )
		surface.SetTextColor( 50, 255, 50, 255 )
		surface.SetTextPos( sw*0.50-tw*0.50-1, sh*0.80-th*0.50-1 )
		surface.DrawText( str )
	end
	
	local str = "You were killed by "..(killer.GetName and killer:GetName() or killer:GetClass())
	surface.SetFont( "DeathCamera" )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.SetTextPos( x, y-32 )
	surface.DrawText( str )
	surface.SetTextPos( x-1, y-32-1 )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.DrawText( str )
	surface.SetTextPos( x+tw+1, y-32+1 )
	surface.SetTextColor( 0, 0, 0, 255 )
	if killerwep then
	surface.DrawText( " - "..killerwep )
	end
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( x+tw, y-32 )
	surface.DrawText( " - "..killerwep )
	local hp, hpmax = math.max(0,killer:Health()), (killer:IsPlayer() and 100 or killer:GetMaxHealth())
	local scale = math.Clamp( hp/ hpmax, 0, 1 )
	
	draw.RoundedBox( 2, x, y, w, h-15, Color(20,20,20,150) )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( x+5, y+5, w-10, h-25 )
	surface.SetDrawColor( 255*(-scale+1), 255*scale, 0, 200 )
	surface.DrawRect( x+5, y+5, (w-10)*scale, h-25 )
	
	surface.SetFont( "Trebuchet19" )
end

local PlayerVoicePanels = nil
function GM:PlayerStartVoice( ply )
	if !IsValid( g_VoicePanelList ) then return end
	
	-- Damnit Garry...
	if PlayerVoicePanels == nil then
		_, PlayerVoicePanels = debug.getupvalue( self.BaseClass.PlayerStartVoice, 1 )
	end
	
	-- There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )
	
	if IsValid( PlayerVoicePanels[ply] ) then
		if PlayerVoicePanels[ply].fadeAnim then
			PlayerVoicePanels[ ply].fadeAnim:Stop()
			PlayerVoicePanels[ply].fadeAnim = nil
		end
		
		PlayerVoicePanels[ ply ]:SetAlpha( 255 )
		
		return
	end
	
	if !IsValid( ply ) then return end
	
	local pnl = g_VoicePanelList:Add( "sh_voicenotify" )
	pnl:Setup( ply )
	
	PlayerVoicePanels[ply] = pnl
end