--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local SND_PRIMARY = Sound( "weapons/mp5Navy/mp5_slideback.wav" )
local SND_SECONDARY = Sound( "weapons/elite/elite_sliderelease.wav" )
local SND_EXPLOSIVE = Sound( "weapons/pinpull.wav" )
local SND_CONFIRM = Sound( "buttons/button9.wav" )
local SND_FAIL = Sound( "buttons/button11.wav" )
local Xm,Ym = 0,0
local PANEL = {}

AccessorFunc( PANEL, "m_iFOV", "FOV", FORCE_NUMBER )

function PANEL:Init()
	self.m_angOffset = Angle( 0, 0, 0 )
	self.m_bMouseHeld = false
end

function PANEL:Setup( model, title, fov, offset, ang )
	self.m_strTitle = title
	self.m_iFOV = fov or self.m_iFOV
	if IsValid( self.m_Entity ) then
		self.m_Entity:Remove()
		self.m_Entity = nil
	end
	
	self.m_Entity = ClientsideModel( model, RENDER_GROUP_OPAQUE_ENTITY )
	self.m_Entity:SetNoDraw( true )
	
	local min, max = self.m_Entity:GetRenderBounds()
	local center = (min+max) * -0.50
	self.m_Entity:SetPos( center + (offset or Vector(0,0,0)) )
	self.m_Entity:SetAngles( Angle(0,35,0) )
	if isangle(ang) then
		self.m_Entity:SetAngles( self.m_Entity:GetAngles()+ang )	
	end
	self.m_Entity.OrigAngle = self.m_Entity:GetAngles()
end

function PANEL:OnMousePressed()
	self:MouseCapture( true )
	self.m_iMouseX, self.m_iMouseY = self:CursorPos()
end

function PANEL:OnMouseReleased()
	self:MouseCapture( false )
end

--Not only is the overly complicated, but does the wrong thing. Jeeeeeez...
--[[function PANEL:OnCursorMoved( x, y )
	if self.m_bMouseHeld then
		self.m_angOffset.p = math.Clamp( self.m_angOffset.p + (self.m_iMouseY - y) * 0.50, -60, 80 )
		--while self.m_angOffset.p > 180 do self.m_angOffset.p = self.m_angOffset.p - 360 end
		--while self.m_angOffset.p < -180 do self.m_angOffset.p = self.m_angOffset.p + 360 end
		self.m_angOffset.y = self.m_angOffset.y + (self.m_iMouseX - x) * 0.50
		while self.m_angOffset.y > 180 do self.m_angOffset.y = self.m_angOffset.y - 360 end
		while self.m_angOffset.y < -180 do self.m_angOffset.y = self.m_angOffset.y + 360 end
	end
	self.m_iMouseX, self.m_iMouseY = x, y
end]]

--Look at this glorius simplicty:
function PANEL:OnCursorMoved( x, y )
	if self.m_bMouseHeld then
		Xm,Ym = Xm - (self.m_iMouseX - x),Ym - (self.m_iMouseY - y)
		self.m_Entity:SetAngles( Angle(Ym,Xm,0)+self.m_Entity.OrigAngle)
	end
	self.m_iMouseX, self.m_iMouseY = x, y
end

function PANEL:Think()
	if !self.m_Entity then return end
	if input.IsMouseDown(MOUSE_LEFT) then
		self.m_bMouseHeld = true
	else
		self.m_bMouseHeld = false
		self.m_Entity:SetAngles(LerpAngle(0.1,self.m_Entity:GetAngles(),self.m_Entity.OrigAngle))
		Xm,Ym = 0,0
	end
end
--wow

function PANEL:Paint( w, h )
	local x, y = self:LocalToScreen( 0, 0 )
	local skin = self:GetSkin()
	
	skin:DrawGenericBackground( 0, 0, w, h, skin.bg_color )
	
	surface.SetFont( "Trebuchet19" )
	--local tw, _ = surface.GetTextSize( self.m_strTitle or "" )
	draw.SimpleTextOutlined( self.m_strTitle or "", "Trebuchet19", math.floor(w*0.50), 20, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255) )
	
	if !IsValid( self.m_Entity ) then return end
	
	local ang = Vector( 0.9285, 0.0000, 0.3714 ):Angle()
	ang = ang + self.m_angOffset
	
	cam.Start3D( ang:Forward()*26, (ang:Forward()*-1):Angle(), self.m_iFOV or 90, x+2, y+2, w-4, h-4 )
	cam.IgnoreZ( true )
		render.SuppressEngineLighting( true )
		
		render.SetLightingOrigin( self.m_Entity:GetPos() )
		render.ResetModelLighting( 1, 1, 1 )
		render.SetColorModulation( 1, 1, 1 )
		
		self.m_Entity:DrawModel()
		
		render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	--MORE COMPLICATE
	--[[if !self.m_bMouseHeld then
		self.m_angOffset.p = math.ApproachAngle( self.m_angOffset.p, 0, self.m_angOffset.p*0.05 )
		self.m_angOffset.y = math.ApproachAngle( self.m_angOffset.y, 0, self.m_angOffset.y*0.05 )
	end]]
end

vgui.Register( "sh_itemmodel", PANEL, "Panel" )