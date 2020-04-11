--[[
	File: sh_uplinkterm.lua
	For: FTS: Stronghold
	By: Ultra
]]--
local font_data = {
	["uplink_font"] = {
		font 	= "Consolas",
		size 	= 18,
		weight 	= 400
	},
}

surface.CreateFont( "uplink_font", font_data.uplink_font )

local LINE = {}
function LINE:Init()
	self.m_sFont = "uplink_font"
	self.m_sText = ""

	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetFont( self.m_sFont )
	self.Label:SetText( self.m_sText)
	self.Label:SetColor( Color(50, 200, 50, 255) )
end

function LINE:SetText( strText )
	self.m_sText = strText
	self.Label:SetText( self.m_sText )
	self:InvalidateLayout()
end

function LINE:PerformLayout()
	self:SetTall( 20 )

	surface.SetFont( self.m_sFont )
	local w, h = surface.GetTextSize( self.m_sText )
	self:SetWide( math.max(self:GetParent():GetWide(), w +4) )

	self.Label:SetPos( 3, 3 )
	self.Label:SizeToContents()
end

vgui.Register( "sh_uplink_term_line", LINE, "EditablePanel" )

local CONTAINER = {}
AccessorFunc( CONTAINER, "m_iMaxLines", "MaxLines", FORCE_NUMBER )

function CONTAINER:Init()
	self:SetSpacing( 0 )
	self:SetPadding( 0 )
	self:EnableHorizontal( true )
	self:EnableVerticalScrollbar( true )

	self.m_iMaxLines 	= 27
	self.m_tLines 		= {}

	self.TextEntry = vgui.Create( "DTextEntry", self )
	self.TextEntry:SetText( "" )
	self.TextEntry:SetFont( "uplink_font" )
	self.TextEntry:SetTextColor( Color(50, 200, 50, 255) )
	self.TextEntry:SetCursorColor( Color(50, 200, 50, 255) )
	self.TextEntry:SetDrawBackground( false )
	self.TextEntry:SetDrawBorder( false )
	self.TextEntry:SetMultiline( false )
	self.TextEntry.OnEnter = function( pnl )
		GAMEMODE.Net:PlayerSendTermLine( pnl:GetValue() )
		pnl:SetText( "" )
		pnl:RequestFocus()
	end
	self.TextEntry.OnKeyCodeTyped = function( pnl, key )
		GAMEMODE.Net:PlayerKeyPress( key )
		DTextEntry.OnKeyCodeTyped( pnl, key )
	end
end

function CONTAINER:OnMousePressed()
	self.TextEntry:RequestFocus()
end

function CONTAINER:Clear()
	for k, v in pairs( self.m_tLines ) do
		if ValidPanel( v ) then v:Remove() end
		self.m_tLines[k] = nil
	end

	DPanelList.Clear( self )
end

function CONTAINER:AddTermLine( str )
	if #self.m_tLines >= self.m_iMaxLines then
		if ValidPanel( self.m_tLines[1] ) then
			self.m_tLines[1]:Remove()
		end

		table.remove( self.m_tLines, 1 )
		DPanelList.Clear( self )
		for k, v in pairs( self.m_tLines ) do
			self:AddItem( v )
		end
	end

	local line = vgui.Create( "sh_uplink_term_line", self )
	line:SetText( str )
	table.insert( self.m_tLines, line )
	self:AddItem( line )
end

function CONTAINER:PerformLayout()
	DPanelList.PerformLayout( self )

	self.TextEntry:SetPos( 0, #self.m_tLines *20 )
	self.TextEntry:SetSize( self:GetWide(), 20 )
end

function CONTAINER:Paint( intW, intH )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, intW, intH )
end

vgui.Register( "sh_uplink_term_linecontainer", CONTAINER, "DPanelList" )

local PANEL = {}

function PANEL:Init()
	self:SetTitle( "Uplink Terminal" )
	self:SetSkin( "stronghold" )
	self:SetDeleteOnClose( false )
	self:SetDraggable( false )

	self.Lines = vgui.Create( "sh_uplink_term_linecontainer", self )
end

function PANEL:AddLine( strLine )
	self.Lines:AddTermLine( strLine )
	self:InvalidateLayout()
end

function PANEL:Clear()
	self.Lines:Clear()
end

function PANEL:Close()
	DFrame.Close( self )
	GAMEMODE.Net:PlayerCloseTermMenu()
	self:Clear()
	self.Lines.TextEntry:SetText( "" )
end

function PANEL:PerformLayout()
	self.Lines:SetPos( 5, 25 )
	self.Lines:SetSize( self:GetWide() -10, self:GetTall() -30 )

	DFrame.PerformLayout( self )
end
vgui.Register( "sh_uplink_term", PANEL, "DFrame" )

function GM:ShowUplinkTerm( bShow )
	if not ValidPanel( self.m_pUplinkTerm ) then
		self.m_pUplinkTerm = vgui.Create( "sh_uplink_term" )
		self.m_pUplinkTerm:SetSize( 800, 600 )
		self.m_pUplinkTerm:Center()
		self.m_pUplinkTerm:SetVisible( false )
	end

	if bShow then
		self.m_pUplinkTerm:SetVisible( true )
		self.m_pUplinkTerm:MakePopup()
		self.m_pUplinkTerm.Lines.TextEntry:RequestFocus()
	else
		GAMEMODE.Net:PlayerCloseTermMenu()
	end
end