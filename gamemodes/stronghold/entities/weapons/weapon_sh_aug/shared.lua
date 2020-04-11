if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
elseif (CLIENT) then
	SWEP.PrintName 		= "STEYR AUG A1"
	SWEP.IconLetter 		= "e"

	killicon.AddFont("weapon_sh_aug", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))

end


SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rc_aug.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_aug.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Aug.Single")
SWEP.Primary.Recoil 		= 0.2
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.085
SWEP.Primary.Cone 			= 0.003
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.RKick					= 10
SWEP.RRise					= 0
SWEP.RSlide					= 0.0065
SWEP.ADSPos 				= Vector (5.894, -3, 1.41)
SWEP.ADSAngle				= Angle (-3.63, -7.49, 0.8)
SWEP.DistantSound			= "aug.mp3"
SWEP.IronPos				= Vector(0.83, 3.90, -1.5)
SWEP.IronAng				= Angle(3, 8, 89)
SWEP.IronFrontPos			= Vector(-0.15, 0, 2)
SWEP.ShootAnim				= 3
SWEP.DeployAnim				= 4
SWEP.ReloadAnim				= 5
SWEP.Origin					= Vector(-2,1.5,-2.5)
SWEP.EjectDir				= Vector(-1,0.3,0)
SWEP.EjectPos				= Vector(6,-5,6)

SWEP.VElements = {
	["suppressor"] = { 
	type = "Model", 
	model = "models/weapons/suppressor.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = Vector(0.1, 2.83, 7.5), 
	angle = Angle(-87.5, 0, 90), 
	size = 0.8--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rds"] = { 
	type = "Model", 
	model = "models/weapons/rds.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = Vector(0.6, 3.32, 0), 
	angle = Angle(-87, 0, 81.5), 
	size = 0.53--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector (5.894, -3, 1.41),
	AuxIronSightsAng = Vector (-3.63, -8.8, 0.8),
	RRise = 0,
	RSlide = 0.0065,
	skin = 0, 
	bodygroup = {} 
	},
	["m145"] = { 
	type = "Model", 
	model = "models/weapons/m145.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = Vector(0.875, 4.8, -1), 
	angle = Angle(3.5, 8, 0), 
	size = 0.47--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector (5.894, -3, 1.41),
	AuxIronSightsAng = Vector (-3.45, -7.49, -0.25),
	RRise = 0.001,
	RSlide = 0.006,
	skin = 0, 
	bodygroup = {} 
	},
	["scope"] = { 
	type = "Model", 
	model = "models/weapons/scope.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = Vector(0.3, 4.84, 10), 
	angle = Angle(93, 0, 98.4), 
	size = 0.14--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector (5.894, -3, 1.6),
	AuxIronSightsAng = Vector (-3.63, -7.49, 0.8),
	RRise = 1,
	RSlide = 0.0004,
	skin = 0, 
	bodygroup = {} 
	}
}

SWEP.Irons = {
	["rear"] = {
	type = "Model", 
	model = "models/weapons/irons.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = SWEP.IronPos, 
	angle = SWEP.IronAng, 
	size = 0.55--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["front"] = {
	type = "Model", 
	model = "models/weapons/irons_f.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = SWEP.IronPos+SWEP.IronFrontPos, 
	angle = SWEP.IronAng,  
	size = 0.55--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}

SWEP.Rails = {
	["rail"] = { 
	type = "Model", 
	model = "models/weapons/augrail.mdl",  
	bone = "v_weapon.aug_Parent", 
	pos = Vector(0.669, 3.57, -0.05), 
	angle = Angle(183, 8.2, 91), 
	size = 1--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}