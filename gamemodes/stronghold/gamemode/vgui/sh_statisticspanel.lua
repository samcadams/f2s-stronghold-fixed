--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self.PlayerListLabel = vgui.Create( "DLabel", self )
	self.PlayerListLabel:SetText( "Select Player:" )
	self.PlayerListLabel:SizeToContents()
	
	self.PlayerList = vgui.Create( "DComboBox", self )
	function self.PlayerList:UpdateColours( skin )
		if ( self:GetDisabled() )						then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
		if ( self.Depressed or self.m_bSelected )		then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
		if ( self.Hovered )								then return self:SetTextStyleColor( skin.Colours.Button.Hover ) end

		return self:SetTextStyleColor( skin.colTextEntryText )
	end
	function self.PlayerList.OnSelect( _, index, value, data )
		self:PlayerSelected( data )
	end
	
	self.GetData = vgui.Create( "DButton", self )
	self.GetData:SetText( "Request Selected (Can take a few seconds)" )
	function self.GetData.DoClick()
		if IsValid( self.m_CurrentPlayer ) then
			RunConsoleCommand( "sh_requeststats", self.m_CurrentPlayer:EntIndex() )
		end
	end
	
	self.LastUpdate = vgui.Create( "DLabel", self )
	self.LastUpdate:SetText( "Last Updated: ----------" )
	self.LastUpdate:SizeToContents()
	self.LastUpdate:SetTall( 22 )
	
	self.StatisticsList = vgui.Create( "DListView", self )
	self.StatisticsList:SetDataHeight( 26 )
	self.StatisticsList:AddColumn( "Statistic" )
	
	local column = self.StatisticsList:AddColumn( "Count" )
	column:SetFixedWidth( 100 )
	
	self.m_LastUpdate = 0
	self.m_CurrentPlayer = nil
end

function PANEL:PlayerSelected( ply )
	-- Variable
	self.m_CurrentPlayer = ply
	--ErrorNoHalt( tostring(self.m_CurrentPlayer).."\n" )
	
	-- Text
	local update = ply:GetName().." ["..(ply.StatisticsUpdated or "X:X:X XX").."]"
	self.PlayerList:SetText( update )
	self.LastUpdate:SetText( "Last Updated: "..update )
	
	-- Text Alignment
	self.LastUpdate:SizeToContents()
	self.LastUpdate:SetTall( 22 )
	local lw = self.LastUpdate:GetWide()
	self.LastUpdate:SetPos( self:GetWide()*0.50-lw*0.50, 64 )
	
	-- Load stats
	self.StatisticsList:Clear()
	for event, count in pairs(ply:GetStatistics()) do
		local statistic = GAMEMODE.StatisticsEventNames[event] or "<UNKNOWN>"
		if string.find(statistic," time ") then
			count = UTIL_FormatTime( count, true )
		end
		
		local line = self.StatisticsList:AddLine( statistic, count or 0 )
		line:SetTextInset( 10 )
	end
end

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 5 then return end
	
	local cur = self.PlayerList:GetValue()
	
	-- Update current selections
	for _, ply in pairs(player.GetAll()) do
		local found, found_index = false, -1
		for index, line in pairs(self.PlayerList.Choices) do
			if self.PlayerList.Data[index] == ply then
				found_index = index
				found = true
				break 
			end
		end
		local update = ply:GetName().." ["..(ply.StatisticsUpdated or "X:X:X XX").."]"
		if !found then
			local index = self.PlayerList:AddChoice( update )
			self.PlayerList.Data[index] = ply
		else
			self.PlayerList.Choices[found_index] = update
		end
	end
	
	-- Clear out bad selections
	for index, line in pairs(self.PlayerList.Choices) do
		if !IsValid( self.PlayerList.Data[index] ) then
			table.remove( self.PlayerList.Choices, index )
		end
	end
	
	if ValidPanel( self.PlayerList.Menu ) and self.PlayerList.Menu:IsVisible() then
		self.PlayerList:OpenMenu() -- First call kills current menu
		self.PlayerList:OpenMenu()
	end
	
	self.m_LastUpdate = CurTime()
end

function PANEL:PerformLayout( w, h )
	local lw = self.PlayerListLabel:GetWide()
	self.PlayerListLabel:SetSize( lw, 22 )
	self.PlayerListLabel:SetPos( 0, 0 )
	
	self.PlayerList:SetSize( w-lw-5, 22 )
	self.PlayerList:SetPos( lw+5, 0 )
	
	self.GetData:SetSize( w, 22 )
	self.GetData:SetPos( 0, 32 )
	
	self.LastUpdate:SizeToContents()
	self.LastUpdate:SetTall( 22 )
	local lw = self.LastUpdate:GetWide()
	self.LastUpdate:SetPos( w*0.50-lw*0.50, 64 )
	
	self.StatisticsList:SetSize( w, h-86 )
	self.StatisticsList:SetPos( 0, 86 )
end

vgui.Register( "sh_statisticspanel", PANEL, "Panel" )