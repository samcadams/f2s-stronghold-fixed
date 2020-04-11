--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

AccessorFunc( PANEL, "m_fAnimSpeed", 	"AnimSpeed" )
AccessorFunc( PANEL, "Entity", 			"Entity" )
AccessorFunc( PANEL, "Weapon", 			"Weapon" )
AccessorFunc( PANEL, "vCamPos", 		"CamPos" )
AccessorFunc( PANEL, "fFOV", 			"FOV" )
AccessorFunc( PANEL, "colAmbientLight", "AmbientLight" )
AccessorFunc( PANEL, "colColor", 		"Color" )
AccessorFunc( PANEL, "bAnimated", 		"Animated" )
AccessorFunc( PANEL, "strText", 		"Text" )
AccessorFunc( PANEL, "strSubText", 		"SubText" )

function PANEL:Init()
	self.Entity = nil
	self.LastPaint = 0
	self.DirectionalLight = {}
	
	self:SetCamPos( Vector( 75, 50, 55 ) )
	self:SetFOV( 70 )
	
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( true )
	
	self:SetAmbientLight( Color( 80, 80, 80 ) )
	
	self:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
	self:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255 ) )
	
	self:SetColor( Color(255,255,255,255) )
	
	self.m_angOffset = Angle( 0, 0, 0 )
	self.m_bMouseHeld = false
end

function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[iDirection] = color
end

function PANEL:SetModel( strModelName, bNotPly )
	if !string.find( strModelName, "player" ) and not bNotPly then
		strModelName = string.gsub( strModelName, "models/player/", "models/player/Group03/" )	
	end
	if strModelName == "models/player/urban.mbl" then
		strModelName = "models/player/urban.mdl"
	end
	if IsValid( self.Entity ) then
		self.Entity:Remove()
		self.Entity = nil		
	end

	if !ClientsideModel then return end
	
	self.Entity = ClientsideModel( strModelName, RENDERGROUP_OPAQUE )
	if !IsValid(self.Entity) then return end
	
	if not bNotPly then
		self.Entity:SetPos( Vector( 0, 8, -30 ) )
	end
	
	if not bNotPly then
		local leye, reye = self.Entity:EyePos()
		self.Entity:SetEyeTarget( leye*1000 )
	end
	
	if not bNotPly then
		self.Entity:SetNoDraw( true )
	end
	
	if not bNotPly then
		local iSeq = self.Entity:LookupSequence( "idle_ar2_aim" );
		if iSeq > 0 then self.Entity:ResetSequence( iSeq ) end
	end
	
	if not bNotPly then
		local iSeq = self.Entity:LookupSequence( "idle_ar2" ); 
		if iSeq > 0 then self.Entity:ResetSequence( iSeq ) end
	end
end

function PANEL:SetWeaponModel( strModelName )
	if !string.find( strModelName, "/w_" ) then
		strModelName = string.gsub( strModelName, "/v_", "/w_" )
	end

	if !IsValid( self.Entity ) then return end

	if IsValid( self.Weapon ) then
		self.Weapon:Remove()
		self.Weapon = nil		
	end

	if !ClientsideModel then return end
	
	self.Weapon = ClientsideModel( strModelName, RENDERGROUP_OPAQUE )
	if !IsValid(self.Weapon) then return end
	
	self.Weapon:SetNoDraw( true )
	
	self.Weapon:SetParent( self.Entity )
	self.Weapon:AddEffects( EF_BONEMERGE )
end

function PANEL:SetHatModel( tblHat )
	if !IsValid( self.Entity ) then return end

	if IsValid( self.Hat ) then
		self.Hat:Remove()
		self.Hat = nil		
	end
	
	self.Hat = ClientsideModel( tblHat.Model, RENDERGROUP_OPAQUE )
	if !IsValid( self.Hat ) then return end
	
	self.Hat:SetNoDraw( true )	
	self.Hat:SetParent( self.Entity )
	
	local BoneIndx = self.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
	local pos, ang = self.Entity:GetBonePosition( BoneIndx )
	local pTable = Hat.PosTable[string.lower(tblHat.Name)]
	
	if self.Hat and self.Hat ~= NULL and self.Hat:IsValid() then
		if pTable[self.Entity:GetModel()] then
			pTable = pTable[self.Entity:GetModel()]
			tblHat.Vec, tblHat.Ang = pTable[2], pTable[1]
		end
		
		local a, v = tblHat.Ang, tblHat.Vec
		
		ang:RotateAroundAxis( ang:Forward(), a.p )
		ang:RotateAroundAxis( ang:Right(), 	 a.y )
		ang:RotateAroundAxis( ang:Up(), 	 a.r )
		
		self.Hat:SetPos( pos +ang:Forward() *v.x -ang:Up() *v.y +ang:Right() *v.z )
		self.Hat:SetAngles( ang )
	end
end

function PANEL:Clear()
	self.strText = "<No Team>"
	self.strSubText = "<No Leader>"
	if IsValid( self.Weapon ) then
		self.Weapon:Remove()
		self.Weapon = nil
	end
	if IsValid( self.Entity ) then
		self.Entity:Remove()
		self.Entity = nil
	end
end

function PANEL:OnMousePressed()
	self:MouseCapture( true )
	self.m_iMouseX, self.m_iMouseY = self:CursorPos()
	self.m_bMouseHeld = true
end

function PANEL:OnMouseReleased()
	self:MouseCapture( false )
	self.m_bMouseHeld = false
end

function PANEL:OnCursorMoved( x, y )
	if self.m_bMouseHeld then
		self.m_angOffset.p = self.m_angOffset.p + (self.m_iMouseY - y) * 0.50
		while self.m_angOffset.p > 180 do self.m_angOffset.p = self.m_angOffset.p - 360 end
		while self.m_angOffset.p < -180 do self.m_angOffset.p = self.m_angOffset.p + 360 end
		self.m_angOffset.y = self.m_angOffset.y + (self.m_iMouseX - x) * 0.50
		while self.m_angOffset.y > 180 do self.m_angOffset.y = self.m_angOffset.y - 360 end
		while self.m_angOffset.y < -180 do self.m_angOffset.y = self.m_angOffset.y + 360 end
	end
	self.m_iMouseX, self.m_iMouseY = x, y
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 4, w*0.125, 0, w*0.75, h, Color(50,50,50,180) )

	if IsValid( self.Entity ) then
		local x, y = self:LocalToScreen( 0, 0 )
		self:LayoutEntity( self.Entity )
		
		local ang = Vector( 0.7103, 0.4735, 0.2509 ):Angle()
		ang = ang + self.m_angOffset
		cam.Start3D( ang:Forward()*100, (ang:Forward()*-1):Angle(), self.fFOV, x, y, w, h )
		
		--cam.Start3D( self.vCamPos, (self.vLookatPos-self.vCamPos):Angle(), self.fFOV, x, y, w, h )
		cam.IgnoreZ( true )
		
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( self.Entity:GetPos() )
		render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
		render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
		render.SetBlend( self.colColor.a/255 )
		
		for i=0, 6 do
			local col = self.DirectionalLight[i]
			if col then
				render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
			end
		end
			
		self.Entity:DrawModel()
		if IsValid( self.Weapon ) then
			self.Weapon:DrawModel()
		end
		
		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
		cam.End3D()
	end
	
	self.LastPaint = RealTime()

	-- Text
	local str = self:GetText()
	surface.SetFont( "DermaDefaultBold" )
	local tw, th = surface.GetTextSize( str )
	local pos = math.floor( w/2-tw/2 )
	
	surface.SetTextPos( pos+1, 5 )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.DrawText( str )
	
	surface.SetTextPos( pos, 4 )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.DrawText( str )
	
	-- Sub Text
	local str = self:GetSubText()
	surface.SetFont( "DermaDefault" )
	local tw, th = surface.GetTextSize( str )
	local pos = math.floor( w/2-tw/2 )
	
	surface.SetTextPos( pos+1, 18 )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.DrawText( str )
	
	surface.SetTextPos( pos, 17 )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.DrawText( str )
	
	if !self.m_bMouseHeld then
		self.m_angOffset.p = math.ApproachAngle( self.m_angOffset.p, 0, self.m_angOffset.p*0.05 )
		self.m_angOffset.y = math.ApproachAngle( self.m_angOffset.y, 0, self.m_angOffset.y*0.05 )
	end
end

function PANEL:RunAnimation()
	self.Entity:FrameAdvance( (RealTime()-self.LastPaint) * self.m_fAnimSpeed )	
end

function PANEL:LayoutEntity( Entity )
	if self.bAnimated then
		self:RunAnimation()
	end
	Entity:SetAngles( Angle( 0, math.sin(RealTime()*0.50)*10,  0) )
end

vgui.Register( "sh_playermodel", PANEL, "Panel" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

AccessorFunc( PANEL, "m_Frame", "Frame" )

function PANEL:Init()
	self.MemberList = vgui.Create( "DListView", self )
	self.MemberList:SetMultiSelect( false )
	self.MemberList:AddColumn( "Members" )
	local column = self.MemberList:AddColumn( "Kills" )
	column:SetFixedWidth( 50 )
	local column = self.MemberList:AddColumn( "Deaths" )
	column:SetFixedWidth( 50 )
	function self.MemberList.OnRowSelected( _, lineid, line )
		self:SetPlayer( line.player )
	end
	
	self.SendPassword = vgui.Create( "DButton", self )
	self.SendPassword:SetText( "Send team password to selected" )
	function self.SendPassword.DoClick()
		local line = self.MemberList:GetLine( self.MemberList:GetSelectedLine() )
		if line and IsValid( line.player ) then
			RunConsoleCommand( "sh_sendteampassword", line.player:EntIndex() )
		end
	end
	
	self.Player = vgui.Create( "sh_playermodel", self )
	self.Player:SetText( "<No Team>" )
	self.Player:SetSubText( "<No Player Selected>" )
	
	self.m_LastUpdate = 0
end

function PANEL:SetTeam( index )
	self.m_Frame.m_iCurrentTeam = -1
	self.MemberList:Clear()
	self.Player:Clear()

	if !GAMEMODE.Teams[index] then return end
	self.m_Frame.m_iCurrentTeam = index

	for _, v in ipairs(team.GetPlayers(index)) do
		local line = self.MemberList:AddLine( v:GetName(), v:Frags(), v:Deaths() )
		line.player = v
	end
	
	self.Player:SetText( team.GetName( index ) )
	self:SetPlayer( GAMEMODE.Teams[index].Leader )
end

function PANEL:SetPlayer( ply )
	if IsValid( ply ) then
		self.Player:SetModel( ply:GetModel() )
		local primary = ply:GetLoadoutPrimary()
		primary = ((primary and primary != "") and primary or "weapon_rc_mp5a4")
		local weptbl = GAMEMODE.PrimaryWeapons[primary]
		if weptbl then
			self.Player:SetWeaponModel( weptbl.model )
		end
		self.Player:SetSubText( ply:GetName() )
	end
end

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 2 then return end
	
	local index = self.m_Frame.m_iCurrentTeam
	if GAMEMODE.Teams[index] then
		for _, ply in pairs(team.GetPlayers(index)) do
			local found = false
			for _, line in pairs(self.MemberList.Lines) do
				if line.player == ply then found = true end
			end
			if !found then
				local line = self.MemberList:AddLine( ply:GetName(), ply:Frags(), ply:Deaths() )
				line.player = ply
			end
		end
		for i, line in pairs(self.MemberList.Lines) do
			if !IsValid( line.player ) then
				self.MemberList:RemoveLine( i )
			else
				line:SetColumnText( 2, line.player:Frags() )
				line:SetColumnText( 3, line.player:Deaths() )
			end
		end
	end
	
	self.m_LastUpdate = CurTime()
end

function PANEL:Paint( w, h )
	local skin = self:GetSkin()
	
	skin:DrawGenericBackground( 0, 0, w-h*0.75-10, 24, skin.bg_color )
	
	local str = (GAMEMODE.Teams[self.m_Frame.m_iCurrentTeam] and GAMEMODE.Teams[self.m_Frame.m_iCurrentTeam].Name or "<No Team>")
	surface.SetFont( "Trebuchet19" )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextPos( 8, 12-th/2 )
	surface.SetTextColor( (GAMEMODE.Teams[self.m_Frame.m_iCurrentTeam] and GAMEMODE.Teams[self.m_Frame.m_iCurrentTeam].Color or Color(255,255,255,255)) )
	surface.DrawText( str )
end

function PANEL:PerformLayout( w, h )
	self.MemberList:SetSize( w-h*0.75-10, h-64 )
	self.MemberList:SetPos( 0, 34 )
	
	self.SendPassword:SetSize( w-h*0.75-10, 22 )
	self.SendPassword:SetPos( 0, h-22 )
	
	self.Player:SetSize( h, h )
	self.Player:SetPos( w-h*0.875, 0 )
end

vgui.Register( "sh_teamjoinpanel", PANEL, "Panel" )