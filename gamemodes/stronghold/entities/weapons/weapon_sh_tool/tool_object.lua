--[[---------------------------------------------------------
   Updates which stage a tool is at
---------------------------------------------------------]]--
function ToolObj:UpdateData()
	self:SetStage( self:NumObjects() )
end
	
--[[---------------------------------------------------------
   Sets which stage a tool is at
---------------------------------------------------------]]--
function ToolObj:SetStage( i )
	if SERVER then
		self:GetWeapon():SetNWInt( "Stage", i, true )
	end
end

--[[---------------------------------------------------------
   Gets which stage a tool is at
---------------------------------------------------------]]--
function ToolObj:GetStage()
	return self:GetWeapon():GetNWInt( "Stage", 0 )
end

--[[---------------------------------------------------------
   ClearObjects - clear the selected objects
---------------------------------------------------------]]--
function ToolObj:ClearObjects()
	self:ReleaseGhostEntity()
	self.Objects = {}
	self:SetStage( 0 )
end

--[[---------------------------------------------------------
	Since we're going to be expanding this a lot I've tried
	to add accessors for all of this crap to make it harder
	for us to mess everything up.
---------------------------------------------------------]]--
function ToolObj:GetEnt( i )
	if !self.Objects[i] then return NULL end
	return self.Objects[i].Ent
end

--[[---------------------------------------------------------
	Returns the world position of the numbered object hit
	We store it as a local vector then convert it to world
	That way even if the object moves it's still valid
---------------------------------------------------------]]--
function ToolObj:GetPos( i )
	if !IsValid( self.Objects[i].Ent ) then
		return self.Objects[i].Pos
	else
		if IsValid( self.Objects[i].Phys ) then
			return self.Objects[i].Phys:LocalToWorld( self.Objects[i].Pos )
		else
			return self.Objects[i].Ent:LocalToWorld( self.Objects[i].Pos )
		end
	end
end

--[[---------------------------------------------------------
	Returns the local position of the numbered hit
---------------------------------------------------------]]--
function ToolObj:GetLocalPos( i )
	return self.Objects[i].Pos
end

--[[---------------------------------------------------------
	Returns the physics bone number of the hit (ragdolls)
---------------------------------------------------------]]--
function ToolObj:GetBone( i )
	return self.Objects[i].Bone
end

function ToolObj:GetNormal( i )
	if !IsValid( self.Objects[i].Ent ) then
		return self.Objects[i].Normal
	else
		local norm
		if IsValid( self.Objects[i].Phys ) then
			norm = self.Objects[i].Phys:LocalToWorld(self.Objects[i].Normal)
		else
			norm = self.Objects[i].Ent:LocalToWorld(self.Objects[i].Normal)
		end
		return norm - self:GetPos(i)
	end
end

--[[---------------------------------------------------------
	Returns the physics object for the numbered hit
---------------------------------------------------------]]--
function ToolObj:GetPhys( i )
	if self.Objects[i].Phys == nil then
		return self:GetEnt( i ):GetPhysicsObject()
	end
	return self.Objects[i].Phys
end

--[[---------------------------------------------------------
	Sets a selected object
---------------------------------------------------------]]--
function ToolObj:SetObject( i, ent, pos, phys, bone, norm )
	self.Objects[i] = {}
	self.Objects[i].Ent = ent
	self.Objects[i].Phys = phys
	self.Objects[i].Bone = bone
	self.Objects[i].Normal = norm

	// Worldspawn is a special case
	if !IsValid( ent ) then
		self.Objects[i].Phys = nil
		self.Objects[i].Pos = pos
	else
		norm = norm + pos
		if IsValid( phys ) then
			self.Objects[i].Normal = self.Objects[i].Phys:WorldToLocal( norm )
			self.Objects[i].Pos = self.Objects[i].Phys:WorldToLocal( pos )
		else
			self.Objects[i].Normal = self.Objects[i].Ent:WorldToLocal( norm )
			self.Objects[i].Pos = self.Objects[i].Ent:WorldToLocal( pos )
		end
	end
end

--[[---------------------------------------------------------
	Returns the number of objects in the list
---------------------------------------------------------]]--
function ToolObj:NumObjects()
	if CLIENT then
		return self:GetStage()
	end
	return #self.Objects
end

if CLIENT then
	--[[---------------------------------------------------------
	   Tool should return true if freezing the view angles
	---------------------------------------------------------]]--
	function ToolObj:FreezeMovement()
			return false 
	end

	--[[---------------------------------------------------------
	   The tool's opportunity to draw to the HUD
	---------------------------------------------------------]]--
	function ToolObj:DrawHUD()
	end
end

--[[---------------------------------------------------------
   Starts up the ghost entity
   The most important part of this is making sure it gets deleted properly
---------------------------------------------------------]]--
function ToolObj:MakeGhostEntity( model, pos, angle )
	util.PrecacheModel( model )
	
	// We do ghosting serverside in single player
	// It's done clientside in multiplayer
	if SERVER and !game.SinglePlayer() then return end
	if CLIENT and game.SinglePlayer() then return end
	
	// Release the old ghost entity
	self:ReleaseGhostEntity()
	
	// Don't allow ragdolls/effects to be ghosts
	if !util.IsValidProp( model ) then return end
	
	if SERVER then
		self.GhostEntity = ents.Create( "prop_physics" )
	elseif CLIENT then
		self.GhostEntity = ClientsideModel( model )
	end
	
	// If there's too many entities we might not spawn..
	if !self.GhostEntity:IsValid() then
		self.GhostEntity = nil
		return
	end
	
	self.GhostEntity:SetModel( model )
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn()
	
	self.GhostEntity:SetSolid( SOLID_VPHYSICS );
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true );
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.GhostEntity:SetColor( Color(255,255,255,150) )
end

--[[---------------------------------------------------------
   Starts up the ghost entity
   The most important part of this is making sure it gets deleted properly
---------------------------------------------------------]]--
function ToolObj:StartGhostEntity( ent )
	// We can't ghost ragdolls because it looks like ass
	local class = ent:GetClass()
	
	// We do ghosting serverside in single player
	// It's done clientside in multiplayer
	if SERVER and !game.SinglePlayer() then return end
	if CLIENT and game.SinglePlayer() then return end
	
	self:MakeGhostEntity( ent:GetModel(), ent:GetPos(), ent:GetAngles() )
end

--[[---------------------------------------------------------
   Releases up the ghost entity
---------------------------------------------------------]]--
function ToolObj:ReleaseGhostEntity()
	if self.GhostEntity then
		if !self.GhostEntity:IsValid() then self.GhostEntity = nil return end
		self.GhostEntity:Remove()
		self.GhostEntity = nil
	end
	
	if self.GhostEntities then
		for k,v in pairs(self.GhostEntities) do
			if v:IsValid() then v:Remove() end
			self.GhostEntities[k] = nil
		end
		
		self.GhostEntities = nil
	end
	
	if self.GhostOffset then
		for k, v in pairs(self.GhostOffset) do
			self.GhostOffset[k] = nil
		end
	end
end

--[[---------------------------------------------------------
   Update the ghost entity
---------------------------------------------------------]]--
function ToolObj:UpdateGhostEntity()
	if self.GhostEntity == nil then return end
	if !self.GhostEntity:IsValid() then self.GhostEntity = nil return end
	
	local tr = utilx.GetPlayerTrace( self:GetOwner(), self:GetOwner():GetCursorAimVector() )
	local trace = util.TraceLine( tr )
	if !trace.Hit then return end
	
	local Ang1, Ang2 = self:GetNormal(1):Angle(), (trace.HitNormal * -1):Angle()
	local TargetAngle = self:GetEnt(1):AlignAngles( Ang1, Ang2 )
	
	self.GhostEntity:SetPos( self:GetEnt(1):GetPos() )
	self.GhostEntity:SetAngles( TargetAngle )
	
	local TranslatedPos = self.GhostEntity:LocalToWorld( self:GetLocalPos(1) )
	local TargetPos = trace.HitPos + (self:GetEnt(1):GetPos() - TranslatedPos) + (trace.HitNormal)
	
	self.GhostEntity:SetPos( TargetPos )
end
