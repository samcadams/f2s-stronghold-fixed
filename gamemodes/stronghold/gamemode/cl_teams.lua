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

team.SetUp( 50, "No Team", Color(250,250,0,255) )

GM.Team = {}
GM.Teams = {}
GM.Teams[50] = { Leader=nil, Name="No Team", Color=Color(250,250,0,255) }

-- local function TeamCreated( um )
-- 	local index = um:ReadShort()
-- 	local leader = um:ReadEntity() or nil
-- 	local name = um:ReadString() or "<No Name>"
-- 	local color = Color( um:ReadShort() or math.random(50,255), um:ReadShort() or math.random(50,255), um:ReadShort() or math.random(50,255), 255 )
-- 	GAMEMODE.Teams[index] = { Leader=leader, Name=name, Color=color }
-- 	team.SetUp( index, name, color )
-- end
-- usermessage.Hook( "sh_teamcreated", TeamCreated )
function GM.Team:TeamCreated( intIndex, pLeader, strName, colColor )
	GAMEMODE.Teams[intIndex] = { Leader=pLeader, Name=strName, Color=colColor }
	team.SetUp( intIndex, strName, colColor )
end

-- local function TeamDisbanded( um )
-- 	local index = um:ReadShort()
-- 	GAMEMODE.Teams[index] = nil
-- 	team.GetAllTeams()[index] = nil
-- end
-- usermessage.Hook( "sh_teamdisbanded", TeamDisbanded )
function GM.Team:TeamDisbanded( intIndex )
	if GAMEMODE.GameOver then return end -- Keep teams at the end for spectate info
	GAMEMODE.Teams[intIndex] 		= nil
	team.GetAllTeams()[intIndex] 	= nil
end

-- local function TeamLeaderChange( um )
-- 	local index = um:ReadShort()
-- 	if GAMEMODE.Teams[index] then
-- 		GAMEMODE.Teams[index].Leader = um:ReadEntity()
-- 	end
-- end
-- usermessage.Hook( "sh_teamleaderchange", TeamLeaderChange )
function GM.Team:TeamLeaderChange( intIndex, pLeader )
	if GAMEMODE.Teams[intIndex] then
		GAMEMODE.Teams[intIndex].Leader = pLeader
	end
end

//Config
//Thanks to Lt.Smith.. who kinda stole this code off me in the first place.. and then modified it a little.. but it's all okay, because now I stole it back and used it for what I needed =)

local enablenames = true
local enabletitles = true
local textalign = 1
// Distance multiplier. The higher this number, the further away you'll see names and titles.
local distancemulti = 2

////////////////////////////////////////////////////////////////////
// Don't edit below this point unless you know what you're doing. //
////////////////////////////////////////////////////////////////////

function DrawNameTitle()

	local vStart = LocalPlayer():GetPos()
	local vEnd
	local ply = LocalPlayer()

	for k, v in pairs(player.GetAll()) do
		if (ply:Team() == v:Team()) and ply:Team() != 50 then
			local vStart = LocalPlayer():EyePos()
			local vEnd = v:EyePos()
			local trace = {}
			
			trace.start = vStart
			trace.endpos = vEnd
			local trace = util.TraceLine( trace )
			
			if trace.HitWorld then
				--Do nothing!
			else
				local mepos = LocalPlayer():GetPos()
				local tpos = v:GetPos()
				local tdist = mepos:Distance(tpos)
				
				if tdist <= 3000 then
					local zadj = 0.03334 * tdist
					local pos = v:GetPos() + Vector(0,0,v:OBBMaxs().z + 5 + zadj)
					pos = pos:ToScreen()
					
					local alphavalue = (200 * distancemulti) - (tdist/1.5)
					alphavalue = math.Clamp(alphavalue, 0, 255)
					
					local outlinealpha = (150 * distancemulti) - (tdist/2)
					outlinealpha = math.Clamp(outlinealpha, 0, 255)
					
					local playercolour = team.GetColor(v:Team())
					local playertitle = string.Left( team.GetName(v:Team()), 16 )
					
					if ( (v != LocalPlayer()) and (v:GetNWBool("exclusivestatus") == false) ) then
						if (enablenames == true) then
							draw.SimpleTextOutlined(v:Name(), "TargetID", pos.x, pos.y - 10, Color(playercolour.r, playercolour.g, playercolour.b, alphavalue),textalign,1,2,Color(0,0,0,outlinealpha))
						end
						if (not (playertitle == "")) and (enabletitles == true) then
							draw.SimpleTextOutlined(playertitle, "Trebuchet18", pos.x, pos.y + 6, Color(255,255,255,alphavalue),textalign,1,1,Color(0,0,0,outlinealpha))
						end
					end
				end
			end
		end
	end
end
hook.Add("HUDPaint", "DrawNameTitle", DrawNameTitle)

function TeamMateHUDPaint()
	local teamIndex = LocalPlayer():Team()
	local tc = team.GetColor( teamIndex )

	for _, v in ipairs(player.GetAll()) do
		if teamIndex != 50 and v:Team() == teamIndex then
			local pos = v:LocalToWorld( v:OBBCenter() )
			local sPos = pos:ToScreen()
			local pDist = (LocalPlayer():GetPos()-pos):Length()
			local fade = math.Clamp( pDist-500, 0, 210 )
			if v != LocalPlayer() then
				local vStart = LocalPlayer():EyePos()
				local vEnd = v:EyePos()
				local trace = {}
				trace.start = vStart
				trace.endpos = vEnd
				local trace = util.TraceLine( trace )
			
				if trace.HitWorld then
					draw.RoundedBox( 4, sPos.x-4, sPos.y-4, 8, 8, Color(20,20,20,210) )
					draw.RoundedBox( 2, sPos.x-2, sPos.y-2, 4, 4, Color(tc.r,tc.g,tc.b,210) )
				elseif pDist > 500 then
					draw.RoundedBox( 4, sPos.x-4, sPos.y-4, 8, 8, Color(20,20,20,fade) )
					draw.RoundedBox( 2, sPos.x-2, sPos.y-2, 4, 4, Color(tc.r,tc.g,tc.b,math.Clamp(fade-30,0,210 )) )
				end
			end
		end
	end
end
hook.Add( "HUDPaint", "TeamMateHUDPaint", TeamMateHUDPaint )
