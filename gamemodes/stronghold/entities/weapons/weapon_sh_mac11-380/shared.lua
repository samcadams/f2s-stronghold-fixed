if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "MAC 11 .380"
	SWEP.IconLetter 		= "l"
	SWEP.Slot 				= 1
	killicon.AddFont("weapon_sh_mac10-380", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_mac10.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_MAC10.Single")
SWEP.Primary.Recoil 		= 0.2
SWEP.Primary.Damage 		= 8
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.03
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.050
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.FireSelect				= 1
SWEP.FreeFloatHair			= false
SWEP.ModelRunAnglePreset	= 2
SWEP.RMod 					= 1
SWEP.RRise					= 0.00
SWEP.RSlide					= 0.01
SWEP.Mac10					= true
SWEP.Subsonic				= true
SWEP.ADSPos 				= Vector (6.765, -2, 2.93)
SWEP.ADSAngle 				= Angle (-5.42, -7.3, 0.7)
SWEP.HoldType				= "smg"
SWEP.DistantSound			= "mac.mp3"
SWEP.RunAngleSet			= "smg"
SWEP.ShootAnim				= 3
SWEP.DeployAnim				= 5
SWEP.ReloadAnim				= 1
SWEP.BoltBone				= false
SWEP.EjectPos				= Vector(6,-4,10)
SWEP.EjectDir				= Vector(-1,0.1,0)
SWEP.Attach					= "ValveBiped.Bip01_R_Thigh"
SWEP.AttachVector			= Vector(-6,3,-3)
SWEP.AttachAngle			= Angle(0,90,0)

SWEP.Riser = {	
	["rail"] = { 
		type = "Model", 
		model = "models/props_interiors/vendingmachinesoda01a.mdl", 
		bone = "v_weapon.MAC10_Parent", 
		pos = Vector(-0.07, 3.55, -3.38),
		angle = Angle(0, 0, 90), 
		size = 0.016--[[Vector(0.123, 0.123, 0.123)]],  
		color = Color(30, 30, 30, 255), 
		surpresslightning = false, 
		material = "models/debug/debugwhite", 
		skin = 0, 
		bodygroup = {} 
		}
	}

SWEP.VElements = {
	["suppressor"] = { 
		type = "Model", 
		model = "models/weapons/suppressor.mdl",  
		bone = "v_weapon.MAC10_Parent", 
		pos = Vector(-0.15, 3, 4), 
		angle = Angle(-90,0,90), 
		size = 0.85, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
	},	
	["rds"] = { 
		type = "Model", 
		model = "models/weapons/mrds.mdl",  
		bone = "v_weapon.MAC10_Parent", 
		pos = Vector(2.82, 2.3, -3.3), 
		angle = Angle(90,90,0),
		AuxIronSightsPos = Vector (6.765, -2, 2.9),
		AuxIronSightsAng = Vector (-5.2, -7.3, -1.7),
		RRise = 0.008,
		size = 0.115, 
		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		skin = 0, 
		bodygroup = {} 
	}
}