if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "D.EAGLE .44"
	SWEP.IconLetter 		= "f"
	SWEP.Slot 				= 1
	killicon.AddFont("weapon_sh_deagle", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
SWEP.HoldType				= "revolver"
SWEP.MuzzleAttachment		= "1" 
SWEP.MuzzleEffect			= "rifle"
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_deagle.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage 		= 25
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 8
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.DefaultClip 	= 8
SWEP.Primary.Recoil 		= 0.4
SWEP.RRise					= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.ADSPos 				= Vector (5.1465, 0.0193, 2.6677)
SWEP.ADSAngle 				= Angle (0.035, 0, 0.19)
SWEP.DistantSound			= "deagle.mp3"
SWEP.BoltBone				= "Deagle_Slide"
SWEP.EjectPos				= Vector(5,-3,5)
SWEP.EjectDir				= Vector(-0.2,1,0)
SWEP.GunBone				= "Deagle_Parent"
SWEP.SlideLockPos			= Vector(0,0,-1.5)
SWEP.DotVis					= -1
SWEP.ShootAnim				= 2
SWEP.DeployAnim				= 5
SWEP.ReloadAnim				= 4
SWEP.RunAngleSet			= "pistol"
SWEP.FireSelect				= 0
SWEP.Effect					= "MuzzleFlash1"
SWEP.ShellSize				= 0
SWEP.Attach					= "ValveBiped.Bip01_R_Thigh"
SWEP.AttachVector			= Vector(-5.5,4,-4)
SWEP.AttachAngle			= Angle(0,90,0)

SWEP.VElements = {
	["suppressor"] = { 
	type = "Model", 
	model = "models/weapons/suppressor.mdl",  
	bone = "v_weapon.Deagle_Parent", 
	pos = Vector(0, 3, 6.8), 
	angle = Angle(-90, -90, 0), 
	size = 0.8, 
	color = Color(255, 255, 255, 255), 
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rds"] = { 
	type = "Model", 
	model = "models/weapons/mrds.mdl",  
	bone = "v_weapon.Deagle_Slide", 
	pos = Vector(3.28, -1.7, 0), 
	angle = Angle(90,90,0),
	AuxIronSightsPos = Vector (5.1465, 0.0193, 2.5),
	AuxIronSightsAng = Vector (0.035, 0, 0.19),
	size = 0.13, 
	color = Color(255, 255, 255, 255), 
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}