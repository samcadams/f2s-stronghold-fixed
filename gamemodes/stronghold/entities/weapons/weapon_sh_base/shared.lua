--[[---------------------------------------------------]]--
--[[--Welcome to RoaringCow's Stronghold weapon base!--]]--
--[[----I realize it's a fuckheap but I don't care.----]]--
--[[---------------------------------------------------]]--

--[[
	GM13 Changes

	surface.CreateFont now uses font data
	Cleaned Code
]]

if (SERVER) then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
	SWEP.Weight 		= 5
elseif (CLIENT) then
	SWEP.DrawAmmo			= true		
	SWEP.DrawCrosshair		= false			
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false
	SWEP.ViewModelFOV		= 60
	SWEP.Slot 				= 0
	SWEP.SlotPos			= 0
	
	-- Moved convars to the rest of them in shared.lua : GM:InitConVars()

	local font_data = {
		["CSKillIcons"] = {
			font 	= "csd",
			size 	=  ScreenScale(60),
			weight 	= 500
		},
	}

	-- This is the font that's used to draw the death icons.
	--surface.CreateFont("csd", ScreenScale(30), 500, true, true, "CSKillIcons")
	-- This is the font that's used to draw the select icons.
	surface.CreateFont( "CSKillIcons", font_data.CSKillIcons )
end

SWEP.HoldType				= "ar2"
SWEP.MuzzleEffect			= "rifle" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2"
SWEP.EjectDelay				= 0
SWEP.Category				= "STRONGHOLD"
SWEP.DrawWeaponInfoBox  	= true
SWEP.Author 				= "RoaringCow"
SWEP.Contact 				= ""
SWEP.Purpose 				= ""
SWEP.Instructions 			= ""
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.Weight 				= 5
SWEP.AutoSwitchTo 			= false
SWEP.AutoSwitchFrom 		= false
SWEP.Primary.Sound 			= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil 		= 1
SWEP.Primary.Damage 		= 0
SWEP.Primary.NumShots 		= 0
SWEP.Primary.Cone 			= 0.0005
SWEP.Primary.ClipSize 		= 0
SWEP.Primary.Delay 			= 0
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "none"
SWEP.Secondary.Ammo 		= "none"
SWEP.bInIronSight 			= false
SWEP.RMod					= 1		--Emulates recoil animation in ironsight if set to 1.
SWEP.SlideLocks				= 0		--Plays the first frame of the reloading animation on the last shot. For pistols.
SWEP.FireSelect				= 1		--Set to 1 if the weapon has a select fire option.
SWEP.Look					= 1		--View model will appear to stay relative to your body while sprinting when you look up/down. 
SWEP.CycleSpeed				= 1		--How fast weapons should play the fire animation. 1 is normal speed.
SWEP.IronCycleSpeed			= 10	--How fast weapons without RMod should fire in ironsight.
SWEP.RKick					= 10	--How much recoil affects rearward travel for RMod.
SWEP.RRise					= 0	--Correct for rise during recoil for RMod.
SWEP.RSlide					= 0		--Correct for left/right movement during recoil for RMod.
SWEP.LastAmmoCount 			= 0	
SWEP.FreeFloatHair			= false	--Set to 1 if the weapon should have a crosshair for ironsight.
SWEP.ModelRunAnglePreset	= 0		--Preset run angles for rifles/pistols/retardedbackwardsmodeledbullshitbecausewhoevermodeledthecssweaponsisfuckingretardedandshoulddie.
SWEP.SMG					= false		--Is the weapon an SMG? Affects hip fire spread and recoil.
SWEP.Sniper					= false		--Is the weapon a Sniper? Affects hip fire spread and recoil.
SWEP.Acog					= false		--Does the weapon use and Acog? Determines 
SWEP.MSniper				= false		--Is the weapon a MSniper(automatic sniper)? Affects hip fire spread and recoil.
SWEP.Reloading				= false		--Is the weapon reloading?
SWEP.InitialScope 			= false		--Has the weapon scoped yet? Used to prevent the scope fade in from playing when you haven't pressed the zoom button.
SWEP.IronSightsPos 			= Vector (0, 0, 0)
SWEP.IronSightsAng 			= Vector (0, 0, 0)
SWEP.Zoom					= 60
SWEP.Attach					= "ValveBiped.Bip01_Spine2" --What part of the body to attach to when not eqquipped.
SWEP.AttachVector			= Vector(-8,-5,5)
SWEP.AttachAngle			= Angle(0,0,0)
SWEP.Subsonic 				= false
local LastRun = 0
local IRONSIGHT_TIME = 0.15
local DashDelta = 0
local Recoil = 0
local Recoil2 = 0
local scale = 0
local scale2 = 0
local Ammo = 0
local LastAmmo = 0
SWEP.LastAmmo = 0
SWEP.time = 0

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

function SWEP:Initialize()
	self:RunAnglePreset()
	self:SetWeaponHoldType( self.HoldType ) 	-- 3rd person hold type
	self.Reloadaftershoot = 0 	-- Can't reload when firing
	self.LastLoad = 0
	self.Loaded = true
	self.DZoom = self.Zoom
	self.Zoom = self.Sniper and !self.MSniper and 30 or self.Sniper and self.MSniper and 50 or self.Zoom
	self.Recoil = 0
	
	--self.IronSightsPos 			= Vector(self.IronSightsPos.x, 0.1, self.IronSightsPos.z)
	if CLIENT then 
		self.DFOV = self.Owner:GetFOV()
		self.ResetBolt = true 
		--self:SetAttachments()
		if self:Clip1() != 0 and self.Owner:GetViewModel() != NULL then
			for i = 1, 128 do self.Owner:GetViewModel():ManipulateBonePosition( i , Vector(0,0,0)) end	
		end
	end
	if self.AuxViewModel then self.DVM = self.ViewModel end
	self:AttachmentCheck()
end

function SWEP:AttachmentCheck()
	if !self.VElements then return end

	local primary = GAMEMODE.PrimaryWeapons[self:GetClass()]
	local seconday = GAMEMODE.SecondaryWeapons[self:GetClass()]
	local typ = (primary ~= nil) and 6 or (seconday ~= nil) and 7 
	
	if IsValid( self.Owner ) then
		local names = { "rds", "m145", "suppressor", "scope" }

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
					--print("WAT")
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


function SWEP:SetIron(sight, pos, ang)
	if !sight then
		if !self.AuxViewModel and self.Rails then table.Merge(self.VElements, self.Rails) end
		
		if self.Irons then table.Merge(self.VElements, self.Irons) end
		
		if IsValid(self.Owner:GetViewModel()) then
		if IsValid(self.Owner) and self.AuxViewModel then 
			self.Owner:GetViewModel():SetModel(self.DVM)
			self.ViewModel = self.DVM self:SendWeaponAnim( ACT_VM_DRAW ) 
		end
		end
		
		--print(self.Owner, self.AuxViewModel, self.Owner:GetViewModel(), self.DVM, self)
		self.Zoom = self.DZoom
		if CLIENT then self:SetAttachments() end 
	return end
	
	if pos and ang then
		self.IronSightsPos = pos
		self.IronSightsAng = ang
	end
	if IsValid(self.Owner) and self.AuxViewModel then self.Owner:GetViewModel():SetModel(self.AuxViewModel) end 
	if self.AuxViewModel then self.ViewModel = self.AuxViewModel self:SendWeaponAnim( ACT_VM_DRAW ) end
	
	if self.Rails then table.Merge(self.VElements, self.Rails) end
	if self.Riser then table.Merge(self.VElements, self.Riser) end
	
	self.Zoom = self.VElements.m145 and 50 or self.VElements.scope and 30 or self.DZoom
	
	local A = self.VElements
	
	if A.m145 and A.m145.RRise then self.RRise, self.RSlide = A.m145.RRise or self.RRise, A.m145.RSlide or self.RSlide end
	if A.rds and A.rds.RRise then self.RRise, self.RSlide = A.rds.RRise or self.RRise, A.rds.RSlide or self.RSlide end
	--print(table.ToString(self.VElements))
	
	if SERVER then return end
	self:SetAttachments()
end

function SWEP:Think()
	--print(self.ViewModel)
	--print(self.Owner:GetFOV())
	if !self.AChecked then 
		self:AttachmentCheck()
		self.AChecked = true
	end
	self:FireMode()
	self:IronSight()
	self.Sprinting = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	self.Walking = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) )
	
	if self.Primary.Ammo == "buckshot" and self:Clip1() < self.Primary.ClipSize then
		self.Loaded = false
	end
	
	if self.Reloading then
		self:Reload()
	end
	
	if self.Reloading and self.Owner:KeyPressed(IN_ATTACK) and self.Primary.Ammo == "buckshot" then
		self.FinishLoad = true
		self.LastLoad = CurTime() + 0.3
	end

	self:FOV()
	self:FOVMOD()
	
	if !self.Owner.Zoomed and !self.Owner.SetZoom then
		self.Owner.Zoomed = true
		self.Owner.SetZoom = true
	end
	
	if self.Sprinting and !self.Pistol then
		self:SetWeaponHoldType( "shotgun" )
	elseif self.Sprinting and self.Pistol then
		self:SetWeaponHoldType( "normal" )
		
	elseif self:GetIronsights() and self.Pistol then
		self:SetWeaponHoldType( "revolver" )
	elseif !self:GetIronsights() and self.Pistol then
		self:SetWeaponHoldType( "pistol" )
	else
		self:SetWeaponHoldType( self.HoldType )
	end		
	LastRun = RealTime()
	if self:GetIronsights() then
	self.Owner.Sighted = true
	else
	self.Owner.Sighted = false
	end
	
	--self.DFOV = self.Owner:GetFOV()
	
end

function SWEP:FOV()
	if self.DZoom == 0 then return end
	if self.UseScope then
		local scopezoom = self.Owner.SZoomed and self.Zoom*0.6 or self.Zoom
		if self:GetIronsights() and !self.ADS then
			if SERVER then self.Owner:SetFOV( scopezoom, 0.2) end
			self.ADS = true
		end
	
		if !self:GetIronsights() and self.ADS then
			if SERVER then self.Owner:SetFOV(0 , 0.2) end
			self.ADS = false
		end
	return end
	
	if self:GetIronsights() and !self.ADS and self.Owner.Zoomed then
		if SERVER then self.Owner:SetFOV(self.Zoom , 0.2) end
		self.ADS = true
	end
	
	if !self:GetIronsights() and self.ADS and self.Owner.Zoomed then
		if SERVER then self.Owner:SetFOV(0 , 0.2) end
		--self.ViewModelFOV = 60
		self.ADS = false
	end
end

function SWEP:FOVMOD()
	if self.DZoom == 0 then return end
	if self.UseScope then 
		if self:GetIronsights() and self.Owner:KeyPressed(IN_USE) then
			if !self.Owner.SZoomed then
				if SERVER then self.Owner:SetFOV(self.Zoom * 0.6 , 0.2) end
				self.Owner.SZoomed = true
			else
				self.Owner.SZoomed = false
				if SERVER then self.Owner:SetFOV(self.Zoom , 0.2) end
			end
		end
	return end
	if self:GetIronsights() and self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_RELOAD) then
		if !self.Owner.Zoomed then
			self.Owner.Zoomed = true
			if SERVER then self.Owner:SetFOV(self.Zoom , 0.2) end
		else
			self.Owner.Zoomed = false
			if SERVER then self.Owner:SetFOV(0 , 0.2) end
		end
	end
end

function SWEP:RunAnglePreset() --Preset run angles for rifles/pistols/retardedbackwardsmodeledbullshitbecausewhoevermodeledthecssweaponsisfuckingretardedandshoulddie.
	if self.ModelRunAnglePreset == 0 then
		self.RunArmAngle  = Angle( 2.5, 50, 6 )
		self.RunArmOffset = Vector( 1, -0.1, -5 )
	end
	if self.ModelRunAnglePreset == 1 then
		self.RunArmAngle  = Angle( -10, -50, -6 )
		self.RunArmOffset = Vector( 1, 2, 5 )
	end
	if self.ModelRunAnglePreset == 2 then
		self.RunArmAngle  = Angle( 10, 60, 5 )
		self.RunArmOffset = Vector( 3, 0, -10 )
	end
	if self.ModelRunAnglePreset == 3 then
		self.RunArmAngle  = Angle( -20, 5, 2 )
		self.RunArmOffset = Vector( -2, 0, 3 )
	end
	if self.ModelRunAnglePreset == 4 then
		self.RunArmAngle  = Angle( -20, 0, 0 )
		self.RunArmOffset = Vector( 0, 0, 0 )
	end
end

function SWEP:IronSight()
	if self.Sprinting then self:SetIronsights( false, self.Owner ) return end
	if !self.Owner:KeyDown(IN_ATTACK2) and self:GetIronsights() then
		self:SetIronsights( false, self.Owner )
	end
	if self.Owner:KeyDown(IN_ATTACK2) and !self:GetIronsights() and !self.Owner:KeyDown(IN_USE) then
		self:SetIronsights( true, self.Owner )
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		self.Owner:GetViewModel():SetPlaybackRate( 0 )
	end
end

function SWEP:AdjustMouseSensitivity( )
	if self.Owner:KeyDown(IN_ATTACK2) then
		return self.Owner:GetFOV( ) / self.Owner:GetInfo( "fov_desired" )
	end
end


function SWEP:Reload()
	--table.remove(self.VElements, table.KeyFromValue(self.VElements, "rail"))
	if self:GetIronsights() and self.Owner:KeyDown(IN_USE) then return end
	if self.Primary.ClipSize > self.Owner:GetAmmoCount(self.Primary.Ammo) and (self.Owner:GetAmmoCount(self.Primary.Ammo) + self:Clip1()) == self:Clip1() then
	return end
	if self.Reloadaftershoot > CurTime() then 
	return end 
	if CLIENT then
		self.ResetBolt = true
	end
	
	if self.FinishLoad then	--Finished loading shotgun?
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self.Reloading = false
		self.FinishLoad = false
	return end
		
	if self.Primary.Ammo == "buckshot" then
		if !self.Reloading and !self.Loaded then
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
			self.LastLoad = CurTime() + 0.3
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
			self.LastLoad = CurTime() + 0.5
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
	if self:GetIronsights() then self.Owner:SetFOV( 0, 0.2 ) end
	
	self:SetIronsights( false )
	self.Owner:AddStatistic( "reloads", 1 )
		

	
	if self.PrintName == "SIG-SAUER P228" and !self.VElements.rds then
		self.IronSightsPos = Vector (4.75, 0, 2.8949)
		self.IronSightsAng = Vector (-0.4, 0, 0)
	end
	
	self.ADS = false
	
end

function SWEP:Deploy()
	if !self.Owner or !self.Owner:Alive() then return false end
	if self:Clip1() != 0 or self:Clip1() == 0 and !self.Pistol then
		for i = 1, 128 do self.Owner:GetViewModel():ManipulateBonePosition( i , Vector(0,0,0)) end	
	end

	-- Get saved firemode
	if self.FireSelect ~= 0 then
		self.Owner.WeaponFireModes = self.Owner.WeaponFireModes or {}
		local saved_firemode = self.Owner.WeaponFireModes[self.ClassName]
		if saved_firemode == nil then saved_firemode = true end
		self:SetNWBool( "FireMode", saved_firemode )
		self.Primary.Automatic = saved_firemode
	end
	
	-- Draw weapon
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Reloadaftershoot = CurTime() + 1
	self:SetIronsights( false )
	self:SetNextPrimaryFire( CurTime() + 1 )
	
	
	if self.PrintName == "SIG-SAUER P228" and !self.VElements.rds then
		self.IronSightsPos = Vector (4.7705, 0, 2.9103)
		self.IronSightsAng = Vector (-0.5696, 0.1092, 0)
	end
	--self.Owner:GetViewModel():SetMaterial("models/props_combine/metal_combinebridge001")
	--self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	return true
	

end

function SWEP:PrimaryAttack()
	if self.Sprinting or self.Reloading then 
	return end

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound(self.Primary.Sound)
	self:RecoilPower()
	self:TakePrimaryAmmo(1)

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNWFloat("LastShootTime", CurTime())
	end
end 

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) and self.Primary.ClipSize > -1 or self.Reloading then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:EmitSound("Weapons/ClipEmpty_Pistol.wav")
		return false
	end
	return true
end
 
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSKillIcons", x + wide*0.5, y + tall*0.3, Color( 255, 220, 0, 255 ), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end
local lastammo = 0
local VelSmooth = 0
--[[function SWEP:GetViewModelPosition( pos, ang )
	if not CLIENT then return end
	
	if (not self.IronSightsPos) then return pos, ang end
	if self:Clip1() < lastammo then Recoil = RealTime() end
	lastammo = self:Clip1()
	scale = math.Clamp((RealTime() - (Recoil+(self.Primary.Recoil*0.3)))*20,-10,0)
	/*Bolt Movement*/
		if self.BoltBone then
			local VM = self.Owner:GetViewModel()
			local Slide = VM:LookupBone("v_weapon."..self.BoltBone)
			local Cap = self.SlideLockPos and -1.5 or -10
			local Length = self.SlideLockPos and 0.14*self.Primary.Recoil or 0.06
			local Speed = self.SlideLockPos and 40 or 80
			local bolt = self:GetIronsights() and math.Clamp((RealTime() - (Recoil+(Length)))*Speed,Cap,0) or 0
			
			if self.SlideLockPos then
				VM:ManipulateBonePosition(  Slide, self.SlideLockPos*-bolt )
			else	
				VM:ManipulateBonePosition(  Slide,  Vector(0,0,bolt) )
			end
			
			if self:Clip1() == 0 and self.SlideLockPos then
				VM:ManipulateBonePosition(  Slide,  self.SlideLockPos )
			end
			
			if self.ResetBolt then
				VM:ManipulateBonePosition(  Slide,  Vector(0,0,0) )
			end	
		end
	/*Bolt Movement*/
	
	local bIron = self.bInIronSight
	if self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED ) then
		if (!self.DashStartTime) then
			self.DashStartTime = RealTime()
		end
		DashDelta = math.Clamp( ((RealTime() - self.DashStartTime) / 0.15) ^ 1.2, 0, 1 )
	else
		if ( self.DashStartTime ) then
			self.DashEndTime = RealTime()
			self.DashStartTime = nil
		end
		if ( self.DashEndTime ) then
			DashDelta = math.Clamp( ((RealTime() - self.DashEndTime) / 0.1) ^ 1.2, 0, 1 )
			DashDelta = 1 - DashDelta
			if ( DashDelta == 0 ) then self.DashEndTime = nil end
		else
			DashDelta = 0
		end
	end
	if ( DashDelta != 0 ) then
		local Down = ang:Up() * -1
		local Right = ang:Right() 
		local Forward = ang:Forward() *2
		pos = pos + ( Down * (self.RunArmOffset.x) + Forward * (self.RunArmOffset.y) + Right * (self.RunArmOffset.z) ) * DashDelta
		local INERT = self.Owner:GetVelocity().z*0.1
		local RUNPOS = math.Clamp(self.Owner:GetAimVector().z*-10, -3,0.3) 
		local RUNPOS2 = math.Clamp(self.Owner:GetAimVector().z*-0.3, -1,0.3) 
		local NEGRUNPOS = math.Clamp(self.Owner:GetAimVector().z*4, -2,2) --ErrorNoHalt(NEGRUNPOS*self.RunArmAngle.pitch)
		local NEGRUNPOS2 = math.Clamp(self.Owner:GetAimVector().z*2, -0.5,2)
		
		if self.bInScope or self.Look == 0 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch  * DashDelta)
		elseif self.ModelRunAnglePreset	== 3 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * NEGRUNPOS2 * DashDelta )
		elseif self.ModelRunAnglePreset == 2 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.yaw * RUNPOS2 * DashDelta )
		elseif self.ModelRunAnglePreset	== 1 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * NEGRUNPOS * DashDelta )--ErrorNoHalt(self.RunArmAngle.pitch)
		elseif self.ModelRunAnglePreset	== 0 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * RUNPOS * DashDelta )
		end
		
		
		--print(math.cos(vel:Length()*FrameTime()*0.0001))
		
		ang:RotateAroundAxis( Down,  self.RunArmAngle.yaw   * DashDelta )
		ang:RotateAroundAxis( Forward,  self.RunArmAngle.roll  * DashDelta ) 
		ang:RotateAroundAxis(Right, self.RunArmAngle.pitch * DashDelta)
	end
	self.Owner.DashDelta = DashDelta
	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()
	end
	
	self.BobScale =  0
	self.SwayScale = 0
	local fIronTime = self.fIronTime or 0
	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end
	local Mul = 1.0
	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then Mul = 1 - Mul end
	end

	local Offset = self.IronSightsPos
	local rmc = self.UseScope and 0 or 0.1
	local amp = self.Pistol and 0.1 or self.RRise*10
	local ampmul = self.Pistol and 20 or 0
	--if (self.IronSightsAng) then
		ang = ang 
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul -(scale*amp*ampmul*self.Primary.Recoil))
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul )
	--end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	if self.PrintName != "M3 SUPER 90" then
		pos = pos + Offset.x * Right * (Mul+(scale*self.RSlide))
		pos = pos + rmc * Forward * (Mul+(scale*self.RKick))
		pos = pos + Offset.z * Up * (Mul+(scale*amp*self.Primary.Recoil))
	else
		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
	end
	if Mul > 0.90 then 
		self.RDDraw = true
	else
		self.RDDraw = false
	end
	self.VMAng = ang
	
	local MFOV = (90 - self.DFOV) * Mul
	
	self.ViewModelFOV = 60 - MFOV
	--print(90 - self.DFOV, MFOV, self.DFOV)
	return pos, ang
	
	
end]]

function SWEP:SetIronsights( b )
	if b and !self.bInIronSight then self.Owner:AddStatistic( "ironsights", 1 ) end
	self.bInIronSight = b
end

function SWEP:GetIronsights()
	return self.bInIronSight
end
local lastclip = 0
local RMul = 0
function SWEP:RecoilPower()
	self.Owner:ViewPunchReset(1000)
	
	local Recoil = self:GetIronsights() and self.Primary.Recoil or 0
	local Punch = Recoil != 0 and 0 or self.Primary.Recoil*0.5
	local Pistol = self.Pistol and 0.1 or 1
	
	if self:Clip1() != lastclip then
		scale2 = math.Clamp((CurTime() - (Recoil2+(self.Primary.Recoil)))*20,-10,0)
		lastclip = self:Clip1()
	end
	
	local IRMul = !self.Pistol and 50 or 30
	
	if scale2 < 0 and !self:GetIronsights() and RMul <= IRMul and RMul > 10 then
		RMul = RMul - (2 - self.Primary.Recoil)
	elseif scale2 < 0 and !self:GetIronsights() then
		RMul = RMul
	else
		RMul = IRMul
	end
	--print(RMul, 2 - self.Primary.Recoil)
	
	local conemod = self.Primary.Ammo != "buckshot" and self.Primary.Cone*RMul*Punch+(self.Primary.Cone*10*Punch*Pistol)+(self.Primary.Cone/2) or self.Primary.Cone
	local eyes = self.Owner:EyeAngles()
	self:CSShootBullet(self.Primary.Damage, Recoil, self.Primary.NumShots, conemod)
	self.Owner:ViewPunch(Angle(math.Rand(-1,1)*Punch,math.Rand(-1,1)*Punch,math.Rand(-1,1)*Punch))
	self.ang = Angle(eyes.p+math.Rand(-10,10)*Punch,eyes.y+math.Rand(-10,10)*Punch,eyes.r+math.Rand(-10,10)*Punch)
	self.amp = 1
	self.time = CurTime() + 1
end

function SWEP:ViewShake()
	if not CLIENT then return end
	
	local length = CurTime() - self.time
	if length < 0 then
	self.Owner:SetEyeAngles((self.ang*length))
	end
	--[[if length < 0 then
	self.Owner:SetEyeAngles(self.ang*self.amp*length)
	end
	
	if length > 0 then return end
	self.Owner:SetEyeAngles(self.ang*self.amp*-length)]]

end

function SWEP:MacShoot()
	local Animation = self.Owner:GetViewModel()
	Animation:SetSequence(Animation:LookupSequence("mac10_fire2"))
end

function SWEP:CSShootBullet(dmg, recoil, numbul, cone, mod)
	if self.Sprinting or self.Reloading then return end
	--if CLIENT then Recoil = CurTime() end
	Recoil2 = CurTime()
	local callback = false
	numbul 			= numbul or 1
	cone 			= cone or 0.01
	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()  -- Source
	bullet.Dir 		= self.Owner:GetAimVector()-Vector(0,0,mod) -- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     -- Aim Cone
	bullet.Tracer 	= 0   						-- Show a tracer on every x bullets
	bullet.Force 	= 0.1 * dmg     			-- Amount of force to give to phys objects
	bullet.Damage 	= dmg						-- Amount of damage to give to the bullets
	bullet.Callback = self.HitImpact
	self.Owner:AddStatistic( "bulletsfired", numbul )

	self.Owner:FireBullets(bullet)					-- Fire the bullets
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if !self:GetIronsights() or self.ViewModel == "models/weapons/v_shot_m3super90.mdl" or self.Sniper then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if self.PrintName == "SIG-SAUER P228" and !self.VElements.rds then
		self.IronSightsPos = Vector (4.7648, -0.0028, 2.92)
		self.IronSightsAng = Vector (-0.6, 0.05, 0)
	end
	end
	--Setting new ironsight angles because of retardedly animated models. Apparently valve employs animators that have never heard of shift+dragging keyframes.
	
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.MuzzleAttachment)
	util.Effect(self.MuzzleEffect,fx)	-- Additional muzzle effects
	
	if CLIENT and self.Owner:KeyDown(IN_ATTACK2) then
	local fx = EffectData()
	fx:SetEntity(self.Owner)
	fx:SetOrigin(self.Owner:EyePos())
	fx:SetNormal(self.Owner:GetAimVector())
		util.Effect(self.MuzzleEffect,fx)	-- Additional muzzle effects
	end
	

	if ( (game.SinglePlayer() and SERVER) or ( !game.SinglePlayer() and CLIENT and IsFirstTimePredicted() ) ) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - math.Rand( recoil * 0.5, recoil * 1 )
		eyeang.yaw = eyeang.yaw + math.Rand( recoil * -0.5, recoil * 0.5 ) 
		self.Owner:SetEyeAngles(eyeang)
		
	end
	
	if CLIENT then
		self.ResetBolt = false
	end
end

function SWEP:FireAnimationEvent(position, angles, event, options)
    -- Disables animation based muzzle event
    --if (event == 20) then return true end  
    --print("WAT")
    -- Disable thirdperson muzzle flash
    if (event == 5001) then return true end
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

function SWEP:Crosshair()
	if !self.RDot then 
		local params = {
		["$basetexture"] = "sprites/glow1",
		["$additive"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		}
		local params2 = {
		["$basetexture"] = "sprites/glow07",
		["$additive"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		}
		self.RDot = CreateMaterial("RedDot6","UnlitGeneric",params)
		self.RDot2 = CreateMaterial("RedDot7","UnlitGeneric",params2)
	end
	
	
	local IsSniper = ( self.Sniper and 2 or 1)
	local Stance = self.Primary.Cone * 1300
	local x = (ScrW() / 2.0) + 1
	local y = (ScrH() / 2.0) + 1
	if self.VElements and self.VElements.rds and self.RDDraw then
		surface.SetDrawColor(math.Rand(200,255),0,0,157)
		surface.SetMaterial(self.RDot)
		--for i = 1, math.random(1,2) do
		
		local ZF = self.Zoom/self.Owner:GetFOV()
		local MD = scale*2*ZF
		local Pistol = 0
		
		if self.Base == "weapon_sh_base_pistol" and self.HoldType != "smg" then 
			Pistol = 1 
		else 
			Pistol = 0 
		end
		
		if !self.DotVis or scale > self.DotVis  then
			surface.DrawTexturedRect( x-(ZF*32-MD*2)/2, y-(ZF*32-MD*2)/2+(scale*30*Pistol), ZF*32-MD*2, ZF*32-MD*2)
			surface.SetDrawColor(math.Rand(200,255),150,150,255)
			surface.SetMaterial(self.RDot2)
			surface.DrawTexturedRect( x-(ZF*16-MD*2)/2, y-(ZF*16-MD*2)/2+(scale*30*Pistol), ZF*16-MD*2, ZF*16-MD*2)
		end
	end
	if self.FreeFloatHair and self:GetIronsights() then
		surface.SetDrawColor( 255, 255, 255, 100 )--white
		surface.DrawRect( x-(Stance*IsSniper)-20+(scale*10),		y-1, 15, 1) --left
		surface.DrawRect( x+(Stance*IsSniper)+4-(scale*10),		y-1, 15, 1) --right
		surface.DrawRect( x-2,				y+(Stance*IsSniper)+2-(scale*10), 3, 10 ) --down

		surface.SetDrawColor( 50, 50, 50, 150 )--grey
		surface.DrawRect( x-(Stance*IsSniper)-5+(scale*10),		y-1, 4, 1) --left
		surface.DrawRect( x+(Stance*IsSniper)-(scale*10),		y-1, 4, 1) --right
		surface.DrawRect( x-2,			y+(Stance*IsSniper)-(scale*10), 3, 2) --down
	end
	--ErrorNoHalt(Stance)

	/*local function OriginCam()
	local CamData = {}
	CamData.angles = LocalPlayer():EyeAngles()
	CamData.origin = LocalPlayer():EyePos()
	CamData.x = (ScrW() / 4) - ((ScrW() / 2)*0.5)
	CamData.y = (ScrH() / 4) - ((ScrH() / 2)*0.5)
	CamData.fov = 30
	CamData.drawviewmodel = true
	CamData.w = ScrW() / 4
	CamData.h = ScrH() / 4
	render.RenderView( CamData )
	end
	hook.Add("HUDPaint", "OriginCam", OriginCam)*/
	
	--render.SetRenderTarget
	
end

function SWEP:CanSecondaryAttack()
	return false
end