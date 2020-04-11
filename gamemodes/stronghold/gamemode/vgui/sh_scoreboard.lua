
surface.CreateFont( "ScoreboardDefault", {
	font	= "calibri",
	size	= 22,
	weight	= 100
} )

surface.CreateFont( "ScoreboardDefaultTitle", {
	font	= "calibri",
	size	= 32,
	weight	= 100
} )

--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {
	Init = function( self )
	


	
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

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
		self.AvatarButton.DoRightClick = function() self:AMenu() end

		self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )
		
		self.NameS = self:Add( "DLabel" )
		self.NameS:Dock( FILL )
		self.NameS:SetFont( "ScoreboardDefault" )
		self.NameS:SetTextColor( Color( 0, 0, 0 ) )
		self.NameS:DockMargin( 9, 2, 0, 0 )
		
		self.Name = self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:SetTextColor( Color( 255, 255, 255 ) )
		self.Name:DockMargin( 8, 0, 0, 0 )
		self.Name.DoRightClick = function() self:AMenu() end
		
		self.Mute = self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )

		self.PingS = self:Add( "DLabel" )
		self.PingS:Dock( FILL )
		self.PingS:SetWidth( 50 )
		self.PingS:SetFont( "ScoreboardDefault" )
		self.PingS:SetTextColor( Color( 0, 0, 0 ) )
		self.PingS:DockMargin( 601, 2, 0, 0 )

		self.Ping = self:Add( "DLabel" )
		self.Ping:Dock( FILL )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetTextColor( Color( 255, 255, 255 ) )
		self.Ping:DockMargin( 600, 0, 0, 0 )

		self.DeathsS = self:Add( "DLabel" )
		self.DeathsS:Dock( FILL )
		self.DeathsS:SetWidth( 50 )
		self.DeathsS:SetFont( "ScoreboardDefault" )
		self.DeathsS:SetTextColor( Color( 0, 0, 0 ) )
		self.DeathsS:DockMargin( 551, 2, 0, 0 )
		
		self.Deaths = self:Add( "DLabel" )
		self.Deaths:Dock(FILL )
		self.Deaths:SetWidth( 50 )
		self.Deaths:SetFont( "ScoreboardDefault" )
		self.Deaths:SetTextColor( Color( 255, 255, 255 ) )
		self.Deaths:DockMargin( 550, 0, 0, 0 )

		self.KillsS = self:Add( "DLabel" )
		self.KillsS:Dock( FILL )
		self.KillsS:SetWidth( 50 )
		self.KillsS:SetFont( "ScoreboardDefault" )
		self.KillsS:SetTextColor( Color( 0, 0, 0 ) )
		self.KillsS:DockMargin( 501, 2, 0, 0 )
		
		self.Kills = self:Add( "DLabel" )
		self.Kills:Dock( FILL )
		self.Kills:SetWidth( 50 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetTextColor( Color( 255, 255, 255 ) )
		self.Kills:DockMargin( 500, 0, 0, 0 )
		
		self.TeamNameS = self:Add( "DLabel" )
		self.TeamNameS:Dock( FILL )
		self.TeamNameS:SetWidth( 200 )
		self.TeamNameS:SetFont( "ScoreboardDefault" )
		self.TeamNameS:SetTextColor( Color( 0, 0, 0 ) )
		self.TeamNameS:DockMargin( 301, 2, 0, 0 )
		
		self.TeamName = self:Add( "DLabel" )
		self.TeamName:Dock( FILL )
		self.TeamName:SetWidth( 200 )
		self.TeamName:SetFont( "ScoreboardDefault" )
		self.TeamName:SetTextColor( Color( 255, 255, 255 ) )
		self.TeamName:DockMargin( 300, 0, 0, 0 )

		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3 * 2 )
		self:DockMargin( 2, 0, 2, 2 )

	end,

	Setup = function( self, pl )

		self.Player = pl
		self.m_pPlayer 	= pl

		self.Avatar:SetPlayer( pl )

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:SetZPos( 9999 ) -- Causes a rebuild
			self:Remove()
			return
		end

		if ( self.PName == nil || self.PName != self.Player:Nick() ) then
			self.PName = self.Player:Nick()
			self.Name:SetText( self.PName )
			self.NameS:SetText( self.PName )
		end
		
		if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
			self.NumKills = self.Player:Frags()
			self.Kills:SetText( self.NumKills )
			self.KillsS:SetText( self.NumKills )
		end

		if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
			self.NumDeaths = self.Player:Deaths()
			self.Deaths:SetText( self.NumDeaths )
			self.DeathsS:SetText( self.NumDeaths )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing = self.Player:Ping()
			self.Ping:SetText( self.NumPing )
			self.PingS:SetText( self.NumPing )
		end
		
		if ( self.TName == nil || self.TName != team.GetName(self.Player:Team()) ) then
			self.TName = team.GetName(self.Player:Team())
			self.TeamName:SetText( self.TName )
			self.TeamNameS:SetText( self.TName )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 + self.Player:EntIndex() )
			return
		end

		--
		-- This is what sorts the list. The panels are docked in the z order,
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos( ( (self.NumKills)+(self.Player:Team() * -50) ) + self.Player:EntIndex() )
	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end
		local color = team.GetColor(self.Player:Team())
		--
		-- We draw our background a different colour based on the status of the player
		--

		if ( self.Player:Team() == TEAM_CONNECTING ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 200 ) )
			return
		end



		--[[if ( self.Player:IsAdmin() ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 255, 230, 255 ) )
			return
		end]]
		draw.RoundedBox(  0, 0, 10, w, h/2, Color(color.r,color.g,color.b,color.a*0.5) )
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawOutlinedRect( 0, 10, w, h/2 )
		if ( !self.Player:Alive() ) then
			surface.SetDrawColor( Color( 255, 100, 100, 255 ) )
			surface.DrawOutlinedRect( 0, 10, w, h/2 )
			return
		end
	end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )

function PLAYER_LINE:AMenu() --holy fukccccc
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

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = {
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "ScoreboardDefaultTitle" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( TOP )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )

		self.Scores = self:Add( "DScrollPanel" )
		self.Scores:Dock( FILL )

	end,

	PerformLayout = function( self )

		self:SetSize( 700, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 350, 100 )

	end,

	Paint = function( self, w, h )

		--draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

	end,

	Think = function( self, w, h )

		self.Name:SetText( GetHostName() )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )

			self.Scores:AddItem( pl.ScoreEntry )

		end

	end
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardShow( )
	Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end

end

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardHide( )
	Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end

end

--[[---------------------------------------------------------
	Name: gamemode:HUDDrawScoreBoard( )
	Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()
end
