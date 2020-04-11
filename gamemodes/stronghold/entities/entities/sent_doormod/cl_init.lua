include('shared.lua')

function ENT:Initialize()
	self.timer = CurTime() +5.5
	self.IdleMat = "doormod_blocked"
	self.IdleDx8 = "models/props_lab/cornerunit_cloud"
	self.ActiveMat = "doormod_unblocked"
end

function ENT:Draw()
	local ent = self:GetParent()
	
	if IsValid( ent ) then
		if self.Disrupted then
			ent:SetMaterial( self.ActiveMat )
		else
			if render.GetDXLevel() <= 81 then
				ent:SetMaterial( self.IdleDx8 )
			else
				ent:SetMaterial( self.IdleMat )
			end
		end
	end

	self.Entity:DrawModel()
end

function ENT:Think()
	self.Disrupted = self:GetNWBool( "Disrupted" )
end