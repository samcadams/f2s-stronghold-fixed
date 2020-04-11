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

local MAT_BLUR 		= Material( "pp/blurscreen" )
local MAT_BLURX 	= Material( "pp/blurx" )
local MAT_BLURY		= Material( "pp/blury" )
local MAT_DYING 	= Material( "blood/dying" )
local MAT_VIGNETTE 	= Material( "vignette" )

local TEX_BLOOM1 = render.GetBloomTex1()

-- ----------------------------------------------------------------------------------------------------

local BloodTime 		= 3.5
local BloodMagnitude 	= 0.01
local BloodSplatters 	= {}
function AddBloodSplatter()
	if not GAMEMODE.ConVars.PPBloodSplat:GetBool() then return end
	for i = 1, math.random( 0, 1 ) do
		local size = math.random( 1024, 2048 )
		
		table.insert( BloodSplatters, {
			x 		= math.random( 100, ScrW() -100 ),
			y 		= math.random( 200, ScrH() -200 ),
			w 		= size +math.random( 0, 50 ),
			h 		= size +math.random( 0, 50 ),
			ang 	= math.random( 0, 360 ),
			mat 	= surface.GetTextureID( "blood/bsplatv1" ),
			alpha 	= math.random( 50, 110 ),
			time 	= CurTime(),
		} )
	end
end

-- ----------------------------------------------------------------------------------------------------

function ScreenspaceBlur( scale )
	surface.SetMaterial( MAT_BLUR )	
	surface.SetDrawColor( 255, 255, 255, 255 )
		
	for i=1, 3 do
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
	end
	
	-- ----------
	
	--[[local rt = render.GetRenderTarget()

	MAT_BLURX:SetTexture( "$basetexture", rt )
	MAT_BLURY:SetTexture( "$basetexture", TEX_BLOOM1  )

	MAT_BLURX:SetFloat( "$size", 0.5 )
	MAT_BLURY:SetFloat( "$size", 0.5 )
	
	render.SetRenderTarget( TEX_BLOOM1 )
	render.SetMaterial( MAT_BLURX )
	render.DrawScreenQuad()

	render.SetRenderTarget( rt )
	render.SetMaterial( MAT_BLURY )
	render.DrawScreenQuad()]]
end

-- ----------------------------------------------------------------------------------------------------

function GM:ScreenEffectsThink()
	local ply 		= LocalPlayer()
	local curtime 	= CurTime()
	local hp 		= ply:Health()

	if !ply.LastHealth then
		ply.LastHealth 	= hp
		ply.LastHurt 	= 0
		ply.LastHeal 	= 0
		
		return
	end

	local delta = hp - ply.LastHealth

	if delta < 0 then
		if delta < -5 then AddBloodSplatter() end
		BloodMagnitude 	= math.Clamp( delta/-20, 0, 1 )
		ply.LastHurt 	= curtime
	elseif delta > 0 then
		ply.LastHeal = curtime
	end

	ply.LastHealth = hp
end

local SpawnProt 		= false
local SpawnProtTime 	= 0
local SpawnProtFadeTime = 0.25
hook.Add( "sh_spawnprotection", "cl_screeneffects", function( bProt )
	SpawnProt = bProt
	SpawnProtTime = CurTime()
end )

local Flashed = false
local FlashTime, FlashDuration = 0, 1
hook.Add( "sh_flashed", "cl_screeneffects", function( intTime )
	if not Flashed then
		FlashTime 		= CurTime()
		FlashDuration 	= intTime
	else
		FlashTime 		= FlashTime +intTime *0.7
		FlashDuration 	= FlashDuration +intTime
	end

	Flashed = true
end )
local fade = 1
local fadeset = false
local SmokeBlur = 0
local SmokeBlurTarget = 0
function GM:RenderScreenspaceEffects()
	local light 	= render.GetLightColor( LocalPlayer():EyePos() )
	local ply 		= LocalPlayer()
	local curtime 	= CurTime()
	local sw, sh 	= ScrW(), ScrH()
	
	if GAMEMODE.ConVars.PPHurtBlur:GetBool() and ply.LastHurt then
		for k, v in pairs( BloodSplatters ) do
			local b_scale = math.Clamp( -((curtime -v.time) /BloodTime) +1, 0, 1 )
			
			if b_scale <= 0 then
				BloodSplatters[k] = nil
			else
				surface.SetTexture( v.mat )
				surface.SetDrawColor( 0, 0, 0, (55 +v.alpha) *b_scale *light.y)
				surface.DrawTexturedRectRotated( v.x, v.y, v.w, v.h, v.ang )
			end
		end
		
		local scale = math.Clamp( -((curtime -ply.LastHurt) /(BloodTime *0.20)) +1, 0, 1 )
		if scale > 0 then
			surface.SetDrawColor( 100, 0, 0, 75 *scale *BloodMagnitude )
			surface.DrawRect( -1, -1, sw+1, sh+1 )
			DisableClipping( true )
				surface.SetMaterial( MAT_BLUR )	
				surface.SetDrawColor( 255, 255, 255, 255 )

				for i = 0.25, 0.50, 0.25 do
					MAT_BLUR:SetFloat( "$blur", scale *10 *i )
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRect( 0, 0, sw, sh )
				end
			DisableClipping( false )
		end
	end
	
	local colormod_brightness 	= 0
	local colormod_contrast_add = 0
	local colormod_color 		= 1
	
	if GAMEMODE.ConVars.PPSpawnProt:GetBool() and (SpawnProt or curtime-SpawnProtTime <= (SpawnProtFadeTime +0.05)) then
		colormod_contrast_add = colormod_contrast_add +0.20 *(SpawnProt and 1 or math.Clamp( -(curtime -SpawnProtTime) /SpawnProtFadeTime +1, 0, 1 ))
		colormod_color = (SpawnProt and 0) or math.Clamp( (curtime -SpawnProtTime) /SpawnProtFadeTime, 0, 1 )
	end
	
	if Flashed then
		if !ply:Alive() or curtime > FlashTime +FlashDuration +4 *(FlashDuration /8) then Flashed = false end
		local scale_w = math.Clamp( ((FlashTime -curtime) /FlashDuration) +1, 0, 1 )
		local scale_b = math.Clamp( ((FlashTime -curtime) /(FlashDuration +4 *(FlashDuration /8))) +1, 0, 1 )

		if scale_b > 0 then
			DrawBloom( 0.10, 1 *scale_b, 8 +12 *scale_b, 0, 8, 1 *scale_b, 1, 1, 1 )
		end
		
		if scale_w > 0 then
			local tbl = {}
			colormod_brightness = 0.60 *scale_w
			colormod_contrast_add = colormod_contrast_add +0.30 *scale_w

			surface.SetDrawColor( 255, 255, 255, 180 *scale_w )
			surface.DrawRect( -1, -1, sw+1, sh+1 )
		end
		
		if scale_b > 0 then
			DisableClipping( true )
				surface.SetMaterial( MAT_BLUR )	
				surface.SetDrawColor( 255, 255, 255, 255 *scale_b )
				
				for i = 0.25, 0.50, 0.25 do
					MAT_BLUR:SetFloat( "$blur", scale_b *10 *i )
					if render then render.UpdateScreenEffectTexture() end
					surface.DrawTexturedRect( 0, 0, sw, sh )
				end
			DisableClipping( false )
		end
	end
	
	local endmul = 0
	if GAMEMODE.GameOverRealTime ~= 0 then
		local fadeout = GAMEMODE.GameOverGraceTime - 2
		endmul = math.Clamp( (RealTime()-fadeout - GAMEMODE.GameOverRealTime) / 2, 0, 1 ) - math.Clamp( (RealTime()-(GAMEMODE.GameOverRealTime+GAMEMODE.GameOverGraceTime+1)) / 2, 0, 1 )
	end
	
	if colormod_brightness != 0 or colormod_contrast_add != 0 or colormod_color != 1 or endmul != 0 then
		local colormod = {}
		colormod["$pp_colour_addr"] 		= endmul
		colormod["$pp_colour_addg"] 		= endmul
		colormod["$pp_colour_addb"] 		= endmul
		colormod["$pp_colour_brightness"] 	= colormod_brightness
		colormod["$pp_colour_contrast"] 	= 1 +colormod_contrast_add
		colormod["$pp_colour_colour"] 		= colormod_color
		colormod["$pp_colour_mulr"] 		= 0
		colormod["$pp_colour_mulg"] 		= 0
		colormod["$pp_colour_mulb"] 		= 0
		
		DrawColorModify( colormod )
	end
	
	local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1+fade,
	["$pp_colour_colour"] = 1-fade*0.8 ,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
	}
	
	if LocalPlayer():Alive() then
		fade = math.Clamp(fade - FrameTime()*0.5,0,1)
		DrawColorModify( tab )
	return end
	fade = math.Clamp(fade + FrameTime()*0.5,0,1)
	DrawColorModify( tab )
	DrawBloom( 0.9, fade, 20 *fade, 0 , 8, 1 *fade, 1, 1, 1 )
	
	if SmokeBlur > 0 then
		surface.SetDrawColor( 0, 0, 0, 200 *SmokeBlur )
		surface.DrawRect( -1, -1, sw+1, sh+1 )
		--[[DisableClipping( true )
			surface.SetMaterial( MAT_BLUR )	
			surface.SetDrawColor( 255, 255, 255, 255 )

			for i = 0.50, 1, 0.50 do
				MAT_BLUR:SetFloat( "$blur", SmokeBlur *7 *i )
				--MAT_BLUR:SetFloat( "$size", SmokeBlur *7 *i )
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect( 0, 0, sw, sh )
			end
		DisableClipping( false )]]
		
		ScreenspaceBlur( SmokeBlur * 5 )
	end
	
	local hp = ply:Health()
	if hp > 0 and hp < 75 then
		local hpscale = -math.Clamp( ply:Health() /75, 0, 1 ) +1
		local hurtscale = (math.sin(RealTime() *8) +1) /2

		surface.SetDrawColor( 0, 0, 0, (50 +70 *hurtscale) *hpscale )
		surface.DrawRect( -1, -1, sw+1, sh+1 )
		surface.SetDrawColor( 255, 255, 255, (48 +60 *hurtscale) *hpscale )
		surface.SetMaterial( MAT_DYING )
		surface.DrawTexturedRect( 0, 0, sw, sh )
	end
	
	if GAMEMODE.ConVars.PPVignette:GetBool() then
		surface.SetMaterial( MAT_VIGNETTE )
		surface.SetDrawColor( 255, 255, 255, GAMEMODE.ConVars.PPVignetteOpacity:GetInt() )
		surface.DrawTexturedRect( 0, 0, sw, sh )
	end
	
	if self.GameOver then
		DisableClipping( true )
			--[[surface.SetMaterial( MAT_BLUR )	
			surface.SetDrawColor( 255, 255, 255, 255 )

			for i = 0.50, 1, 0.50 do
				MAT_BLUR:SetFloat( "$blur", 0.50 *7 *i )
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect( 0, 0, sw, sh )
			end]]
		DisableClipping( false )
	
		surface.SetFont( "DeathCamera" )
		local tw, th = surface.GetTextSize( "Game over!" )
		
		local endmul2 = math.Clamp( (RealTime()-(GAMEMODE.GameOverRealTime+GAMEMODE.GameOverGraceTime+1)) / 2, 0, 1 )
		
		local x, y, w, h = 0, math.floor(sh *0.10 -th *0.50 -10), sw, th +20
		surface.SetDrawColor( 0, 0, 0, 249*endmul2 )
		--surface.DrawRect( -1, -1, sw+1, sh+1 )
		surface.SetTexture(surface.GetTextureID( "vgui/gradient-r" ))
		surface.DrawTexturedRect( 0, y, w*0.5, h )
		surface.SetDrawColor( 0, 0, 0, 255*endmul2 )
		surface.SetTexture(surface.GetTextureID( "vgui/gradient-l" ))
		surface.DrawTexturedRect( ScrW()*0.5, y, w*0.5, h )
		--surface.SetDrawColor( 200, 200, 200, 255 )
		--surface.DrawRect( x, y +1, w, 1 )
		--surface.DrawRect( x, y +h -2, w, 1 )
		
		surface.SetTextColor( 255, 255, 255, 255*endmul2 )
		surface.SetTextPos( ScrW() *0.50 -tw *0.50, y +12 )
		surface.DrawText( "Game over!" )
		
		surface.SetFont( "Trebuchet24" )
		tw, th = surface.GetTextSize( self.GameOverWinner:Name().." - "..self.GameOverWinner:Frags().." kills." )
		surface.SetTextPos( ScrW() *0.50 -tw *0.50, sh*0.9 )
		surface.DrawText( self.GameOverWinner:Name().." - "..self.GameOverWinner:Frags().." kills." )
	end
end

local function DyingBlur( x, y, forward, spin )
	local ply = LocalPlayer()
	local hp = ply:Health()

	if hp > 0 and hp < 45 then
		local hpscale = -math.Clamp( ply:Health() /45, 0, 1 ) +1
		local hurtscale = (math.sin(RealTime() *8) +1) /2
		return 0, 0, 0.01 *hpscale *hurtscale, 0.002 *hpscale *hurtscale
	end
end
hook.Add( "GetMotionBlurValues", "DyingBlur", DyingBlur )

local function SmokeGrenadeBlur()
	local ply = LocalPlayer()
	local nade, dist = nil, -1

	for _, v in ipairs( ents.FindByClass("sent_smokegrenade") ) do
		local testdist = (v:GetPos() -ply:EyePos()):Length()
		if CurTime() -v.Created > 3 and v:WaterLevel() < 3 and (nade == nil or testdist < dist) then
			nade = v
			dist = testdist
		end
	end
	
	if dist != -1 then
		SmokeBlurTarget = math.Clamp( -(dist /275) +1, 0, 1 )
	else
		SmokeBlurTarget = 0
	end

	SmokeBlur = math.Approach( SmokeBlur, SmokeBlurTarget, (SmokeBlurTarget -SmokeBlur < 0 and 0.02 or 0.05) )
end
timer.Create( "SmokeGrenadeBlur", 0.10, 0, SmokeGrenadeBlur )