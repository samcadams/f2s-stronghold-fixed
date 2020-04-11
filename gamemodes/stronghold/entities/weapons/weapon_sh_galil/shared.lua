if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
elseif (CLIENT) then
	SWEP.PrintName 		= "GALIL SAR"
	SWEP.IconLetter 		= "v"
	SWEP.ViewModelFlip	= false

	killicon.AddFont("weapon_sh_galil", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end


SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rc_galil.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_galil.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Galil.Single")
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.01
SWEP.Primary.ClipSize 		= 35
SWEP.Primary.Delay 			= 0.085
SWEP.Primary.DefaultClip 	= 35
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RRise					= 0.0
SWEP.ADSPos 				= Vector(5.15,-5,2.37)
SWEP.ADSAngle	 			= Angle(0,0,-0.3)
SWEP.ModelRunAnglePreset	= 1
SWEP.DistantSound			= "galil.mp3"
SWEP.BoltBone				= "bolt"
SWEP.ShootAnim				= 3
SWEP.DeployAnim				= 2
SWEP.ReloadAnim				= 1
SWEP.Origin					= Vector(-4,2.5,-3)
SWEP.MuzzlePos				= Vector(32,4.8, -4.3)
SWEP.EjectPos				= Vector(5,-3.5,10)
SWEP.EjectDir				= Vector(1,0,0)

SWEP.VElements = {
	["suppressor"] = { 
	type = "Model", 
	model = "models/weapons/suppressor.mdl",  
	bone = "v_weapon.galil", 
	pos = Vector(0.1, -0.12, 17.7), 
	angle = Angle(-90, 0, 270), 
	size = 0.79--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rds"] = { 
	type = "Model", 
	model = "models/weapons/rds.mdl",  
	bone = "v_weapon.galil", 
	pos = Vector(0.02, -0.95, 3), 
	angle = Angle(-90, 0, -90), 
	size = 0.55--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector(5.15,-5,1.6),
	AuxIronSightsAng = Vector(-0,0,0),
	RRise = 0.001,
	RSlide = 0,
	skin = 0, 
	bodygroup = {} 
	},
	["m145"] = { 
	type = "Model", 
	model = "models/weapons/m145.mdl",  
	bone = "v_weapon.galil", 
	pos = Vector(0.03, -2.45, 2), 
	angle = Angle(0, -180, 0), 
	size = 0.48--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector(5.15,-3,1.6),
	AuxIronSightsAng = Vector(0,0,-0.45),
	RRise = 0.002,
	RSlide = 0,
	skin = 0, 
	bodygroup = {} 
	},
	["scope"] = { 
	type = "Model", 
	model = "models/weapons/scope.mdl",  
	bone = "v_weapon.galil", 
	pos = Vector(0.03, -2.65, 14.1), 
	angle = Angle(90, -180, 90), 
	size = 0.155--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector(5.15,0.1,1.6),
	AuxIronSightsAng = Vector(0,0,0.5),
	RRise = 0.002,
	RSlide = 0,
	skin = 0, 
	bodygroup = {} 
	}
}

SWEP.Rails = {
	["rail"] = { 
	type = "Model", 
	model = "models/weapons/akmount.mdl",  
	bone = "v_weapon.galil", 
	pos = Vector(0.55, 0.75, 8), 
	angle = Angle(-90, 0, -90), 
	size = 0.2--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}