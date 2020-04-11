ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Mobile Spawnpoint"
ENT.Author			= "RoaringCow"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

local using = false
ENT.lastusing = false



function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "PlayerOwner")
	self:NetworkVar("Entity", 1, "Activator")
	self:NetworkVar("Bool", 0, "Using")
	self:NetworkVar("Bool", 1, "UsePressed")
	self:NetworkVar("Float", 0, "Cash")
end

