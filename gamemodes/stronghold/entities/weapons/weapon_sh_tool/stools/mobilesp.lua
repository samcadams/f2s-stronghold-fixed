--[[
	Changes

	TehBigA - 10/23/12:
		Standardized owner information - No longer uses ENT.SteamID and uses ENT:<Get/Set>Owner<Ent/UID>
]]

TOOL.Category		= "Fight To Survive"
TOOL.Name			= "Spawn Point/Comm Tower"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if CLIENT then TOOL.SelectIcon = surface.GetTextureID( "tool/spawnpoint" ) end
TOOL.NoAuthOnPlayer = true
TOOL.RequiresTraceHit = true
TOOL.TraceDistance = 100

if CLIENT then
	language.Add( "Tool_mobilesp_name", "Mobile Spawn Point" )
	language.Add( "Tool_mobilesp_desc", "Create Mobile Spawn Points" )
	language.Add( "Tool_mobilesp_0", "Click to create a Spawn Point." )
	language.Add( "Undone_mobile spawn point", "Undone Mobile Spawn point" )
	language.Add( "Undone_base marker", "Undone Comm Tower" )
end

function TOOL:LeftClick( trace )
	if !self.Placeable then return false end
	if CLIENT then return true end
	local ply = self:GetOwner()
	local model = "models/props_combine/combine_mine01.mdl"
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local msp = MakeSpawnPoint( ply, Ang, trace.HitPos, model )
	if IsValid( msp ) then
		msp:SetMaxHealth( 20 )
		msp:SetHealth( 1 )
		msp:SetOwner(ply)
		msp.Owner = ply
		undo.Create( "Mobile Spawn Point" )
			undo.AddEntity( msp )
			undo.SetPlayer( ply )
		undo.Finish()
		ply.PointCount = ply.PointCount + 1
		self.SWEP:SetNextPrimaryFire( CurTime() + 1 )
	end
	
	return true
end

function TOOL:RightClick( trace )
	if !self.Placeable then return false end
	if CLIENT then return true end
	local ply = self:GetOwner()
	local model = "models/props_combine/combine_light001b.mdl"
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local mbm = MakeBaseMarker( ply, Ang, trace.HitPos+Vector(0,0,20), model )
	if IsValid( mbm ) then
		mbm:SetMaxHealth( 500 )
		mbm:SetHealth( 500 )
		mbm.Owner = ply
		undo.Create( "Base Marker" )
			undo.AddEntity( mbm )
			undo.SetPlayer( ply )
		undo.Finish()
		
		self.SWEP:SetNextPrimaryFire( CurTime() + 1 )
	end
	
	return true
end

function TOOL:Think()
	local ply = self:GetOwner()
	local pos, ang = ply:GetShootPos(), ply:GetAimVector()
	local tr = util.TraceLine( {start=pos,endpos=pos+100*ang,filter=ply} )
	self.Placeable = tr.Hit and math.abs( tr.HitNormal.z ) > 0.70
	self.PlacePos = tr.HitPos

	local ang = tr.HitNormal:Angle()
	ang.pitch = ang.pitch + 90
	if CLIENT then self:DoGhostEntity( tr.HitPos, ang ) end
end

local ERROR_SOUND = Sound( "buttons/button10.wav" )
if SERVER then
	function MakeSpawnPoint( ply, Ang, Pos, Model )
		if ply:GetCount( "spawnpoints" ) > 4 then ply:SendMessage("Mobile Spawnpoint limit reached.") return false end
	
		local spawnpoint = ents.Create( "sent_spawnpoint" )
		if !spawnpoint:IsValid() then return end
		spawnpoint:SetModel( Model )
		
		spawnpoint:SetOwnerEnt( ply )
		spawnpoint:SetOwnerUID( ply:UniqueID() )
		
		spawnpoint:SetAngles( Ang )
		spawnpoint:SetPos( Pos+Ang:Up() )
		spawnpoint:Spawn()
		spawnpoint:SetPlayer( ply )
		spawnpoint.Owner = ply
		if !ply.SpawnPoint then ply.SpawnPoint = {} end
		table.insert( ply.SpawnPoint, spawnpoint )
		
		ply:AddCount( "spawnpoints", spawnpoint )
		
		DoPropSpawnedEffect( spawnpoint )

		gamemode.Call( "PlayerSpawnedSENT", ply, spawnpoint )

		return spawnpoint
	end
	
	function MakeBaseMarker( ply, Ang, Pos, Model )
		if ply:GetCount( "markers" ) > 0 then ply:SendMessage("You already have a Comm Tower.") return false end
	
		local marker = ents.Create( "sent_basemarker" )
		if !marker:IsValid() then return end
		marker:SetModel( Model )
		
		marker:SetOwnerEnt( ply )
		marker:SetOwnerUID( ply:UniqueID() )
		
		marker:SetAngles( Angle( 0, ply:GetAngles().y, 0 ) )
		marker:SetPos( Pos )
		marker:Spawn()
		marker:SetPlayer( ply )
		marker.Owner = ply
		marker:SetPlayerOwner(ply)
		marker:SetUseType(SIMPLE_USE)
		for _, v in ipairs(ents.FindInSphere(marker:LocalToWorld(marker:OBBCenter(v)),marker:BoundingRadius())) do
			if v:IsPlayer() then
				if v:IsPlayer() and v:IsColliding( marker ) or marker:IsColliding( v ) then
					ply:SendMessage( "Obstruction detected!", "CommTower spawn", false )
					marker:Remove()
				end
			end
		end

		if !ply.Marker then ply.Marker = {} end
		table.insert( ply.Marker, marker )
		
		ply:AddCount( "markers", marker )
		
		DoPropSpawnedEffect( marker )

		gamemode.Call( "PlayerSpawnedSENT", ply, marker )

		return marker
	end
elseif CLIENT then
	function TOOL:DoGhostEntity( pos, ang )
		if self.SWEP:GetFireMode() == 1 then  
			ang = Angle( 0, self:GetOwner():GetAngles().y, 0 )
			pos = pos + Vector(0,0,20)
		elseif !self.Placeable then
			ang = Angle( 0, 0, 0 ) 
		end
		local model = self.SWEP:GetFireMode() == 1 and "models/props_combine/combine_light001b.mdl" or "models/props_combine/combine_mine01.mdl"
		if !IsValid( self.GhostEntity ) or model !=self.GhostEntity:GetModel() then
			if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
			self.GhostEntity = ClientsideModel( model )
			--self.GhostEntity:SetModel( "models/props_combine/combine_mine01.mdl" )
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