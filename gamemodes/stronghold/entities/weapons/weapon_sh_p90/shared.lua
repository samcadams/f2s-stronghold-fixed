if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName 			= "FN P90"
	SWEP.IconLetter 		= "m"

	killicon.AddFont("weapon_sh_p90", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255))
end

SWEP.HoldType				= "smg"
SWEP.MuzzleEffect			= "pistol"
SWEP.ShellEffect			= "rg_shelleject_rifle" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rc_p90.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_p90.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_P90.Single")
SWEP.SuppressedSound 		= Sound( "weapons/suppressed_p90.wav")
SWEP.Primary.Damage 		= 10
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.006
SWEP.Primary.ClipSize 		= 50
SWEP.Primary.Delay 			= 0.066
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= true
SWEP.SMG					= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RRise					= 0.005
SWEP.ADSPos 				= Vector (4.655, -3, 1.05)
SWEP.ADSAngle 				= Angle (-0.06, 0, -0.6)
SWEP.DistantSound			= "p90.mp3"
SWEP.IronPos				= Vector(0.1, 5.3, 3.82)
SWEP.IronAng				= Angle(0, 0, 90)
SWEP.IronFrontPos			= Vector(0, 0, -1.1)
SWEP.ShootAnim				= 3
SWEP.DeployAnim				= 2
SWEP.ReloadAnim				= 1
SWEP.Origin					= Vector(-2,2,-2)
SWEP.EjectPos				= Vector(4.7,-5,7)
SWEP.EjectDir				= Vector(0,-0.5,0)
SWEP.fiveseven				= true

SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl",  
		bone = "v_weapon.p90_Parent", 
		pos = Vector(-0.1, 3.05, 6.25), 
		angle = Angle(-90, -90, 0), 
		size = 0.75, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
	},
	["m145"] = { 
		type = "Model", 
		model = "models/weapons/m145.mdl", 
		bone = "v_weapon.p90_Parent", 
		pos = Vector(0.055, 6.32, 2.5), 
		angle = Angle(0, 0, 0), 
		size = 0.5, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		AuxIronSightsPos = Vector (4.655, -5, 0.8),
		AuxIronSightsAng = Vector (-0.06, 0, -0.05),
		--RRise = -0.005,
		--RSlide = 0.0045,
		skin = 0, 
		bodygroup = {} 
	},
	["rds"] = { 
		type = "Model", 
		model = "models/weapons/rds.mdl", 
		bone = "v_weapon.p90_Parent", 
		pos = Vector(0.06, 4.7, 3), 
		angle = Angle(-90, 0, 90), 
		size = 0.58, 
		color = Color(255, 255, 255, 255), 
		AuxIronSightsPos = Vector (4.655, -3, 1.05),
		AuxIronSightsAng = Vector (-0.06, 0, -0.6),
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		},
	["scope"] = { 
		type = "Model", 
		model = "models/weapons/scope.mdl",  
		bone = "v_weapon.p90_Parent", 
		pos = Vector(0.035, 6.5, 14.5), 
		angle = Angle(90, 0, 90), 
		size = 0.155--[[Vector(0.123, 0.123, 0.123)]], 
		color = Color(255, 255, 255, 255),
		surpresslightning = false, 
			AuxIronSightsPos = Vector (4.655, 0.1, 1.2),
			AuxIronSightsAng = Vector (0, 0, 0),
		RRise = 0.003,
		RSlide = 0.0004,
		skin = 0, 
		bodygroup = {} 
	}
}
SWEP.Irons = {
	["rear"] = {
	type = "Model", 
	model = "models/weapons/irons.mdl",  
	bone = "v_weapon.p90_Parent", 
	pos = SWEP.IronPos, 
	angle = SWEP.IronAng, 
	size = 0.6--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	},
	["front"] = {
	type = "Model", 
	model = "models/weapons/irons_f.mdl",  
	bone = "v_weapon.p90_Parent", 
	pos = SWEP.IronPos+SWEP.IronFrontPos, 
	angle = SWEP.IronAng,  
	size = 0.6--[[Vector(0.123, 0.123, 0.123)]], 
	color = Color(255, 255, 255, 255),
	surpresslightning = false, 
	skin = 0, 
	bodygroup = {} 
	}
}
SWEP.Rails = {	
	["rail"] = { 
		type = "Model", 
		model = "models/weapons/rail.mdl", 
		bone = "v_weapon.p90_Parent", 
		pos = Vector(0.08, 5.2, 3.2),
		angle = Angle(-90, 0, 90), 
		size = 0.65--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		--material = "models/props_combine/metal_combinebridge001", 
		skin = 0, 
		bodygroup = {} 
		}
	}