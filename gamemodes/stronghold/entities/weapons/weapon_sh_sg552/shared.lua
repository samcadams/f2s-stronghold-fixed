if SERVER then
	AddCSLuaFile("shared.lua")
elseif CLIENT then
	SWEP.PrintName 			= "SIG SG-552"
	SWEP.IconLetter 		= "A"

	killicon.AddFont("weapon_sh_sg552", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rc_sg552.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_sg552.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_SG552.Single")
SWEP.SuppressedSound		= Sound("weapons/suppressed_552.wav")
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Recoil			= 0.2
SWEP.Primary.Cone 			= 0.01
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.085
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.DistantSound			= "sg552.mp3"
SWEP.BoltBone				= "sg552_Chamber"
SWEP.RSlide					= 0.0010
SWEP.RRise					= 0.001
SWEP.ADSPos 				= Vector (6.825, -6, 3.3)
SWEP.ADSAngle				= Angle (-0.4, 0.28, 0.85)
SWEP.AuxIronSightsPos 		= Vector (6.825, 0, 3.3)
SWEP.AuxIronSightsAng 		= Vector (-1, 0.28, 0)
SWEP.VEBone					= "sg552_Parent"
SWEP.ShootAnim				= 3
SWEP.DeployAnim				= 2
SWEP.ReloadAnim				= 1
SWEP.Origin					= Vector(-4,2.5,-3)
SWEP.EjectPos				= Vector(6,-4.5,11)
SWEP.EjectDir				= Vector(1,0,0)

SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl", 
		bone = "v_weapon.sg552_Parent", 
		pos = Vector(-0.07, 3.95, 14), 
		angle = Angle(-90, -90, 0), 
		size = 0.85, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
		},
	["m145"] = { 
		type = "Model", 
		model = "models/weapons/m145.mdl", 
		bone = "v_weapon.sg552_Parent", 
		pos = Vector(0, 6.2, 2.3),
		angle = Angle(0, 0, 0), 
		size = 0.5, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		AuxIronSightsPos 			= Vector (6.825, -6, 2.975),
		AuxIronSightsAng 			= Vector (-0.45, 0.28, -0.4),
		skin = 0, 
		bodygroup = {} 
		},
	["rds"] = { 
		type = "Model", 
		model = "models/weapons/rds.mdl", 
		bone = "v_weapon.sg552_Parent", 
		pos = Vector(0, 4.6, 3), 
		angle = Angle(-90, 0, 90), 
		size = 0.58, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001",
		AuxIronSightsPos 			= Vector (6.825, -6, 3.3),
		AuxIronSightsAng 			= Vector (-0.5, 0.28, -1.5),		
		skin = 0, 
		bodygroup = {} 
		},
	["scope"] = { 
		type = "Model", 
		model = "models/weapons/scope.mdl",  
		bone = "v_weapon.sg552_Parent", 
		pos = Vector(0, 6.35, 13.8),
		angle = Angle(90, 0, 90), 
		size = 0.155--[[Vector(0.123, 0.123, 0.123)]], 
		color = Color(255, 255, 255, 255),
		surpresslightning = false, 
		AuxIronSightsPos 			= Vector (6.825, -6, 3.3),
		AuxIronSightsAng 			= Vector (-1, 0.28, 0),	
		RRise = 0.003,
		RSlide = 0.0004,
		skin = 0, 
		bodygroup = {} 
	}
}

SWEP.Rails = {	
	["rail"] = { 
		type = "Model", 
		model = "models/weapons/rail.mdl", 
		bone = "v_weapon.sg552_Parent", 
		pos = Vector(0, 5.1, 2.3),
		angle = Angle(-90, 0, 90), 
		size = 0.65--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(150, 150, 150, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		},
	["rail2"] = { 
		type = "Model", 
		model = "models/weapons/rail.mdl", 
		bone = "v_weapon.sg552_Parent", 
		pos = Vector(0, 5.1, 3.8),
		angle = Angle(-90, 0, 90), 
		size = 0.65--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(150, 150, 150, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		}
	}