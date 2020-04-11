--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--require( "datastream" )

-- There is an inconsistency in the DMultiChoice derma file on the Linux side compared to Windows
-- This fixes it:
--DMultiChoice.SetTextOld = DMultiChoice.SetText
--function DMultiChoice.SetText( self, text )
--	DMultiChoice.SetTextOld( self, text or "" )
--end

-- Variables
if GAMEMODE and ValidPanel( GAMEMODE.HelpFrame ) then GAMEMODE.HelpFrame:Remove() end
GM.HelpFrame = nil

if GAMEMODE and ValidPanel( GAMEMODE.TeamFrame ) then GAMEMODE.TeamFrame:Remove() end
GM.TeamFrame = nil

if GAMEMODE and ValidPanel( GAMEMODE.LoadoutFrame ) then GAMEMODE.LoadoutFrame:Remove() end
GM.LoadoutFrame = nil

if GAMEMODE and ValidPanel( GAMEMODE.OptionsFrame ) then GAMEMODE.OptionsFrame:Remove() end
GM.OptionsFrame = nil

-- Options menu
function GM:OptionsInit()
	self.OptionsFrame = vgui.Create( "sh_optionsmenu" )
	self.OptionsFrame:SetSize( 400, 600 )
	self.OptionsFrame:SetVisible( false )
	self.OptionsFrame:SetSkin( "stronghold" )
	
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "CheckBox", "Show HUD", "sh_hudenabled" )

	local minimalhudlabel = vgui.Create( "DLabel" ) minimalhudlabel:SetText( "Use Minimal HUD" ) 
	local minimalhudmode = vgui.Create( "sh_combobox" )
	minimalhudmode:Dock( FILL )
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "AddItem", minimalhudlabel, minimalhudmode )
	minimalhudmode:AddChoice( "Normal" )
	minimalhudmode:AddChoice( "Slim" )
	--minimalhudmode:AddChoice( "Health + Ammo" )
	minimalhudmode:SetConVar( "sh_hudminimal" )
	
	local slider, _ = self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "NumSlider", "GBux x-axis offset", "sh_gbuxoffset", 0, ScrW()-150, 0 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "CheckBox", "Enable Compass", "sh_compass" )
	local slider, _ = self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "NumSlider", "Compass Position X", "sh_composx", 0.1, 0.9, 3 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	local slider, _ = self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "NumSlider", "Compass Position Y", "sh_composy", 0, 0.992, 3 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	local slider, _ = self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "NumSlider", "Compass Sensitivity", "sh_comspeed", 1, 12, 0 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	local slider, _ = self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "NumSlider", "Compass Tick Spacing", "sh_comtd", 1, 12, 0 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )

	local btn = vgui.Create( "sh_colorbutton" )
	btn:SetText( "Compass Color" )
	btn:SetColorVars( "sh_comred", "sh_comgreen", "sh_comblue" )
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "AddItem", btn )

	self.OptionsFrame:AddOption( "Hit Indicator", "CheckBox", "Hit Indicator", "sh_hitindicator" )
	self.OptionsFrame:AddOption( "Hit Indicator", "CheckBox", "Hit Sound", "sh_hitsound" )

	local btn = vgui.Create( "sh_colorbutton" )
	btn:SetText( "Hit Indicator Color" )
	btn:SetColorVars( "sh_hitred", "sh_hitgreen", "sh_hitblue" )
	btn:SetColorTexture( "hitdetection2" )
	self.OptionsFrame:AddOption( "Hit Indicator", "AddItem", btn )
	
	self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Enabled", "voice_enable" )
	local slider, _ = self.OptionsFrame:AddOption( "Voice Chat", "NumSlider", "Voice Scale", "voice_scale", 0, 2, 2 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	local channel = self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Talk to team (Uncheck for public)" )
	function channel:OnChange( b ) RunConsoleCommand( "sh_voice_channel", b and 1 or 0 ) end
	self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Always Hear Public", "sh_voice_alwayshearpublic" )
	self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Always Hear Team", "sh_voice_alwayshearteam" )
	
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Impact Effects", "sh_fx_impacteffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Detailed Bullet Impact Effects", "sh_fx_detailedimpacteffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Lingering Bullet Impacts Dust", "sh_fx_smokeyimpacteffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Muzzle Effects", "sh_fx_muzzleeffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Detailed Explosions", "sh_fx_explosiveeffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Repair Tool Light", "sh_fx_dynamicweldlight" )

	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Hurt Blur", "sh_pp_hurtblur" )
	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Blood Splatter", "sh_pp_bloodsplat" )
	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Spawn Protection", "sh_pp_spawnprot" )
	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Vignette (Cheap texture)", "sh_pp_vignette" )
	local slider, _ = self.OptionsFrame:AddOption( "Screen Effects", "NumSlider", "Vignette Opacity", "sh_pp_vignette_opacity", 1, 100, 0 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )

	self.OptionsFrame:AddOption( "Tool Gun", "CheckBox", "Alternate Inputs", "sh_tool_altinput" )
	self.OptionsFrame:AddOption( "Tool Gun", "CheckBox", "Move Crosshair in Radial Menu", "sh_tool_radialshowmouse" )
	
	local radiallabel = vgui.Create( "DLabel" ) radiallabel:SetText( "Alt Radial Mode" ) 
	local radialmode = vgui.Create( "sh_combobox" )
	radialmode:Dock( FILL )
	self.OptionsFrame:AddOption( "Tool Gun", "AddItem", radiallabel, radialmode )
	radialmode:AddChoice( "Normal" )
	radialmode:AddChoice( "Left <-> Right" )
	radialmode:AddChoice( "Up <-> Down" )
	radialmode:SetConVar( "sh_tool_radialmode" )
	
	local slider, _ = self.OptionsFrame:AddOption( "Tool Gun", "NumSlider", "Alt Radial Speed", "sh_tool_radialmode_speed", 0, 1, 2 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	
	local slider, _ = self.OptionsFrame:AddOption( "Prop Spawn Tool", "NumSlider", "Snap Degrees", "propspawn_snapdegrees", 1, 360, 0 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	local slider, _ = self.OptionsFrame:AddOption( "Prop Spawn Tool", "NumSlider", "Sensitivity", "propspawn_sensitivity", 0, 1, 3 ) slider:SetTall( 24 ) slider.TextArea:SetDrawBackground( true )
	
	self.OptionsFrame:AddOption( "Repair Tool", "CheckBox", "Show Health Bar", "sh_repair_healthbar" )
	self.OptionsFrame:AddOption( "Repair Tool", "CheckBox", "Show actual numbers", "sh_repair_healthnum" )
end

concommand.Add( "sh_options",
	function()
		if ValidPanel( GAMEMODE.OptionsFrame ) then
			GAMEMODE.OptionsFrame:Open()
		end
	end )

-- Team menu

function GM:TeamInit()
	self.TeamFrame = vgui.Create( "sh_teammenu" )
	self.TeamFrame:SetSize( 750, 550 )
	self.TeamFrame:SetVisible( false )
	self.TeamFrame:SetSkin( "stronghold" )
end

concommand.Add( "sh_teams",
	function()
		if ValidPanel( GAMEMODE.TeamFrame ) then
			GAMEMODE.TeamFrame:Open()
		end
	end )


function GM:LoadoutInit()
	self.LoadoutFrame = vgui.Create( "sh_loadoutmenu" )
	self.LoadoutFrame:SetSize( 750, 550 )
	self.LoadoutFrame:SetVisible( false )
	self.LoadoutFrame:SetSkin( "stronghold" )
end

concommand.Add( "sh_loadout",
	function()
		if ValidPanel( GAMEMODE.LoadoutFrame ) then
			GAMEMODE.LoadoutFrame:Open()
		end
	end )
	
function GM:HelpInit()
	self.HelpFrame = vgui.Create( "sh_helpmenu" )
	self.HelpFrame:SetSize( 750, 550 )
	self.HelpFrame:SetVisible( false )
	self.HelpFrame:SetSkin( "stronghold" )
end

concommand.Add( "sh_help",
	function()
		if ValidPanel( GAMEMODE.HelpFrame ) then
			GAMEMODE.HelpFrame:Open()
		end
	end )
	
-- ----------------------------------------------------------------------------------------------------

local StoredCursorPos = {}

function RememberCursorPosition()
	local x, y = input.GetCursorPos()
	if x == 0 and y == 0 then return end
	StoredCursorPos.x, StoredCursorPos.y = x, y
end

function RestoreCursorPosition()
	if not StoredCursorPos.x or not StoredCursorPos.y then return end
	input.SetCursorPos( StoredCursorPos.x, StoredCursorPos.y )
end