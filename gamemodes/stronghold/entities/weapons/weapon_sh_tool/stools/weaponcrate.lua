--[[
	Changes

	TehBigA - 10/23/12:
		Standardized owner information - No longer uses ENT.SteamID and uses ENT:<Get/Set>Owner<Ent/UID>
]]

TOOL.Category		= ""
TOOL.Name			= "Weapon Crate"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if CLIENT then TOOL.SelectIcon = surface.GetTextureID( "tool/ammocrate_open" ) end

TOOL.NoAuthOnPlayer = true
TOOL.RequiresTraceHit = true
TOOL.TraceDistance = 100

if CLIENT then
	language.Add( "Tool_weaponcrate_name", "Weapon Crate" )
	language.Add( "Tool_weaponcrate_desc", "Create Weapon Crates" )
	language.Add( "Tool_weaponcrate_0", "Click to create a Weapon Crate." )
	language.Add( "Undone_Weapon Crate", "Undone Weapon Crate" )
end

function TOOL:LeftClick( trace )
	if !self.Placeable then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()
	local crate = MakeWeaponCrate( ply, self.PlacePos, self.PlaceAng )
	if !crate then return end
	
	crate:SetMaxHealth( 250 )
	crate:SetHealth( 250 )
	crate.StackBTime = 1
	if ply:GetGroundEntity().StackBTime then
	crate.StackBTime = crate.StackBTime + ply:GetGroundEntity().StackBTime
	end

	undo.Create( "Weapon Crate" )
		undo.AddEntity( crate )
		undo.SetPlayer( ply )
	undo.Finish()
	crate.CanRepair = true
	return true
end

function TOOL:RightClick( trace )
	return self:LeftClick( trace )
end

function TOOL:Think()
	local ply = self:GetOwner()
	local pos, ang = ply:GetShootPos(), ply:GetAimVector()
	local tr = util.TraceLine( {start=pos,endpos=pos+100*ang,filter=ply} )
	self.Placeable = tr.Hit and math.abs( tr.HitNormal.z ) > 0.70
	self.PlacePos = tr.HitPos + Vector( 0, 0, 16 )
	self.PlaceAng = tr.HitNormal:Angle()
	self.PlaceAng.p = self.PlaceAng.p + 90
	self.PlaceAng:RotateAroundAxis( tr.HitNormal, (ply:GetPos()-self.PlacePos):Angle().y + (tr.HitNormal.z == 1 and 0 or 90) )

	if CLIENT then self:DoGhostEntity( self.PlacePos, self.PlaceAng ) end
end

if SERVER then
	function MakeWeaponCrate( ply, pos, ang )
		if ply:GetCount( "sent_weaponcrate" ) > 0 then ply:SendMessage("You already have a crate elsewhere.") return false end
	
		local crate = ents.Create( "sent_weaponcrate" )
		if !crate:IsValid() then return false end
		crate:SetModel( "models/items/ammocrate_smg1.mdl" ) 

		crate:SetOwnerEnt( ply )
		crate:SetOwnerUID( ply:UniqueID() )
		
		crate:SetAngles( ang )
		crate:SetPos( pos )
		crate:Spawn()
		crate:SetPlayer( ply )
		crate.Owner = ply
		crate.CanRepair = true
		for _, v in ipairs(ents.FindInSphere(crate:LocalToWorld(crate:OBBCenter(v)),crate:BoundingRadius())) do
			if v:IsPlayer() then
				if v:IsPlayer() and v:IsColliding( crate ) or crate:IsColliding( v ) then
					ply:SendMessage( "Obstruction detected!", "Crate spawn", false )
					crate:Remove()
				end
			end
		end
		
		ply:AddCount( "sent_weaponcrate", crate )
		
		DoPropSpawnedEffect( crate )

		gamemode.Call( "PlayerSpawnedSENT", ply, crate )

		return crate
	end
elseif CLIENT then
	function TOOL:DoGhostEntity( pos, ang )
		if !self.Placeable then ang = Angle( 0, self:GetOwner():GetAngles().y-180, 0 ) end

		if !IsValid( self.GhostEntity ) then
			self.GhostEntity = ClientsideModel( "models/items/ammocrate_smg1.mdl" )
			self.GhostEntity:SetColor( Color(255,0,0,200) )
			self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.GhostEntity:SetPos( pos )
			self.GhostEntity:SetAngles( ang )
			--self.GhostEntity:Spawn()
			--self.GhostEntity:SetMoveType( MOVETYPE_NONE )
		end
		
		self.GhostEntity:SetPos( pos )
		self.GhostEntity:SetAngles( ang )
		
		if self.Placeable then
			self.GhostEntity:SetColor( Color(0,255,0,200) )
		else
			self.GhostEntity:SetColor( Color(255,0,0,200) )
		end
	end
	
	function TOOL:Holster()
		if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
	end
	
	function TOOL:OnRemove()
		if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
	end
	
	function TOOL:OwnerChanged()
		if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
	end
end

