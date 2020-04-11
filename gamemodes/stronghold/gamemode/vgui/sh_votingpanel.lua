--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local SND_CONFIRM = Sound( "buttons/button9.wav" )

local function shadowedtext( str, x, y, color, salpha )
	surface.SetTextColor( 0, 0, 0, salpha )
	surface.SetTextPos( x+1, y+1 )
	surface.DrawText( str )
	surface.SetTextColor( color.r, color.g, color.b, color.a )
	surface.SetTextPos( x, y )
	surface.DrawText( str )
end

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	g_MapVotingPanel = self

	self.MapList = vgui.Create( "DListView", self )
	self.MapList:SetDataHeight( 24 )
	self.MapList:AddColumn( "Map Name" )
	local column = self.MapList:AddColumn( "Raw Name" )
	column:SetFixedWidth( 150 )
	local column = self.MapList:AddColumn( "Votes" )
	column:SetFixedWidth( 50 )
	
	function self.MapList:OnRowSelected( lineid, line )
		RunConsoleCommand( "sh_votemap", line:GetColumnText(2) )
		surface.PlaySound( SND_CONFIRM )
	end
	
	self.Overlay = vgui.Create( "DPanel", self )
	self.Overlay:SetBackgroundColor( Color(0,0,0,200) )
	function self.Overlay:PaintOver()
		local w, h = self:GetWide(), self:GetTall()
		
		surface.SetFont( "Trebuchet19" )
		local tw, th = surface.GetTextSize( "Disabled until end of game!" )
		surface.SetTextColor( 255, 0, 0, 220 )
		surface.SetTextPos( w*0.50-tw*0.50, h*0.50-th*0.50 )
		surface.DrawText( "Disabled until end of game!" )
	end
	
	self.m_WinningMap = nil
	self.m_LastUpdate = 0
end

function PANEL:SetEnabled( b )
	self.MapList:Clear()
	for _, v in pairs(GAMEMODE.MapList) do
		self.MapList:AddLine( v.name, v.map, 0 )
	end
	self.Overlay:SetVisible( !b )
end

function PANEL:GetVotes()
	local votes = {}
	for _, v in ipairs(player.GetAll()) do
		local vote = v:GetMapVote()
		if vote != "" and GAMEMODE.MapList[vote] then
			if !votes[vote] then votes[vote] = 0 end
			votes[vote] = votes[vote] + 1
		end
	end
	return votes
end

function PANEL:GetWinningMap( votes )
	local highest = nil
	for k, v in pairs(votes) do
		if highest == nil or v > votes[highest] then
			highest = k
		end
	end
	return highest
end

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 1 then return end
	
	local votes = self:GetVotes()
	for _, v in ipairs(self.MapList.Lines) do
		local map = v:GetColumnText( 2 )
		v:SetColumnText( 3, votes[map] or 0 )
	end
	
	self.m_WinningMap = self:GetWinningMap( votes )
	
	self.m_LastUpdate = CurTime()
end

local TEX_NOICON = surface.GetTextureID( "maps/noicon" )
function PANEL:Paint( w, h )
	local ph = math.floor( h*0.40 )
	local pw = math.floor( w*0.50 )
	local skin = self:GetSkin()
	
	skin:DrawGenericBackground( 0, 0, pw, ph, skin.panel_transback )
	skin:DrawGenericBackground( pw, 0, pw, ph, skin.panel_transback )
	--skin:DrawGenericBackground( (pw*2)+20, 0, w-(pw*2)-20, ph, skin.bg_color )
	
	local winning, vote = self.m_WinningMap, LocalPlayer():GetMapVote()
	local texWinning, texVote = TEX_NOICON, TEX_NOICON
	
	if winning and GAMEMODE.MapList[winning] then
		texWinning = GAMEMODE.MapList[winning].texture or TEX_NOICON
	end
	
	if vote and GAMEMODE.MapList[vote] then
		texVote = GAMEMODE.MapList[vote].texture or TEX_NOICON
	end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( texWinning )
	surface.DrawTexturedRect( 2, 2, pw-4, ph-4 )
	surface.SetTexture( texVote )
	surface.DrawTexturedRect( 2+pw, 2, pw-4, ph-4 )
	
	surface.SetFont( "Trebuchet19" )
	local tw, _ = surface.GetTextSize( "Winning Map" )
	shadowedtext( "Winning Map", pw*0.50-tw*0.50, 8, Color(255,255,255,255), 255 )
	local tw, _ = surface.GetTextSize( "Your Selection" )
	shadowedtext( "Your Selection", pw+pw*0.50-tw*0.50+10, 8, Color(255,255,255,255), 255 )
end

function PANEL:PerformLayout( w, h )
	local ph = math.floor( h*0.40 )
	
	self.MapList:SetSize( w, h-ph-10 )
	self.MapList:SetPos( 0, ph+10 )
	
	self.Overlay:SetSize( w, h )
	self.Overlay:SetPos( 0, 0 )
end

vgui.Register( "sh_votingpanel", PANEL, "Panel" )