--[[
	File: sh_commorose.lua
	For: FTS: Stronghold
	By: Ultra
]]--

local PANEL = {}

function PANEL:Init()
	self.ModeSound 				= Sound( "Weapon_Shotgun.Empty" )
	self.DuringSelectionSound 	= Sound( "ui/buttonclick.wav" )
	self.TOOL_RADIAL_SHOWMOUSE 	= GetConVar( "sh_tool_radialshowmouse" )
	self.TOOL_RADIAL_MODE 		= GetConVar( "sh_tool_radialmode" )
	self.TOOL_RADIAL_SPEED 		= GetConVar( "sh_tool_radialmode_speed" )
	self.TOOL_ALTERNATEINPUT 	= GetConVar( "sh_tool_altinput" )
	self.TEX_RADIALBG 			= surface.GetTextureID( "tool_radialbg" )
	self.TEX_RADIALSELECT 		= surface.GetTextureID( "tool_radialselect" )
	self.TEX_RADIALMOUSE 		= surface.GetTextureID( "sprites/hud/v_crosshair1" )

	self.m_tOptions				= {}
	self.MenuOpen 				= false
	self.MenuCurAngle 			= 90
	self.MenuTargetAngle 		= 90
	self.ToolAngBetween			= 0

	self:AddOption( GAMEMODE.Map.MarkerTypes[1].text, "toolicons/propspawn", 	true, 	function() GAMEMODE.Map:PlaceMarker( 1 ) 			end )
	self:AddOption( GAMEMODE.Map.MarkerTypes[2].text, "toolicons/propspawn", 	true, 	function() GAMEMODE.Map:PlaceMarker( 1 ) 			end )
	self:AddOption( GAMEMODE.Map.MarkerTypes[3].text, "toolicons/propspawn", 	true, 	function() GAMEMODE.Map:PlaceMarker( 3 ) 			end )
	self:AddOption( GAMEMODE.Map.MarkerTypes[4].text, "toolicons/propspawn", 	false, 	function() GAMEMODE.Map:PlaceMarker( 4 ) 			end )
	self:AddOption( GAMEMODE.Map.MarkerTypes[5].text, "toolicons/propspawn", 	false, 	function() GAMEMODE.Map:PlaceMarker( 5 ) 			end )
	self:AddOption( "Clear Team Commands.", "toolicons/propspawn", 				true, 	function() GAMEMODE.Net:RequestClearTeamMarkers() 	end )
	self:InitializeOptions()
end

function PANEL:AddOption( strName, strIcon, bLeaderCommand, funcCommand )
	table.insert( self.m_tOptions, {
		Name 		= strName,
		SelectIcon 	= surface.GetTextureID( strIcon ),
		LeaderCmd 	= bLeaderCommand,
		DoClick 	= funcCommand,
	} )
end

function PANEL:InitializeOptions()
	local tbl = {}

	local count = table.Count( self.m_tOptions )
	self.ToolAngBetween = math.pi *2 /count
	
	local sorted = {}
	for k, _ in pairs( self.m_tOptions ) do table.insert( sorted, k ) end
	table.sort( sorted, function(a, b) return a > b end )

	for i, v in pairs( sorted ) do
		tbl[v] = table.Copy( self.m_tOptions[v] )
		tbl[v].RadialAngle = (i -2) *self.ToolAngBetween -math.pi /2
		
		while tbl[v].RadialAngle < 0 do tbl[v].RadialAngle = tbl[v].RadialAngle +math.pi *2 end
	end
	
	self.m_tOptions = tbl
end

function PANEL:ClearOptions()
	self.m_tOptions = {}
end

function PANEL:GetMode()
	return self.TOOL_RADIAL_MODE:GetInt()
end

local MOUSE_CHECK_DIST = 80
local MOUSE_CUR_DIST = 0
local CUR_SELECTION, LAST_SELECTION = nil
function PANEL:Think()
	if not self.MenuOpen then return end
	
	--local sscale 		= self:GetTall() /1050
	local radialmode 	= self.TOOL_RADIAL_MODE:GetInt()

	if radialmode == 1 then
		if self.MenuOpen then
			local mx, my 	= gui.MousePos()
			local cx, cy 	= ScrW() /2, ScrH() /2
			MOUSE_CUR_DIST 	= math.Distance( mx, my, cx, cy )

			if MOUSE_CUR_DIST > 48 then
				local norm = Vector( mx -cx, cy -my, 0 ):GetNormal()
				self.MenuTargetAngle = norm:Angle().y

				if MOUSE_CUR_DIST > MOUSE_CHECK_DIST then
					gui.SetMousePos( cx +norm.x *MOUSE_CHECK_DIST, cy -norm.y *MOUSE_CHECK_DIST )
				end
			end
		end

		self.MenuCurAngle = math.ApproachAngle( self.MenuCurAngle, self.MenuTargetAngle, 15 *(math.AngleDifference(self.MenuCurAngle, self.MenuTargetAngle) /180) )
	else
		local cmd = LocalPlayer():GetCurrentCommand()
		self.MenuCurAngle = self.MenuCurAngle -(radialmode == 2 and cmd:GetMouseX() or cmd:GetMouseY()) *self.TOOL_RADIAL_SPEED:GetFloat()
		if self.MenuCurAngle < 0 then self.MenuCurAngle = self.MenuCurAngle +360 end
	end
	
	CUR_SELECTION, _ = self:GetCurrentSelection()
	if LAST_SELECTION != nil and CUR_SELECTION != LAST_SELECTION then
		surface.PlaySound( self.DuringSelectionSound )
	end
	LAST_SELECTION = CUR_SELECTION
end

function PANEL:Paint( intW, intH )
	if !self.MenuOpen then return end

	--local sscale = intH /1050
	local sx, sy = intW /2, intH /2
	local size, size_half, center, label = 256, 128 , 84 , 150 

	surface.SetDrawColor( 255, 255, 255, 255 )
	
	local i, count = 0, table.Count( self.m_tOptions )
	for k, v in pairs( self.m_tOptions ) do
		local team = GAMEMODE.Teams[LocalPlayer():Team()]

		local brightness 	= (k == CUR_SELECTION and 255 or 200)
		local ang 			= v.RadialAngle
		local vx, vy 		= math.cos( ang ), math.sin( ang )
		local x, y 			= sx -vx *center, sy +vy *(center -1)

		if v.LeaderCmd and (team and team.Leader ~= LocalPlayer() or false) then brightness = 150 end
		
		local lx, ly = math.cos( ang +self.ToolAngBetween /2 ), math.sin( ang +self.ToolAngBetween /2 )
		surface.SetDrawColor( 80, 80, 80, 200 )
		surface.DrawLine( sx +lx *74, sy +ly *74, sx +lx *94, sy +ly *94 )
		
		surface.SetDrawColor( brightness, brightness, brightness, 255 )
		surface.SetTexture( v.SelectIcon or self.WepSelectIcon )
		surface.DrawTexturedRectRotated( x, y, 64, 64, 0 )
		
		surface.SetFont( "DermaDefaultBold" )
		local tw, th = surface.GetTextSize( v.Name )
		local tx, ty = sx -vx *label -tw /2 -tw /4 *vx, sy +vy *label -th /2 -th *vy
		
		surface.SetTextColor( 0, 0, 0, 255 )
		for _x = -1, 1 do
			for _y = -1, 1 do
				surface.SetTextPos( tx +_x, ty +_y )
				surface.DrawText( v.Name )
			end
		end

		surface.SetTextColor( brightness, brightness, brightness, 220 )
		surface.SetTextPos( tx, ty )
		surface.DrawText( v.Name )

		i = i +1
	end
end

function PANEL:GetCurrentSelection()
	--local sscale = self:GetTall() /1050
	local radialmenu = self.TOOL_RADIAL_MODE:GetInt() != 1
	local selection, selectionang = self:GetMode(), -1
	
	if MOUSE_CUR_DIST > 48 or radialmenu then
		local selang = -1
		local i, count = 0, table.Count( self.m_tOptions )

		for k, v in pairs( self.m_tOptions ) do
			local ang = math.deg( v.RadialAngle -self.ToolAngBetween /2 )
			local diff = math.AngleDifference( (!radialmenu and self.MenuTargetAngle or self.MenuCurAngle), ang )
			
			if selang == -1 or diff < selang then
				selang = diff
				selection = k
				selectionang = math.deg( v.RadialAngle ) +180 -- I'm not sure what is going on here but WHAT EVER
			end

			i = i +1
		end
	end
	
	return selection, math.NormalizeAngle( selectionang )
end

function PANEL:OpenMenu()
	if self.MenuOpen then return end

	if self.TOOL_RADIAL_MODE:GetInt() == 1 then
		gui.EnableScreenClicker( true )
		gui.SetMousePos( ScrW()/2, ScrH()/2 )
	else
		local sel, ang = self:GetCurrentSelection()
		self.MenuTargetAngle = ang
		self.MenuCurAngle = ang
	end

	self.MenuOpen = true
	self:SetVisible( true )
end

function PANEL:CloseMenu()
	if !self.MenuOpen then return end

	self.MenuOpen = false
	local selection, _ = self:GetCurrentSelection()

	--if selection != self:GetMode() then
	local option = self.m_tOptions[selection]
	if option and option.DoClick then
		option.DoClick()
	end
	--end

	if self.TOOL_RADIAL_MODE:GetInt() == 1 then
		gui.EnableScreenClicker( false )
	end

	self:SetVisible( false )
end

function PANEL:Toggle( bOpen )
	if bOpen then self:OpenMenu() else self:CloseMenu() end
end

function PANEL:PerformLayout()
end
vgui.Register( "sh_commorose", PANEL, "EditablePanel" )

function GM:ToggleCommoRose( bShow )
	local pl = LocalPlayer()

	if IsValid( pl ) then
		if IsValid( pl:GetActiveWeapon() ) and pl:GetActiveWeapon():GetClass() == "weapon_sh_tool" then
			if pl:GetActiveWeapon().MenuOpen then
				bShow = nil
			end
		end
	end

	if bShow then
		if not ValidPanel( self.m_pCommoRose ) then
			self.m_pCommoRose = vgui.Create( "sh_commorose" )
			self.m_pCommoRose:SetSize( ScrW(), ScrH() )
			self.m_pCommoRose:Center()
		end
	
		self.m_pCommoRose:Toggle( true )
	else
		if not ValidPanel( self.m_pCommoRose ) then return end
		self.m_pCommoRose:Toggle()
	end
end
concommand.Add( "+menu_context", function()
	GAMEMODE:ToggleCommoRose( true )
end )

concommand.Add( "-menu_context", function()
	GAMEMODE:ToggleCommoRose()
end )