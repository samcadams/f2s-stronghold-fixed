ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Mobile Spawnpoint"
ENT.Author			= "RoaringCow / TehBigA"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 50, "Team" ) --AccessorFuncNW( ENT, "m_iTeam", "Team", 50, FORCE_NUMBER )
end
