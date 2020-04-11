local GRENADE_COOK_TIME = 2

if SERVER then
	AddCSLuaFile ("shared.lua")
	SWEP.Weight 			= 1
	SWEP.AutoSwitchTo 		= false
	SWEP.AutoSwitchFrom 	= false
end

if CLIENT then
	SWEP.PrintName 			= "FLASH GRENADE"
	SWEP.DrawAmmo 			= true
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV		= 65
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false

	SWEP.IconLetter 		= "P"
	killicon.AddFont( "weapon_sh_flash", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Base 					= "weapon_sh_grenade"
SWEP.ViewModel 				= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel 			= "models/weapons/w_eq_flashbang.mdl"

SWEP.ThrowForce					= 2000
SWEP.GrenadeClass			= "sent_flashgrenade"

SWEP.ShootAnim				= 1
SWEP.DeployAnim				= 6
SWEP.ReloadAnim				= 5