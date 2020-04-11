if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "HK G3SG1"
	SWEP.IconLetter 		= "i"

	killicon.AddFont("weapon_sh_g3sg1", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255) )
end


SWEP.MuzzleEffect			= "sniper"
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rc_g3sg1.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_g3sg1.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_G3SG1.Single")
SWEP.Primary.Damage 		= 30
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.Cone 			= 0.002
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 20
SWEP.Primary.Delay 			= 0.11
SWEP.Primary.DefaultClip 	= 20
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 4
SWEP.DrawParabolicSights	= false
SWEP.ADSPos 				= Vector (5.375, -5, 3.15)
SWEP.ADSAngle 				= Angle (0.07, -0.05, 0.1)
SWEP.DistantSound			= "g3sg1.mp3"
SWEP.ShootAnim				= 1
SWEP.DeployAnim				= 4
SWEP.ReloadAnim				= 3
SWEP.Origin					= Vector(-5,2.5,-3)
SWEP.EjectPos				= Vector(6,-5,10)
SWEP.EjectDir				= Vector(-1,0.2,0)

SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl",
		bone = "v_weapon.g3sg1_Parent", 
		pos = Vector(-0.01, 3.76, 18), 
		angle = Angle(-90, 0, 90), 
		size = 0.77, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
	},
	["rds"] = { 
	type = "Model", 
	model = "models/weapons/rds.mdl",  
	bone = "v_weapon.g3sg1_Parent", 
	pos = Vector(0, 4.3, 2), 
	angle = Angle(-90, 0, 90), 
	size = 0.55--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector (5.375, -5, 2.25),
	AuxIronSightsAng = Vector (0, -0.05, 0.3),
	skin = 0, 
	bodygroup = {} 
	},
	["m145"] = { 
	type = "Model", 
	model = "models/weapons/m145.mdl",  
	bone = "v_weapon.g3sg1_Parent", 
	pos = Vector(0, 5.85, 0.5), 
	angle = Angle(0, 0, 0), 
	size = 0.48--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector (5.369, -3, 2.085),
	AuxIronSightsAng = Vector (0.04, -0.05, 0.35),
	RRise = 0.00,
	RSlide = 0,
	skin = 0, 
	bodygroup = {} 
	},
	["scope"] = { 
	type = "Model", 
	model = "models/weapons/scope.mdl",  
	bone = "v_weapon.g3sg1_Parent", 
	pos = Vector(0, 6.05, 13), 
	angle = Angle(90, 0, 90), 
	size = 0.155--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	AuxIronSightsPos = Vector (5.369, 0.1, 2.085),
	AuxIronSightsAng = Vector (0, -0.05, 1),
	RRise = 0.00,
	RSlide = 0,
	skin = 0, 
	bodygroup = {} 
	}
}

SWEP.Rails = {
	["post"] = { 
		type = "Model", 
		model = "models/Squad/sf_bars/sf_bar25x25x1.mdl",
		bone = "v_weapon.g3sg1_Parent", 
		pos = Vector(0.025, 6.2, 16), 
		angle = Angle(0, 90, 0), 
		size = 0.2, 
		color = Color(0, 0, 0, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
	},	
	["rail"] = { 
	type = "Model", 
	model = "models/weapons/rail.mdl",  
	bone = "v_weapon.g3sg1_Parent", 
	pos = Vector(0, 4.8, 0.8), 
	angle = Angle(-90, 0, 90), 
	size = 0.6--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(200, 200, 200, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rail2"] = { 
	type = "Model", 
	model = "models/weapons/rail.mdl",  
	bone = "v_weapon.g3sg1_Parent", 
	pos = Vector(0, 4.8, 3), 
	angle = Angle(-90, 0, 90), 
	size = 0.6--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(200, 200, 200, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}