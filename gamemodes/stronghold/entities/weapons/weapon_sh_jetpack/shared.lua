if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "Jump Pack"
	SWEP.IconLetter 		= ""

	killicon.AddFont("weapon_sh_ak47", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/thrusters/jetpack.mdl"
SWEP.WorldModel 			= "models/thrusters/jetpack.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_AK47.Single")
SWEP.DistantSound			= "ak.mp3"
SWEP.Primary.Damage 		= 25
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.005
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RKick					= 10
SWEP.RRise					= -0.01
SWEP.ADSPos 				= Vector (6.0776, -5, 2.35)
SWEP.ADSAngle 				= Angle (0.065, 0, 2.5)
SWEP.BoltBone				= "AK47_Bolt"
SWEP.EjectPos				= Vector(5,-3.5,10)
SWEP.EjectDir				= Vector(1,0,0)
SWEP.Heavy					= true
SWEP.ShootAnim				= 1
SWEP.DeployAnim				= 4
SWEP.ReloadAnim				= 5
SWEP.Origin					= Vector(-3,2.5,-3)
SWEP.AttachVector			= Vector(1,5,7)
SWEP.AttachAngle			= Angle(180,95,270)

function SWEP:Initialize()
	if SERVER then
	timer.Simple( 1, function() self:Remove() end )
	end
	self.Owner.JetPack = true
end