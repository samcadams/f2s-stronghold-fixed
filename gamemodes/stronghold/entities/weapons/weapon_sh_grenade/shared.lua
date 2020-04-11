local GRENADE_COOK_TIME = 4

if SERVER then
	AddCSLuaFile ("shared.lua")
	SWEP.Weight 			= 5
	SWEP.AutoSwitchTo 		= true
	SWEP.AutoSwitchFrom 	= true
end

if CLIENT then
	SWEP.PrintName 			= "H.E. GRENADE"
	SWEP.Slot 				= 2
	SWEP.DrawAmmo 			= true
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV		= 65
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false
	
	CreateClientConVar( "sh_wep_quickgrenade", "0", true, false )

	SWEP.IconLetter 			= "O"
	killicon.AddFont( "weapon_sh_grenade", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Author 					= "RoaringCow"
SWEP.Category					= "STRONGHOLD"
SWEP.Base						= "sh_base"
SWEP.Contact 					= ""
SWEP.Purpose 					= ""
SWEP.Spawnable 					= false
SWEP.AdminSpawnable 			= false
SWEP.ViewModel 					= "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel 				= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.Primary.ClipSize 			= -1
SWEP.Primary.DefaultClip 		= 1
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 				= "grenade"
SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= -1
SWEP.Secondary.Automatic 		= false
SWEP.Secondary.Ammo 			= "none"
SWEP.Primed 					= 0
SWEP.Throw 						= CurTime()
SWEP.PrimaryThrow				= true
SWEP.ModelRunAnglePreset		= 4
SWEP.Look 						= 0
SWEP.ThrowForce					= 1000
SWEP.wep						= "grenade"
SWEP.RunArmAngle  = Angle( -10, 50, 6 )
SWEP.RunArmOffset = Vector( 1, -0.1, -5 )
SWEP.RunAngleSet			="rpg"
SWEP.ShootAnim				= 4
SWEP.DeployAnim				= 6
SWEP.ReloadAnim				= 5
SWEP.Origin					= Vector(0,0,0)
SWEP.GrenadeClass				= "sent_explosivegrenade"
SWEP.Cookable					= true
SWEP.CookableDamage				= false

function SWEP:Initialize()
		self:SetWeaponHoldType( "grenade" )
		self.CookTime = 0
		self.LastThrow = 0
		self.Drawn = false
		self.Attach	= nil
end

function SWEP:Holster()
	if self.Primed == 1 then
		self.Primed = 2
		self.CookTime = CurTime() - self.Throw -- THIS GETS THE TIME BETWEEN WHEN YOU STARTED COOKING AND NOW
		self.Throw = CurTime() + 0.05
		self:ThrowGrenade( true )
	end
	self.Primed = 0
	self.Throw = CurTime()
	return true
end

function SWEP:Reload()
end

function SWEP:Think()
	self.BobScale = 0
	 if self.Primed == 1 and SERVER then
		if self.Cookable and CurTime() - self.Throw > GRENADE_COOK_TIME then -- LOL HELD TOO LONG
			self.Primed = 2
			
			self.CookTime = CurTime() - self.Throw -- THIS GETS THE TIME BETWEEN WHEN YOU STARTED COOKING AND NOW
			self.Throw = CurTime() + 0

			self:ThrowGrenade( true )
		elseif !self.Owner:KeyDown( IN_ATTACK ) and self.PrimaryThrow then -- Far throw
			if self.Throw < CurTime() then
				self.Primed = 2
				self.CookTime = CurTime() - self.Throw -- THIS GETS THE TIME BETWEEN WHEN YOU STARTED COOKING AND NOW
				self.Throw = CurTime() + 0.5	
				self.Weapon:SendWeaponAnim( ACT_VM_THROW )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				timer.Simple( 0.3, function()
				if !IsValid( self ) then return end

					self:ThrowGrenade( false )
				end)
			end

		elseif !self.Owner:KeyDown( IN_ATTACK2 ) and !self.PrimaryThrow then -- Short throw
			if self.Throw < CurTime() then
				self.Primed = 2
				self.Throw = CurTime() + 0.5
				self.Weapon:SendWeaponAnim( ACT_VM_THROW )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				timer.Simple( 0.3, function()
				if !IsValid( self ) then return end
					self:ThrowGrenade( true )
				end)
			end
		end
	end
	if self.LastThrow < CurTime() and self.Owner:GetAmmoCount( self.Primary.Ammo ) < 2 and !self.Drawn then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
			self.Drawn = true
		end
		self.Primed = 0
		self.CookTime = 0
	end
end

function SWEP:ThrowGrenade( short )
	if self.Primed != 2 or !SERVER then return end

	local tr = self.Owner:GetEyeTrace()
	local ent = ents.Create( self.GrenadeClass )

	local v = self.Owner:GetShootPos()
		v = v + self.Owner:GetForward() * (!short and 1 or 2)
		v = v + self.Owner:GetRight() * 3
		v = v + self.Owner:GetUp() * (!short and 1 or -3)
	ent:SetPos( v )
	ent:SetAngles( Angle(math.random(1,100),math.random(1,100),math.random(1,100)) )
	ent.GrenadeOwner = self.Owner
	ent:Spawn() 
	
	if self.Cookable then
		ent:SetDuration( GRENADE_COOK_TIME - self.CookTime )
		if self.CookableDamage and self.CookTime > GRENADE_COOK_TIME then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( 20 )
			dmginfo:SetAttacker( self.Owner )
			dmginfo:SetInflictor( self )
			self.Owner:TakeDamageInfo( dmginfo )
			self.Owner:SetDSP( 31 )
		end
	end
	
	if self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_SPEED) ) then
		self.Force = (!short and self.ThrowForce + 300 or self.ThrowForce + 300 - 1500)
	elseif self.Owner:KeyDown( bit.bor(IN_BACK,IN_SPEED) ) then
		self.Force = (!short and self.ThrowForce - 300 or self.ThrowForce - 300 - 1500)
	else
		self.Force = (!short and self.ThrowForce or self.ThrowForce*0.5)
	end
	
	--if not self.Owner then return end self.Owner:ViewPunch(Vector(math.Rand(-0.1, -0.5), math.Rand(0.1, 0.5), math.Rand(-0.1, -0.5)))
 
	local phys = ent:GetPhysicsObject()
	phys:ApplyForceCenter( self.Owner:GetAimVector() * self.Force *1.2 + Vector(0,0,200) )
	phys:SetVelocity( phys:GetVelocity() + self.Owner:GetVelocity() )
	phys:AddAngleVelocity( Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)) )
	self.Owner:RemoveAmmo( 1, self.Primary.Ammo )

	self.LastThrow = CurTime() + 0.6
	
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 then
		self.Owner:ConCommand( "lastinv" )
		self.Weapon:Remove()
	end
	


end


function SWEP:PrimaryAttack()
	if CLIENT then
		self.FireOne = true
	end
	if self.Throw < CurTime() and self.Primed == 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_PULLPIN )
		self.Primed = 1
		self.Throw = CurTime() + 0.1
		self.PrimaryThrow = true
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then
		self.FireOne = true
	end
	if self.Throw < CurTime() and self.Primed == 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_PULLPIN )
		self.Primed = 1
		self.Throw = CurTime() + 0.1
		self.PrimaryThrow = false
	end
end

function SWEP:Deploy()
	self.Switched = true
	self.Throw = CurTime() + 0.1
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText( self.IconLetter, "CSKillIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER )
	-- Draw a CS:S select icon
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	-- Print weapon information
end