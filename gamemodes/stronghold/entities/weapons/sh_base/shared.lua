if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
	SWEP.Weight 		= 5
elseif CLIENT then
	SWEP.DrawAmmo			= true		
	SWEP.DrawCrosshair		= false			
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false
	SWEP.ViewModelFOV		= 60
	SWEP.Slot 				= 0
	SWEP.SlotPos			= 0
	SWEP.MuzzlePos				= Vector(30,50, 50)
	
	local font_data = {
		["CSKillIcons"] = {
			font 	= "csd",
			size 	=  ScreenScale(200),
			shadow	= true,
			weight 	= 0
		},
		["CSIcons"] = {
			font 	= "csd",
			size 	=  ScreenScale(100),
			shadow	= true,
			weight 	= 0
		},
		["HL2MPTypeDeath"] = {
			font 	= "HALFLIFE2",
			size 	=  ScreenScale(100),
			shadow	= true,
			weight 	= 0
		},
	}

	-- This is the font that's used to draw the death icons.
	--surface.CreateFont("csd", ScreenScale(30), 500, true, true, "CSKillIcons")
	-- This is the font that's used to draw the select icons.
	surface.CreateFont( "CSKillIcons", font_data.CSKillIcons )
	surface.CreateFont( "CSIcons", font_data.CSIcons )
	surface.CreateFont( "HL2MPTypeDeath", font_data.HL2MPTypeDeath )

end
game.AddParticles("particles/Muzzle.pcf")
PrecacheParticleSystem("MuzzleFlash1")
PrecacheParticleSystem("Pistol")
PrecacheParticleSystem("Smoke")
PrecacheParticleSystem("Finder")

SWEP.HoldType				= "ar2"
SWEP.DrawWeaponInfoBox  	= false
SWEP.MuzzleEffect			= "rifle" 
SWEP.MuzzleAttachment		= "1" 
SWEP.DefaultClip			= 19
SWEP.Spread					= 0.01
SWEP.ADSPos					= Vector(0,0,0)
SWEP.ADSAngle				= Angle(0,0,0)
SWEP.Primary.Recoil			= 0.2
SWEP.BoltBone				= nil	
SWEP.Switched				= true	
SWEP.Origin					= Vector(2,2,-2)
SWEP.Primary.Cone			= 0.01
SWEP.Secondary.Ammo 		= "none"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Primary.NumShots		= 1
SWEP.Zoom					= 0
SWEP.FireSelect				= 1
SWEP.Reloading				= false		--Is the weapon reloading?
SWEP.CanMuzzle				= 10
SWEP.AttachVector			= Vector(-12,0,7)
SWEP.AttachAngle			= Angle(0,0,0)
SWEP.Attach					= "ValveBiped.Bip01_Spine2" --What part of the body to attach to when not eqquipped.
SWEP.LastRun = false
SWEP.CanFire = true
SWEP.Suppressed = false
SWEP.LastClip = 0
SWEP.LastWeapon = nil

Recoil = 0
local Recoil2 = 0
WepFired = false
local HipCone = 0.5

function SWEP:Initialize()
	self.LastLoad = 0
	self.Loaded = true
	self:AttachmentCheck()
	self.BobScale =  0
	self.SwayScale = 0
	Set = false
	self:SetHoldType( self.HoldType ) 	-- 3rd person hold type
	if CLIENT then
		self.LastClip = self:Clip1()
	end
	if self:GetClass() != "weapon_sh_jetpack" then
	self.Owner.LastWeapon = self
	end
	--[[if CLIENT then
	for k = 1, self.Owner:GetViewModel():GetBoneCount() do
		print(self.Owner:GetViewModel():GetBoneName(k))
	end
	end]]
	self.Owner.JetPack = false
end

SWEP.HitImpact = function( attacker, tr, dmginfo )
--if not SERVER then return end
--Stat tracking, disregard.
	if IsValid( tr.Entity ) and tr.Entity:IsPlayer() then
		attacker:AddStatistic( "bulletshit", 1 )
	end
	
--Damage people in vehicles.
	if (SERVER) and IsValid( tr.Entity ) and tr.Entity:GetClass() == "prop_vehicle_prisoner_pod" and IsValid( tr.Entity:GetDriver() ) then
		local driver = tr.Entity:GetDriver()
		driver:TakeDamage( dmginfo:GetDamage(), dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	end
	
--Position	
	local hit = EffectData()
		hit:SetOrigin(tr.HitPos)
		hit:SetNormal( (tr.StartPos-tr.HitPos):GetNormal() )
		hit:SetScale(20)
		hit:SetEntity( tr.Entity )
--Dirt
	--if tr.MatType == MAT_DIRT then
	--return end
--Ragdolls
	if tr.Entity:GetClass() == ( "prop_ragdoll" ) then
			util.Effect("bloodspray", hit)
			util.Effect("BloodImpact", hit)
			--util.Effect("bloodimpact", hit)
--The Living
		elseif tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			util.Effect("bloodspray", hit)
--Glass			
		elseif tr.MatType == MAT_GLASS then
			util.Effect("GlassImpact", hit)	
--Metal \m/
		elseif tr.MatType == MAT_METAL then
			--util.Effect("hitmetal", hit)
--Plastic			
		elseif tr.MatType == MAT_PLASTIC then
			util.Effect("impactplastic", hit)
--World not skybox
		elseif tr.HitWorld and !tr.HitSky  then
			hit:SetNormal(tr.HitNormal)
			util.Effect("impactdust", hit)
	end
end



function SWEP:AttachmentCheck()
	if !self.VElements then return end

	local primary = GAMEMODE.PrimaryWeapons[self:GetClass()]
	local seconday = GAMEMODE.SecondaryWeapons[self:GetClass()]
	local typ = (primary ~= nil) and 6 or (seconday ~= nil) and 7 
	
	if IsValid( self.Owner ) then
		local names = { "rds", "m145", "suppressor", "scope", "slugs" }

		for _, n in pairs( names ) do
			if not typ then
				self.VElements[n] = nil
				continue
			end

			local var = "attach_".. n.. (typ == 6 and "_primary" or "_secondary")
			if not self.Owner:HasAttachment( typ, self:GetClass(), n ) or self.Owner:GetInfoNum( var, 0 ) == 0 then
				self.VElements[n] = nil
			end
		end

		if self.VElements.suppressor then
			if !self.SuppressedSound  then 
				if self.Pistol then
					self.Primary.Sound = "weapons/suppressed_pistol.wav"
				elseif self.Heavy then
					self.Primary.Sound = "weapons/suppressed_ak.wav" 
				else
					self.Primary.Sound = "weapons/suppressed_ar.wav" 
				end
			else
				self.Primary.Sound = self.SuppressedSound
			end
			
			self.DistantSound = nil
			self.MuzzleEffect = "silenced"
			if !self.Subsonic then 
				self.Primary.Damage = self.Primary.Damage * 0.6
				self.Primary.Recoil = self.Primary.Recoil * 0.8
			end
		end
		local sight = self.VElements.rds and true or self.VElements.m145 and true or self.VElements.scope and true or false
		local pos, ang = 
		self.VElements.m145 and self.VElements.m145.AuxIronSightsPos or 
		self.VElements.rds and self.VElements.rds.AuxIronSightsPos or
		self.VElements.scope and self.VElements.scope.AuxIronSightsPos,
		self.VElements.m145 and self.VElements.m145.AuxIronSightsAng or 
		self.VElements.rds and self.VElements.rds.AuxIronSightsAng or
		self.VElements.scope and self.VElements.scope.AuxIronSightsAng
		self:SetIron(sight, pos, ang)
	end
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSIcons", x + wide*0.5, y + tall*0.1, Color( 255, 220, 0, 255 ), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end


function SWEP:SetIron(sight, pos, ang)
	if !sight then
		if !self.AuxViewModel and self.Rails then table.Merge(self.VElements, self.Rails) end
		
		if self.Irons then table.Merge(self.VElements, self.Irons) end
		
	return end
	
	if pos and ang then
		self.ADSPos = pos
		self.ADSAngle = Angle(ang.x, ang.y, ang.z)
	end
	if IsValid(self.Owner) and self.AuxViewModel then self.Owner:GetViewModel():SetModel(self.AuxViewModel) end 
	if self.AuxViewModel then self.ViewModel = self.AuxViewModel self:SendWeaponAnim( ACT_VM_DRAW ) end
	
	if self.Rails then table.Merge(self.VElements, self.Rails) end
	if self.Riser then table.Merge(self.VElements, self.Riser) end
	
	self.Zoom = self.VElements.m145 and 30 or self.VElements.scope and 60 or 0
	
	local A = self.VElements
	
	if A.m145 and A.m145.RRise then self.RRise, self.RSlide = A.m145.RRise or self.RRise, A.m145.RSlide or self.RSlide end
	if A.rds and A.rds.RRise then self.RRise, self.RSlide = A.rds.RRise or self.RRise, A.rds.RSlide or self.RSlide end

	if self.VElements.suppressor then
		self.Owner.Suppressed = true
	end
end

function SWEP:AdjustMouseSensitivity( )
local CanFire = (CurTime()-self:GetNextPrimaryFire())>=-0.3 and true or false
local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	if self.Owner:KeyDown(IN_ATTACK2)  and !Running then
		return (self.Owner:GetFOV( )-self.Zoom) / self.Owner:GetFOV( )
	end
end

function SWEP:Deploy()
	self.Switched = true
	Reloading = false
	self:SendWeaponAnim(ACT_VM_DEPLOY)
    local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
    self.ReloadingTime = CurTime() + AnimationTime
    self:SetNextPrimaryFire(CurTime() + AnimationTime)
	Set = false
	--self.Owner:GetViewModel():SetModel(self.ViewModel)
	-- Get saved firemode
	if self.FireSelect ~= 0 then
		self.Owner.WeaponFireModes = self.Owner.WeaponFireModes or {}
		local saved_firemode = self.Owner.WeaponFireModes[self.ClassName]
		if saved_firemode == nil then saved_firemode = true end
		self:SetNWBool( "FireMode", saved_firemode )
		self.Primary.Automatic = saved_firemode
	end
	
	if CLIENT then
		self.LastClip = self:Clip1()
	end
	
	self:SetHoldType( self.HoldType )
	
	return true
end

function SWEP:FireMode()
	if self.FireSelect == 0 then return end
	
	if SERVER then
		if self.Primary.Automatic==false and self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) then
			self:SetNWBool( "FireMode", true )
			self.Primary.Automatic = true
			self.Owner:EmitSound( "Weapon_AR2.Empty" )
			
			self.Owner.WeaponFireModes[self.ClassName] = true
		elseif self.Primary.Automatic==true and self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) then
			self:SetNWBool( "FireMode", false)
			self.Primary.Automatic = false
			self.Owner:EmitSound( "Weapon_AR2.Empty" )
			
			self.Owner.WeaponFireModes[self.ClassName] = false
		end
	elseif CLIENT then
		self.Primary.Automatic = self:GetNWBool( "FireMode", true )
	end
end

function SWEP:Holster() 
	if self:Clip1() <= 0 and self:Ammo1() <= 0 then 
		if SERVER then
			self:Remove() 
		end
	end
	self.Reloading = false
	return true
end

function SWEP:Reload()
	if self.HoldType == "revolver" then self:SetHoldType( "pistol") end
	if self.Primary.ClipSize > self.Owner:GetAmmoCount(self.Primary.Ammo) and (self.Owner:GetAmmoCount(self.Primary.Ammo) + self:Clip1()) == self:Clip1() then
	return end
	
	if self.Hacker and self:Clip1() != self.Primary.ClipSize then
		self:EmitSound("Weapon_PhysCannon.Pickup", 100, 100, 1, CHAN_AUTO )
	end
	
	if self.FinishLoad then	--Finished loading shotgun?
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)

		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self.Reloading = false
		self.FinishLoad = false
	return end
	
	if self.Primary.Ammo == "buckshot" then
		if !self.Reloading and !self.Loaded then
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
			self.LastLoad = CurTime() + 0.8
			self.Reloading = true

		end
		if self.Reloading and CurTime() >= self.LastLoad and self:Clip1() == self.Primary.ClipSize - 1 then
			self:SendWeaponAnim(ACT_VM_RELOAD)
			self:SetClip1(self:Clip1() + 1)
			self.Owner:SetAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo)-1,self.Primary.Ammo)
			self.LastLoad = CurTime() + 0.3
		end
		if self.Reloading and CurTime() >= self.LastLoad and self:Clip1() < self.Primary.ClipSize - 1 then
			self:SendWeaponAnim(ACT_VM_RELOAD)
			self:SetClip1(self:Clip1() + 1)
			self.Owner:SetAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo)-1,self.Primary.Ammo)
			self.LastLoad = CurTime() + 0.7
		end
		if self.Reloading and CurTime() >= self.LastLoad and self:Clip1() == self.Primary.ClipSize and !self.Loaded then
			self.FinishLoad = true
			self.Loaded = true
		end
	end
	
	if self:Clip1() == self.Primary.ClipSize then
	return end
	if self.Primary.Ammo == "buckshot" then return end
	self:DefaultReload(ACT_VM_RELOAD)
	self.Owner:AddStatistic( "reloads", 1 )
end
local fuel = 100
local LastTime = 0
function SWEP:Think()
	if !self.AChecked then 
		self:AttachmentCheck()
		self.AChecked = true
	end
	self:FireMode()
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	if self.LastRun and self:GetNextPrimaryFire() < (CurTime() + 0.2) then 
		self:SetNextPrimaryFire(CurTime() + 0.2)
	end
	
	if Running and self.HoldType != "revolver"then
		self:SetHoldType( "passive")
	elseif Running and self.HoldType == "revolver" then
		self:SetHoldType("normal")
	else
		self:SetHoldType( self.HoldType)
	end
	
	if self.Primary.Ammo == "buckshot" and self:Clip1() < self.Primary.ClipSize then
		self.Loaded = false
	end
	
	if self.Reloading then
		self:Reload()
	end
	
	if self.Reloading and self.Owner:KeyPressed(IN_ATTACK) and self.Primary.Ammo == "buckshot" and self:Clip1() > 0 then
		self.Reloading = false
		self.LastLoad = CurTime() + 0.3
	end	
	
	self.LastRun = Running or self.Owner:GetColor().a < 255
end

function SWEP:PrimaryAttack()
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	if Running or self.Owner:GetColor().a < 255 then
	return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self:Clip1() <= 0 then return end
	self:ShootBullet()
end

local LastFired = 0
local Cone = 0
local headfix = 0
function SWEP:ShootBullet( damage, num_bullets, aimcone )
	self.VRecoil = CurTime() - LastFired
	self:EmitSound(self.Primary.Sound)
	if self.Owner:KeyDown(IN_ATTACK2) and self.Primary.Ammo != "buckshot" and self.Primary.Ammo != "pistol" then
		Cone = self.Primary.Cone * 0.1
	elseif self.Owner:KeyDown(IN_ATTACK2) and self.Primary.Ammo == "buckshot" then
		Cone = self.Primary.Cone * 0.5
	elseif self.Owner:KeyDown(IN_ATTACK2) and self.Primary.Ammo == "pistol" then
		Cone = self.Primary.Cone * 1
	else
		Cone = self.Primary.Cone * 0.5
	end
	
	HType = {"passive", "pistol", "revolver","normal"}
	headfix = self.Owner:Alive() and table.HasValue(HType,self.Owner:GetActiveWeapon():GetHoldType()) and 0 or -5
	
	local bullet = {}
	
	local HipMul = self.Owner:KeyDown(IN_ATTACK2) and 0 or self.Primary.Ammo == "buckshot" and 0 or 1
	HipCone = math.Clamp(HipCone-0.002+((CurTime()-LastFired)*0.03),0.01,0.05)*HipMul
	
	if self.VElements.slugs then
		bullet.Num = 1
		bullet.Spread 	= Vector( Cone+HipCone, Cone+HipCone, 0 )*0.1
		bullet.Damage	= self.Primary.Damage*10
	else
		bullet.Num 		= self.Primary.NumShots
		bullet.Spread 	= Vector( Cone+HipCone, Cone+HipCone, 0 )	-- Aim Cone
		bullet.Damage	= self.Primary.Damage
	end
	bullet.Src 		= self.Owner:GetShootPos()+Vector(0,0,headfix) -- Source
	bullet.Dir 		= self.Owner:GetAimVector() -- Dir of bullet
	bullet.Tracer	= 0 -- Show a tracer on every x bullets
	bullet.Force	= 0 -- Amount of force to give to phys objects
	
	bullet.Callback = self.HitImpact
	bullet.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets( bullet )
	self:TakePrimaryAmmo(1)
	if CLIENT then
		self.FireOne = true
	end
	LastFired = CurTime()
	self.Owner:SetAnimation(PLAYER_ATTACK1)


	if SERVER and self.VElements and !self.VElements.suppressor or SERVER and !self.VElements then
	local fx = EffectData()
		fx:SetEntity(self)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.MuzzleAttachment)
		util.Effect("pistol",fx)
	end
	
	if self.VElements and self.VElements.suppressor or self.Subsonic then 
		if SERVER then
			local fx = EffectData()
			fx:SetEntity(self)
			fx:SetOrigin(self.Owner:GetShootPos())
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetAttachment(self.MuzzleAttachment)
			util.Effect("rifle",fx)
		end
	end
end

function SWEP:FireAnimationEvent(position, angles, event, options)
    -- Disables animation based muzzle event
    if (event == 21) then return true end  
    -- Disable thirdperson muzzle flash
    if ( event == 5003 or event == 5011 or event == 5021 or event == 5031 ) then return true end
end

local Shot = false
local SP = game.SinglePlayer()

scale=0
SWEP.MPos = Vector(0,0,0)
function SWEP:ShootEffects()	
	--if self.Reloading then return end
	--WepFired = true
	if !CLIENT then return end
	local Muzzle = vm:GetAttachment(vm:LookupAttachment(self.MuzzleAttachment))
	self.Effect = self.Effect or self.Primary.Ammo == "pistol" and "Pistol" or self.Primary.Ammo == "smg1" and "Pistol" or "MuzzleFlash1"
	
	if Muzzle then
		if !self.VElements or !self.VElements.suppressor then
			ParticleEffect( self.Effect, Muzzle.Pos, vm:GetAngles(), vm)
			ParticleEffect( "Smoke", Muzzle.Pos, vm:GetAngles(), vm)
		elseif self.VElements.suppressor then
			ParticleEffect( "Smoke", Muzzle.Pos+vm:GetAngles():Forward()*self.CanMuzzle, vm:GetAngles(), vm)
		end
	else 
		if self.VElements and !self.VElements.suppressor then
			ParticleEffect( self.Effect, vm:GetPos()+
			vm:GetAngles():Forward()*self.MuzzlePos.x+
			vm:GetAngles():Right()*self.MuzzlePos.y+
			vm:GetAngles():Up()*self.MuzzlePos.z, 
			vm:GetAngles(), 
			vm)
		end
		ParticleEffect( "Smoke", vm:GetPos()+
		vm:GetAngles():Forward()*self.MuzzlePos.x+
		vm:GetAngles():Right()*self.MuzzlePos.y+
		vm:GetAngles():Up()*self.MuzzlePos.z, 
		vm:GetAngles(), 
		vm)
	end
end

function SWEP:SecondaryAttack()
return false
end