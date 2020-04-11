if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "M4A2"
	SWEP.IconLetter 		= "w"
	SWEP.ViewModelFlip		= true	

	killicon.AddFont("weapon_sh_m4a2", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "none"
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_m4a1.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_M4A1.Single")
SWEP.SuppressedSound		= Sound("weapons/suppressed_m4.wav")
SWEP.Primary.Damage 		= 22
SWEP.Primary.Recoil 		= 0.2
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.01
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.075
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.Recoil 				= 2
SWEP.RMod					= 1
SWEP.SlideLocks				= 0
SWEP.FireSelect				= 1
SWEP.Look					= 1
SWEP.CycleSpeed				= 1
SWEP.IronCycleSpeed			= 0
SWEP.RKick					= 10
SWEP.RRise					= -0.01
SWEP.RSlide					= 0.0025
SWEP.LastAmmoCount 			= 0
SWEP.IronsightCorrection 	= 0
SWEP.ADSPos 				= Vector (5.97, -3, 1.1)
SWEP.ADSAngle 				= Angle (-1.55, -3.1, 2.8)
SWEP.DistantSound			= "m4.mp3"
SWEP.AuxViewModel 			= "models/weapons/v_rc_m4a1.mdl"
SWEP.AuxIronSightsPos = Vector (6.065, 0.1, 0.85)
SWEP.AuxIronSightsAng = Vector (2.3, 1.3, 3.6)
SWEP.ShootAnim				= 8
SWEP.DeployAnim				= 12
SWEP.ReloadAnim				= 11
SWEP.IdleAnim				= 7
SWEP.Origin					= Vector(-3,1.3,-3)
SWEP.EjectPos				= Vector(5,-3.5,10)
SWEP.EjectDir				= Vector(1,0,0)


SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl",  
		bone = "v_weapon.m4_Parent", 
		pos = Vector(0.2, 3.7, 10), 
		angle = Angle(-88.7, 0, -270), 
		size = 0.8, 
		color = Color(255, 255, 255, 255),
		surpresslightning = false,  
		skin = 0, 
		bodygroup = {} 
		},
	["m145"] = { 
		type = "Model", 
		model = "models/weapons/m145.mdl", 
		bone = "v_weapon.m4_Parent", 
		pos = Vector(0.75, 5.35, 1),
		angle = Angle(1.5, 8, 0), 
		size = 0.5, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		AuxIronSightsPos = Vector (5.97, -3, 1.1),
		AuxIronSightsAng = Vector (-1.55, -3.1, 0.3),
		RRise = -0.01,
		RSlide = 0.0045,
		skin = 0, 
		bodygroup = {} 
		},
	["rds"] = { 
		type = "Model", 
		model = "models/weapons/rds.mdl", 
		bone = "v_weapon.m4_Parent", 
		pos = Vector(0.535, 3.7, 2), 
		angle = Angle(-88.5, 0, 82), 
		size = 0.58, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001",
		AuxIronSightsPos = Vector (5.97, -3, 1.1),
		AuxIronSightsAng = Vector (-1.55, -3.1, 1.5),
		skin = 0, 
		bodygroup = {} 
		},
	["scope"] = { 
		type = "Model", 
		model = "models/weapons/scope.mdl",  
		bone = "v_weapon.m4_Parent", 
		pos = Vector(0.2, 5.51, 13.5),
		angle = Angle(92.5, 0, 98), 
		size = 0.155--[[Vector(0.123, 0.123, 0.123)]], 
		color = Color(255, 255, 255, 255),
		surpresslightning = false, 
		AuxIronSightsPos = Vector (5.97, -3, 1.1),
		AuxIronSightsAng = Vector (-2, -3.1, 2.5),
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
		bone = "v_weapon.m4_Parent", 
		pos = Vector(0.64,4.24,0.8735), 
		angle = Angle(-88.5, 0, 82), 
		size = 0.65--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(190, 190, 200, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		},
	["rail2"] = { 
		type = "Model", 
		model = "models/weapons/rail.mdl", 
		bone = "v_weapon.m4_Parent", 
		pos = Vector(0.5924,4.24,2.7), 
		angle = Angle(-88.5, 0, 82), 
		size = 0.65--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(190, 190, 200, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		}
	}