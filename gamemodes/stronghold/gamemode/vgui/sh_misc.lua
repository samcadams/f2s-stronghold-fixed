--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

local PANEL = {}

function PANEL:Init()
end

function PANEL:ChooseOption( value, index )
	if self.Menu then
		self.Menu:Remove()
		self.Menu = nil
	end

	self:SetText( value )
	--self.TextEntry:ConVarChanged( value )
	
	if self.m_strConVar and self.m_strConVar != "" then
		RunConsoleCommand( self.m_strConVar, index )
	end

	self:OnSelect( index, value, self.Data[index] )
end

function PANEL:SetConVar( convar )
	self.m_strConVar = convar
	local index = GetConVarNumber( convar )
	self:ChooseOption( self:GetOptionText(index), index )
end

function PANEL:ConVarNumberThink()
	if !self.m_strConVar then return end	
	
	local strValue = GetConVarNumber( self.m_strConVar )
	if self.m_strConVarValue == strValue then return end
	
	self.m_strConVarValue = strValue
	self:SetValue( self:GetOptionText( tonumber(self.m_strConVarValue) ) )
end

function PANEL:UpdateColours( skin )
	if ( self:GetDisabled() )						then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
	if ( self.Depressed or self.m_bSelected )		then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
	if ( self.Hovered )								then return self:SetTextStyleColor( skin.Colours.Button.Hover ) end

	return self:SetTextStyleColor( skin.colTextEntryText )
end

vgui.Register( "sh_combobox", PANEL, "DComboBox" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
end

function PANEL:ApplySchemeSettings()

	local ExtraInset = 10

	if ( self.Image ) then
		ExtraInset = ExtraInset + self.Image:GetWide()
	end
	
	local Active = self:GetPropertySheet():GetActiveTab() == self
	
	self:SetTextInset( ExtraInset, 4 )
	local w, h = self:GetContentSize()
	h = 24
	--if ( Active ) then h = 28 end

	self:SetSize( w + 10, h )
	
	
	DLabel.ApplySchemeSettings( self )
		
end

vgui.Register( "sh_propertysheet_tab", PANEL, "DTab" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
end

function PANEL:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )
	if !IsValid( panel ) then return end

	local Sheet = {}
	
	Sheet.Tab = vgui.Create( "sh_propertysheet_tab", self )
	Sheet.Tab:SetTooltip( Tooltip )
	Sheet.Tab:Setup( label, self, panel, material )
	
	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetPos( self:GetPadding(), 20 + self:GetPadding() )
	
	panel:SetParent( self )
	
	table.insert( self.Items, Sheet )
	
	if !self:GetActiveTab() then
		self:SetActiveTab( Sheet.Tab )
	end
	
	self.tabScroller:AddPanel( Sheet.Tab )
	
	return Sheet
end

function PANEL:CrossFade( anim, delta, data )
	local old = data.OldTab:GetPanel()
	local new = data.NewTab:GetPanel()
	
	if anim.Finished then
		old:SetVisible( false )
		new:SetAlpha( 255 )
		
		old:SetZPos( 0 )
		new:SetZPos( 0 )
		return
	end
	
	if anim.Started then
		old:SetZPos( 0 )
		new:SetZPos( 1 )
		
		old:SetAlpha( 255 )
		new:SetAlpha( 0 )
	end
	
	old:SetVisible( true )
	new:SetVisible( true )
	
	old:SetAlpha( 255 * (1-delta) )
	new:SetAlpha( 255 * delta )
end

function PANEL:PerformLayout( w, h )
	local ActiveTab = self:GetActiveTab()
	local Padding = self:GetPadding()
	if !ActiveTab then return end

	ActiveTab:InvalidateLayout( true )

	self.tabScroller:StretchToParent( Padding, 0, Padding, nil )
	self.tabScroller:SetTall( ActiveTab:GetTall() )
	self.tabScroller:InvalidateLayout( true )

	for k, v in pairs(self.Items) do
		v.Tab:GetPanel():SetVisible( false )
		v.Tab:SetZPos( 100 - k )
		v.Tab:ApplySchemeSettings()
	end

	if ActiveTab then
		local ActivePanel = ActiveTab:GetPanel()

		ActivePanel:SetVisible( true )
		ActivePanel:SetPos( 10, ActiveTab:GetTall() + 10 )

		if !ActivePanel.NoStretchX then 
			ActivePanel:SetWide( w - 20 )
		else
			ActivePanel:CenterHorizontal()
		end

		if !ActivePanel.NoStretchY then 
			ActivePanel:SetTall( h - ActiveTab:GetTall() - 20 ) 
		else
			ActivePanel:CenterVertical()
		end

		ActivePanel:InvalidateLayout()
		ActiveTab:SetZPos( 100 )
	end
	self.animFade:Run()
end

vgui.Register( "sh_propertysheet", PANEL, "DPropertySheet" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self:SetSkin( "stronghold" )
end

function PANEL:Paint( w, h )
	if !IsValid( self.ply ) then return end
	
	surface.SetDrawColor( self.Color.r, self.Color.g, self.Color.b, self.Color.a )
	surface.DrawRect( 0, 0, w, 1 )
	surface.DrawRect( w-1, 0, 1, h )
	surface.DrawRect( 0, h-1, w, 1 )
	surface.DrawRect( 0, 0, 1, h )
	
	self:GetSkin():DrawGenericBackground( 1, 1, w-2, h-2, Color(60,60,60,240) )
end

vgui.Register( "sh_voicenotify", PANEL, "VoiceNotify" )

-- ----------------------------------------------------------------------------------------------------

local active_color_picker
local function DermaColorPicker( strCvarR, strCvarG, strCvarB, funcValueChange )
	local pnlColMixer, btnCurCol, btnClose

	if ValidPanel( active_color_picker ) then
		active_color_picker:Remove()
	end

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( " " )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	Window:SetSkin( "stronghold" )

	pnlColMixer = vgui.Create( "DColorMixer", Window )
	pnlColMixer:SetConVarR( strCvarR )
	pnlColMixer:SetConVarG( strCvarG )
	pnlColMixer:SetConVarB( strCvarB )
	pnlColMixer:SetAlphaBar( false )
	pnlColMixer.ValueChanged = function( pnl, col )
		btnCurCol:SetColor( col )
		funcValueChange( pnl, col )
	end

	btnCurCol = vgui.Create( "DColorButton", pnlColMixer )
	btnCurCol:SetColor( Color(GetConVarNumber(strCvarR), GetConVarNumber(strCvarG), GetConVarNumber(strCvarB), 255) )

	btnClose = vgui.Create( "DButton", pnlColMixer )
	btnClose:SetText( "Done" )
	btnClose.DoClick = function ( button )
		Window:Remove()
	end

	pnlColMixer.PerformLayout = function( pnl, intW, intH )
		DColorMixer.PerformLayout( pnl, intW, intH )
		btnClose:SetPos( intW -50, intH /1.5 )
		btnClose:SetSize( 50, 21 )

		btnCurCol:SetPos( intW -50, 75 )
		btnCurCol:SetSize( 50, 75 )
	end

	active_color_picker = Window

	Window.Paint = function( pnl, intW, intH )
		pnl:GetSkin():DrawGenericBackground( 0, 0, intW, intH, Color(50, 50, 50, 240), true )
	end

	Window:SetSize( pnlColMixer:GetWide() +8, pnlColMixer:GetTall() +8 )
	pnlColMixer:SetPos( 4, 4 )
	Window:Center()
	Window:MakePopup()
	Window:DoModal()

	return pnlColMixer
end

--[[ sh_colorbutton ]]--
local PANEL = {}
function PANEL:Init()
	self.m_colBlack = Color( 0, 0, 0, 255 )
	self.m_colTexBg = Color( 50, 50, 50, 100 )
	self.m_colColor = Color( 255, 255, 255, 255 )
	self.m_strVarR = ""
	self.m_strVarG = ""
	self.m_strVarB = ""
end

function PANEL:SetColorVars( strR, strG, strB )
	self.m_strVarR = strR
	self.m_strVarG = strG
	self.m_strVarB = strB

	self.m_colColor.r = GetConVarNumber( strR )
	self.m_colColor.g = GetConVarNumber( strG )
	self.m_colColor.b = GetConVarNumber( strB )
end

function PANEL:SetColorTexture( strTex )
	self.m_iTextID = surface.GetTextureID( strTex )
end

function PANEL:DoClick()
	if ValidPanel( self.ColorPicker ) then return end
	
	self.ColorPicker = DermaColorPicker( self.m_strVarR, self.m_strVarG, self.m_strVarB, function(pnl, col)
		self.m_colColor = col
	end, self:GetParent():GetParent() )
end

function PANEL:Paint( intW, intH )
	DButton.Paint( self, intW, intH )

	local cposx, cposy = 2, 3

	surface.SetDrawColor( self.m_iTextID and self.m_colTexBg or self.m_colBlack )
	surface.DrawRect( cposx, cposy, 16, 16 )
	surface.SetDrawColor( self.m_colColor.r, self.m_colColor.g, self.m_colColor.b, 255 )

	if not self.m_iTextID then
		surface.DrawRect( cposx +1, cposy +1, 14, 14 )
	else
		surface.SetTexture( self.m_iTextID )
		surface.DrawTexturedRect( cposx +1, cposy +1, 14, 14 )
	end
end

vgui.Register( "sh_colorbutton", PANEL, "DButton" )