if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "MAC 10 .45"
	SWEP.IconLetter 		= "l"
	SWEP.Slot 				= 1
	killicon.AddFont("weapon_sh_mac10-45", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
SWEP.Spawnable 				= true
SWEP.Base 					= "weapon_sh_mac11-380"
SWEP.Primary.Recoil 		= 0.2
SWEP.Primary.Damage 		= 13
SWEP.Primary.Delay 			= 0.06 
SWEP.Subsonic				= true
--SWEP.DotVis					= false