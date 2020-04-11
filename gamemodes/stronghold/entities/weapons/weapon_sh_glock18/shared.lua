if (SERVER) then
	AddCSLuaFile("shared.lua")
	
elseif (CLIENT) then
	SWEP.PrintName 			= "GLOCK 18"
	SWEP.IconLetter 		= "c"
	SWEP.Slot 				= 1
	killicon.AddFont("weapon_sh_glock18", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
	

SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_glock18.mdl"
SWEP.HoldType				= "revolver"
SWEP.Primary.ClipSize		= 19
SWEP.Spread					= 0.01
SWEP.ADSPos					= Vector(4.33,0,2.79)
SWEP.ADSAngle				= Angle(0.05,0,0.7)
SWEP.BoltBone				= "Glock_Slide"
SWEP.SlideLockPos			= Vector(1.2,-0.35,0.05)
SWEP.Primary.Sound 			= Sound("Weapon_Glock.Single")
SWEP.Primary.Damage 		= 10
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Delay 			= 0.05
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Primary.Recoil			= 0.2
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.FireSelect				= 1
SWEP.RRise					= 0.005
SWEP.DistantSound			= "glock.mp3"
SWEP.BoltBone				= "Glock_Slide"
SWEP.Subsonic				= true
SWEP.SlideLockPos			= Vector(1.2,-0.35,0.05)
SWEP.DotVis					= -0.9
SWEP.ShootAnim				= 4
SWEP.DeployAnim				= 5
SWEP.ReloadAnim				= 6
SWEP.RunAngleSet			= "pistol"
SWEP.Pistol					= true
SWEP.EjectPos				= Vector(4,-3.5,10)
SWEP.EjectDir				= Vector(0.5,0.5,0)
SWEP.Attach					= "ValveBiped.Bip01_R_Thigh"
SWEP.AttachVector			= Vector(-6,3,-3)
SWEP.AttachAngle			= Angle(0,90,0)

SWEP.VElements = {
	["suppressor"] = { 
	type = "Model", 
	model = "models/weapons/suppressor.mdl",  
	bone = "v_weapon.Glock_Parent", 
	pos = Vector(-4, 3.55, -0.632), 
	angle = Angle(2, 15.6, 90), 
	size = 0.7, 
	color = Color(255, 255, 255, 255), 
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rds"] = { 
	type = "Model", 
	model = "models/weapons/mrds.mdl",  
	bone = "v_weapon.Glock_Slide", 
	pos = Vector(0.5, -1.05, -3.2), 
	angle = Angle(0,0,77),
	AuxIronSightsPos = Vector (4.34, 0.1, 2.65),
	AuxIronSightsAng = Vector (-0.1,0,0.7),
	size = 0.115, 
	color = Color(255, 255, 255, 255), 
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}