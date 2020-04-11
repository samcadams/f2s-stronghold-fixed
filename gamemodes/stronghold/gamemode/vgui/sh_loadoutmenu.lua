--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self:SetTitle( "Stronghold: Loadout Menu" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetDeleteOnClose( false )
	
	self.Sections = vgui.Create( "sh_propertysheet", self )
	
	self.LoadoutPanel = vgui.Create( "sh_loadoutpanel", self.Sections )
	self.Sections:AddSheet( "Loadout", self.LoadoutPanel )
	
	--self.Sections:AddSheet( "Inventory [WIP]", vgui.Create("Panel"), "gui/silkicons/table_edit" )
	--TODO
	
	self.GBuxShop = vgui.Create( "sh_gbuxshop" )
	self.Sections:AddSheet( "Weapons", self.GBuxShop )
	
	self.AppearancePanel = vgui.Create( "sh_appearancepanel" )
	self.Sections:AddSheet( "Appearance", self.AppearancePanel )
	
	self.FinanceMenu = vgui.Create( "sh_finance" )
	self.Sections:AddSheet( "Finance", self.FinanceMenu )
	
	self.BountyMenu = vgui.Create( "sh_bounty" )
	self.Sections:AddSheet( "Bounty Board", self.BountyMenu )
	
	self.CloseButton = vgui.Create( "DButton", self )
	self.CloseButton:SetText( "Close" )
	
	function self.CloseButton:DoClick()
		GAMEMODE.LoadoutFrame:Close()
	end
end

function PANEL:Refresh()
	self.LoadoutPanel:DoRefreshLicenses()
	self.GBuxShop:RefreshShop()
	self.AppearancePanel:RefreshHats()
end

function PANEL:RefreshLicenses()
	self.LoadoutPanel:DoRefreshLicenses()
end

function PANEL:RefreshShop()
	self.GBuxShop:RefreshShop()
end

function PANEL:RefreshHats()
	self.AppearancePanel:RefreshHats()
end

function PANEL:Open()
	self:Refresh()
	self:Center()
	self:SetVisible( true )
	self:MakePopup()
	RestoreCursorPosition()
end

function PANEL:Close()
	RememberCursorPosition()
	self:SetVisible( false )
	RunConsoleCommand( "sh_closedloadoutmenu" )
end

function PANEL:OnKeyCodePressed( key )
	if key == KEY_F3 then
		self:Close()
	--elseif self.Sections.Items[key-1] then
	--	self.Sections:SetActiveTab( self.Sections.Items[key-1].Tab )
	end
end

function PANEL:Paint( w, h )
	local skin = self:GetSkin()
	
	derma.SkinHook( "Paint", "Frame", self, w, h )

	skin:DrawGenericBackground( 10, h-34, w-20, 24, skin.panel_transback )
end

function PANEL:PerformLayout( w, h )
	DFrame.PerformLayout( self, w, h )
	
	self.Sections:SetPos( 0, 30 )
	self.Sections:SetSize( w, h-64 )
	
	self.CloseButton:SetSize( 60, 22 )
	self.CloseButton:SetPos( w-71, h-33 )
end

vgui.Register( "sh_loadoutmenu", PANEL, "DFrame" )