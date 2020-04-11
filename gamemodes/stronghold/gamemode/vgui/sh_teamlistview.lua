--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

AccessorFunc( PANEL, "m_cColor", "TeamColor" )

function PANEL:Init()
end

function PANEL:Paint( w, h )
	derma.SkinHook( "Paint", "ListViewLabel", self, w, h )
	local color = self:GetTeamColor()
	if color then
		surface.SetDrawColor( color )
		surface.DrawRect( 0, 0, w, h )
	end
end

vgui.Register( "sh_teamlistview_linelabel", PANEL, "DListViewLabel"  )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

AccessorFunc( PANEL, "m_iTeam", "Team" )

function PANEL:Init()
end

function PANEL:SetColumnText( i, strText )
	if type(strText) == "Panel" then
		if IsValid( self.Columns[i] ) then self.Columns[i]:Remove() end
		strText:SetParent( self )
		self.Columns[i] = strText
		self.Columns[i].Value = strText
		return
	end

	if !IsValid( self.Columns[i] ) then
		self.Columns[i] = vgui.Create( "sh_teamlistview_linelabel", self )
		self.Columns[i]:SetMouseInputEnabled( false )
	end
	
	self.Columns[i]:SetText( tostring(strText) )
	self.Columns[i].Value = strText
	return self.Columns[i]
end

vgui.Register( "sh_teamlistview_line", PANEL, "DListViewLine"  )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	local column = self:AddColumn( "Color" )
	column:SetFixedWidth( 40 )
	
	self:AddColumn( "Name" )
	self:AddColumn( "Leader" )
	
	local column = self:AddColumn( "Members" )
	column:SetFixedWidth( 60 )
	
	local column = self:AddColumn( "Frags" )
	column:SetFixedWidth( 60 )
	
	local column = self:AddColumn( "Deaths" )
	column:SetFixedWidth( 60 )
	
	self.m_LastUpdate = 0
end

function PANEL:AddLine( ... )
	self:SetDirty( true )
	self:InvalidateLayout()

	local Line = vgui.Create( "sh_teamlistview_line", self.pnlCanvas )
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

function PANEL:AddTeam( index )
	local tbl = GAMEMODE.Teams[index]
	if !tbl then return end
	local line = self:AddLine( "", tbl.Name, (IsValid(tbl.Leader) and tbl.Leader:GetName() or "<No Leader>"), #team.GetPlayers(index), team.TotalFrags(index), team.TotalDeaths(index) )
	line.Columns[1]:SetTeamColor( tbl.Color )
	line:SetTeam( index )
end

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 0.50 then return end
	for _, line in ipairs(self.Lines) do
		local index = line:GetTeam()
		local tbl = GAMEMODE.Teams[index]
		if tbl then
			line:SetColumnText( 3, (IsValid(tbl.Leader) and tbl.Leader:GetName() or "<No Leader>") )
			line:SetColumnText( 4, #team.GetPlayers(index) )
			line:SetColumnText( 5, team.TotalFrags(index) )
			line:SetColumnText( 6, team.TotalDeaths(index) )
		elseif index != -1 then
			line.Columns[1]:SetTeamColor( nil )
			line:SetColumnText( 1, "x" )
			line:SetColumnText( 2, "<Disbanded>" )
			line:SetColumnText( 3, "<Disbanded>" )
			line:SetColumnText( 4, "x" )
			line:SetColumnText( 5, "x" )
			line:SetColumnText( 6, "x" )
			line:SetTeam( -1 )
		end
	end
	self.m_LastUpdate = CurTime()
end

vgui.Register( "sh_teamlistview", PANEL, "DListView" )