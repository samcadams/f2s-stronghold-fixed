AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )


net.Receive( "CTowerD", function()
	local ent = net.ReadEntity()
	local value = net.ReadFloat()
	ent.Deposit = value
	ent:GetActivator():AddMoney(-value)
	ent:SetUsePressed(false)
	if value > 0 then
		ent:GetPlayerOwner():SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have deposited $]]..sql.SQLStr(math.Round(value,2),true)..[[ in the comm tower.")]] )
		ent:GetPlayerOwner():SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
	end
end )

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create( "sent_basemarker" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	return ent
end

function ENT:Initialize()
	self.Created = CurTime()
	self:SetModel( "models/props_combine/combine_light001b.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self.StartPos = self:GetPos()
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self.players = {}
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableDrag(true)
		phys:EnableMotion(false)
		phys:EnableGravity(false)
	end
	self.Blocked = false
	
	self.PlayerLeft = 0
	self.LastTeamUpdate = 0
	util.AddNetworkString( "CTowerD" )
	self.Deposit = 0
	self.Cash = 0
end
ENT.lastdeposit = 1
function ENT:Think()
	local hp = self:Health()
	local hpmax = self:GetMaxHealth()
	local c = 255 * (hp / hpmax)
	self:SetHealth(math.Clamp(hp + 1,1,hpmax))
	self:SetColor( Color(c,c,c,255) )
	if !IsValid(self.Owner) then
		self:Remove()
	end
	
	if self:GetActivator() == NULL then
		self:SetActivator(self.Owner)
	end
	
	if self.Deposit != self.lastdeposit then
		self:SetUsing(false)
		self.Cash = self.Deposit
		self:SetUsePressed(false)
	end
	if self.Deposit < 0 then
		self.Deposit = 0
		self.Cash = 0
	end
	self.lastdeposit = self.Deposit
	
	self.Cash = self.Cash + (((self.Cash*0.01)*0.003))*self:GetPlayerOwner():GetMultiplier() + (self:GetPlayerOwner().bounty*0.00003)
	self:SetCash(self.Cash)

	if self.Deposit > 0 and GAMEMODE.GameOver then
		self:GetPlayerOwner():AddMoney(self.Deposit)
		self:GetPlayerOwner():SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have been returned $]]..sql.SQLStr(math.Round(self.Deposit,2),true)..[[ from your comm tower. The round has ended.")]] )
		self:GetPlayerOwner():SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		self.Deposit = 0
	end
	print(self,self:GetActivator())
	local Pos = self:GetActivator():GetPos()
	if self:GetActivator() then
		if Pos:Distance(self:GetPos()) > 100 then
			if self:GetUsing() then
				self:SetUsing(false)
			end
		end
	end
	
	--Disable jumppacks
	local radius = math.Clamp(512 + math.Round(self.Deposit / 1000) * 256, 512, 2048)
	local e = ents.FindInSphere(self:GetPos(), radius)
	local playersthistick = {}
	for _,v in pairs(e) do
		if v:IsPlayer() then
			table.insert(playersthistick, v)
			if not table.HasValue(self.players, v) then
				table.insert(self.players, v)
				v:SetNWBool("CanJetPack", false) 
			end
		end
	end
	for _,v in pairs(self.players) do
		if not table.HasValue(playersthistick, v) then
			v:SetNWBool("CanJetPack", true)
			table.RemoveByValue(self.players, v)
		end
	end
end


function ENT:Use( activator, caller)
	self:SetUsePressed(true)
	local trace = activator:GetEyeTrace()
	if trace.Entity != self or (trace.StartPos-trace.HitPos):Length() > 50 or self:GetUsing() then return end
	self:SetUsePressed(false)
	self:SetActivator(activator)
	
	self:SetUsing(true)
	
	
	if self.Cash > 0 then
	activator:SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have collected $]]..sql.SQLStr(math.Round(self.Cash,2),true)..[[ from the comm tower.")]] )
	activator:SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
	activator:AddMoney(self.Cash)
	self.Cash = 0
	self.Deposit = 0
	end
end

function ENT:OnRemove()
	if self.Deposit > 0 then
		self:GetPlayerOwner():SendLua( [[chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),"You have been reimbursed $]]..sql.SQLStr(math.Round(self.Cash,2),true)..[[ from your comm tower.")]] )
		self:GetPlayerOwner():SendLua( [[surface.PlaySound( "buttons/button15.wav" )]] )
		self:GetPlayerOwner():AddMoney(self.Deposit)
	end
end

