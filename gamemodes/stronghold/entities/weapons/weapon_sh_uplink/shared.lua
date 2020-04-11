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
SWEP.ViewModel 				= "models/weapons/v_slam.mdl"
SWEP.WorldModel 			= "models/weapons/w_slam.mdl"

SWEP.Primary.ClipSize 		= 1
SWEP.Primary.DefaultClip 	= 2
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "battery"

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
	if self:Clip1() < 1 then return end

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()
	local ang = dir:Angle()

	local ent = ents.Create( "sent_uplink" )
	ent:SetAngles( Angle(0, ang.y -180, 0) )
	ent:SetPos( pos )
	ent:SetPlayer( self.Owner )
	ent.Owner = self.Owner
	ent:Spawn()
	ent:Activate()

	undo.Create( "uplink" )
		undo.AddEntity( ent )
		undo.AddFunction( function( tbl )
			print( tbl, tbl.Owner )

			tbl.Owner:Give( "weapon_sh_uplink" )
			tbl.Owner:SelectWeapon( "weapon_sh_uplink" )
		end )
		undo.SetCustomUndoText( "Undone uplink" )
		undo.SetPlayer( self.Owner )
	undo.Finish()

	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:ApplyForceCenter( dir *phys:GetMass() *250 )
		phys:SetDamping( 0, phys:GetMass() *750 )
	end

	self:SetNextPrimaryFire( CurTime() +1.05 )
	self.Owner:StripWeapon( self:GetClass() )
end

function SWEP:SecondaryAttack()
end