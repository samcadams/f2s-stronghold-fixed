--[[
	Changes

	TehBigA - 10/23/12:
		Standardized owner information - No longer uses ENT.SteamID and uses ENT:<Get/Set>Owner<Ent/UID>
		Increased auto removal to 30 seconds
]]

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create( "sent_spawnpoint" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	if !ply.SpawnPoint then ply.SpawnPoint = {} end
	ply.SpawnPoint[self:EntIndex()] = self
	print(ent.Owner)
	return ent
end

function ENT:Initialize()
	self.Created = CurTime()
	self:SetModel( "models/props_combine/combine_mine01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self.StartPos = self:GetPos()
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableDrag(true)
		phys:EnableMotion(true)
		phys:EnableGravity(false)
	end
	self.Blocked = false
	
	self.PlayerLeft = 0
	self.LastTeamUpdate = 0
	self:SetNWEntity("owner", self.Owner)
	
end

function ENT:Use()
return false
end


function ENT:OnRemove()
	local ply = self.Owner
	self.Killer = self.Killer or ply.LastAttacker
	if !IsValid( ply ) or !ply.SpawnPoint then return end
	
	ply.SpawnPoint[self:EntIndex()] = nil
	for k,v in ipairs( ply.SpawnPoint) do
		if !IsValid(v) then
			table.remove(ply.SpawnPoint,ply.SpawnPoint[self:EntIndex()])
		end
	end
	ply.PointCount = ply.PointCount-1
	
	if ply.PointCount == 0 and ply:Alive() and ply.bounty > 0 and self.Killer and self.Killer != ply then
		self.Killer:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"That was ]]..sql.SQLStr(ply:GetName(),true)..[['s last Spawn Point! Kill them to take the bounty!")]] )
		self.Killer = NULL
	end

	if ply.PointCount == 0 and !ply:Alive() and ply.bounty > 0 then
		self.Killer:AddMoney(ply.bounty)
		self.Killer:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have been awarded $]]..sql.SQLStr(ply.bounty,true)..[[ for killing ]]..sql.SQLStr(ply:GetName(),true)..[[!")]] )
		self.Killer:SendLua( [[surface.PlaySound( "/items/suitchargeok1.wav" )]] )
		ply.binfo = nil
		ply.bounty = 0
		net.Start( "PlayerBounty" )
			net.WriteEntity( ply )
			net.WriteFloat( ply.bounty )
			net.WriteBool(true)
		net.Broadcast()
	end
	
	print(ply:GetName().." has "..ply.PointCount.." spawn points.")
end

function ENT:OnTakeDamage(dmg)
	if dmg:GetAttacker() != self.Owner then
		self.Killer = dmg:GetAttacker()
	end
end

function ENT:Think()
	local ply = self.Owner
	if !IsValid( ply ) and self:GetOwnerUID() != nil then
		if self.PlayerLeft == 0 then
			self.PlayerLeft = CurTime()
		elseif CurTime() - self.PlayerLeft > 30 then
			self:Remove()
		end
		return
	end
	if self:GetPos() != self.StartPos then ply:SendMessage( "Obstruction detected.", "Spawnpoint", false ) self:Remove() end
	self:SetMoveType( MOVETYPE_NONE )
	local hp = self:Health()
	local hpmax = self:GetMaxHealth()
	local c = 255 * (hp / hpmax)
	self:SetHealth(math.Clamp(hp + 0.25,1,hpmax))
	self:SetColor( Color(c,c,c,255) )
	
	--[[local pos, up = self:LocalToWorld( self:OBBCenter() ), self:GetAngles():Up()
	local tr = util.TraceLine( {start=pos,endpos=pos+60*up,filter=self} )
	if tr.Hit and !self.Blocked then
		self.Blocked = true
		ply.SpawnPoint[self:EntIndex()] = nil
	elseif !tr.Hit and self.Blocked then
		self.Blocked = false
		ply.SpawnPoint[self:EntIndex()] = self
	end]]
	
	if CurTime() - self.LastTeamUpdate > 5 then
		self:SetTeam( ply:Team() )
		self.LastTeamUpdate = CurTime()
	end
	
end
