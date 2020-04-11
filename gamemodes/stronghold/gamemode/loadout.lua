--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	GM13 Changes
	
	Added:
	Removed:
	Updated:
		net code
	Changed:
		cleaned code
]]--

concommand.Add( "sh_buyitem",
function( ply, cmd, args )
	ply:BuyItem( tonumber(args[1]), args[2], math.floor(tonumber(args[3])) )
end
)


concommand.Add( "sh_removeloadout", function( ply, cmd, args )
	ply:RemoveLoadout( args[1] )
end )

concommand.Add( "sh_editloadout", function( ply, cmd, args )
	ply:EditLoadout( args[1], args[2], args[3], args[4] )
	ply:SetLoadout( args[1] )
end )

concommand.Add( "sh_setloadout", function( ply, cmd, args )
	ply:SetLoadout( args[1] )
end )

concommand.Add( "sh_setprimary", function( ply, cmd, args )
	if !GAMEMODE.PrimaryWeapons[args[1]] then return end
	ply:SetLoadoutPrimary( args[1] )
end )

concommand.Add( "sh_setsecondary", function( ply, cmd, args )
	if !GAMEMODE.SecondaryWeapons[args[1]] then return end
	ply:SetLoadoutSecondary( args[1] )
end )

concommand.Add( "sh_setexplosive", function( ply, cmd, args )
	if !GAMEMODE.Explosives[args[1]] then return end
	ply:SetLoadoutExplosive( args[1] )
end )

concommand.Add( "sh_equiphat", function( ply, cmd, args )
	if !GAMEMODE.ValidHats[args[1]] then args[1] = "" end
	if !ply:IsDonator() and GAMEMODE.DonatorHats[args[1]] then args[1] = "" end
	ply:EnableHat( args[1] )
end )

concommand.Add( "sh_closedloadoutmenu", function( ply, cmd, args )
	if ply:GetInitialized() != INITSTATE_OK then return end
	if ply:GetObserverMode() != OBS_MODE_NONE then -- Just now setting first loadout
		ply:Spawn()
	elseif ply.WeaponLoadout then
		ply.WeaponLoadout = false
		hook.Call( "PlayerLoadout", GAMEMODE, ply )
	end
end )

concommand.Add( "sh_closedhelpmenu", function( ply, cmd, args )
	-- Opens loadout menu on first join
	if ply:GetInitialized() != INITSTATE_OK then return end
	if !ply.FirstHelpClose then
		ply.FirstHelpClose = true
		ply:ConCommand( "sh_loadout" )
	end
end )