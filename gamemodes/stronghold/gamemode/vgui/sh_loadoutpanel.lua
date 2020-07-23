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

local PANEL = {}

local function HandleMultiOption( pnl, tbl )
	if pnl:GetChecked() then
		if not tbl then return end

		for _, v in pairs( tbl ) do
			if v ~= pnl then
				RunConsoleCommand( v.ConVar, "0" )
				v:SetChecked( false )
			end
		end
	end
end

function PANEL:BuildCheckBoxes()
	local pw, sw = weapons.Get( self.CurrentPrimary ), weapons.Get( self.CurrentSecondary )

	self.PAttachments:Clear()
	for k, t in pairs( GAMEMODE.WeaponAttachments ) do
		if pw then
			if not pw.VElements or not pw.VElements[k] then
				continue
			end
		end

		if not self.Attachments.primary[t.type] then
			self.Attachments.primary[t.type] = {}
		end

		local parent = vgui.Create( "DPanel", self )
		parent:SetTall( 15 )

		local cbox = vgui.Create( "DCheckBoxLabel", parent )
		cbox:SetText( t.printname )
		cbox:SetConVar( "attach_".. k.. "_primary" )
		cbox.ConVar = "attach_".. k.. "_primary"
		cbox.OnChange = function(...) HandleMultiOption(..., self.Attachments.primary[t.type]) end
		cbox:SizeToContents()

		cbox.buy = vgui.Create( "DButton", parent )
		cbox.buy:SetText( "BUY" )
		cbox.buy:SetSize( 35, 15 )
		cbox.buy.DoClick = function( pnl )
			if not self.CurrentPrimary then return end
			local w = weapons.Get( self.CurrentPrimary )
			if not w then return end

			local dq = Derma_Query( "Purchase ".. t.printname.. " for your ".. w.PrintName.. "?\n\nPrice: $".. t.cost, "Purchase Attachment",
				"Yes", 	function() GAMEMODE.Net:SendBuyAttachmentRequest( 6, self.CurrentPrimary, k ) end, 
				"No", 	function()end
			)
			dq.Paint = function( p )
				Derma_DrawBackgroundBlur( p, p.m_fCreateTime )
				p:GetSkin():DrawGenericBackground( 0, 0, p:GetWide(), p:GetTall(), Color( 40, 40, 40, 240 ), false, true )
			end
		end

		cbox.Think = function( pnl )
			if not self.CurrentPrimary or not LocalPlayer():HasAttachment( 6, self.CurrentPrimary, k ) then
				pnl:SetDisabled( true )
				pnl:SetValue( false )
			else
				pnl:SetDisabled( false )
			end
		end
		cbox.buy.Think = function( pnl )
			if not self.CurrentPrimary or LocalPlayer():HasAttachment( 6, self.CurrentPrimary, k ) then
				pnl:SetDisabled( true )
			else
				pnl:SetDisabled( false )
			end
		end

		parent.PerformLayout = function( pnl )
			cbox.buy:SetPos( parent:GetWide() -cbox.buy:GetWide(), 0 )
		end

		self.PAttachments:AddItem( parent )
		table.insert( self.Attachments.primary[t.type], cbox )
	end

	self.SAttachments:Clear()
	for k, t in pairs( GAMEMODE.WeaponAttachments ) do
		if sw then
			if not sw.VElements or not sw.VElements[k] then
				continue
			end
		end

		if not self.Attachments.secondary[t.type] then
			self.Attachments.secondary[t.type] = {}
		end

		local parent = vgui.Create( "DPanel", self )
		parent:SetTall( 15 )

		local cbox = vgui.Create( "DCheckBoxLabel", parent )
		cbox:SetText( t.printname )
		cbox:SetConVar( "attach_".. k.. "_secondary" )
		cbox.ConVar = "attach_".. k.. "_secondary"
		cbox.OnChange = function(...) HandleMultiOption(..., self.Attachments.secondary[t.type]) end
		cbox:SizeToContents()

		cbox.buy = vgui.Create( "DButton", parent )
		cbox.buy:SetText( "BUY" )
		cbox.buy:SetSize( 35, 15 )
		cbox.buy.DoClick = function( pnl )
			if not self.CurrentSecondary then return end
			local w = weapons.Get( self.CurrentSecondary )
			if not w then return end

			local dq = Derma_Query( "Purchase ".. t.printname.. " for your ".. w.PrintName.. "?\n\nPrice: $".. t.cost, "Purchase Attachment",
				"Yes", 	function() GAMEMODE.Net:SendBuyAttachmentRequest( 7, self.CurrentSecondary, k ) end, 
				"No", 	function()end
			)
			dq.Paint = function( p )
				Derma_DrawBackgroundBlur( p, p.m_fCreateTime )
				p:GetSkin():DrawGenericBackground( 0, 0, p:GetWide(), p:GetTall(), Color( 40, 40, 40, 240 ), false, true )
			end
		end

		cbox.Think = function( pnl )
			if not self.CurrentSecondary or not LocalPlayer():HasAttachment( 7, self.CurrentSecondary, k ) then
				pnl:SetDisabled( true )
				pnl:SetValue( false )
			else
				pnl:SetDisabled( false )
			end
		end
		cbox.buy.Think = function( pnl )
			if not self.CurrentSecondary or LocalPlayer():HasAttachment( 7, self.CurrentSecondary, k ) then
				pnl:SetDisabled( true )
			else
				pnl:SetDisabled( false )
			end
		end

		parent.PerformLayout = function( pnl )
			cbox.buy:SetPos( parent:GetWide() -cbox.buy:GetWide(), 0 )
		end

		self.SAttachments:AddItem( parent )
		table.insert( self.Attachments.secondary[t.type], cbox )
	end
end

function PANEL:Init()
	self.Attachments = { primary = {}, secondary = {} }

	self.PAttachments = vgui.Create( "DPanelList", self )
	self.PAttachments:SetPadding( 5 )
	self.PAttachments:SetSpacing( 5 )
	self.PAttachments:EnableVerticalScrollbar( false )
	self.PATitle = vgui.Create( "DButton", self )
	self.PATitle:SetText( "Primary Attachments")

	self.SAttachments = vgui.Create( "DPanelList", self )
	self.SAttachments:SetPadding( 5 )
	self.SAttachments:SetSpacing( 5 )
	self.SATitle = vgui.Create( "DButton", self )
	self.SATitle:SetText( "Secondary Attachments" )
	
	self:BuildCheckBoxes()

	-- ----------
	
	self.CurrentPrimary = ""
	
	self.PrimaryModel = vgui.Create( "sh_itemmodel", self )
	self.PrimaryModel:Setup( "models/weapons/w_smg_mp5.mdl", "MP5-A4" )
	
	self.PrimaryList = vgui.Create( "DListView", self )
	self.PrimaryList:SetMultiSelect( false )
	self.PrimaryList:AddColumn( "Primary" )
	
	local column = self.PrimaryList:AddColumn( "Time left" )
	column:SetFixedWidth( 70 )
	
	self.PrimaryQuickBuy = vgui.Create( "sh_quickbuy", self )
	self.PrimaryQuickBuy:Setup( "SMG Ammo", "smg1", 4 )
	
	function self.PrimaryList.OnRowSelected( panel, lineid, line )
		local old_primary = self.CurrentPrimary
		self.CurrentPrimary = line.weaponclass or ""
		
		if self.CurrentPrimary != "" and old_primary != self.CurrentPrimary then
			RunConsoleCommand( "sh_setprimary", self.CurrentPrimary )
			local tbl = GAMEMODE.PrimaryWeapons[self.CurrentPrimary]
			self.PrimaryModel:Setup( tbl.model, tbl.name, (tbl.fov or 90), tbl.offset, (tbl.ang or Angle(0,0,0)) )
			self.PrimaryQuickBuy:Setup( ((tbl.type=="smg1" and "SMG") or (tbl.type=="buckshot" and "Shotgun") or (tbl.type=="ar2" and "Rifle") or (tbl.type=="rpg_round" and "RPG") or (tbl.type=="battery" and "Charge")).." Ammo", tbl.type, 4 )
			surface.PlaySound( SND_PRIMARY )

			self:BuildCheckBoxes()
		end
	end
	
	self.PrimaryQBAmmoPrice = vgui.Create( "DLabel", self )
	
	-- ----------
	
	self.CurrentSecondary = ""
	
	self.SecondaryModel = vgui.Create( "sh_itemmodel", self )
	self.SecondaryModel:Setup( "models/weapons/w_pist_p228.mdl", "SIG-SAUER P228", 60 )
	
	self.SecondaryList = vgui.Create( "DListView", self )
	self.SecondaryList:SetMultiSelect( false )
	self.SecondaryList:AddColumn( "Secondary" )
	local column = self.SecondaryList:AddColumn( "Time left" )
	column:SetFixedWidth( 70 )
	
	self.SecondaryQuickBuy = vgui.Create( "sh_quickbuy", self )
	self.SecondaryQuickBuy:Setup( "Pistol Ammo", "pistol", 4 )
	
	function self.SecondaryList.OnRowSelected( panel, lineid, line )
		local old_secondary = self.CurrentSecondary
		self.CurrentSecondary = line.weaponclass or ""
		if self.CurrentSecondary != "" and old_secondary != self.CurrentSecondary then
			RunConsoleCommand( "sh_setsecondary", self.CurrentSecondary )
			local tbl = GAMEMODE.SecondaryWeapons[self.CurrentSecondary]
			self.SecondaryModel:Setup( tbl.model, tbl.name, (tbl.fov or 60), tbl.offset, 4 )
			self.SecondaryQuickBuy:Setup( ((tbl.type=="smg1" and "SMG") or (tbl.type=="pistol" and "Pistol") or (tbl.type=="buckshot" and "Shotgun") or (tbl.type=="ar2" and "Rifle") or (tbl.type=="rpg_round" and "RPG")).." Ammo", tbl.type, 4 )
			surface.PlaySound( SND_SECONDARY )

			self:BuildCheckBoxes()
		end
	end
	
	self.SecondaryQBAmmoPrice = vgui.Create( "DLabel", self )
	
	-- ----------
	
	self.CurrentExplosive = ""
	
	self.ExplosiveModel = vgui.Create( "sh_itemmodel", self )
	self.ExplosiveModel:Setup( "models/weapons/w_eq_fraggrenade.mdl", "H.E. Grenade", 35 )
	
	self.ExplosiveList = vgui.Create( "DListView", self )
	self.ExplosiveList:SetMultiSelect( false )
	self.ExplosiveList:AddColumn( "Explosives" )
	local column = self.ExplosiveList:AddColumn( "Count" )
	column:SetFixedWidth( 50 )
	
	self.ExplosiveQuickBuy = vgui.Create( "sh_quickbuy", self )
	self.ExplosiveQuickBuy:Setup( "Grenade Ammo", "weapon_sh_grenade", 3 )
	
	function self.ExplosiveList.OnRowSelected( panel, lineid, line )
		local old_explosive = self.CurrentExplosive
		self.CurrentExplosive = line.weaponclass or ""
		if self.CurrentExplosive != "" and old_explosive != self.CurrentExplosive then
			RunConsoleCommand( "sh_setexplosive", self.CurrentExplosive )
			local tbl = GAMEMODE.Explosives[self.CurrentExplosive]
			self.ExplosiveModel:Setup( tbl.model, tbl.name, (tbl.fov or 35), tbl.offset, (tbl.ang or Angle(0,0,0)) )
			self.ExplosiveQuickBuy:Setup(
				((self.CurrentExplosive=="weapon_sh_drone" and "Assault Drones") or
				 (self.CurrentExplosive=="weapon_sh_grenade" and "H.E. Grenades") or
				 (self.CurrentExplosive=="weapon_sh_incendiarygrenade" and "Incendiaries") or
				 (self.CurrentExplosive=="weapon_sh_smoke" and "Smoke Grenades") or
				 (self.CurrentExplosive=="weapon_sh_flash" and "Flash Grenades") or
				 (self.CurrentExplosive=="weapon_sh_c4" and "C4 Explosives")),
				self.CurrentExplosive, 3 )
			surface.PlaySound( SND_EXPLOSIVE )
		end
	end
	
	self.ExplosiveQBAmmoPrice = vgui.Create( "DLabel", self )
	
	-- ----------
	
	self.SaveRequest = vgui.Create( "DFrame" )
	self.SaveRequest:SetDeleteOnClose( false )
	self.SaveRequest:SetTitle( "Save Loadout" )
	self.SaveRequest:SetDraggable( false )
	self.SaveRequest:ShowCloseButton( false )
	self.SaveRequest:SetSize( 150, 94 )
	self.SaveRequest:SetVisible( false )
	self.SaveRequest:SetSkin( "stronghold" )
	
	function self.SaveRequest.Close( panel )
		GAMEMODE.LoadoutFrame:SetKeyboardInputEnabled( false )
		GAMEMODE.LoadoutFrame:SetMouseInputEnabled( false )
		panel:SetVisible( false )
		GAMEMODE.LoadoutFrame:MakePopup()
	end
	
	local label = vgui.Create( "DLabel", self.SaveRequest )
	label:SetText( "Name:" )
	label:SizeToContents()
	label:SetTall( 22 )
	label:SetPos( 10, 30 )
	
	local name = vgui.Create( "DTextEntry", self.SaveRequest )
	name:SetSize( 120-label:GetWide(), 22 )
	name:SetPos( label:GetWide()+20, 30 )
	
	local cancel = vgui.Create( "DButton", self.SaveRequest )
	cancel:SetText( "Cancel" )
	cancel:SetSize( 60, 22 )
	cancel:SetPos( 10, 64 )
	function cancel.DoClick() self.SaveRequest:Close() end
	
	local save = vgui.Create( "DButton", self.SaveRequest )
	save:SetText( "Save" )
	save:SetSize( 60, 22 )
	save:SetPos( 80, 64 ) 
	function save.DoClick() local ply = LocalPlayer()
		if name:GetValue() != "" then 
			self:DoSaveLoadout( name:GetValue() ) self.SaveRequest:Close() 
		else 
			ply:SendMessage( "You must name your loadout." )
			surface.PlaySound( SND_FAIL )
		end 
	end
end

function PANEL:DoRefreshLicenses()
	local ply = LocalPlayer()
	local ostime = os.time()
	
	-- Make sure these are checked for gamemode reloads
	local primary = ply:GetLoadoutPrimary()
	local secondary = ply:GetLoadoutSecondary()
	local explosive = ply:GetLoadoutExplosive()

	self.PrimaryList:Clear()
	for class, time in pairs(ply:GetLicenses(1)) do
		local timeleft = (time == -1 and -1 or time-ostime)
		local tbl = GAMEMODE.PrimaryWeapons[class]
		if tbl and (timeleft == -1 or timeleft > 0) then
			local line = self.PrimaryList:AddLine( tbl.name, (timeleft != -1 and UTIL_FormatTime(timeleft,true) or "~") )
			line.weaponclass = class
			if class == primary then
				line:SetSelected( true )
				self.PrimaryList:OnRowSelected( _, line )
			end
		end
	end
	self.PrimaryList:SortByColumn( 1, false )
	
		-- What does this do?
		--[[local selectedid = self.PrimaryList:GetSelectedLine() or 1
		if selectedid != nil then
			local line = self.PrimaryList:GetLine(selectedid)
			if line != nil then
				self.PrimaryList:OnClickLine( line )
			end
		end]]
	
	self.SecondaryList:Clear()
	for class, time in pairs(ply:GetLicenses(2)) do
		local timeleft = (time == -1 and -1 or time-ostime)
		local tbl = GAMEMODE.SecondaryWeapons[class]
		if tbl and (timeleft == -1 or timeleft > 0) then
			local line = self.SecondaryList:AddLine( tbl.name, (timeleft != -1 and UTIL_FormatTime(timeleft,true) or "~") )
			line.weaponclass = class
			if class == secondary then
				line:SetSelected( true )
				self.SecondaryList:OnRowSelected( _, line )
			end
		end
	end
	self.SecondaryList:SortByColumn( 1, false )
	
		-- What does this do?
		--[[local selectedid = self.SecondaryList:GetSelectedLine() or 1
		if selectedid != nil then
			local line = self.SecondaryList:GetLine(selectedid)
			if line != nil then
				self.SecondaryList:OnClickLine( line )
			end
		end]]
	
	self.ExplosiveList:Clear()
	for class, tbl in pairs(GAMEMODE.Explosives) do
		local line = self.ExplosiveList:AddLine( tbl.name, ply:GetItemCount(class) )
		line.weaponclass = class
		if class == explosive then
			line:SetSelected( true )
			self.ExplosiveList:OnRowSelected( _, line )
		end
	end
	self.ExplosiveList:SortByColumn( 1, false )
	
		-- What does this do?
		--[[local selectedid = self.ExplosiveList:GetSelectedLine() or 1
		if selectedid != nil then
			local line = self.ExplosiveList:GetLine(selectedid)
			if line != nil then
				self.ExplosiveList:OnClickLine( line )
			end
		end]]
	
	self.PrimaryQuickBuy:Update()
	self.SecondaryQuickBuy:Update()
	self.ExplosiveQuickBuy:Update()
end

function PANEL:DoSaveLoadout( name )
	local pri = self.CurrentPrimary or ""
	local sec = self.CurrentSecondary or ""
	local expl = self.CurrentExplosive or ""
	local ply = LocalPlayer()
	if name != "" and pri != "" and sec != "" and expl != "" then
		RunConsoleCommand( "sh_editloadout", name, pri, sec, expl )
		ply:EditLoadout( name, pri, sec, expl )
		self:DoRefreshLoadouts()
		surface.PlaySound( SND_CONFIRM )
	end
end

function PANEL:Think()
	if !GAMEMODE.PrimaryWeapons then return end
	if not self.CurrentPrimary or self.CurrentPrimary == "" then return end
	if not self.CurrentSecondary or self.CurrentSecondary == "" then return end
	if not self.CurrentExplosive or self.CurrentExplosive == "" then return end
	local Atype = GAMEMODE.PrimaryWeapons[self.CurrentPrimary].type
	local price = GAMEMODE.Ammo[Atype].price
	local Atype2 = GAMEMODE.SecondaryWeapons[self.CurrentSecondary].type
	local price2 = GAMEMODE.Ammo[Atype2].price
	local Atype3 = GAMEMODE.Explosives[self.CurrentExplosive].price
	if !price then return end
	self.PrimaryQBAmmoPrice:SetText("Price: $"..self.PrimaryQuickBuy.Value:GetValue()*price)
	self.SecondaryQBAmmoPrice:SetText("Price: $"..self.SecondaryQuickBuy.Value:GetValue()*price2)
	self.ExplosiveQBAmmoPrice:SetText("Price: $"..self.ExplosiveQuickBuy.Value:GetValue()*Atype3)
end

function PANEL:PerformLayout( w, h )
	local spacing = (w-30) * 0.25
	
	self.PAttachments:SetSize( spacing, 150 )
	self.PAttachments:SetPos( 0, 14 )
	self.PATitle:SetPos(1,0)
	self.PATitle:SetSize(173,15)
	
	self.SAttachments:SetSize( spacing, 150 )
	self.SAttachments:SetPos( 0, 164 )
	self.SATitle:SetPos( 1, 150 )
	self.SATitle:SetSize( 173, 15 )

	self.PrimaryModel:SetSize( spacing, spacing )
	self.PrimaryModel:SetPos( spacing+10, 0 )
	self.PrimaryList:SetSize( spacing, h-54-spacing )
	self.PrimaryList:SetPos( spacing+10, 10+spacing )
	self.PrimaryQuickBuy:SetSize( spacing, 44 )
	self.PrimaryQuickBuy:SetPos( spacing+10, h-44 )
	
	self.PrimaryQBAmmoPrice:SetSize( spacing, 44 )
	self.PrimaryQBAmmoPrice:SetPos( spacing+70, h-32 )

	
	self.SecondaryModel:SetSize( spacing, spacing )
	self.SecondaryModel:SetPos( (spacing+10)*2, 0 )
	self.SecondaryList:SetSize( spacing, h-54-spacing )
	self.SecondaryList:SetPos( (spacing+10)*2, 10+spacing )
	self.SecondaryQuickBuy:SetSize( spacing, 44 )
	self.SecondaryQuickBuy:SetPos( (spacing+10)*2, h-44 )
	
	self.SecondaryQBAmmoPrice:SetSize( spacing, 44 )
	self.SecondaryQBAmmoPrice:SetPos( (spacing+40)*2, h-32 )
	
	self.ExplosiveModel:SetSize( spacing, spacing )
	self.ExplosiveModel:SetPos( (spacing+10)*3, 0 )
	self.ExplosiveList:SetSize( spacing, h-54-spacing )
	self.ExplosiveList:SetPos( (spacing+10)*3, 10+spacing )
	self.ExplosiveQuickBuy:SetSize( spacing, 44 )
	self.ExplosiveQuickBuy:SetPos( (spacing+10)*3, h-44 )
	
	self.ExplosiveQBAmmoPrice:SetSize( spacing, 44 )
	self.ExplosiveQBAmmoPrice:SetPos( (spacing+30)*3, h-32 )
	
	self.SaveRequest:Center()
end

vgui.Register( "sh_loadoutpanel", PANEL, "Panel" )