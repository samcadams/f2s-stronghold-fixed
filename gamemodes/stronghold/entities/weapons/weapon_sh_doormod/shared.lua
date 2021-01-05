SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.DrawWeaponInfoBox  	= false

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "battery"

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- For view animations and placing
SWEP.PlaceTripMine = 0
SWEP.ResetTripMine = 0
SWEP.ModelRunAnglePreset = 5

SWEP.ThrowSound = Sound( "weapons/slam/throw.wav" )

local BlockedPropModels = {
	"models/props_c17/furniturebed001a.mdl",
	"models/props_c17/furnitureshelf002a.mdl",
	"models/props_c17/lampshade001a.mdl",
	"models/props_doors/door03_slotted_left.mdl",
	"models/props_interiors/furniture_vanity01a.mdl",
	"models/props_junk/pushcart01a.mdl",
	"models/props_trainstation/tracksign02.mdl",
	"models/props_wasteland/kitchen_shelf002a.mdl",
}

function SWEP:Precache()
end

function SWEP:Initialize()
	if CLIENT then
		--[[if self:GetOwner():IsPlatinum() then
		self.Primary.ClipSize = 4
		elseif self:GetOwner():IsGold() then
		self.Primary.Clipsize = 3
		else]]
	self.Primary.ClipSize = 3
	end
end

function SWEP:CheckAmmo()
	local ply = self:GetOwner()
	local count = 0
	for _, v in ipairs(ents.FindByClass("sent_doormod")) do
		if SERVER then
			if v:GetPlayer() == ply then
				count = count + 1
			end
		end
	end
	--[[if ply:IsGold() then
	self:SetClip1( 3-count )
	elseif ply:IsPlatinum() then
	self:SetClip1( 4-count )
	else
	end]]
	self:SetClip1( 3-count )
end

function SWEP:Think()
	if self:Clip1() > 0 and self.PlaceTripMine != 0 and CurTime() >= self.PlaceTripMine then
		self.PlaceTripMine = 0
		self:SendWeaponAnim( (self:Clip1()<3 and ACT_SLAM_THROW_THROW2 or ACT_SLAM_THROW_THROW_ND2) )
		self.ResetTripMine = CurTime() + 0.60
		if SERVER then
			local pos = self.Owner:GetShootPos()
			local tr = util.TraceLine( {start=pos,endpos=pos+45*self.Owner:GetAimVector(),filter=self.Owner,mask=MASK_SHOT} )
			if !tr.Hit or !IsValid( tr.Entity ) or tr.Entity:GetClass() != "prop_physics" then return end
			if !gamemode.Call( "CanTool", self.Owner, tr, "doormod" ) then return end
			if IsValid( tr.Entity.Disruptor ) then return end
			
			local ent = ents.Create( "sent_doormod" )
			ent:SetPos( tr.HitPos + 2.30 * tr.HitNormal )
			ent:SetAngles( tr.HitNormal:Angle() + Angle(90,0,0) )
			ent:SetPlayer( self.Owner )
			ent:SetOwner( self.Owner )
			ent:SetParent( tr.Entity )
			ent:Spawn()
			ent:Activate()
			
			ent:SetOwnerEnt( self.Owner )
			ent:SetOwnerUID( self.Owner:UniqueID() )
			
			self:SetClip1( self:Clip1()-1 )
		end
	elseif self.ResetTripMine != 0 and CurTime() >= self.ResetTripMine then
		self.ResetTripMine = 0
		if self:Clip1() < 1 then
			self:SendWeaponAnim( ACT_SLAM_DETONATOR_IDLE )
		elseif self:Clip1() < 2 then
			self:SendWeaponAnim( ACT_SLAM_DETONATOR_THROW_DRAW )
		else
			self:SendWeaponAnim( ACT_SLAM_THROW_ND_DRAW )
		end
		self:SetNextPrimaryFire( CurTime() + 1.05 )
	end
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
	if self.PlaceTripMine != 0 or self.ResetTripMine != 0 or self:Clip1() <= 0 then return end

	local pos = self.Owner:GetShootPos()
	local tr = util.TraceLine( {start=pos,endpos=pos+45*self.Owner:GetAimVector(),filter=self.Owner,mask=MASK_SHOT} )
	if !tr.Hit or !IsValid( tr.Entity ) or tr.Entity:GetClass() != "prop_physics" then return end
	if !gamemode.Call( "CanTool", self.Owner, tr, "doormod" ) then return end
	
	if table.HasValue( BlockedPropModels, tr.Entity:GetModel() ) then
		self.Owner:SendMessage( "Can not modulate this material.", "Door Modulator", false )
		return
	end
	
	if (SERVER and IsValid( tr.Entity.Disruptor )) or (CLIENT and IsValid( tr.Entity:GetNetworkedEntity("Disruptor",nil) )) then return end
	
	self:SendWeaponAnim( (self:Clip1()<2 and ACT_SLAM_THROW_THROW or ACT_SLAM_THROW_THROW_ND) )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if SERVER then
		timer.Simple( 0.20,
			function()
				if !IsValid( self ) then return end
				self:EmitSound( self.ThrowSound )
			end )
	end
	
	-- Make sure they can't fire again
	self:SetNextPrimaryFire( CurTime() + 999 )
	self.PlaceTripMine = CurTime() + 0.25
end

function SWEP:SecondaryAttack()
	if self.PlaceTripMine != 0 then return end
	
	local pos = self.Owner:GetShootPos()
	local tr = util.TraceLine( {start=pos,endpos=pos+45*self.Owner:GetAimVector(),filter=self.Owner,mask=MASK_SHOT} )
	if !tr.Hit or !IsValid( tr.Entity ) then return end
	
	if tr.Entity:GetClass() == "sent_g4p_doormod" then
		local disruptor = tr.Entity
		if SERVER then
			if IsValid( disruptor ) and disruptor:GetPlayer() == self.Owner then
				disruptor:Remove()
				self:SetClip1( self:Clip1()+1 )
				if self:Clip1() > 1 then
					self:SendWeaponAnim( ACT_SLAM_THROW_ND_DRAW )
				else
					self:SendWeaponAnim( ACT_SLAM_THROW_DRAW )
				end
				self:SetNextPrimaryFire( CurTime() + 1.05 )
			end
		end
	elseif tr.Entity:GetClass() == "prop_physics" then
		local disruptor = (SERVER and tr.Entity.Disruptor) or (CLIENT and tr.Entity:GetNetworkedEntity("Disruptor",nil)) or nil
		if SERVER then
			if IsValid( disruptor ) and disruptor:GetPlayer() == self.Owner then
				disruptor:Remove()
				self:SetClip1( self:Clip1()+1 )
				if self:Clip1() > 1 then
					self:SendWeaponAnim( ACT_SLAM_THROW_ND_DRAW )
				else
					self:SendWeaponAnim( ACT_SLAM_THROW_DRAW )
				end
				self:SetNextPrimaryFire( CurTime() + 1.05 )
			end
		end
	end
end

function SWEP:Deploy()
	self:CheckAmmo()
	if self:Clip1() < 1 then
		self:SendWeaponAnim( ACT_SLAM_DETONATOR_DRAW )
	elseif self:Clip1() < 3 then
		self:SendWeaponAnim( ACT_SLAM_DETONATOR_THROW_DRAW )
	else
		self:SendWeaponAnim( ACT_SLAM_THROW_ND_DRAW )
	end
	self:SetNextPrimaryFire( CurTime() + 1.05 )
	return true
end

function SWEP:Holster()
	return self.PlaceTripMine == 0
end

function SWEP:OnRemove()
end

function SWEP:OwnerChanged()
end