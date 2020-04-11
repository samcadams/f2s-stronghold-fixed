--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self.Equip = vgui.Create( "DButton", self )
	self.Equip:SetText( "Equip" )
	
	self.Unequip = vgui.Create( "DButton", self )
	self.Unequip:SetText( "Unequip" )
	function self.Unequip:DoClick()
		RunConsoleCommand( "sh_equiphat", "" )
		surface.PlaySound( "buttons/button9.wav" )
	end
	
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetFont( "DermaDefaultBold" )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 190 ) )
	
	self.TimeLabel = vgui.Create( "DLabel", self )
	self.TimeLabel:SetFont( "DermaDefaultBold" )
	self.TimeLabel:SetExpensiveShadow( 1, Color( 0, 0, 0, 190 ) )
	self.TimeLabel:SetText( "00000:00:00" )
	self.TimeLabel:SizeToContents()

	self.m_iIndex = 0
	self.m_PanelList = nil
	self.m_strName = nil
	self.m_Entity = nil
end

function PANEL:Setup( index, panellist, hatid, name, model, doclick )
	self.m_iIndex = index
	self.m_PanelList = panellist
	self.m_strHatId = hatid
	self.m_strName = name
	
	self.Label:SetText( self.m_strName )
	self.Label:SizeToContents()
	self.Equip.DoClick = doclick

	if IsValid( self.m_Entity ) then
		self.m_Entity:Remove()
		self.m_Entity = nil
	end
	
	self.m_Entity = ClientsideModel( model, RENDERGROUP_OPAQUE )
	if !IsValid( self.m_Entity ) then return end
	
	self.m_Entity:SetNoDraw( true )
end

function PANEL:SetHideTime( b )
	self.TimeLabel:SetVisible( !b )
end

function PANEL:Think()
	local ply = LocalPlayer()
	if ply.HatID == self.m_strHatId then
		if !self.Unequip:IsVisible() then
			self.Unequip:SetVisible( true )
		end
	else
		if self.Unequip:IsVisible() then
			self.Unequip:SetVisible( false )
		end
	end
end

function PANEL:Paint( w, h )
	local skin = self:GetSkin()
	
	skin:DrawGenericBackground( 0, 0, w, h, skin.panel_transback )
	
	local timeleft = LocalPlayer():GetLicenseTimeLeft( 5, self.m_strHatId )
	self.TimeLabel:SetText( UTIL_FormatTime(timeleft,true) )
	
	if !IsValid( self.m_Entity ) then return end
	
	self.m_Entity:SetAngles( Angle( 0, RealTime()*10,  0) )
	
	local x, y = self:LocalToScreen( 5, 5 )
	local _, py = self.m_PanelList:LocalToScreen( 0, 0 )
	local _, ph = self.m_PanelList:GetSize()
	local campos = Vector( 50, 50, 120 )
	
	render.SetScissorRect( x, math.max(y,py), x+h-10, math.min(y+h-10,py+ph), true )
	cam.Start3D( campos, (campos * -1):Angle(), 17, x, y, h-10, h-10 )
		render.SuppressEngineLighting( true )
		
		self.m_Entity:DrawModel()

		render.SuppressEngineLighting( false )
	cam.End3D()
	render.SetScissorRect( 0, 0, 0, 0, false )
end

function PANEL:PerformLayout( w, h )
	self.Equip:SetSize( 50, 22 )
	self.Equip:SetPos( w-60, h*0.50-11 )
	
	self.Unequip:SetSize( 50, 22 )
	self.Unequip:SetPos( w-120, h*0.50-11 )
	
	self.Label:SetPos( 70, 10 )
	
	self.TimeLabel:SetPos( 70, 30 )
end

vgui.Register( "sh_hatselection", PANEL, "Panel" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.PlayerModelList = vgui.Create( "DPanelSelect", self )
	self.PlayerModelList:SetPadding( 5 )
	self.PlayerModelList:SetSpacing( 5 )
	self.PlayerModelList:EnableVerticalScrollbar( true )
	self:PopulateModelList( GAMEMODE.PlayerModels, self.PlayerModelList )
	
	self.HatList = vgui.Create( "DPanelList", self )
	self.HatList:SetPadding( 5 )
	self.HatList:SetSpacing( 5 )
	self.HatList:EnableVerticalScrollbar( true )
	
	self.PlayerModelsLabel = vgui.Create( "DLabel", self )
	self.PlayerModelsLabel:SetFont( "Trebuchet19" )
	self.PlayerModelsLabel:SetText( "Player Models" )
	self.PlayerModelsLabel:SizeToContents()
	
	self.HatModelsLabel = vgui.Create( "DLabel", self )
	self.HatModelsLabel:SetFont( "Trebuchet19" )
	self.HatModelsLabel:SetText( "Hat Models" )
	self.HatModelsLabel:SizeToContents()
	
	self.Hats = {}
end

function PANEL:Think()
end

function PANEL:PopulateModelList( tbl, panel )
	local added = {}
	local models = {}
	for simple, model in pairs(tbl) do
		if !table.HasValue( added, model ) then
			local tbl = {
				Simple = simple,
				Model = model
			}
			table.insert( models, tbl )
			table.insert( added, model )
		end
	end
	table.sort( models, function(a,b) return a.Simple < b.Simple end )
	
	for _, v in ipairs(models) do
		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( v.Model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( string.gsub( string.upper(string.sub(v.Simple,1,1))..string.sub(v.Simple,2), "_", " " ) )
		
		panel:AddPanel( icon, { cl_playermodel = v.Simple } )
		
		icon.OldDoClick = icon.DoClick
		function icon:DoClick()
			self:OldDoClick()
			surface.PlaySound( "buttons/button9.wav" )
		end
	end
end

function PANEL:AddHat( listpanel, id, tbl )
	local name = tbl.name
	local model = tbl.model

	local function DoClick()
		surface.PlaySound( "buttons/button9.wav" )
		RunConsoleCommand( "sh_equiphat", id )
		--self.HatPreview:Setup( model, name, 90, Vector(-10,0,-5) )
	end
	
	local panel = vgui.Create( "sh_hatselection" )
	panel:SetSize( 60, 60 )
	panel:Setup( #(listpanel:GetItems() or {}), listpanel, id, name, model, DoClick )
	
	listpanel:AddItem( panel )
	
	return panel
end

function PANEL:RefreshHats()
	local ostime = os.time()

	self.HatList:Clear()
	
	local hats = LocalPlayer():GetLicenses( 5 )
	for hat, time in pairs(hats or {}) do
		if time == -1 or time > ostime then self:AddHat( self.HatList, hat, GAMEMODE.Hats[hat] ) end
	end	
end

function PANEL:PerformLayout( w, h )
	local hw = (w-30)
	local ps = (h-30) * 0.50

	self.PlayerModelList:SetSize( hw, ps-20 )
	self.PlayerModelList:SetPos( 10, 30 )
	
	if self.Overlay then
		self.Overlay:SetSize( hw-4, h-45 )
		self.Overlay:SetPos( hw+22, 32 )
	end

	self.HatList:SetSize( hw, ps-20 )
	self.HatList:SetPos( 10, ps+40 )
	
	self.PlayerModelsLabel:SetPos( 20, 12 )
	
	self.HatModelsLabel:SetPos( 20, ps+22 )
end

vgui.Register( "sh_appearancepanel", PANEL, "DPanel" )