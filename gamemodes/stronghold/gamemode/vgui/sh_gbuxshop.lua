--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local SND_PRIMARY = Sound( "weapons/mp5Navy/mp5_slideback.wav" )
local SND_SECONDARY = Sound( "weapons/elite/elite_sliderelease.wav" )
local SND_EXPLOSIVE = Sound( "weapons/pinpull.wav" )
local SND_AMMO = Sound( "items/ammo_pickup.wav" )
local SND_CONFIRM = Sound( "buttons/button9.wav" )
local SND_FAIL = Sound( "buttons/button11.wav" )

local UTIL_FormatMoney = UTIL_FormatMoney
local UTIL_PRound = UTIL_PRound

local TEX_GRADIENT_BOTTOM = surface.GetTextureID( "vgui/gradient-d" )
local TEX_GRADIENT_TOP = surface.GetTextureID( "vgui/gradient-u" )

local PANEL = {}

function PANEL:Init()
	self:SetDataHeight( 26 )

	local column = self:AddColumn( "Type" )
	column:SetFixedWidth( 50 )
	
	self:AddColumn( "Name" )
	
	local column = self:AddColumn( "Price" )
	column:SetFixedWidth( 50 )
	
	local column = self:AddColumn( "Buy" )
	column:SetFixedWidth( 150 )
end

function PANEL:AddLine( ... )
	self:SetDirty( true )
	self:InvalidateLayout()

	local Line = vgui.Create( "sh_itemlistview_line", self.pnlCanvas )
	local ID = table.insert( self.Lines, Line )
	Line:SetListView( self ) 
	Line:SetID( ID )

	for k, v in pairs(self.Columns) do
		Line:SetColumnText( k, "" )
	end

	for k, v in pairs({...}) do
		Line:SetColumnText( k, v )
	end

	local SortID = table.insert( self.Sorted, Line )
	if SortID % 2 == 1 then
		Line:SetAltLine( true )
	end

	return Line
end

vgui.Register( "sh_itemlistview", PANEL, "DListView" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.Quantity = vgui.Create( "DNumberWang", self )
	self.Quantity:SetDecimals( 0 )
	self.Quantity:SetMinMax( 1, 1000 )
	self.Quantity:SetValue( 1 )
	self.Quantity:SetTextColor(Color(0,0,0,255))
	self.Quantity:SetCursorColor(Color(0,0,0,255))	
	self.Quantity:SetHighlightColor(Color(0, 200, 255))
	function self.Quantity.OnMouseWheeled( panel, delta )
		if self.m_iType == 4 then
			panel:SetValue(math.max( 1, panel:GetValue() + (panel:GetValue() == 1 and 9 or 10) * delta ))
		else
			panel:SetValue(math.max( 1, panel:GetValue() + delta ))
		end
	end
	
	self.BuyMode = vgui.Create( "DComboBox", self )
	self.BuyMode:AddChoice( "Hour [%10]" )
	self.BuyMode:AddChoice( "Permanently" )
	self.BuyMode:ChooseOptionID( 1 )
	self.BuyMode:SetVisible( false )
	function self.BuyMode.OnMousePressed( panel, mc )
		if !self:IsSelected() then self:OnMousePressed( mc ) end
	end
	function self.BuyMode.OnSelect( panel, index, value, data )
		self.m_iLicenseMode = index
	end
	function self.BuyMode.DropButton.OnMousePressed( panel, mc )
		self.BuyMode:OpenMenu( self.BuyMode.DropButton )
		if !self:IsSelected() then self:OnMousePressed( mc ) end
	end
	function self.BuyMode.OnMousePressed( panel, mc )
		self.BuyMode:OpenMenu( self.BuyMode )
		if !self:IsSelected() then self:OnMousePressed( mc ) end
	end
	function self.BuyMode:UpdateColours( skin )
		if ( self:GetDisabled() )						then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
		if ( self.Depressed or self.m_bSelected )		then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
		if ( self.Hovered )								then return self:SetTextStyleColor( skin.Colours.Button.Hover ) end

		return self:SetTextStyleColor( skin.colTextEntryText )
	end
	
	self.Buy = vgui.Create( "DButton", self )
	self.Buy:SetText( "BUY" )
	function self.Buy.OnMousePressed( panel, mc )
		if panel.m_bDisabled then return end
		panel:MouseCapture( true )
		panel.Depressed = true
		if !self:IsSelected() then self:OnMousePressed( MOUSE_LEFT ) end
	end
	function self.Buy.DoClick()
		self:DoBuy()
	end
	
	self.m_iType = 0
	self.m_iLicenseMode = 1
end

function PANEL:DoBuy()
	local money = LocalPlayer():GetMoney()
	local cost
	
	if self.m_iType <= 2 then
		cost = (self.m_iLicenseMode==2 and tonumber( self:GetColumnText(3) ) or tonumber( self:GetColumnText(3) )*0.10)
	else
		cost = tonumber( self:GetColumnText(3) ) * self.Quantity:GetValue()
	end

	if cost <= money then
		surface.PlaySound( SND_CONFIRM )
		if self.m_iLicenseMode == 2 then self:GetListView():RemoveLine( self:GetID() ) end
	else
		surface.PlaySound( SND_FAIL )
	end
	
	if self.m_iType <= 2 then
		RunConsoleCommand( "sh_buyitem", self.m_iType, self:GetColumnText(4), self.m_iLicenseMode )
	else
		RunConsoleCommand( "sh_buyitem", self.m_iType, self:GetColumnText(4), self.Quantity:GetValue() )
	end
end

function PANEL:SetType( i )
	self.m_iType = i
	self.Quantity:SetVisible( i > 2 and i ~= 5 )	
	self.BuyMode:SetVisible( i <= 2 )
end

function PANEL:GetType( i )
	return self.m_iType
end

function PANEL:DataLayout( listview )
	self:ApplySchemeSettings()
	local height = self:GetTall()
	
	local x = 0
	for i, column in pairs(self.Columns) do
		local w = listview:ColumnWidth( i )
		column:SetPos( x, 0 )
		column:SetSize( w, height )
		if i == 4 then
			column:SetVisible( false )
			self.Quantity:SetPos( x+2, 2 )
			self.Quantity:SetSize( w-46, height-4 )
			self.BuyMode:SetPos( x+2, 2 )
			self.BuyMode:SetSize( w-46, height-4 )
			self.Buy:SetPos( x+w-42, 2 )
			self.Buy:SetSize( 40, height-4 )
		end
		x = x + w
	end
end

vgui.Register( "sh_itemlistview_line", PANEL, "DListView_Line" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.CurrentItem = { name="<Select Item>", price=0, line=nil, item="", type=0 }

	self.ItemModel = vgui.Create( "sh_itemmodel", self )
	
	self.Sections = vgui.Create( "sh_propertysheet", self )
	
	local function OnRowSelected( panel, lineid, line )
		local tbl
		local type, item = line:GetType(), line:GetColumnText( 4 )
		if type == 1 then
			tbl = GAMEMODE.PrimaryWeapons[item]
			--surface.PlaySound( SND_PRIMARY )
		elseif type == 2 then
			tbl = GAMEMODE.SecondaryWeapons[item]
			--surface.PlaySound( SND_SECONDARY )
		elseif type == 3 then
			tbl = GAMEMODE.Explosives[item]
			--surface.PlaySound( SND_EXPLOSIVE )
		elseif type == 4 then
			tbl = GAMEMODE.Ammo[item]
			--surface.PlaySound( SND_AMMO )
		elseif type == 5 then
			tbl = GAMEMODE.Hats[item]
		end
		
		if tbl then
			self.CurrentItem.name = tbl.name
			self.CurrentItem.price = tbl.price
			self.CurrentItem.line = line
			self.CurrentItem.item = item
			self.CurrentItem.type = type
			self.ItemModel:Setup( tbl.model, tbl.name, tbl.fov+3 or 90, tbl.offset or Vector(-10,0,-5),(tbl.ang or Angle(0,0,0)) )
		end
	end
	
	-- ----------
	
	self.PrimaryList = vgui.Create( "sh_itemlistview", self.Sections )
	self.PrimaryList:SetMultiSelect( false )
	self.Sections:AddSheet( "Primary Weapons", self.PrimaryList )
	
	self.PrimaryList.OnRowSelected = OnRowSelected
	
	-- ----------
	
	self.SecondaryList = vgui.Create( "sh_itemlistview", self.Sections )
	self.SecondaryList:SetMultiSelect( false )
	self.Sections:AddSheet( "Secondary Weapons", self.SecondaryList )
	
	self.SecondaryList.OnRowSelected = OnRowSelected
	
	-- ----------
	
	self.ExplosiveList = vgui.Create( "sh_itemlistview", self.Sections )
	self.ExplosiveList:SetMultiSelect( false )
	self.Sections:AddSheet( "Explosives", self.ExplosiveList )
	
	self.ExplosiveList.OnRowSelected = OnRowSelected
	
	-- ----------
	
	self.AmmoList = vgui.Create( "sh_itemlistview", self.Sections )
	self.AmmoList:SetMultiSelect( false )
	self.Sections:AddSheet( "Ammo", self.AmmoList )
	
	self.AmmoList.OnRowSelected = OnRowSelected
	
	-- ----------
	
	self.Apparel = vgui.Create( "sh_itemlistview", self.Sections )
	self.Apparel:SetMultiSelect( false )
	self.Sections:AddSheet( "Apparel", self.Apparel )
	
	self.Apparel.OnRowSelected = OnRowSelected
end

function PANEL:RefreshShop()
	local ply = LocalPlayer()

	self.PrimaryList:Clear()
	for class, tbl in pairs(GAMEMODE.PrimaryWeapons) do
		if tbl.price != 0 and ply:GetLicenseTimeLeft( 1, class ) != -1 then
			local type = ((tbl.type=="smg1" and "SMG") or (tbl.type=="buckshot" and "Shotgun") or "Rifle")
			local line = self.PrimaryList:AddLine( type, tbl.name, tbl.price, class )
			line:SetType( 1 )
		end
	end
	self.PrimaryList:SortByColumn( 2, false )
	
	self.SecondaryList:Clear()
	for class, tbl in pairs(GAMEMODE.SecondaryWeapons) do
		if tbl.price != 0 and ply:GetLicenseTimeLeft( 2, class ) != -1 then
			local type = ((tbl.auto and "Auto") or "Semi")
			local line = self.SecondaryList:AddLine( type, tbl.name, tbl.price, class )
			line:SetType( 2 )
		end
	end
	self.SecondaryList:SortByColumn( 2, false )
	
	self.ExplosiveList:Clear()
	for class, tbl in pairs(GAMEMODE.Explosives) do
		local type = ((tbl.cook and "Cookable") or "Timed")
		local line = self.ExplosiveList:AddLine( type, tbl.name, tbl.price, class )
		line:SetType( 3 )
	end
	self.ExplosiveList:SortByColumn( 2, false )
	
	self.AmmoList:Clear()
	for ammo, tbl in pairs(GAMEMODE.Ammo) do
		local line = self.AmmoList:AddLine( tbl.type, tbl.name, tbl.price, ammo )
		line:SetType( 4 )
	end
	self.AmmoList:SortByColumn( 2, false )
	
	self.Apparel:Clear()
	for hat, tbl in pairs(GAMEMODE.Hats) do
		local line = self.Apparel:AddLine( "Hat", tbl.name, tbl.price, hat )
		line:SetType( 5 )
	end
	self.Apparel:SortByColumn( 2, false )	
end

local function shadowedtext( str, x, y, color, salpha )
	surface.SetTextColor( 0, 0, 0, salpha )
	surface.SetTextPos( x+1, y+1 )
	surface.DrawText( str )
	surface.SetTextColor( color.r, color.g, color.b, color.a )
	surface.SetTextPos( x, y )
	surface.DrawText( str )
end

function PANEL:Paint( w, h )
	local ply = LocalPlayer()
	local rw = h-150
	local wallet_x, wallet_y = w-rw, 34
	local skin = self:GetSkin()
	local wh = h-rw-44
	
	skin:DrawGenericBackground( 0, 0, w, 24, skin.panel_transback )
	skin:DrawGenericBackground( wallet_x, wallet_y, rw, wh, skin.panel_transback )
	skin:DrawGenericBackground( wallet_x, wallet_y+wh+10, rw, 24, skin.panel_transback )
	
	surface.SetFont( "Trebuchet19" )
	surface.SetTextColor( 255, 255, 255, 255 )
	
	local tw, th = surface.GetTextSize( "The GBux Shop" )
	surface.SetTextPos( w*0.50-tw*0.50, 12-th*0.50 )
	surface.DrawText( "Available Weapons" )

	local tw, th = surface.GetTextSize( "Wallet" )
	surface.SetTextPos( w-rw*0.50-tw*0.50, 46-th*0.50 )
	surface.DrawText( "Wallet" )
	
	local tw, th = surface.GetTextSize( "Inventory Count" )
	surface.SetTextPos( wallet_x+12, wallet_y+wh+22-th*0.50 )
	surface.DrawText( "Inventory Count" )
	
	local lineoffset = wallet_y+wh+11
	surface.SetDrawColor( 200, 200, 200, 200 )
	surface.DrawLine( wallet_x+1, 56, w-2, 56 )
	surface.DrawLine( wallet_x+tw+20, lineoffset, wallet_x+tw+20, lineoffset+21 )
	
	surface.SetFont( "Trebuchet19" )
	
	local initial = ply:GetMoney()
	local money = UTIL_FormatMoney( UTIL_PRound(initial,2) )
	local tw, th = surface.GetTextSize( money )
	shadowedtext( "Current Balance:", wallet_x+8, wallet_y+26, Color(255,255,255,255), 255 )
	shadowedtext( money, w-tw-10, wallet_y+26, Color(255,255,255,255), 255 )
	
	local rawprice = math.abs( (IsValid(self.CurrentItem.line) and self.CurrentItem.price*tonumber(self.CurrentItem.line.Quantity:GetValue()) or self.CurrentItem.price) ) * -1
	if IsValid( self.CurrentItem.line ) and self.CurrentItem.type <= 2 and self.CurrentItem.line.m_iLicenseMode == 1 then rawprice = rawprice * 0.10 end
	local enough = (initial + rawprice) > 0
	
	local col
	if enough then
		local scale = math.abs( rawprice / initial )
		col = Color( 180+75*scale, 255-128*scale, 180-180*scale, 255 )
	else
		col = Color( 255, 0, 0, 255 )
	end
	
	local price = UTIL_FormatMoney( UTIL_PRound(rawprice,2) )
	local tw, th = surface.GetTextSize( price )
	shadowedtext( "Last Selected: "..self.CurrentItem.name, wallet_x+8, wallet_y+46, col, 255 )
	shadowedtext( price, w-tw-10, wallet_y+46, col, 255 )
	
	local balance = UTIL_FormatMoney( UTIL_PRound(initial + rawprice,2) )
	local tw, th = surface.GetTextSize( balance )
	shadowedtext( "Final Balance:", wallet_x+8, wallet_y+76, col, 255 )
	shadowedtext( balance, w-tw-10, wallet_y+76, col, 255 )
	
	local invcount
	if self.CurrentItem.type <= 2 or self.CurrentItem.type == 5 then
		local timeleft = ply:GetLicenseTimeLeft( self.CurrentItem.type, self.CurrentItem.item )
		invcount = (timeleft == -1 and "Forever" or UTIL_FormatTime( timeleft, true ))
	else
		invcount = ply:GetItemCount( self.CurrentItem.item )
	end
	local tw, th = surface.GetTextSize( invcount )
	shadowedtext( invcount, w-tw-10, wallet_y+wh+22-th*0.50, Color(200,200,200,255), 255 )
end

function PANEL:PerformLayout( w, h )
	local rw = h-150
	
	self.ItemModel:SetSize( rw, rw-34 )
	self.ItemModel:SetPos( w-rw, h-rw+34 )
	
	self.Sections:SetSize( w-rw-10, h-34 )
	self.Sections:SetPos( 0, 34 )
end

vgui.Register( "sh_gbuxshop", PANEL, "Panel" )