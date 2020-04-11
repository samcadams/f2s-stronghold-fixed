--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	File: shared.lua
	For: FTS: Stronghold
	By: Ultra
]]--

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_c4.mdl"
SWEP.WorldModel 			= "models/weapons/w_c4.mdl"
SWEP.DrawWeaponInfoBox  	= false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "grenade"

SWEP.Secondary.ClipSize 	= 1
SWEP.Secondary.DefaultClip 	= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.ModelRunAnglePreset 	= 5

function SWEP:Precache()
end

function SWEP:Initialize()
end

function SWEP:OnRemove()
end

function SWEP:OwnerChanged()
end

function SWEP:Reload()
end

function SWEP:Deploy()
	self:SetNextPrimaryFire( CurTime() +1.05 )
	return true
end

function SWEP:Holster()
	return not self.m_bDeploying
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	if IsValid(UAV) and UAV:GetOwner() == self.Owner then return end
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 then return end

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()
	local ang = dir:Angle()
	if SERVER then
		UAV = ents.Create "sent_uav"
		UAV:SetPos( self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 30 )
		UAV:SetAngles( self.Owner:EyeAngles() )
		UAV:Spawn()
		UAV:SetOwner(self.Owner)
		UAV:Activate()
		UAV:Drive( self.Owner )
	self.Owner:RemoveAmmo( 1, self.Primary.Ammo )
	local phys = UAV:GetPhysicsObject()
		if IsValid( phys ) then
			phys:ApplyForceCenter( dir *phys:GetMass() *250 )
			phys:SetDamping( 0, phys:GetMass() *750 )
		end
	end
end

function SWEP:SecondaryAttack()
end