surface.CreateFont( "Trebuchet19", {
	font = "Trebuchet MS",
	size = 19,
	weight = 700
} )

-- ----------------------------------------------------------------------------------------------------

function GM:ForceDermaSkin()
	return "stronghold"
end

SKIN = {}

SKIN.PrintName 		= "Stronghold Derma Skin"
SKIN.Author 		= "TehBigA/RoaringCow"
SKIN.DermaVersion	= 1
SKIN.GwenTexture	= Material( "vgui/null" )

-- ----------------------------------------------------------------------------------------------------

local TEX_GRADIENT = surface.GetTextureID( "vgui/null" )
local TEX_GRADIENT_UP = surface.GetTextureID( "vgui/null" )
local TEX_GRADIENT_RIGHT = surface.GetTextureID( "vgui/null" )
local MAT_BLUR = Material( "vgui/null" )

-- ----------------------------------------------------------------------------------------------------

SKIN.bg_color 					= Color( 20, 20, 20, 220 )
SKIN.bg_color_sleep 			= Color( 50, 50, 50, 50 )
SKIN.bg_color_dark				= Color( 0, 0, 0, 50 )
SKIN.bg_color_bright			= Color( 70, 70, 70, 50 )

SKIN.bg_alt1 					= Color( 10, 10, 10, 120 )
SKIN.bg_alt2 					= Color( 12, 12, 12, 120 )

SKIN.panel_transback			= Color( 0, 0, 0, 150 )

SKIN.colPropertySheet 			= Color( 100, 100, 100, 255 )
SKIN.colTab			 			= SKIN.colPropertySheet
SKIN.colTabInactive				= Color( 80,80, 80, 255 )
SKIN.colTabShadow				= Color( 0, 0, 0, 140 )
SKIN.colTabText		 			= Color( 255, 255, 255, 255 )
SKIN.colTabTextInactive			= Color( 50, 50, 50, 255 )

SKIN.colButtonText				= Color( 255, 255, 255, 255 )
SKIN.colButtonTextDisabled		= Color( 0, 0, 0, 255 )
SKIN.colButtonBorder			= Color( 0, 0, 0, 255 )
SKIN.colButtonBorderHighlight	= Color( 0, 0, 0, 255 )
SKIN.colButtonBorderShadow		= Color( 0, 0, 0, 255 )

SKIN.colTextEntryBG				= Color( 255, 255, 255, 0 )
SKIN.colTextEntryBorder			= Color( 20, 20, 20, 0 )
SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )
SKIN.colTextEntryText			= Color( 0, 0, 0, 255 )


SKIN.listview_hover				= Color( 60, 102, 132, 255 )
SKIN.listview_selected			= Color( 100, 170, 220, 200 )

SKIN.control_color 				= Color( 50, 50, 50, 200 )
SKIN.control_color_highlight	= Color( 150, 150, 150, 50 )
SKIN.control_color_active 		= Color( 110, 150, 250, 50 )
SKIN.control_color_bright 		= Color( 255, 200, 100, 50 )
SKIN.control_color_dark 		= Color( 0, 0, 0, 100 )


-- ----------

SKIN.Colours = {}

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal		= SKIN.colButtonText
SKIN.Colours.Button.Hover		= Color( 186, 226, 255, 255 )
SKIN.Colours.Button.Down		= SKIN.colButtonTextDisabled
SKIN.Colours.Button.Disabled	= Color( 186, 226, 255, 0 )

-- ----------

SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive			= Color( 255, 255, 255, 255 )
SKIN.Colours.Window.TitleInactive		= Color( 200, 200, 200, 255 )

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal			= Color( 255, 255, 255, 255 )
SKIN.Colours.Tab.Active.Hover			= Color( 255, 255, 255, 255 )
SKIN.Colours.Tab.Active.Down			= Color( 200, 200, 200, 255 )
SKIN.Colours.Tab.Active.Disabled		= Color( 200, 200, 200, 255 )

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal		= Color( 200, 200, 200, 255 )
SKIN.Colours.Tab.Inactive.Hover			= Color( 220, 220, 220, 255 )
SKIN.Colours.Tab.Inactive.Down			= Color( 220, 220, 220, 255 )
SKIN.Colours.Tab.Inactive.Disabled		= Color( 180, 180, 180, 255 )

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default				= Color( 255, 255, 255, 255 )
SKIN.Colours.Label.Bright				= Color( 255, 255, 255, 255 )
SKIN.Colours.Label.Dark					= Color( 200, 200, 200, 255 )
SKIN.Colours.Label.Highlight			= Color( 255, 255, 255, 255 )

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines					= GWEN.TextureColor( 4 + 8 * 10, 508 );		---- !!!
SKIN.Colours.Tree.Normal				= GWEN.TextureColor( 4 + 8 * 11, 508 );
SKIN.Colours.Tree.Hover					= GWEN.TextureColor( 4 + 8 * 10, 500 );
SKIN.Colours.Tree.Selected				= GWEN.TextureColor( 4 + 8 * 11, 500 );

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal			= Color( 255, 255, 255, 255 );
SKIN.Colours.Properties.Line_Selected		= GWEN.TextureColor( 4 + 8 * 13, 508 );
SKIN.Colours.Properties.Line_Hover			= GWEN.TextureColor( 4 + 8 * 12, 500 );
SKIN.Colours.Properties.Title				= Color( 255, 255, 255, 255 )
SKIN.Colours.Properties.Column_Normal		= Color( 255, 255, 255, 255 )
SKIN.Colours.Properties.Column_Selected		= Color( 255, 255, 255, 255 )
SKIN.Colours.Properties.Column_Hover		= Color( 255, 255, 255, 255 )
SKIN.Colours.Properties.Border				= Color( 255, 255, 255, 255 );
SKIN.Colours.Properties.Label_Normal		= Color( 255, 255, 255, 255 )
SKIN.Colours.Properties.Label_Selected		= Color( 255, 255, 255, 255 )
SKIN.Colours.Properties.Label_Hover			= Color( 255, 255, 255, 255 )

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header				= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.Header_Closed			= Color( 180, 180, 180, 255 )
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text				= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.Line.Text_Hover		= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.Line.Text_Selected	= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.Line.Button			= GWEN.TextureColor( 4 + 8 * 21, 500 );
SKIN.Colours.Category.Line.Button_Hover		= GWEN.TextureColor( 4 + 8 * 22, 508 );
SKIN.Colours.Category.Line.Button_Selected	= GWEN.TextureColor( 4 + 8 * 23, 508 );
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text				= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.LineAlt.Text_Hover		= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.LineAlt.Text_Selected		= Color( 255, 255, 255, 255 )
SKIN.Colours.Category.LineAlt.Button			= GWEN.TextureColor( 4 + 8 * 25, 508 );
SKIN.Colours.Category.LineAlt.Button_Hover		= GWEN.TextureColor( 4 + 8 * 24, 500 );
SKIN.Colours.Category.LineAlt.Button_Selected	= GWEN.TextureColor( 4 + 8 * 25, 500 );

SKIN.Colours.TooltipText	= GWEN.TextureColor( 4 + 8 * 26, 500 );



-- GENERIC    ----------------------------------------------------------------------------------------------------

local SCR_H_DIV_4 = nil
function SKIN:DrawGenericBackground( x, y, w, h, color, skip_top, title_line, title_line_panel )
	if !SCR_H_DIV_4 then SCR_H_DIV_4 = ScrH() * 0.25 end

	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	if !skip_top then surface.DrawRect( x, y, w-1, 1 ) end
	surface.DrawRect( x, y, 1, h-1 )
	surface.DrawRect( x, y+h-1, w, 1 )
	surface.DrawRect( x+w-1, y, 1, h-1 )
	
	--surface.SetDrawColor( 200, 200, 200, 120 )
	
	local scale = math.Clamp( h/SCR_H_DIV_4, 0, 1 )
	surface.SetDrawColor( 0, 0, 0, 80+80*scale ) -- Smaller it is the lighter
	surface.SetTexture( TEX_GRADIENT )
end

function SKIN:DrawFlippedBackground( x, y, w, h, color, skip_top )
	if !SCR_H_DIV_4 then SCR_H_DIV_4 = ScrH() * 0.25 end

	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 120 )
	if !skip_top then surface.DrawRect( x, y, w-1, 1 ) end
	surface.DrawRect( x, y, 1, h-1 )
	surface.DrawRect( x, y+h-1, w, 1 )
	surface.DrawRect( x+w-1, y, 1, h-1 )
	
	surface.SetDrawColor( 200, 200, 200, 120 )
	if !skip_top then surface.DrawRect( x+1, y+1, w-2, 1 ) end
	surface.DrawRect( x+1, y+1, 1, h-2 )
	surface.DrawRect( x+1, y+h-2, w-2, 1 )
	surface.DrawRect( x+w-2, y+1, 1, h-2 )
	
	local scale = math.Clamp( h/SCR_H_DIV_4, 0, 1 )
	surface.SetDrawColor( 0, 0, 0, 80+80*scale ) -- Smaller it is the lighter
	surface.SetTexture( TEX_GRADIENT_UP )
	surface.DrawTexturedRect( x+2, y+h*0.25-2, w-4, h*0.75 )
end

function SKIN:DrawRightBackground( x, y, w, h, color )
	if !SCR_H_DIV_4 then SCR_H_DIV_4 = ScrH() * 0.25 end

	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawRect( x, y, w-1, 1 )
	surface.DrawRect( x, y, 1, h-1 )
	surface.DrawRect( x, y+h-1, w, 1 )
	surface.DrawRect( x+w-1, y, 1, h-1 )
	
	surface.SetDrawColor( 200, 200, 200, 120 )
	surface.DrawRect( x+1, y+1, w-2, 1 )
	surface.DrawRect( x+1, y+1, 1, h-2 )
	surface.DrawRect( x+1, y+h-2, w-2, 1 )
	surface.DrawRect( x+w-2, y+1, 1, h-2 )
	
	local scale = math.Clamp( h/SCR_H_DIV_4, 0, 1 )
	surface.SetDrawColor( 0, 0, 0, 80+80*scale ) -- Smaller it is the lighter
	surface.SetTexture( TEX_GRADIENT_RIGHT )
	surface.DrawTexturedRect( x+w*0.25-2, y+2, w*0.75, h-4 )
end

function SKIN:DrawLeftBackground( x, y, w, h, color )
	if !SCR_H_DIV_4 then SCR_H_DIV_4 = ScrH() * 0.25 end

	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawRect( x, y, w-1, 1 )
	surface.DrawRect( x, y, 1, h-1 )
	surface.DrawRect( x, y+h-1, w, 1 )
	surface.DrawRect( x+w-1, y, 1, h-1 )
	
	surface.SetDrawColor( 200, 200, 200, 255 )
	surface.DrawRect( x+1, y+1, w-2, 1 )
	surface.DrawRect( x+1, y+1, 1, h-2 )
	surface.DrawRect( x+1, y+h-2, w-2, 1 )
	surface.DrawRect( x+w-2, y+1, 1, h-2 )
	
	local scale = math.Clamp( h/SCR_H_DIV_4, 0, 1 )
	surface.SetDrawColor( 0, 0, 0, 80+80*scale ) -- Smaller it is the lighter
	surface.SetTexture( TEX_GRADIENT_RIGHT )
	surface.DrawTexturedRectRotated( x+2, y+2, w*0.75, h-4, 180 )
end

function SKIN:DrawCheapBackground( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w, h )
end

-- TOOLTIP    ----------------------------------------------------------------------------------------------------

--[[function SKIN:PaintTooltip( panel, w, h )
	DisableClipping( true )

	for i=1, 4 do
		local BorderSize = i*2
		local BGColor = Color( 0, 0, 0, (255/i) * 0.3 )
		self:DrawCheapBackground( -BorderSize, -BorderSize, w+BorderSize*2, h+BorderSize*2, BGColor )
		panel:DrawArrow( BorderSize, BorderSize )
		panel:DrawArrow( -BorderSize, BorderSize )
		panel:DrawArrow( BorderSize, -BorderSize )
		panel:DrawArrow( -BorderSize, -BorderSize )
	end

	self:DrawGenericBackground( 0, 0, w, h, self.tooltip )
	panel:DrawArrow( 0, 0 )
	
	DisableClipping( false )
end]]

-- PANEL      ----------------------------------------------------------------------------------------------------

function SKIN:PaintPanel( panel, w, h )
	if panel.m_bPaintBackground then
		self:DrawGenericBackground( 0, 0, w, h, panel.m_bgColor or self.panel_transback )
	end	
end

-- FORM       ----------------------------------------------------------------------------------------------------

function SKIN:PaintForm( panel, w, h )
	local x, y, w, h = 0, 9, w, h-9
	self:DrawGenericBackground( x, y, w, h, self.bg_color, true )
	
	local lw = panel.Label:GetWide()
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawRect( x, y, 3, 1 )
	surface.DrawRect( x+lw+5, y, w-lw-6, 1 )
	surface.SetDrawColor( 200, 200, 200, 120 )
	surface.DrawRect( x+1, y+1, 2, 1 )
	surface.DrawRect( x+lw+6, y+1, w-lw-8, 1 )
end

-- FRAME      ----------------------------------------------------------------------------------------------------

local RT_FULLFRAMEFB = GetRenderTarget( "_rt_FullFrameFB", ScrW(), ScrH(), false )
local MAT_FULLFRAMEFB = Material( "_rt_FullFrameFB" )
function SKIN:PaintFrame( panel, w, h )
	--[[if LocalPlayer then
		DisableClipping( true )
		local x, y = panel:LocalToScreen( 0, 0 )
		surface.SetMaterial( MAT_BLUR )	
		surface.SetDrawColor( 255, 255, 255, 255 )
		for i=0.33, 1, 0.33 do
			--MAT_BLUR:SetFloat( "$blur", 500 )
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
		end
		--surface.SetDrawColor( 10, 10, 10, 200 * Fraction )
		--surface.DrawRect( 0, 0, w, h )
		DisableClipping( false )
	end]]
	
	--[[DisableClipping( true )
		local x, y = panel:LocalToScreen( 0, 0 )
		
		render.UpdateScreenEffectTexture()
		render.BlurRenderTarget( RT_FULLFRAMEFB, 5, 5, 3 )
		
		surface.SetMaterial( MAT_FULLFRAMEFB )	
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	DisableClipping( false )]]
	
	self:DrawGenericBackground( 0, 0, w, h, self.bg_color, false, true, panel )
end

-- PROP SHEET ----------------------------------------------------------------------------------------------------

function SKIN:PaintPropertySheet( panel, w, h )
	local ActiveTab = panel:GetActiveTab()
	local Offset = 0
	--draw.RoundedBox( 4, 0, Offset, panel:GetWide(), panel:GetTall()-Offset, self.colPropertySheet )
	if ActiveTab then
		local padding = panel:GetPadding()-8
		Offset = ActiveTab:GetTall()
		surface.SetDrawColor( self.colPropertySheet )
		surface.SetTexture( TEX_GRADIENT )
		surface.DrawTexturedRect( 2, Offset, w-4, h*0.75 )
		
		local tab = ActiveTab:GetWide()
		local x, _ = ActiveTab:GetPos()
		local tab_offset = -panel.tabScroller.pnlCanvas.x --panel.tabScroller.OffsetX
		local x1, x2 = math.Round( x+padding+1-tab_offset ), math.Round( x+padding+tab-2-tab_offset )
		surface.SetDrawColor( 200, 200, 200, 50 )
		local left, right = (x1 >= 0 and x1 <= w), (x2 >= 0 and x2 <= w)
		if left then
			surface.DrawRect( 2, Offset, x1+2, 1 )
			surface.DrawRect( x1+3, Offset, 1, 2 )
		end
		if right then
			surface.DrawRect( x2+3, Offset, w-x2-2, 1 )
			surface.DrawRect( x2+3, Offset, 1, 2 )
		end
		if !left and !right then
			surface.DrawRect( 2, Offset, w-4, 1 )
		end
	end
end

function SKIN:PaintTab( panel, w, h )
	if panel:GetPropertySheet():GetActiveTab() == panel then
		-- Active
		surface.SetTexture( TEX_GRADIENT_UP )
		surface.SetDrawColor( SKIN.colTab )
		--surface.DrawRect( 0, h*0.05+1, w, h*0.95 )
		surface.SetDrawColor( 200, 200, 200, 50 )
		surface.DrawRect( 1, 0, 1, h )
		surface.DrawRect( w-2, 0, 1, h )
	else
		-- Inactive
		surface.SetDrawColor( SKIN.colTabInactive )
		surface.SetTexture( TEX_GRADIENT_UP )
		--surface.DrawRect( 0, h*0.30+1, w, h*0.70 )
		surface.SetDrawColor( 120, 120, 120, 120 )
		surface.DrawTexturedRect( 1, h*0.25+1, 1, h*0.75 )
		surface.DrawTexturedRect( w-2, h*0.25, 1, h*0.75 )
	end
end

-- BUTTON     ----------------------------------------------------------------------------------------------------

function SKIN:PaintButton( panel, w, h )
	if panel.m_bBackground then
		if panel:GetDisabled() then
		surface.SetDrawColor( self.control_color_dark )
			surface.DrawRect( 0, 0, w, h )
			return
		elseif self.Depressed or self.m_bSelected then
		surface.SetDrawColor( self.control_color_active )
			surface.DrawRect( 0, 0, w, h )
			return
		elseif panel.Hovered then
		surface.SetDrawColor( self.control_color_highlight )
			surface.DrawRect( 0, 0, w, h )
			return
		end
		surface.SetDrawColor( self.control_color )
		surface.DrawRect( 0, 0, w, h )
	end
end
--[[
function SKIN:PaintOverButton( panel )
end

function SKIN:DrawButtonBorder( x, y, w, h, depressed )
end

function SKIN:DrawDisabledButtonBorder( x, y, w, h, depressed )
end
]]
-- TEXTENTRY  ----------------------------------------------------------------------------------------------------

--[[function SKIN:PaintTextEntry( panel, w, h )

		if ( panel:GetDisabled() ) then
			self.tex.TextBox_Disabled( 0, 0, w, h, self.colTextEntryBG )
		elseif ( panel:HasFocus() ) then
			self.tex.TextBox_Focus( 0, 0, w, h, self.colTextEntryBG )
		else
			self.tex.TextBox( 0, 0, w, h, self.colTextEntryBG )
		end
	
	panel:DrawTextEntryText( panel.m_colText, panel.m_colHighlight, panel.m_colCursor )
end]]

-- SCROLLBAR  ----------------------------------------------------------------------------------------------------
function SKIN:PaintVScrollBar( panel, w, h )
	surface.SetDrawColor( self.control_color_highlight )
	surface.DrawRect( 0, 0, w, h)
end

function SKIN:PaintScrollBarGrip( panel, w, h )
	surface.SetDrawColor( self.control_color_dark )
	surface.DrawRect( 0, 0, w, h)
end

--[[---------------------------------------------------------
	ButtonDown
-----------------------------------------------------------]]
function SKIN:PaintButtonDown( panel, w, h )
return end

--[[---------------------------------------------------------
	ButtonUp
-----------------------------------------------------------]]
function SKIN:PaintButtonUp( panel, w, h )
return end

--[[---------------------------------------------------------
	ButtonLeft
-----------------------------------------------------------]]
function SKIN:PaintButtonLeft( panel, w, h )
end

--[[---------------------------------------------------------
	ButtonRight
-----------------------------------------------------------]]
function SKIN:PaintButtonRight( panel, w, h )
end

-- VOICE      ----------------------------------------------------------------------------------------------------

--[[function SKIN:PaintVoiceNotify( panel )
	local w, h = panel:GetSize()
	self:DrawGenericBackground( 0, 0, w, h, Color(panel.Color.r,panel.Color.g,panel.Color.b,panel.Color.a*0.25) )
	self:DrawGenericBackground( 1, 1, w-2, h-2, Color( 60, 60, 60, 240 ) )
end]]

-- LISTVIEW   ----------------------------------------------------------------------------------------------------

function SKIN:PaintListView( panel )
	if panel.m_bBackground then
		surface.SetDrawColor( 0, 0, 0, 180 )
		panel:DrawFilledRect()
	end
end

function SKIN:PaintListViewLine( panel, w, h )
	local Col = nil
	if panel:IsSelected() then
		Col = self.listview_selected
	elseif panel.Hovered then
		Col = self.listview_hover
	elseif panel.m_bAlt then
		Col = self.bg_alt2
	else
		return
	end
	surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
	surface.DrawRect( 0, 0, w, h )
end

-- PANELLIST   ----------------------------------------------------------------------------------------------------

function SKIN:PaintPanelList( panel, w, h )
	surface.SetTexture( TEX_GRADIENT )
	surface.SetDrawColor( 0, 0, 0, 180 )
	surface.DrawTexturedRect( 2, 0, w-4, h )
	
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( 1, 0, w-2, h )
end

-- ----------------------------------------------------------------------------------------------------

derma.DefineSkin( "stronghold", "Recreation of GMod12 skin for GMod13", SKIN )