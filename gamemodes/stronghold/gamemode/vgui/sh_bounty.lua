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
	local column = self.MemberList:AddColumn( "Player" )
	column:SetFixedWidth( 100 )
	local column = self.MemberList:AddColumn( "Kills" )
	column:SetFixedWidth( 50 )
	local column = self.MemberList:AddColumn( "Current Bounty" )
	column:SetFixedWidth( 100 )
	local column =self.MemberList:AddColumn( "Team" )
	function self.MemberList.OnRowSelected( _, lineid, line )
		self:SetPlayer( line.player )
	end
	
	self.Amount = vgui.Create( "DNumberWang", self )
	self.Amount:SetDecimals( 2 )
	self.Amount:SetMinMax( 0, 1000000000 )
	
	self.GiveAway = vgui.Create( "DButton", self )
	self.GiveAway:SetText( "Add Bounty to selected player" )
	function self.GiveAway.DoClick()
		if self.Amount:GetValue() == 0 then return end
	
		local line = self.MemberList:GetLine( self.MemberList:GetSelectedLine() )
		if line and IsValid( line.player ) then
			RunConsoleCommand( "sh_addbounty", line.player:EntIndex(), self.Amount:GetValue() )
		end
	end
	
	self.m_LastUpdate = 0
end

net.Receive( "PlayerBounty", function()
	local BPlayer = net.ReadEntity()
	local PLBounty= net.ReadFloat()
	local ClearBounty = net.ReadBool()
	
	for _, ply in pairs(player.GetAll()) do
		if ply == BPlayer then 
			if BPlayer.bounty then
				BPlayer.bounty = BPlayer.bounty + PLBounty
			else
				BPlayer.bounty = PLBounty
			end
			if ClearBounty then 
				BPlayer.bounty = 0 
			end
		end
	end
	if !ClearBounty and BPlayer.bounty > 0 then
		chat.AddText(Color(200,200,200,255),"Stronghold: ",Color(200,50,50,255),UTIL_FormatMoney(PLBounty).." has been placed on "..BPlayer:GetName().."! "..BPlayer:GetName().."'s bounty is now "..UTIL_FormatMoney(BPlayer.bounty))
	end
end )

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 2 then return end
	
	local lply = LocalPlayer()
	self.Amount:SetMinMax( 0, lply:GetMoney() )
	
	for _, ply in pairs(player.GetAll()) do
			local found = false
			for _, line in pairs(self.MemberList.Lines) do
				if line.player == ply then found = true end
			end
			if !found then
				local line = self.MemberList:AddLine( ply:GetName(), ply:Frags(), ply:Deaths() )
				line.player = ply
			end
		--end
	end
	for i, line in pairs(self.MemberList.Lines) do
		if !IsValid( line.player ) then
			self.MemberList:RemoveLine( i )
		else
			line:SetColumnText( 4, team.GetName( line.player:Team() ) )
			line:SetColumnText( 1, line.player:GetName() )
			if line.player == lply then
				line:SetColumnText( 1, "*"..line.player:GetName().."*" )
			end
			line:SetColumnText( 2, line.player:Frags() )
			if line.player.bounty and line.player.bounty > 0 then
			line:SetColumnText( 3, UTIL_FormatMoney( UTIL_PRound(line.player.bounty,2) ))
			else
			line:SetColumnText( 3, "No Bounty")
			end
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
	surface.DrawText( "Bounty on selected:" )
	
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
	shadowedtext( "Bounty:", wallet_x+8, wallet_y+46, col, 255 )
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

vgui.Register( "sh_bounty", PANEL, "Panel" )