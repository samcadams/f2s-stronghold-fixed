if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "HK MP-5A5"
	SWEP.IconLetter 		= "x"

	killicon.AddFont("weapon_sh_mp5a4", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.ShellEffect			= "rg_shelleject"
SWEP.MuzzleEffect			= "pistol" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_mp5.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_MP5Navy.Single")
SWEP.Primary.Damage 		= 12
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.007
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.075
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.SMG					= true
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RKick					= 10
SWEP.RRise					= -0.002
SWEP.ADSPos 				= Vector (4.7456, -4, 1.94)
SWEP.ADSAngle 				= Angle (0.06, -0.0424, 0.95)
SWEP.DistantSound			= "mp5.mp3"
SWEP.Subsonic				= true
SWEP.ShootAnim				= 3
SWEP.DeployAnim				= 2
SWEP.ReloadAnim				= 1
SWEP.Origin					= Vector(-2,2,-2)
SWEP.EjectPos				= Vector(6,-4.5,11)
SWEP.EjectDir				= Vector(-1,0,0)

SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl",
		bone = "v_weapon.MP5_Parent", 
		pos = Vector(0.1, 3, 13), 
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
		bone = "v_weapon.MP5_Parent", 
		pos = Vector(0.13, 3.5, 4), 
		angle = Angle(-90, 0, 90), 
		size = 0.55--[[Vector(0.123, 0.123, 0.123)]], 
		color = Color(255, 255, 255, 255),
		surpresslightning = false, 
		AuxIronSightsPos = Vector (4.7456, -4, 1.4),
		AuxIronSightsAng = Vector (0.06, -0.0424, 0.95),
		RRise = 0.003,
		RSlide = 0,
		skin = 0, 
		bodygroup = {} 
	},
	["m145"] = { 
		type = "Model", 
		model = "models/weapons/m145.mdl",  
		bone = "v_weapon.MP5_Parent", 
		pos = Vector(0.13, 5.05, 4),  
		angle = Angle(0, 0, 0), 
		size = 0.48--[[Vector(0.123, 0.123, 0.123)]], 
		color = Color(255, 255, 255, 255),
		surpresslightning = false, 
		AuxIronSightsPos = Vector (4.7456, -4, 1.4),
		AuxIronSightsAng = Vector (0.06, -0.0424, -0.25),
		RRise = 0.002,
		RSlide = 0,
		skin = 0, 
		bodygroup = {} 
	},
	["scope"] = { 
		type = "Model", 
		model = "models/weapons/scope.mdl",  
		bone = "v_weapon.MP5_Parent", 
		pos = Vector(0.13, 5.25, 15),  
		angle = Angle(90, 0, 90), 
		size = 0.155--[[Vector(0.123, 0.123, 0.123)]], 
		color = Color(255, 255, 255, 255),
		surpresslightning = false, 
		AuxIronSightsPos = Vector (4.7456, 0.1, 1.5),
		AuxIronSightsAng = Vector (0.06, -0.0424, 0.5),
		RRise = 0.002,
		RSlide = 0,
		skin = 0, 
		bodygroup = {} 
	}
}

SWEP.Rails = {
	["rail"] = { 
	type = "Model", 
	model = "models/weapons/rail.mdl",  
	bone = "v_weapon.MP5_Parent", 
	pos = Vector(0.13, 4, 3.5), 
	angle = Angle(-90, 0, 90), 
	size = 0.6--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(235, 245, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["rail2"] = { 
	type = "Model", 
	model = "models/weapons/rail.mdl",  
	bone = "v_weapon.MP5_Parent", 
	pos = Vector(0.13, 4, 5), 
	angle = Angle(-90, 0, 90), 
	size = 0.6--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(235, 245, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}