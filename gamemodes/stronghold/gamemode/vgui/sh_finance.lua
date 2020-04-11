--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

local PANEL = {}

function PANEL:Init()
	self.MemberList = vgui.Create( "DListView", self )
	self.MemberList:SetMultiSelect( false )
	self.MemberList:AddColumn( "Players" )
	local column = self.MemberList:AddColumn( "Kills" )
	column:SetFixedWidth( 50 )
	local column = self.MemberList:AddColumn( "Deaths" )
	column:SetFixedWidth( 50 )
	function self.MemberList.OnRowSelected( _, lineid, line )
		self:SetPlayer( line.player )
	end
	
	self.Amount = vgui.Create( "DNumberWang", self )
	self.Amount:SetDecimals( 2 )
	self.Amount:SetMinMax( 0, 1000000000 )
	
	self.GiveAway = vgui.Create( "DButton", self )
	self.GiveAway:SetText( "Give amount to selected player" )
	function self.GiveAway.DoClick()
		if self.Amount:GetValue() == 0 then return end
	
		local line = self.MemberList:GetLine( self.MemberList:GetSelectedLine() )
		if line and IsValid( line.player ) then
			RunConsoleCommand( "sh_giveawaymoney", line.player:EntIndex(), self.Amount:GetValue() )
		end
	end
	
	self.m_LastUpdate = 0
end

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 2 then return end
	
	local lply = LocalPlayer()
	self.Amount:SetMinMax( 0, lply:GetMoney() )
	
	for _, ply in pairs(player.GetAll()) do
		if ply != lply then
			local found = false
			for _, line in pairs(self.MemberList.Lines) do
				if line.player == ply then found = true end
			end
			if !found then
				local line = self.MemberList:AddLine( ply:GetName(), ply:Frags(), ply:Deaths() )
				line.player = ply
			end
		end
	end
	for i, line in pairs(self.MemberList.Lines) do
		if !IsValid( line.player ) then
			self.MemberList:RemoveLine( i )
		else
			line:SetColumnText( 2, line.player:Frags() )
			line:SetColumnText( 3, line.player:Deaths() )
		end
	end
	
	self.m_LastUpdate = CurTime()
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
	local wallet_x, wallet_y = w-rw, 0
	local skin = self:GetSkin()
	local wh = h-rw-44
	
	skin:DrawGenericBackground( wallet_x, wallet_y, rw, wh, skin.panel_transback )
	skin:DrawGenericBackground( wallet_x, wallet_y+wh+10, rw, h-wh-10, skin.panel_transback )
	
	surface.SetFont( "Trebuchet19" )
	surface.SetTextColor( 255, 255, 255, 255 )

	local tw, th = surface.GetTextSize( "Wallet" )
	surface.SetTextPos( w-rw*0.50-tw*0.50, 12-th*0.50 )
	surface.DrawText( "Wallet" )
	
	surface.SetDrawColor( 200, 200, 200, 200 )
	surface.DrawLine( wallet_x+1, 22, w-2, 22 )
	
	surface.SetTextPos( w-rw+10, wh+33-th*0.50 )
	surface.DrawText( "Giving away to selected:" )
	
	surface.SetFont( "Trebuchet19" )
	
	local initial = ply:GetMoney()
	local money = UTIL_FormatMoney( UTIL_PRound(initial,2) )
	local tw, th = surface.GetTextSize( money )
	shadowedtext( "Current Balance:", wallet_x+8, wallet_y+26, Color(255,255,255,255), 255 )
	shadowedtext( money, w-tw-10, wallet_y+26, Color(255,255,255,255), 255 )
	
	local rawprice = self.Amount:GetValue()
	local enough = (initial - rawprice) > 0
	
	local col
	if enough then
		local scale = math.abs( rawprice / initial )
		col = Color( 180+75*scale, 255-128*scale, 180-180*scale, 255 )
	else
		col = Color( 255, 0, 0, 255 )
	end
	
	local price = UTIL_FormatMoney( UTIL_PRound(rawprice,2) )
	local tw, th = surface.GetTextSize( price )
	shadowedtext( "Giving away:", wallet_x+8, wallet_y+46, col, 255 )
	shadowedtext( price, w-tw-10, wallet_y+46, col, 255 )
	
	local balance = UTIL_FormatMoney( UTIL_PRound(initial - rawprice,2) )
	local tw, th = surface.GetTextSize( balance )
	shadowedtext( "Final Balance:", wallet_x+8, wallet_y+76, col, 255 )
	shadowedtext( balance, w-tw-10, wallet_y+76, col, 255 )
end

function PANEL:PerformLayout( w, h )
	self.MemberList:SetSize( w-305, h )
	self.MemberList:SetPos( 0, 0 )
	
	self.Amount:SetSize( 100, 22 )
	self.Amount:SetPos( w-110, 128 )
	
	self.GiveAway:SetSize( h-170, 22 )
	self.GiveAway:SetPos( w-h+160, 160 )
end

vgui.Register( "sh_finance", PANEL, "Panel" )