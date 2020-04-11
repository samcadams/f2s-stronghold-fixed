if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
elseif (CLIENT) then
	SWEP.PrintName 		= "M3 SUPER 90"
	SWEP.IconLetter 	= "k"
	SWEP.Slot 			= 1
	killicon.AddFont("weapon_sh_pumpshotgun2", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
SWEP.Base 					= "weapon_sh_pumpshotgun"
