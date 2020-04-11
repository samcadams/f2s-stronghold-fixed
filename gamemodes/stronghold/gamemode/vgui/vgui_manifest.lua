--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

if SERVER then
	--AddCSLuaFile( "" )
	AddCSLuaFile( "sh_misc.lua" )
	AddCSLuaFile( "sh_optionsmenu.lua" )
	AddCSLuaFile( "sh_spawnmenu.lua" )
	AddCSLuaFile( "sh_teamlistview.lua" )
	AddCSLuaFile( "sh_teamjoinpanel.lua" )
	AddCSLuaFile( "sh_teamcreatepanel.lua" )
	AddCSLuaFile( "sh_teammanagepanel.lua" )
	AddCSLuaFile( "sh_teammenu.lua" )
	AddCSLuaFile( "sh_helpmenu.lua" )
	AddCSLuaFile( "sh_loadoutmenu.lua" )
	AddCSLuaFile( "sh_loadoutpanel.lua" )
	AddCSLuaFile( "sh_itemmodel.lua" )
	AddCSLuaFile( "sh_quickbuy.lua" )
	AddCSLuaFile( "sh_gbuxshop.lua" )
	AddCSLuaFile( "sh_votingpanel.lua" )
	AddCSLuaFile( "sh_statisticspanel.lua" )
	AddCSLuaFile( "sh_appearancepanel.lua" )
	AddCSLuaFile( "sh_finance.lua" )
	AddCSLuaFile( "sh_bounty.lua" )
	AddCSLuaFile( "sh_donatepanel.lua" )
	AddCSLuaFile( "sh_tutorialpanel.lua" )
	AddCSLuaFile( "sh_scoreboard.lua" )
	AddCSLuaFile( "sh_commorose.lua" )
	AddCSLuaFile( "sh_uplinkterm.lua" )
elseif CLIENT then
	--include( "" )
	include( "sh_misc.lua" )
	include( "sh_optionsmenu.lua" )
	include( "sh_spawnmenu.lua" )
	include( "sh_teamlistview.lua" )
	include( "sh_teamjoinpanel.lua" )
	include( "sh_teamcreatepanel.lua" )
	include( "sh_teammanagepanel.lua" )
	include( "sh_teammenu.lua" )
	include( "sh_helpmenu.lua" )
	include( "sh_loadoutmenu.lua" )
	include( "sh_loadoutpanel.lua" )
	include( "sh_itemmodel.lua" )
	include( "sh_quickbuy.lua" )
	include( "sh_gbuxshop.lua" )
	include( "sh_votingpanel.lua" )
	include( "sh_statisticspanel.lua" )
	include( "sh_appearancepanel.lua" )
	include( "sh_finance.lua" )
	include( "sh_bounty.lua" )
	include( "sh_donatepanel.lua" )
	include( "sh_tutorialpanel.lua" )
	include( "sh_scoreboard.lua" )
	include( "sh_commorose.lua" )
	include( "sh_uplinkterm.lua" )
end