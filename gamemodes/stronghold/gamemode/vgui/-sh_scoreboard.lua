--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	File: sh_scoreboard.lua
	For: FTS: Stronghold
	By: Ultra

	Fuck you table.sort, fuck you.
]]--

surface.CreateFont( "sh_ScoreboardDefault", {
	font		= "Helvetica",
	size		= 16,
	weight		= 550
})

local TEX_GRADIENT_BOTTOM	= surface.GetTextureID( "vgui/gradient-d" )
local TEX_GRADIENT_LEFT		= surface.GetTextureID( "vgui/gradient-l" )
local TEX_LEADER_ICON		= surface.GetTextureID( "gui/silkicons/leader" )

--[[ Initalize ]] --
if GAMEMODE and ValidPanel( GAMEMODE.m_pScorePanel ) then GAMEMODE.m_pScorePanel:Remove() end
GM.m_pScorePanel = nil

--[[ Show/Hide ]]--
function GM:ScoreboardShow()
	if not ValidPanel( self.m_pScorePanel ) then
		self.m_pScorePanel = vgui.Create( "sh_score_main" )
	end

	self.m_pScorePanel:Toggle( true )
end

function GM:ScoreboardHide()
	if not ValidPanel( self.m_pScorePanel ) then return end
	self.m_pScorePanel:Toggle()
	CloseDermaMenus()
end

-- ----------------------------------------------------------------------------------------------------
--[[ Main Panel ]]--

local MAIN = {}

function MAIN:Init()
	self:SetSize( 800, math.max(ScrH() *0.9, 480) )
	
	self.m_pHeader = vgui.Create( "DImage", self )
	self.m_pGroupList = vgui.Create( "DPanelList", self )

	self.m_pHeader:SetMaterial( "vgui/stronghold/scoreboard_header" )
	self.m_pGroupList:EnableVerticalScrollbar( true )
	self.m_pGroupList:SetSpacing( 5 )
	self.m_pGroupList.Paint = function() end

	self.m_tGroupPanels 	= {}
	self.m_iHeaderOffset 	= 125
	self.m_iKillTotal		= 0
	self.m_bInvalidRefresh	= false
	self.m_bVerbose			= false

	self.m_fLastRefresh		= CurTime()
	
	self:Refresh()
end

function MAIN:Think()
	if CurTime() - self.m_fLastRefresh >= 2 then
		self.m_fLastRefresh = CurTime()
		self:Refresh()
	end
end

function MAIN:FindGroupPanel( index )
	for i, panel in ipairs(self.m_tGroupPanels) do
		if panel:GetGroupIndex() == index then
			return i, panel
		end
	end
	return nil, nil
end

function MAIN:Refresh()
	-- Create missing groups
	for index, tbl in pairs(GAMEMODE.Teams) do
		local _, panel = self:FindGroupPanel( index )
		if panel then
			-- Refresh
			panel:Refresh()
		else
			-- Create
			local panel = vgui.Create( "sh_score_group", self.m_pGroupList )
			panel:SetGroup( index, tbl )
			panel:Refresh()
			
			table.insert( self.m_tGroupPanels, panel )
		end
	end
	
	-- Destroy empty teams
	for i, panel in pairs(self.m_tGroupPanels) do
		if team.NumPlayers( panel:GetGroupIndex() ) == 0 then
			table.remove( self.m_tGroupPanels, i )
			panel:Remove()
		end
	end

	--Sort/order/add
	self.m_pGroupList:Clear()
	table.sort( self.m_tGroupPanels, function( a, b )
		return (ValidPanel(a) and a.m_iGroupKills or 0) > (ValidPanel(b) and b.m_iGroupKills or 0)
	end )

	--No Team (50) is last
	for k, pnlGroup in ipairs( self.m_tGroupPanels ) do
		if pnlGroup:GetGroupIndex() == 50 then
			table.remove( self.m_tGroupPanels, k )
			table.insert( self.m_tGroupPanels, pnlGroup )
			break
		end
	end

	for k, pnlGroup in ipairs( self.m_tGroupPanels ) do
		if table.Count( pnlGroup.m_tPlayers ) > 0 then
			self.m_pGroupList:AddItem( pnlGroup )
		end
	end

	self:InvalidateLayout()
end

function MAIN:Paint( intW, intH )
end

function MAIN:PerformLayout()
	self:Center()

	self.m_pHeader:SetPos( 0, 0 )
	self.m_pHeader:SetSize( 512, 512 )
	self.m_pHeader:CenterHorizontal()

	self.m_pGroupList:SetPos( 0, 0 +self.m_iHeaderOffset )
	self.m_pGroupList:SetSize( self:GetWide(), self:GetTall() -self.m_iHeaderOffset )
end

function MAIN:Toggle( bShowHide )
	if bShowHide then
		self:SetVisible( true )
		self:MakePopup()
		self:SetKeyboardInputEnabled( false )
	else
		self:SetVisible( false )
	end
	self:Refresh()
end

vgui.Register( "sh_score_main", MAIN, "EditablePanel"  )

-- ----------------------------------------------------------------------------------------------------
--[[ Group Container ]]--

local GROUP = {}

function GROUP:Init()
	self.m_pPlayerList = vgui.Create( "DPanelList", self )

	self.m_pPlayerList:EnableHorizontal( false )
	self.m_pPlayerList:EnableVerticalScrollbar( true )
	self.m_pPlayerList:SetPadding( 2 )
	self.m_pPlayerList:SetSpacing( 2 )
	self.m_pPlayerList.Paint = function() end

	self.m_iLastK			= 0
	self.m_iGroupKills		= 0
	self.m_iGroupDeaths		= 0
	self.m_iGroupIndex		= 50
	self.m_bInvalid 		= false
	self.m_bVerbose			= true
	self.m_tGroup 			= {}
	self.m_tPlayers 		= {}
	self.m_tPlayerPanels 	= {}

	self.m_cColWhite		= Color( 255, 255, 255, 255 )
	self.m_cColBlack		= Color( 0, 0, 0, 255 )
	self.m_cColBlackT		= Color( 0, 0, 0, 100 )
end

function GROUP:CalcKD()
	self.m_iLastK = self.m_iGroupKills
	self.m_iGroupKills = 0
	self.m_iGroupDeaths = 0

	for k, pl in pairs( self.m_tPlayers ) do
		if IsValid( pl ) then
			self.m_iGroupKills = self.m_iGroupKills +pl:Frags()
			self.m_iGroupDeaths = self.m_iGroupDeaths +pl:Deaths()
		end
	end
end

function GROUP:GetGroupIndex()
	return self.m_iGroupIndex
end

function GROUP:SetGroup( intIndex, tblGroup )
	self.m_iGroupIndex = intIndex
	self.m_tGroup = tblGroup
end

function GROUP:Refresh()
	--Check for dead players
	for k, pnlPlayer in pairs( self.m_tPlayerPanels ) do
		self.m_bInvalid = true

		for k2, pPlayer in pairs( team.GetPlayers(self.m_iGroupIndex) ) do
			if pPlayer == pnlPlayer:GetPlayer() then
				self.m_bInvalid = false

				break
			end
		end

		if self.m_bInvalid then
			self.m_tPlayers[pnlPlayer:GetPlayer()] = nil

			if ValidPanel( pnlPlayer ) then
				pnlPlayer:Remove()
			end

			self.m_tPlayerPanels[k] = nil
		end
	end

	--Update&create
	for k, pPlayer in pairs( team.GetPlayers(self.m_iGroupIndex) ) do
		self.m_bInvalid = true

		for k2, pnlPlayer in pairs( self.m_tPlayerPanels ) do
			if pPlayer == pnlPlayer:GetPlayer() then
				pnlPlayer:Refresh()
				self.m_bInvalid = false
				break
			end
		end

		if self.m_bInvalid then
			local pnlPlayer = vgui.Create( "sh_score_player", self.m_pPlayerList )
			pnlPlayer:SetPlayer( pPlayer )
			pnlPlayer:Refresh()

			table.insert( self.m_tPlayerPanels, pnlPlayer )
			self.m_tPlayers[pPlayer] = pPlayer
		end
	end

	--Calc K/D
	self.m_iLastK = self.m_iGroupKills
	self.m_iGroupKills = 0
	self.m_iGroupDeaths = 0

	for k, pl in pairs( self.m_tPlayers ) do
		self.m_iGroupKills = self.m_iGroupKills +pl:Frags()
		self.m_iGroupDeaths = self.m_iGroupDeaths +pl:Deaths()
	end

	--Sort
	if self.m_iLastK ~= self.m_iGroupKills then
		table.sort( self.m_tPlayerPanels, function( a, b )
			return (ValidPanel(a) and a.m_iKills or 0) > (ValidPanel(b) and b.m_iKills or 0)
		end )
	
		--Leader on top
		for k, pnlPlayer in ipairs( self.m_tPlayerPanels ) do
			if pnlPlayer:GetPlayer() == self.m_tGroup.Leader then
				table.remove( self.m_tPlayerPanels, k )
				table.insert( self.m_tPlayerPanels, 1, pnlPlayer )
			end
		end
	end

	--Build list
	self.m_pPlayerList:Clear()
	for i = 1, #self.m_tPlayerPanels do
		self.m_pPlayerList:AddItem( self.m_tPlayerPanels[i] )
	end
	
	self.m_pPlayerList:InvalidateLayout( true ) -- Invalidate to update sizes - true to force it NOW
	self:SetTall( self.m_pPlayerList.pnlCanvas:GetTall()+25 )
end

function GROUP:Paint( intW, intH )
	local tc = team.GetColor(self.m_iGroupIndex)
	local y = 20
	
	-- Stronghold skin background
	local skin = derma.GetNamedSkin( "stronghold" )
	skin:DrawGenericBackground( 0, 0, intW, intH, Color(tc.r,tc.g,tc.b,100), false, true, self )
	
	draw.SimpleTextOutlined(
		self.m_tGroup.Name,
		"sh_ScoreboardDefault",
		8,
		4,
		self.m_cColWhite,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_LEFT,
		1,
		self.m_cColBlack
	)
	draw.SimpleTextOutlined(
		"Kills        Deaths",
		"sh_ScoreboardDefault",
		self:GetWide() -10,
		4,
		self.m_cColWhite,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_RIGHT,
		1,
		self.m_cColBlack
	)
end

function GROUP:PerformLayout()
	self.m_pPlayerList:SetPos( 2, 23 )
	self.m_pPlayerList:SetSize( self:GetWide() -4, self:GetTall() -25 )
end

vgui.Register( "sh_score_group", GROUP, "EditablePanel"  )

-- ----------------------------------------------------------------------------------------------------
--[[ Player Line ]]--

local PLAYER = {}

function PLAYER:Init()
	self:SetTall( 34 )

	self:SetText( " " )
	self.Avatar	= vgui.Create( "AvatarImage", self )
	self.Avatar:SetMouseInputEnabled( false )
	
	self.Mute = self:Add( "DImageButton" )
	self.Mute:SetSize( 16, 16 )
	self.Mute:SetImage( "icon32/unmuted.png" )
	self.Mute.DoClick = function()
		if IsValid( self.m_pPlayer ) then
			self.m_bMuted = not self.m_bMuted
			self.m_pPlayer:SetMuted( self.m_bMuted )
			self.Mute:SetImage( self.m_bMuted and "icon32/muted.png" or "icon32/unmuted.png" )
		end
	end

	self.m_pPlayer 		= nil
	self.m_bTeamLeader 	= false
	self.m_iKills 		= 0
	self.m_iDeaths 		= 0
	self.m_cColWhite	= Color( 255, 255, 255, 255 )
	self.m_cColBlack	= Color( 0, 0, 0, 200 )
	self.m_cColHover	= Color( 255, 255, 255, 30 )
	self.m_tMoneyPreset = { 100, 200, 500, 1000 }
	self.m_tAdminPreset = {
		"Cheating",
		"Minge",
		"Spam",
		"No Reason",
	}
	self.m_tBanTimes 	= {
		{ 1, 			"1 minute" },
		{ 5, 			"5 minutes" },
		{ 15, 			"15 minutes" },
		{ 60, 			"1 hour" },
		{ 60 *24, 		"24 hours" },
		{ 60 *24 *7, 	"1 week" },
		{ 0, 			"Forever" },
	}
end

function PLAYER:Think()
end

function PLAYER:DoClick()
end

function PLAYER:DoRightClick() --holy fukccccc
	if self.m_pPlayer == LocalPlayer() then return end
	local pnlMenu = DermaMenu()

	--Player options
	local pnlSendMT = pnlMenu:AddSubMenu( "Send Money" )
		for k, v in pairs( self.m_tMoneyPreset ) do
			pnlSendMT:AddOption( v, function() RunConsoleCommand( "sh_giveawaymoney", self.m_pPlayer:EntIndex(), v ) end )
		end

		pnlSendMT:AddOption( "Open Finance Menu", function()
			--Show menu
			GAMEMODE.LoadoutFrame:SetVisible( true )
			GAMEMODE.LoadoutFrame:MakePopup()

			--Set tab
			for k, Sheet in pairs( GAMEMODE.LoadoutFrame.Sections.Items ) do
				if Sheet.Panel == GAMEMODE.LoadoutFrame.FinanceMenu then
					GAMEMODE.LoadoutFrame.Sections:SetActiveTab( Sheet.Tab )
					break
				end
			end

			--Select player
			local pnl = GAMEMODE.LoadoutFrame.FinanceMenu
			
			for k, line in pairs( pnl.MemberList.Sorted ) do
				if line and IsValid( line.player ) then
					if line.player == self.m_pPlayer then
						pnl.MemberList:SelectItem( line )
						break
					end
				end
			end

			--Select text box
			pnl:KillFocus()
			timer.Simple( 0.1, function()
				pnl.Amount:RequestFocus()
			end )
		end )

	if self.m_pPlayer:Team() ~= 50 then
		pnlMenu:AddOption( "Join Team", function()
			local gtbl = GAMEMODE.Teams[self.m_pPlayer:Team()]
			Derma_StringRequest( "Join Team",
				"Please enter the team password, if any.", 
				"", 
				function( strTextOut ) RunConsoleCommand("sh_jointeam", (gtbl and gtbl.Name or ""), strTextOut ) end,
				function( strTextOut ) end,
				"Join", 
				"Cancel"
			)
		end )
	end

	if LocalPlayer():Team() ~= 50 then
		pnlMenu:AddOption( "Send Team Password", function()
			Derma_Query( "Are you sure you want to send ".. self.m_pPlayer:Name().. " your team password?", "Are you sure?",
				"Yes", 	function() RunConsoleCommand( "sh_sendteampassword", self.m_pPlayer:EntIndex() ) end, 
				"No", 	function()end
			)
		end )
	end

	--Team leader options
	if GAMEMODE.Teams[LocalPlayer():Team()].Leader == LocalPlayer() and self.m_pPlayer:Team() == LocalPlayer():Team() then
		pnlMenu:AddSpacer()
		pnlMenu:AddOption( "Kick From Team", function()
			Derma_Query( "Are you sure you want to kick ".. self.m_pPlayer:Name().. " from the team?", "Are you sure?",
				"Yes", 	function() RunConsoleCommand( "sh_kickteammember", self.m_pPlayer:EntIndex() ) end, 
				"No", 	function()end
			)
		end )
	end

	--Admin options
	if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
		pnlMenu:AddSpacer()

		local pnlAdminK = pnlMenu:AddSubMenu( "Kick From Game" )
			for k, v in pairs( self.m_tAdminPreset ) do
				pnlAdminK:AddOption( v, function()
					Derma_Query( "Are you sure you want to kick ".. self.m_pPlayer:Name().. " from the game?", "Are you sure?",
						"Yes", 	function() GAMEMODE.Net:RequestKickUser( self.m_pPlayer, v ) end, 
						"No", 	function()end
					)
				end )
			end

			pnlAdminK:AddOption( "Enter Reason...", function() 
				Derma_StringRequest( "Kick ".. self.m_pPlayer:Name(), 
					"Enter a reason to kick the user with.", 
					"", 
					function( strTextOut ) GAMEMODE.Net:RequestKickUser( self.m_pPlayer, strTextOut ) end,
					function( strTextOut ) end,
					"Kick", 
					"Cancel"
				)
			end )
		local pnlAdminB = pnlMenu:AddSubMenu( "Ban From Game" )
			for k, v in pairs( self.m_tAdminPreset ) do
				local sub = pnlAdminB:AddSubMenu( v )

				for k2, v2 in pairs( self.m_tBanTimes ) do
					sub:AddOption( v2[2], function()
						Derma_Query( "Are you sure you want to ban ".. self.m_pPlayer:Name().. " from the game?", "Are you sure?",
							"Yes", 	function() GAMEMODE.Net:RequestBanUser( self.m_pPlayer, v, v2[1] ) end, 
							"No", 	function()end
						)
					end )
				end
			end

			pnlAdminB:AddOption( "Enter Reason...", function() 
				Derma_StringRequest( "Ban ".. self.m_pPlayer:Name(), 
					"Enter a reason to ban the user with.", 
					"No Reason", 
					function( strTextOut )
						Derma_StringRequest( "Ban ".. self.m_pPlayer:Name(), 
							"Enter a time in minutes to ban the user for (Leave 0 for perma).", 
							"0", 
							function( strTime ) GAMEMODE.Net:RequestBanUser( self.m_pPlayer, strTextOut, tonumber(strTime) ) end,
							function() end,
							"Ban", 
							"Cancel"
						)
					end,
					function() end,
					"Enter Time", 
					"Cancel"
				)
			end )

		local pnlAdminS = pnlMenu:AddOption( "Spectate", function() 
			GAMEMODE.Net:RequestSpectateUser( self.m_pPlayer )
		end )
	end

	pnlMenu:Open()
end

function PLAYER:GetPlayer()
	return self.m_pPlayer
end

function PLAYER:SetPlayer( pPlayer )
	self.m_pPlayer = pPlayer
	self.Avatar:SetPlayer( pPlayer )
end

function PLAYER:Refresh()
	if not IsValid( self.m_pPlayer ) then return end

	--Calc K/D
	self.m_iKills = self.m_pPlayer:Frags()
	self.m_iDeaths = self.m_pPlayer:Deaths()

	self.m_bTeamLeader = GAMEMODE.Teams[self.m_pPlayer:Team()].Leader == self.m_pPlayer
end

function PLAYER:Paint( intW, intH )
	if not IsValid( self.m_pPlayer ) then return end
	
	local tc = team.GetColor( self.m_pPlayer:Team() )
	local yp = (self:GetTall() /2) -(self.Avatar:GetTall() /2) +8

	--Info bar
	surface.SetTexture( TEX_GRADIENT_LEFT )
	surface.SetDrawColor( tc.r, tc.g, tc.b, 100 )
	surface.DrawTexturedRect( 34, yp, intW -40, 20 )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawTexturedRect( 34, yp, intW -40, 1 )
	surface.DrawTexturedRect( 34, yp+19, intW -40, 1 )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawTexturedRect( 34, yp, 40, 1 )
	surface.DrawTexturedRect( 34, yp+19, 40, 1 )

	--Avatar border
	local x, y = self.Avatar:GetPos()
	surface.SetDrawColor( self.m_bTeamLeader and tc or self.m_cColBlack )
	surface.DrawRect( x -1, y -1, 34, 34 )

	--Leader icon
	if self.m_bTeamLeader then
		surface.SetFont( "sh_ScoreboardDefault" )
		local tx, ty = surface.GetTextSize( self.m_pPlayer:Name() )

		surface.SetDrawColor( self.m_cColWhite )
		surface.SetTexture( TEX_LEADER_ICON )
		surface.DrawTexturedRect( 42 +tx +18, yp +2, 16, 16 )
	end
	
	--Name, Kills, Deaths
	draw.SimpleTextOutlined(
		self.m_pPlayer:Name(),
		"sh_ScoreboardDefault",
		40,
		yp +2,
		self.m_cColWhite,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_LEFT,
		1,
		self.m_cColBlack
	)
	draw.SimpleTextOutlined(
		self.m_pPlayer:Frags(),
		"sh_ScoreboardDefault",
		intW -103,
		yp +2,
		self.m_cColWhite,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_LEFT,
		1,
		self.m_cColBlack
	)
	draw.SimpleTextOutlined(
		self.m_pPlayer:Deaths(),
		"sh_ScoreboardDefault",
		intW -45,
		yp +2,
		self.m_cColWhite,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_LEFT,
		1,
		self.m_cColBlack
	)
	
	-- Highlight moved to PaintOver
end

function PLAYER:PaintOver( w, h )
	if (self.Hovered or self.Avatar.Hovered) and LocalPlayer() ~= self.m_pPlayer then
		surface.SetDrawColor( self.m_cColHover )
		surface.DrawRect( 0, 0, w, h )		
	end
end

function PLAYER:PerformLayout()
	if not IsValid( self.m_pPlayer ) then return end
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetPos( 1, 1 )
	
	surface.SetFont( "sh_ScoreboardDefault" )
		local tx, ty = surface.GetTextSize( self.m_pPlayer:Name() )
		self.Mute:SetPos( 42 +tx, (self:GetTall() /2) -(self.Avatar:GetTall() /2) +10 )
end

vgui.Register( "sh_score_player", PLAYER, "DButton"  )