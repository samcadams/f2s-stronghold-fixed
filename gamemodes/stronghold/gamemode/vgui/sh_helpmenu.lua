--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self:SetTitle( "Stronghold: Help Menu" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetDeleteOnClose( false )
	
	self.Sections = vgui.Create( "sh_propertysheet", self )
	
	self.HelpPanel = vgui.Create( "Panel", self )
	local html = vgui.Create( "HTML", self.HelpPanel )
	html:OpenURL( "http://stronghold.roaringcow.com/" )
	--local controls = vgui.Create( "DHTMLControls", self.HelpPanel )
	--controls:SetHTML( html )
	
	function self.HelpPanel.PerformLayout( panel )
		local w, h = panel:GetSize()
		--controls:SetSize( w, 32 )
		html:SetSize( w, h )
		html:SetPos( 0, 0 )
	end
	
	self.Sections:AddSheet( "Info", self.HelpPanel )
	
	self.StatsPanel = vgui.Create( "sh_statisticspanel", self )
	self.Sections:AddSheet( "Statistics", self.StatsPanel )

	self.VotingPanel = vgui.Create( "sh_votingpanel", self )
	self.Sections:AddSheet( "Map Voting", self.VotingPanel )
	
	self.TutorialPanel = vgui.Create( "sh_tutorialpanel", self )
	self.Sections:AddSheet( "Tutorial", self.TutorialPanel )

	self.DonatePanel = vgui.Create( "sh_donatepanel", self )
	self.Sections:AddSheet( "Donate", self.DonatePanel )
	
	self.CloseButton = vgui.Create( "DButton", self )
	self.CloseButton:SetText( "Close" )
	function self.CloseButton:DoClick()
		GAMEMODE.HelpFrame:Close()
	end	
end

function PANEL:Open()
	self:Center()
	self:SetVisible( true )
	self:MakePopup()
	RestoreCursorPosition()
end

function PANEL:Close()
	RememberCursorPosition()
	self:SetVisible( false )
	RunConsoleCommand( "sh_closedhelpmenu" )
end

function PANEL:OnKeyCodePressed( key )
	if key == KEY_F1 then
		self:Close()
	--elseif self.Sections.Items[key-1] then
	--	self.Sections:SetActiveTab( self.Sections.Items[key-1].Tab )
	end
end

function PANEL:Paint( w, h )
	derma.SkinHook( "Paint", "Frame", self, w, h )
	
	local skin = self:GetSkin()
	skin:DrawGenericBackground( 10, self:GetTall()-34, self:GetWide()-20, 24, skin.panel_transback )
	--skin.tex.Panels.Normal( 10, h-34, w-20, 24 )
end

function PANEL:PerformLayout( w, h )
	DFrame.PerformLayout( self, w, h )
	
	self.Sections:SetPos( 0, 30 )
	self.Sections:SetSize( w, h-64 )
	
	self.CloseButton:SetSize( 60, 22 )
	self.CloseButton:SetPos( w-71, h-33 )
end

vgui.Register( "sh_helpmenu", PANEL, "DFrame" )