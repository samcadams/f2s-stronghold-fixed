--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

local PANEL = {}

AccessorFunc( PANEL, "m_fSlideX", "SlideX" )
AccessorFunc( PANEL, "m_fSlideY", "SlideY" )
AccessorFunc( PANEL, "Dragging", "Dragging" )

AccessorFunc( PANEL, "m_Hue", "Hue" )
AccessorFunc( PANEL, "m_Saturation", "Saturation" )
AccessorFunc( PANEL, "m_RGB", "RGB" )

function PANEL:Init()
	self:SetMouseInputEnabled( true )
	
	self:SetSlideX( 0.5 )
	self:SetSlideY( 0.5 )
	
	self.BGImage = vgui.Create( "DImage", self )
	self.BGImage:SetImage( "vgui/hsv" )
	
	self.Knob = vgui.Create( "DImage", self )
	self.Knob:SetImage( "vgui/minixhair" )
	self.Knob:SizeToContents()
	self.Knob:NoClipping( true )

	self.Reset = vgui.Create( "DImageButton", self )
	self.Reset:SetImage( "gui/silkicons/arrow_refresh" )
	self.Reset:SizeToContents()
	function self.Reset.DoClick()
		local x, y = self:TranslateValues( 0.50, 0.50 )
		self:SetSlideX( x )
		self:SetSlideY( y )
		self:InvalidateLayout()
	end
end

function PANEL:SetValue( iNumValue )
	self:SetSelected( iNumValue )
end

function PANEL:GetValue()
	return self:GetSelectedNumber()
end

function PANEL:SetSlideX( i )
	self.m_fSlideX = i
	self:InvalidateLayout()
end

function PANEL:SetSlideY( i )
	self.m_fSlideY = i
	self:InvalidateLayout()
end

function PANEL:OnMousePressed( mcode )
	self:SetDragging( true )
	self:MouseCapture( true )
	
	local x, y = self:CursorPos()
	self:OnCursorMoved( x, y )
end

function PANEL:OnMouseReleased( mcode )
	self:SetDragging( false )
	self:MouseCapture( false )
end

function PANEL:OnCursorMoved( x, y )
	if !self.Dragging then return end
	
	local w, h = self:GetSize()
	local iw, ih = self.Knob:GetSize()
	
	x = math.Clamp( x, 0, w ) / w
	y = math.Clamp( y, 0, h ) / h
	
	x, y = self:TranslateValues( x, y )
	
	self:SetSlideX( x )
	self:SetSlideY( y )
	
	self:InvalidateLayout()
end

function PANEL:TranslateValues( x, y )
	x = x - 0.5
	y = y - 0.5
	
	local angle = math.atan2( x, y )
	
	local length = math.sqrt( x*x + y*y )
	length = math.Clamp( length, 0, 0.5 )
	
	x = 0.5 + math.sin( angle ) * length
	y = 0.5 + math.cos( angle ) * length
	
	self:SetHue( math.deg( angle ) + 270 )
	self:SetSaturation( length * 2 )
	
	self:SetRGB( HSVToColor( self:GetHue(), self:GetSaturation(), 1 ) )
	self.Knob:SetImageColor( self:GetRGB() )
	
	self:OnChange( self:GetRGB() )
	
	return x, y
end

function PANEL:OnChange( color )
end

function PANEL:PerformLayout( w, h )
	local iw, ih = self.Knob:GetSize()
	local rw, rh = self.Reset:GetSize()
	
	self.BGImage:SetPos( 0, 0 )
	self.BGImage:SetSize( w, h )
	
	self.Knob:SetPos( (self.m_fSlideX or 0) * (w) - iw * 0.5, (self.m_fSlideY or 0) * (h) - ih * 0.5 )
	self.Reset:SetPos( w-rw, h-rh )
end

vgui.Register( "sh_colorcircle", PANEL, "Panel" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

AccessorFunc( PANEL, "m_Saturation", "Saturation" )
AccessorFunc( PANEL, "m_RGB", "RGB" )
AccessorFunc( PANEL, "m_SatRGB", "SaturatedRGB" )

function PANEL:Init()
	self.m_Saturation = 1
	self.m_RGB = Color( 255, 255, 255, 255 )
	self.m_SatRGB = Color( 255, 255, 255, 255 )

	self.Saturation = vgui.Create( "DAlphaBar", self )
	--self.Saturation.imgBackground:SetImage( "vgui/black" )
	self.Saturation:SetValue( 1 )
	function self.Saturation.OnChange( _, saturation )
		self.m_Saturation = saturation
		self.m_SatRGB = Color( self.m_RGB.r*self.m_Saturation, self.m_RGB.g*self.m_Saturation, self.m_RGB.b*self.m_Saturation, 255 )
		self:OnChange( self.m_SatRGB )
	end
	--[[function self.Saturation:PerformLayout( w, h )
		DSlider.PerformLayout( self )
		self.imgBackground:SetZPos( -15 )
		self.imgBackground:SetSize( self:GetWide(), self:GetTall() )
	end]]
	
	self.Circle = vgui.Create( "sh_colorcircle", self )
	function self.Circle.OnChange( _, color )
		self.m_RGB = color
		self.m_SatRGB = Color( self.m_RGB.r*self.m_Saturation, self.m_RGB.g*self.m_Saturation, self.m_RGB.b*self.m_Saturation, 255 )
		self.Saturation:SetBarColor( color )
		self:OnChange( self.m_SatRGB )
	end
end

function PANEL:GetColor()
	return self.m_SatRGB
end

function PANEL:OnChange( color )
end

function PANEL:PerformLayout( w, h )
	self.Saturation:SetPos( 0, 0 )
	self.Saturation:SetSize( 20, h )
	
	self.Circle:SetPos( 24, 0 )
	self.Circle:SetSize( w-24, h )
end

vgui.Register( "sh_colormixer", PANEL, "Panel" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.NameLabel = vgui.Create( "DLabel", self )
	self.NameLabel:SetText( "Team Name:" )
	self.Name = vgui.Create( "DTextEntry", self )
	self.Name:SetValue( "<Enter Name Here>" )

	self.PasswordLabel = vgui.Create( "DLabel", self )
	self.PasswordLabel:SetText( "Team Password:" )
	self.Password = vgui.Create( "DTextEntry", self )
	
	self.CreateTeam = vgui.Create( "DButton", self )
	self.CreateTeam:SetText( "Create Team" )
	function self.CreateTeam.DoClick()
		local color = self.Color:GetColor()
		RunConsoleCommand( "sh_createteam", self.Name:GetValue(), self.Password:GetValue(), color.r, color.g, color.b )
	end
	
	self.Color = vgui.Create( "sh_colormixer", self )
end

function PANEL:Paint( w, h )
	local skin = self:GetSkin()
	
	skin:DrawGenericBackground( 0, 0, w, 24, skin.bg_color )
	skin:DrawGenericBackground( 0, 34, w-210, h-34, skin.bg_color )
	skin:DrawGenericBackground( w-200, 34, 200, h-34, skin.bg_color )

	local str = self.Name:GetValue()
	surface.SetFont( "Trebuchet19" )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextPos( 8, 12-th/2 )
	surface.SetTextColor( self.Color:GetColor() )
	surface.DrawText( str )
end

function PANEL:PerformLayout( w, h )
	self.NameLabel:SizeToContents()
	self.NameLabel:SetTall( 22 )
	self.NameLabel:SetPos( 10, 44 )
	self.Name:SetSize( w-self.NameLabel:GetWide()-235, 22 )
	self.Name:SetPos( self.NameLabel:GetWide()+15, 44 )
	
	self.PasswordLabel:SizeToContents()
	self.PasswordLabel:SetTall( 22 )
	self.PasswordLabel:SetPos( 10, 76 )
	self.Password:SetSize( w-self.PasswordLabel:GetWide()-235, 22 )
	self.Password:SetPos( self.PasswordLabel:GetWide()+15, 76 )
	
	self.CreateTeam:SetPos( 10, 108 )
	self.CreateTeam:SetSize( w-230, 22 )
	
	self.Color:SetPos( w-195, (h-29)*0.50-54 )
	self.Color:SetSize( 190, 166 )
end

vgui.Register( "sh_teamcreatepanel", PANEL, "Panel" )