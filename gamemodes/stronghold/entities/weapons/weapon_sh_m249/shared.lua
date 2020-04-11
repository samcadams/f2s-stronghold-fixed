if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "M249 SAW"
	SWEP.IconLetter 		= "z"
	SWEP.ViewModelFlip		= false

	killicon.AddFont("weapon_sh_m249", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "rifle"
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.ViewModel 				= "models/weapons/v_rc_m249para.mdl"
SWEP.WorldModel 			= "models/weapons/w_mach_m249para.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_M249.Single")
SWEP.Primary.Recoil 		= 0.2
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.007
SWEP.Primary.ClipSize 		= 200
SWEP.Primary.Delay 			= 0.077
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.ADSPos 				= Vector (4.43, -3, 2.1305)
SWEP.ADSAngle 				= Angle (0.1, 0, 0)
SWEP.ModelRunAnglePreset	= 1
SWEP.RKick					= 10
SWEP.RRise					= 0
SWEP.RSlide					= -0.0005
SWEP.NoCrossHair			= true
SWEP.DistantSound			= "m4.mp3"
SWEP.VEBone					= "receiver"
SWEP.ShootAnim				= 2
SWEP.DeployAnim				= 4
SWEP.ReloadAnim				= 3
SWEP.Origin					= Vector(-3,1.5,-3)
SWEP.FireSelect				= 0
SWEP.MuzzlePos				= Vector(28,4.3,-3.5)
SWEP.EjectPos				= Vector(6,-5,10)
SWEP.EjectDir				= Vector(-1,0.2,0)

SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl",
		bone = "v_weapon.m249", 
		pos = Vector(0.14, -1.05, 19), 
		angle = Angle(-90, 90, 0), 
		size = 0.77, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
		},
	["m145"] = { 
		type = "Model", 
		model = "models/weapons/m145.mdl", 
		bone = "v_weapon.receiver", 
		pos = Vector(-4.4, 0.08, -1.25),
		angle = Angle(0, 90, 90), 
		size = 0.45, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		AuxIronSightsPos 			= Vector (4.425, -3, 1.393),
		AuxIronSightsAng 			= Vector (0.15, 0.1, 0.15),
		skin = 0, 
		bodygroup = {} 
		},
	["rds"] = { 
		type = "Model", 
		model = "models/weapons/rds.mdl", 
		bone = "v_weapon.receiver", 
		pos = Vector(-3.5, 0.08, 0.2),
		angle = Angle(-180, 0, 0), 
		size = 0.5, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001",
		AuxIronSightsPos 			= Vector (4.42, -3, 1.6),
		AuxIronSightsAng 			= Vector (0.1, 0.1, 0),	
		skin = 0, 
		bodygroup = {} 
		}
}

SWEP.Rails = {	
	["rail"] = { 
		type = "Model", 
		model = "models/weapons/rail.mdl", 
		bone = "v_weapon.receiver", 
		pos = Vector(-4, 0.08, -0.3),
		angle = Angle(180, 0, 0), 
		size = 0.55--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		}
	}