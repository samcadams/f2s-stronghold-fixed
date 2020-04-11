AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.AttachSound = Sound( "weapons/tripwire/mine_activate.wav" )
ENT.DoorLoop = Sound( "doormod_loop.wav" )
ENT.DisruptLoop = Sound( "doormod_disrupted.wav" )
ENT.PickupSound = Sound( "buttons/button19.wav" )

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_slam.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self.Entity:SetTrigger( false )
	self.Entity:SetOwner(self:GetPlayer())
	self:EmitSound( self.AttachSound )
	self.AmbientSound = CreateSound( self, self.DoorLoop )
	self.AmbientSound:Play()
	self.DisruptSound = CreateSound( self, self.DisruptLoop )
	self.Disrupted = 0
	
	local ent = self:GetParent()
	if !IsValid( ent ) then return end
	ent:SetMaterial( "doormod_blocked" )
	ent:SetKeyValue( "spawnflags", 256 )
	
	-- FUCKING CLIENT
	ent.Disruptor = self
	ent:SetNWEntity( "Disruptor", self )
end

function ENT:OnRemove()
	if self.AmbientSound then
		self.AmbientSound:Stop()
	end
	
	if self.DisruptSound then
		self.DisruptSound:Stop()
	end
	
	local ent = self:GetParent()
	if !IsValid( ent ) then return end
	ent:SetMaterial( "" )
	ent:SetCollisionGroup( COLLISION_GROUP_NONE )
	ent:SetSolid( SOLID_VPHYSICS )
	ent.Disrupted = false
	
	self:EmitSound( self.PickupSound )
end
local wat
util.AddNetworkString( "ActivateDoor" )
net.Receive( "ActivateDoor", function()
	--print( net.ReadEntity() )
	wat = net.ReadEntity()
end )

function ENT:Use( activator, caller )
	if !IsValid( activator ) or !activator:IsPlayer() then return end
	
	local ply = self:GetPlayer()
	if !IsValid( ply ) then
		self:Remove()
		return
	end
	
	
	
	local my_team, other_team = ply:Team(), activator:Team()
	if my_team <= 50 or my_team >= 1000 then
		if ply != activator then
			-- Not owner
			--Error( "Incorrect!" )
			return
		end
	else
		if my_team != other_team then
			-- Not owner or team
			--Error( "Incorrect!" )
			return
		end
	end

	self.Disrupted = CurTime() + 1.50
	local ent = self:GetParent()
	if !IsValid( ent ) then return end
	ent:SetMaterial( "doormod_unblocked" )
	ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
	ent:SetSolid( SOLID_NONE )
	ent.Disrupted = true
	self.AmbientSound:Stop()
	if !self.DisruptSound:IsPlaying() then self.DisruptSound:Play() end
	
	self:SetNWBool( "Disrupted", true )
end

function ENT:Hacked()
	self.Disrupted = CurTime() + 5
	local ent = self:GetParent()
	if !IsValid( ent ) then return end
	ent:SetMaterial( "doormod_unblocked" )
	ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
	ent:SetSolid( SOLID_NONE )
	ent.Disrupted = true
	self.AmbientSound:Stop()
	if !self.DisruptSound:IsPlaying() then self.DisruptSound:Play() end
	self:SetNWBool( "Disrupted", true )
	self:EmitSound( "ambient/machines/thumper_shutdown1.wav", self:GetPos(), 100, 150+math.random(0,20) )
	print("WAT")
end

function ENT:Think()
	if wat == self then self:Hacked() wat = nil end
	if !IsValid( self:GetPlayer() ) then
		self:Remove()
		return
	end
	
	for _, v in ipairs(ents.FindInSphere( self:GetPos(), 1000 )) do
		if v:GetClass() == "sent_basemarker" and !self.SetSecLevel then
			self.Level = 4
			self.SetSecLevel = true
			print(self.Level)
		end
	end
	
	if self.Disrupted != 0 and self.Disrupted <= CurTime() then
		self.Disrupted = 0
		local ent = self:GetParent()
		if !IsValid( ent ) then return end
		ent:SetMaterial( "doormod_blocked" )
		ent:SetCollisionGroup( COLLISION_GROUP_NONE )
		ent:SetSolid( SOLID_VPHYSICS )
		ent.Disrupted = false
		if !self.AmbientSound:IsPlaying() then self.AmbientSound:Play() end
		self.DisruptSound:Stop()
		self:SetNWBool( "Disrupted", false )
	end
end

local function DisruptorUse( ply, ent )
	if IsValid( ent ) and IsValid( ent.Disruptor ) then ent.Disruptor:Use( ply, ply, USE_SET, 0 ) end
end
hook.Add( "PlayerUse", "DisruptorUse", DisruptorUse )

-- Wtf is this? -BIG
--[[self.OldRemove = self.Remove
function ENT:Remove()
print( debug.traceback() )

self:OldRemove()
end]]
