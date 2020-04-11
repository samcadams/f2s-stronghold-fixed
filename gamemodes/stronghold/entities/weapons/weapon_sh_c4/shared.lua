if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	SWEP.HoldType			= "slam"
elseif (CLIENT) then
	SWEP.PrintName			= "C4"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot 				= 2
	killicon.Add("weapon_sh_c4","weapons/c4_sg_killicon",Color(200, 200, 200, 255));
end
SWEP.DrawWeaponInfoBox  	= false
SWEP.AdminSpawnable			= true
SWEP.Spawnable              = true
SWEP.ViewModel				= "models/weapons/v_c4.mdl"
SWEP.WorldModel				= "models/weapons/w_c4.mdl"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "grenade"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Primary.Delay 			= 3
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Author					= "RoaringCow"
SWEP.Category				= "STRONGHOLD"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.reloadtimer 			= 1
SWEP.StartSprite 			= 1
SWEP.DetonationMode			= 1
SWEP.RemoteDetonation 		= 0
SWEP.ShowHud 				= 0
SWEP.ModelRunAnglePreset	= 5

function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType) 	-- 3rd person hold type
	end
end

function SWEP:Reload()
	if CLIENT then return end
end

function SWEP:Think()
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	return true
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64
	trace.mask = MASK_SOLID
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )
	if tr.Hit then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		timer.Simple( 2.5,
			function()
				if !IsValid( self ) then return end
				self:Plant()
				self:SendWeaponAnim( ACT_VM_DRAW )
			end )
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Plant()
	if CLIENT then return end

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64
	trace.mask = MASK_SOLID
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )
	local ent = ents.Create( "sent_c4" )
	if ( ent and ent != NULL ) then
		if !( tr.Hit ) then return end
		ent:SetPos (trace.endpos)
		ent:SetVar("Radius", self.DetectRadius)
		ent:SetVar("Owner", self.Owner)
		ent:Spawn()
		ent:Activate()
		self.Owner:EmitSound( "buttons/button17.wav" )
		self.Owner:EmitSound( "weapons/c4/c4_plant.wav" )
		ent:GetTable():WallPlant( tr.HitPos + tr.HitNormal, tr.HitNormal )
		self:TakePrimaryAmmo( 1 )
		self.Owner:ConCommand( "lastinv" )
		self.Weapon:Remove()
	end 
end

function SWEP:CanPrimaryAttack()
	if ( self.Weapon:Clip1() <= 0 ) and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("Weapons/ClipEmpty_Pistol.wav")
		return false
	end
	return true
end

function SWEP:OnRemove()
end
