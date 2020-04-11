--[[
	Changes

	TehBigA - 10/23/12:
		Standardized owner information - No longer uses ENT.SteamID and uses ENT:<Get/Set>Owner<Ent/UID>
]]

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Weapon Crate"
ENT.Author			= "RoaringCow"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.AutomaticFrameAdvance = true 

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

ENT.OpenSnd = Sound( "AmmoCrate.Open" )
ENT.CloseSnd = Sound( "AmmoCrate.Close" )

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create( "sent_weaponcrate" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	if !ply.WeaponCrate then ply.WeaponCrate = {} end
	ply.WeaponCrate[self:EntIndex()] = self
	
	
	return ent
end

function ENT:Initialize(ply)
	self.Created = CurTime()

	self:SetModel( "models/items/ammocrate_smg1.mdl" )
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	if CLIENT then
		if true then return end
		-- This is broken, wtf
	elseif SERVER then
		local physobj = self:GetPhysicsObject()
		if IsValid( physobj ) then
			physobj:Wake()
			physobj:EnableMotion( false )
		end
		
		self.PlayerLeft = 0
	end
end

function ENT:Use( activator, caller )
	if IsValid( activator ) and activator:IsPlayer() and activator.WeaponLoadout != true then
		local trace = activator:GetEyeTrace()
		if trace.Entity != self or (trace.StartPos-trace.HitPos):Length() > 50 then return end
	
		activator.WeaponLoadout = true
		activator:ConCommand( "sh_loadout" )
		self:Open( ent )
		self.activator = activator
	end
end

function ENT:Open( ply )
	self:ResetSequence(self:LookupSequence( "Open" ))
	if self.Closed then
		self:EmitSound( self.OpenSnd )
	end
	self.Closed = false
end

function ENT:Close()
	if self.Closed or !IsValid( self.activator ) then return end
	local trace = self.activator:GetEyeTrace()
	if trace.Entity != self or (trace.StartPos-trace.HitPos):Length() > 50 then
		self:ResetSequence(self:LookupSequence( "Close" ))
		timer.Simple( 0.5, function() if not IsValid( self ) then return end self:EmitSound( self.CloseSnd ) end )
		self.Closed = true
		self.activator = nil
	end
end

function ENT:Think()
	self:Close()
	
	if SERVER then
		local ply = self.Owner
		if !IsValid( ply ) and self:GetOwnerUID() != nil then
			if self.PlayerLeft == 0 then
				self.PlayerLeft = CurTime()
			elseif CurTime() - self.PlayerLeft > 120 then
				self:Remove()
			end
			return
		end
	end
	self:NextThink(CurTime());  return true; 
end