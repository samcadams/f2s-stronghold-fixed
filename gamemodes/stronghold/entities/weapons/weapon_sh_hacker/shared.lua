if (SERVER) then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_viewscreen.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "GIBSON PENETRATOR"
	SWEP.DrawCrosshair		= true
	SWEP.IconLetter 		= "m"
	SWEP.Slot 				= 0
	SWEP.ViewModelFlip		= false
	SWEP.DrawCrosshair		= true
	killicon.AddFont("weapon_sh_hacker", "HL2MPTypeDeath", SWEP.IconLetter, Color(200, 200, 200, 255))
	include( "cl_viewscreen.lua" )
end
SWEP.HoldType				= "physgun"
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel 			= "models/weapons/w_physics.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_AR2.Reload_Rotate")
SWEP.Primary.Damage 		= 25
SWEP.Primary.Recoil 		= 0.1
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "battery"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RKick					= 10
SWEP.RRise					= -0.01
SWEP.Heavy					= true
SWEP.ShootAnim				= 4
SWEP.DeployAnim				= 2
SWEP.ReloadAnim				= 5
SWEP.Origin					= Vector(0,0,0)
SWEP.Hacker					= true
SWEP.RunAngleSet			= "rpg"
SWEP.RDDraw 				= false
SWEP.AlwaysAnim				= true
SWEP.FireSelect				= 0

local LastFired = 0
local Cone = 0
SWEP.Rails = {
	["post"] = { 
	type = "Model", 
	model = "models/weapons/w_toolgun.mdl",  
	bone = "Base", 
	pos = Vector(0, 8.4, -17), 
	angle = Angle(90, 0,-90), 
	size = 2--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "HL2MPTypeDeath", x + wide*0.5, y + tall*0.1, Color( 255, 220, 0, 255 ), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

SWEP.VElements = {
}

function SWEP:ShootBullet( damage, num_bullets, aimcone )
	if !self.Owner:KeyDown(IN_ATTACK2) then return end
	self:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo(1)
	if CLIENT then
		self.FireOne = true
	end
	LastFired = CurTime()
end