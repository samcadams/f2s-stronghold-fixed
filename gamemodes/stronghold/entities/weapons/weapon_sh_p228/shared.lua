if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "pistol"
elseif (CLIENT) then
	SWEP.PrintName 		= "SIG-SAUER P228"
	SWEP.IconLetter 	= "y"
	SWEP.Slot 				= 1
	killicon.AddFont("weapon_sh_p228", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.HoldType				= "revolver"
SWEP.EjectDelay				= 0.05
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_p228.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_P228.Single")
SWEP.Primary.Damage 		= 12
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 15
SWEP.Primary.Delay 			= 0.05
SWEP.Primary.DefaultClip 	= 15
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.ADSPos 				= Vector (4.7648, -0.1, 2.91)
SWEP.ADSAngle	 			= Angle (-0.1, 0, -0.5)
SWEP.DistantSound			= "p228.mp3"
SWEP.BoltBone				= "p228_Slide"
SWEP.SlideLockPos			= Vector(-1.2,0,0)
SWEP.Subsonic				= true
SWEP.DotVis					= -1.4
SWEP.ShootAnim				= 1
SWEP.DeployAnim				= 6
SWEP.ReloadAnim				= 5
SWEP.RunAngleSet			= "pistol"
SWEP.FireSelect				= 0
SWEP.EjectPos				= Vector(4,-3.5,10)
SWEP.EjectDir				= Vector(0.5,0.5,0)
SWEP.Attach					= "ValveBiped.Bip01_R_Thigh"
SWEP.AttachVector			= Vector(-6,3,-3)
SWEP.AttachAngle			= Angle(0,90,0)

SWEP.VElements = {
	["suppressor"] = { 
	type = "Model", 
	model = "models/weapons/suppressor.mdl",  
	bone = "v_weapon.P228_Parent", 
	pos = Vector(0.02, 2.9, 4.35), 
	angle = Angle(-90,0,90), 
	size = 0.7, 
	color = Color(255, 255, 255, 255), 
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rds"] = { 
	type = "Model", 
	model = "models/weapons/mrds.mdl",  
	bone = "v_weapon.P228_Slide", 
	pos = Vector(2.86, -1.55, 0), 
	angle = Angle(90,0,90),
	AuxIronSightsPos = Vector (4.7648, -0.1, 2.65),
	AuxIronSightsAng = Vector (-0.1, 0, -0.0),
	size = 0.11, 
	color = Color(255, 255, 255, 255), 
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}