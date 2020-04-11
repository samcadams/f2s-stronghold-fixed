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
	self.MemberList:AddColumn( "Members" )
	local column = self.MemberList:AddColumn( "Kills" )
	column:SetFixedWidth( 50 )
	local column = self.MemberList:AddColumn( "Deaths" )
	column:SetFixedWidth( 50 )
	
	self.PasswordLabel = vgui.Create( "DLabel", self )
	self.PasswordLabel:SetText( "Password:" )
	self.Password = vgui.Create( "DTextEntry", self )
	
	self.ChangePassword = vgui.Create( "DButton", self )
	self.ChangePassword:SetText( "Change password" )
	function self.ChangePassword.DoClick()
		RunConsoleCommand( "sh_changeteampassword", self.Password:GetValue() )
	end
	
	self.KickSelected = vgui.Create( "DButton", self )
	self.KickSelected:SetText( "Kick selected" )
	function self.KickSelected.DoClick()
		local line = self.MemberList:GetLine( self.MemberList:GetSelectedLine() )
		if line and IsValid( line.player ) then
			RunConsoleCommand( "sh_kickteammember", line.player:EntIndex() )
		end
	end
	
	self.ChangeLeader = vgui.Create( "DButton", self )
	self.ChangeLeader:SetText( "Give selected leadership" )
	function self.ChangeLeader.DoClick()
		local line = self.MemberList:GetLine( self.MemberList:GetSelectedLine() )
		if line and IsValid( line.player ) then
			RunConsoleCommand( "sh_changeteamleader", line.player:EntIndex() )
		end
	end
	
	self.LeaderOnlyPass = vgui.Create( "DCheckBoxLabel", self )
	self.LeaderOnlyPass:SetText( "Only leader can send password" )
	function self.LeaderOnlyPass.OnChange( _, b )
		RunConsoleCommand( "sh_leaderonlypasswordsending", b and 1 or 0 )
	end
	
	self.DisbandTeam = vgui.Create( "DButton", self )
	self.DisbandTeam:SetText( "Disband team" )
	function self.DisbandTeam.DoClick()
		RunConsoleCommand( "sh_disbandteam" )
	end
	
	self.m_LastUpdate = 0
end

function PANEL:UpdatePlayerList()
	local index = LocalPlayer():Team()
	for _, ply in pairs(team.GetPlayers(index)) do
		local found = false
		for _, line in pairs(self.MemberList.Lines) do
			if line.player == ply then found = true end
		end
		if !found then
			local line = self.MemberList:AddLine( ply:GetName(), ply:Frags(), ply:Deaths() )
			line.player = ply
		end
	end
	for i, line in pairs(self.MemberList.Lines) do
		if !IsValid( line.player ) or line.player:Team() != index then
			self.MemberList:RemoveLine( i )
		else
			line:SetColumnText( 2, line.player:Frags() )
			line:SetColumnText( 3, line.player:Deaths() )
		end
	end
end

function PANEL:Think()
	if CurTime() - self.m_LastUpdate < 2 then return end
	self:UpdatePlayerList()
	self.m_LastUpdate = CurTime()
end

function PANEL:Paint( w, h )
	local skin = self:GetSkin()
	local teams =  team.GetAllTeams()
	local tbl = teams[LocalPlayer():Team()]
	
	skin:DrawGenericBackground( 0, 0, w, 24, skin.bg_color )
	skin:DrawGenericBackground( 0, 34, w-210, h-34, skin.bg_color )
	skin:DrawGenericBackground( w-200, 34, 200, h-34, skin.bg_color )
	
	surface.SetDrawColor( 200, 200, 200, 120 )
	surface.DrawRect( w-199, h-44, 198, 1 )

	if !tbl then return end
	
	local str = tbl.Name
	surface.SetFont( "Trebuchet19" )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextPos( 8, 12-th/2 )
	surface.SetTextColor( tbl.Color )
	surface.DrawText( str )
end

function PANEL:PerformLayout( w, h )
	self.MemberList:SetSize( w-230, h-54 )
	self.MemberList:SetPos( 10, 44 )
	
	self.PasswordLabel:SizeToContents()
	self.PasswordLabel:SetTall( 22 )
	self.PasswordLabel:SetPos( w-190, 44 )
	
	self.Password:SetSize( 125, 22 )
	self.Password:SetPos( self.PasswordLabel:GetWide()+w-185, 44 )
	
	self.ChangePassword:SetSize( 180, 22 )
	self.ChangePassword:SetPos( w-190, 76 )
	
	self.KickSelected:SetSize( 180, 22 )
	self.KickSelected:SetPos( w-190, 108 )
	
	self.ChangeLeader:SetSize( 180, 22 )
	self.ChangeLeader:SetPos( w-190, 140 )
	
	self.LeaderOnlyPass:SetSize( 180, 22 )
	self.LeaderOnlyPass:SetPos( w-190, 172 )
	
	self.DisbandTeam:SetSize( 180, 22 )
	self.DisbandTeam:SetPos( w-190, h-34 )
end

vgui.Register( "sh_teammanagepanel", PANEL, "Panel" )