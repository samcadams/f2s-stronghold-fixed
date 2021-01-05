if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType			= "rpg"
elseif (CLIENT) then
	SWEP.PrintName 		= "RPG"
	SWEP.IconLetter 	= ";"
	SWEP.Slot 			= 0
	SWEP.ViewModelFlip	= false
	SWEP.DrawAmmo		= false

	killicon.AddFont("weapon_sh_rpg", "HalfLife2", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Base 					= "sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 				= "rpg"	
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.Automatic 		= true
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Ammo			= "rpg_round"
SWEP.ViewModel				= "models/weapons/v_rpg.mdl"
SWEP.WorldModel				= "models/weapons/w_rocket_launcher.mdl"
SWEP.Primary.Sound			= Sound( "weapons/rpg/rocketfire1.wav" )
SWEP.Primary.Damage			= 10
SWEP.Primary.Cone			= 0.01
SWEP.Secondary.Ammo			= "none"
SWEP.FreeFloatHair			= 1
SWEP.ModelRunAnglePreset	= 5
SWEP.FireSelect				= 0
SWEP.ADSPos 				= Vector(15,-50,0)
SWEP.ADSAngle 				= Angle (0, 0, 0)
SWEP.AttachVector			= Vector(-8,-15,5)
SWEP.AttachAngle			= Angle(0,0,0)
SWEP.ShootAnim				= 2
SWEP.DeployAnim				= 1
SWEP.ReloadAnim				= 3
SWEP.Origin					= Vector(-15,1,-10)
SWEP.RunAngleSet 			= "rpg"
SWEP.Zoom					= 0.3

function SWEP:PrimaryAttack()
	if self.Sprinting or self.Reloading then 
	return end
	
	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound(self.Primary.Sound)
	self:CSShootBullet()
	self:TakePrimaryAmmo(1)

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNWFloat("LastShootTime", CurTime())
	end
end 
	
function SWEP:CSShootBullet()
	if SERVER then
		local tr = self.Owner:GetEyeTrace()
		local ent = ents.Create( "sent_rocket" )
		print("ROCKET!")
		local v = self.Owner:GetShootPos()
			v = v + self.Owner:GetForward() * (!short and 1 or 2)
			v = v + self.Owner:GetRight() * 3
			v = v + self.Owner:GetUp() * (!short and 1 or -3)
		if SERVER then
		ent:SetPos( v )
		ent:SetOwner( self.Owner )
		ent:SetAngles(self.Owner:EyeAngles())
		ent.RocketOwner = self.Owner
		ent:Spawn()
		ent:Activate()
	 
		local phys = ent:GetPhysicsObject()
		--phys:ApplyForceCenter( self.Owner:GetAimVector() * 10000000 + Vector(0,0,200) )
		--phys:SetVelocity( self.Owner:GetShootPos() * 200 )
		--phys:EnableGravity( false )
		end
		self.Owner:RemoveAmmo( 0, self.Primary.Ammo )
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

--[[function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
	draw.SimpleText( self.IconLetter, "Trebuchet19", x + w*0.5, y + h*0.1, Color( 255, 220, 0, 255 ), TEXT_ALIGN_CENTER )
end]]