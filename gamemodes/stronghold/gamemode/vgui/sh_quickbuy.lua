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

function PANEL:Init()
	self.Label = vgui.Create( "DLabel", self )
	self.Current = vgui.Create( "DLabel", self )
	
	self.Value = vgui.Create( "DNumberWang", self )
	self.Value:SetDecimals( 0 )
	self.Value:SetMinMax( 0, 1000 )
	self.Value:HideWang()

	
	self.Buy = vgui.Create( "DButton", self )
	self.Buy:SetText( "BUY" )
	function self.Buy.DoClick() self:DoBuy() end
	
	self.m_strBuyClass = ""
	self.m_iBuyType = 0
	self.m_BuyTbl = nil
	self.m_fLastLayout = 0
end

function PANEL:Setup( title, class, type )
	self.Label:SetText( title )
	self.m_strBuyClass = class
	self.m_iBuyType = type
	self.m_BuyTbl = GAMEMODE.Explosives[class] or GAMEMODE.Ammo[class] or nil
	
	local ply = LocalPlayer()
	local money = (ply and ply.GetMoney) and ply:GetMoney() or 0
	if self.m_BuyTbl then
		local max = money / self.m_BuyTbl.price
		self.Value:SetMinMax( 0, max )
		self.Value:SetValue( math.min(100,math.floor(max*0.50)) )
		if self.m_BuyTbl == GAMEMODE.Explosives[class] then
			self.Value:SetValue( 1 )
		end
	else
		self.Value:SetMinMax( 0, 1000 )
		self.Value:SetValue( 50 )
	end
end

function PANEL:Update()
	local ply = LocalPlayer()
	local money = (ply and ply.GetMoney) and ply:GetMoney() or 0
	if money > 0 and self.m_BuyTbl then
		local max = money/self.m_BuyTbl.price
		self.Value:SetMinMax( 0, max )
		
		if self.m_BuyTbl == GAMEMODE.Ammo[class] then
			self.Value:SetValue( math.min(100,math.floor(max*0.50)) )
		end
		if self.m_BuyTbl == GAMEMODE.Explosives[class] then
			self.Value:SetValue( 1 )
		end
	else
		self.Value:SetMinMax( 0, 1000 )
		self.Value:SetValue( 50 )
	end
end

function PANEL:DoBuy()
	local money = LocalPlayer():GetMoney()
	local cost = self.m_BuyTbl.price * self.Value:GetValue()

	if cost <= money then
		surface.PlaySound( SND_CONFIRM )
	else
		surface.PlaySound( SND_FAIL )
	end
	
	RunConsoleCommand( "sh_buyitem", self.m_iBuyType, self.m_strBuyClass, self.Value:GetValue() )
end

function PANEL:Think()
	local count
	if self.m_strBuyClass == "" then
		count = 0
	end
	count = LocalPlayer():GetItemCount( self.m_strBuyClass )
	self.Current:SetText( tostring(count) )
	
	if RealTime() - self.m_fLastLayout > 0.20 then
		self:InvalidateLayout( true )
	end
end

function PANEL:PerformLayout( w, h )
	local qw = w*0.25
	
	self.Label:SizeToContents()
	self.Label:SetTall( h*0.50 )
	self.Label:SetPos( qw-self.Label:GetWide()*0.50, 0 )
	
	self.Current:SizeToContents()
	self.Current:SetTall( h*0.50 )
	self.Current:SetPos( w-qw-self.Current:GetWide()*0.50, 0 )
	
	self.Value:SetSize( w-120, h*0.50 )
	self.Value:SetPos( 0, h*0.50 )
	
	self.Buy:SetSize( 40, h*0.50 )
	self.Buy:SetPos( w-40, h*0.50 )
	
	self.m_fLastLayout = RealTime()
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(0,0,0,127)
	surface.DrawRect(0, h*0.50,1000,1000)
end

vgui.Register( "sh_quickbuy", PANEL, "Panel" )