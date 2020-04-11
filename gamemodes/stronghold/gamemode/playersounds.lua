--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
--[[
	GM13 Changes

	usermessage - > net
	datastream - > net

	Cleaned Code
]]--

-- Standalone file, can work in autorun, otherwise include

AddCSLuaFile( "playersounds.lua" )

PlayerSounds = {}
PlayerSounds.Distance = 700

if CLIENT then

	PlayerSounds.CSS = {}
	PlayerSounds.CSS.Death = {
		"player/death1.wav",
		"player/death2.wav",
		"player/death3.wav",
		"player/death4.wav",
		"player/death5.wav",
		"player/death6.wav"
	}
	PlayerSounds.CSS.Hurt = {
		"player/pl_pain5.wav",
		"player/pl_pain6.wav",
		"player/pl_pain7.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.CSSHostage = {}
	PlayerSounds.CSSHostage.Death = {
		"hostage/hpain/hpain1.wav",
		"hostage/hpain/hpain2.wav",
		"hostage/hpain/hpain3.wav",
		"hostage/hpain/hpain4.wav",
		"hostage/hpain/hpain5.wav",
		"hostage/hpain/hpain6.wav"
	}
	PlayerSounds.CSSHostage.Hurt = {
		"hostage/hpain/hpain1.wav",
		"hostage/hpain/hpain2.wav",
		"hostage/hpain/hpain3.wav",
		"hostage/hpain/hpain4.wav",
		"hostage/hpain/hpain5.wav",
		"hostage/hpain/hpain6.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Alyx = {}
	PlayerSounds.Alyx.Death = {
		"vo/npc/alyx/no01.wav",
		"vo/npc/alyx/no02.wav",
		"vo/npc/alyx/no03.wav",
		"vo/streetwar/alyx_gate/al_no.wav"
	}
	PlayerSounds.Alyx.Hurt = {
		"vo/npc/alyx/hurt04.wav",
		"vo/npc/alyx/hurt05.wav",
		"vo/npc/alyx/hurt06.wav",
		"vo/npc/alyx/hurt08.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Female = {}
	PlayerSounds.Female.Death = {
		"vo/npc/female01/startle01.wav",
		"vo/npc/female01/startle01.wav",
		"vo/npc/female01/ow01.wav",
		"vo/npc/female01/ow02.wav"
	}
	PlayerSounds.Female.Hurt = {
		"vo/npc/female01/pain01.wav",
		"vo/npc/female01/pain02.wav",
		"vo/npc/female01/pain03.wav",
		"vo/npc/female01/pain04.wav",
		"vo/npc/female01/pain05.wav",
		"vo/npc/female01/pain06.wav",
		"vo/npc/female01/pain07.wav",
		"vo/npc/female01/pain08.wav",
		"vo/npc/female01/pain09.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Male = {}
	PlayerSounds.Male.Death = {
		"vo/npc/male01/startle01.wav",
		"vo/npc/male01/startle01.wav",
		"vo/npc/male01/ow01.wav",
		"vo/npc/male01/ow02.wav"
	}
	PlayerSounds.Male.Hurt = {
		"vo/npc/male01/pain01.wav",
		"vo/npc/male01/pain02.wav",
		"vo/npc/male01/pain03.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain05.wav",
		"vo/npc/male01/pain06.wav",
		"vo/npc/male01/pain07.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/pain09.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Monk = {}
	PlayerSounds.Monk.Death = {
		"vo/ravenholm/monk_death07.wav"
	}
	PlayerSounds.Monk.Hurt = {
		"vo/ravenholm/monk_pain01.wav",
		"vo/ravenholm/monk_pain02.wav",
		"vo/ravenholm/monk_pain03.wav",
		"vo/ravenholm/monk_pain04.wav",
		"vo/ravenholm/monk_pain05.wav",
		"vo/ravenholm/monk_pain06.wav",
		"vo/ravenholm/monk_pain07.wav",
		"vo/ravenholm/monk_pain08.wav",
		"vo/ravenholm/monk_pain09.wav",
		"vo/ravenholm/monk_pain10.wav",
		"vo/ravenholm/monk_pain11.wav",
		"vo/ravenholm/monk_pain12.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Zombie = {}
	PlayerSounds.Zombie.Death = {
		"npc/zombie/zombie_die1.wav",
		"npc/zombie/zombie_die2.wav",
		"npc/zombie/zombie_die3.wav"
	}
	PlayerSounds.Zombie.Hurt = {
		"npc/zombie/zombie_pain1.wav",
		"npc/zombie/zombie_pain2.wav",
		"npc/zombie/zombie_pain3.wav",
		"npc/zombie/zombie_pain4.wav",
		"npc/zombie/zombie_pain5.wav",
		"npc/zombie/zombie_pain6.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Zombine = {}
	PlayerSounds.Zombine.Death = {
		"npc/zombine/zombine_die1.wav",
		"npc/zombine/zombine_die2.wav"
	}
	PlayerSounds.Zombine.Hurt = {
		"npc/zombine/zombine_pain1.wav",
		"npc/zombine/zombine_pain2.wav",
		"npc/zombine/zombine_pain3.wav",
		"npc/zombine/zombine_pain4.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Barney = {}
	PlayerSounds.Barney.Death = {
		"vo/npc/barney/ba_ohshit03.wav",
		"vo/npc/barney/ba_no01.wav",
		"vo/npc/barney/ba_no02.wav"
	}
	PlayerSounds.Barney.Hurt = {
		"vo/npc/barney/ba_pain01.wav",
		"vo/npc/barney/ba_pain02.wav",
		"vo/npc/barney/ba_pain03.wav",
		"vo/npc/barney/ba_pain04.wav",
		"vo/npc/barney/ba_pain05.wav",
		"vo/npc/barney/ba_pain06.wav",
		"vo/npc/barney/ba_pain07.wav",
		"vo/npc/barney/ba_pain08.wav",
		"vo/npc/barney/ba_pain09.wav",
		"vo/npc/barney/ba_pain10.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Eli = {}
	PlayerSounds.Eli.Death = {
		"vo/outland_12a/launch/eli_launch_bigpain01.wav",
		"vo/outland_12a/launch/eli_launch_bigpain04.wav"
	}
	PlayerSounds.Eli.Hurt = {
		"vo/outland_12a/launch/eli_launch_pain01.wav",
		"vo/outland_12a/launch/eli_launch_pain04.wav",
		"vo/outland_12a/launch/eli_launch_pain05.wav",
		"vo/outland_12a/launch/eli_launch_pain06.wav",
		"vo/outland_12a/launch/eli_launch_pain09.wav",
		"vo/outland_12a/launch/eli_launch_pain13.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Mossman = {}
	PlayerSounds.Mossman.Death = {
		"vo/npc/female01/startle01.wav",
		"vo/npc/female01/startle01.wav",
		"vo/npc/female01/ow01.wav",
		"vo/npc/female01/ow02.wav"
	}
	PlayerSounds.Mossman.Hurt = {
		"vo/npc/female01/pain01.wav",
		"vo/npc/female01/pain02.wav",
		"vo/npc/female01/pain03.wav",
		"vo/npc/female01/pain04.wav",
		"vo/npc/female01/pain05.wav",
		"vo/npc/female01/pain06.wav",
		"vo/npc/female01/pain07.wav",
		"vo/npc/female01/pain08.wav",
		"vo/npc/female01/pain09.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Combine = {}
	PlayerSounds.Combine.Death = {
		"npc/combine_soldier/die1.wav",
		"npc/combine_soldier/die2.wav",
		"npc/combine_soldier/die3.wav"
	}
	PlayerSounds.Combine.Hurt = {
		"npc/combine_soldier/pain1.wav",
		"npc/combine_soldier/pain2.wav",
		"npc/combine_soldier/pain3.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.Metro = {}
	PlayerSounds.Metro.Death = {
		"npc/metropolice/die1.wav",
		"npc/metropolice/die2.wav",
		"npc/metropolice/die3.wav",
		"npc/metropolice/die4.wav"
	}
	PlayerSounds.Metro.Hurt = {
		"npc/metropolice/pain1.wav",
		"npc/metropolice/pain2.wav",
		"npc/metropolice/pain3.wav",
		"npc/metropolice/pain4.wav"
	}

--[[ ------------------------------------ ]]

	PlayerSounds.HeadShotSnd = {
		"player/pl_pain5.wav",
		"player/pl_pain6.wav",
		"player/pl_pain7.wav"
	}

	PlayerSounds.Models = {}
	PlayerSounds.Models["models/player/alyx.mdl"] = "Alyx"
	PlayerSounds.Models["models/player/barney.mdl"] = "Barney"
	PlayerSounds.Models["models/player/combine_soldier.mdl"] = "Combine"
	PlayerSounds.Models["models/player/combine_soldier_prisonguard.mdl"] = "Combine"
	PlayerSounds.Models["models/player/combine_super_soldier.mdl"] = "Combine"
	PlayerSounds.Models["models/player/eli.mdl"] = "Eli"
	PlayerSounds.Models["models/player/Kleiner.mdl"] = "Male"
	PlayerSounds.Models["models/player/monk.mdl"] = "Monk"
	PlayerSounds.Models["models/player/mossman.mdl"] = "Female"
	PlayerSounds.Models["models/player/police.mdl"] = "Metro"
	PlayerSounds.Models["models/player/classic.mdl"] = "Zombie"
	PlayerSounds.Models["models/player/zombie_soldier.mdl"] = "Zombine"
	PlayerSounds.Models["models/player/zombiefast.mdl"] = "Zombie"
	PlayerSounds.Models["models/player/soldier_stripped.mdl"] = "Combine"
	PlayerSounds.Models["models/alyx.mdl"] = "Alyx"
	PlayerSounds.Models["models/barney.mdl"] = "Barney"
	PlayerSounds.Models["models/combine_soldier.mdl"] = "Combine"
	PlayerSounds.Models["models/combine_soldier_prisonguard.mdl"] = "Combine"
	PlayerSounds.Models["models/combine_super_soldier.mdl"] = "Combine"
	PlayerSounds.Models["models/eli.mdl"] = "Eli"
	PlayerSounds.Models["models/Kleiner.mdl"] = "Male"
	PlayerSounds.Models["models/monk.mdl"] = "Monk"
	PlayerSounds.Models["models/mossman.mdl"] = "Female"
	PlayerSounds.Models["models/police.mdl"] = "Metro"
	PlayerSounds.Models["models/classic.mdl"] = "Zombie"
	PlayerSounds.Models["models/zombie_soldier.mdl"] = "Zombine"
	PlayerSounds.Models["models/zombiefast.mdl"] = "Zombie"
	PlayerSounds.Models["models/soldier_stripped.mdl"] = "Combine"

	PlayerSounds.Models["models/player/group01/female_01.mdl"] = "Female"
	PlayerSounds.Models["models/player/group01/female_02.mdl"] = "Female"
	PlayerSounds.Models["models/player/group01/female_03.mdl"] = "Female"
	PlayerSounds.Models["models/player/group01/female_04.mdl"] = "Female"
	PlayerSounds.Models["models/player/group01/female_06.mdl"] = "Female"
	PlayerSounds.Models["models/player/group01/female_07.mdl"] = "Female"
	PlayerSounds.Models["models/player/group03/female_01.mdl"] = "Female"
	PlayerSounds.Models["models/player/group03/female_02.mdl"] = "Female"
	PlayerSounds.Models["models/player/group03/female_03.mdl"] = "Female"
	PlayerSounds.Models["models/player/group03/female_04.mdl"] = "Female"
	PlayerSounds.Models["models/player/group03/female_06.mdl"] = "Female"
	PlayerSounds.Models["models/player/group03/female_07.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group01/female_01.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group01/female_02.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group01/female_03.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group01/female_04.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group01/female_06.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group01/female_07.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group03/female_01.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group03/female_02.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group03/female_03.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group03/female_04.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group03/female_06.mdl"] = "Female"
	PlayerSounds.Models["models/humans/group03/female_07.mdl"] = "Female"

	PlayerSounds.Models["models/player/group01/male_01.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_02.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_03.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_04.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_05.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_06.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_07.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_08.mdl"] = "Male"
	PlayerSounds.Models["models/player/group01/male_09.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_01.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_02.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_03.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_04.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_05.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_06.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_07.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_08.mdl"] = "Male"
	PlayerSounds.Models["models/player/group03/male_09.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_01.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_02.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_03.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_04.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_05.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_06.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_07.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_08.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group01/male_09.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_01.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_02.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_03.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_04.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_05.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_06.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_07.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_08.mdl"] = "Male"
	PlayerSounds.Models["models/humans/group03/male_09.mdl"] = "Male"

	PlayerSounds.Models["models/player/urban.mdl"] = "CSS"
	PlayerSounds.Models["models/player/swat.mdl"] = "CSS"
	PlayerSounds.Models["models/player/gasmask.mdl"] = "CSS"
	PlayerSounds.Models["models/player/riot.mdl"] = "CSS"
	PlayerSounds.Models["models/player/leet.mdl"] = "CSS"
	PlayerSounds.Models["models/player/guerilla.mdl"] = "CSS"
	PlayerSounds.Models["models/player/phoenix.mdl"] = "CSS"
	PlayerSounds.Models["models/player/arctic.mdl"] = "CSS"
	PlayerSounds.Models["models/urban.mdl"] = "CSS"
	PlayerSounds.Models["models/swat.mdl"] = "CSS"
	PlayerSounds.Models["models/gasmask.mdl"] = "CSS"
	PlayerSounds.Models["models/riot.mdl"] = "CSS"
	PlayerSounds.Models["models/leet.mdl"] = "CSS"
	PlayerSounds.Models["models/guerilla.mdl"] = "CSS"
	PlayerSounds.Models["models/phoenix.mdl"] = "CSS"
	PlayerSounds.Models["models/arctic.mdl"] = "CSS"

	PlayerSounds.Models["models/player/hostage/hostage_01.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/player/hostage/hostage_02.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/player/hostage/hostage_03.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/player/hostage/hostage_04.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/hostage/hostage_01.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/hostage/hostage_02.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/hostage/hostage_03.mdl"] = "CSSHostage"
	PlayerSounds.Models["models/hostage/hostage_04.mdl"] = "CSSHostage"

	function PlayerSounds.PlaySound( ply, sound, head )
		if !IsValid( ply ) then return end

		local snd, snd2 = CreateSound( ply, sound ), CreateSound( ply, sound )
		snd:PlayEx( 2, 100 )
		snd:PlayEx( 2, 100 )
	end

	--See cl_networking.lua, net.Receive( "PlayerSounds_PlayerDeath", function( intMsgLen ) ... )
	-- function PlayerSounds.PlayerDeath( um )
	-- 	local ply = um:ReadEntity()
	-- 	local model = um:ReadString()
	-- 	if !IsValid( ply ) then return end

	-- 	local model = string.lower( ply:GetModel() )
	-- 	local index = PlayerSounds.Models[model]
	-- 	if !index then
	-- 		PlayerSounds.PlaySound( ply, table.Random(PlayerSounds["Male"]["Death"]), false )
	-- 	else
	-- 		PlayerSounds.PlaySound( ply, table.Random(PlayerSounds[index]["Death"]), false )
	-- 	end
	-- end
	-- usermessage.Hook( "PlayerSounds_PlayerDeath", PlayerSounds.PlayerDeath )
	function PlayerSounds.PlayerDeath( pPlayer, model )
		if not IsValid( pPlayer ) then return end

		local model = string.lower( pPlayer:GetModel() )
		local index = PlayerSounds.Models[model]
		
		if not index then
			PlayerSounds.PlaySound( pPlayer, table.Random(PlayerSounds["Male"]["Death"]), false )
		else
			PlayerSounds.PlaySound( pPlayer, table.Random(PlayerSounds[index]["Death"]), false )
		end		
	end

	--See cl_networking.lua, net.Receive( "PlayerSounds_ScalePlayerDamage", function( intMsgLen ) ... )
	-- function PlayerSounds.ScalePlayerDamage( um )
	-- 	local ply = um:ReadEntity()
	-- 	local model = um:ReadString()
	-- 	local head = um:ReadBool()
	-- 	if !IsValid( ply ) then return end

	-- 	if head then
	-- 		PlayerSounds.PlaySound( ply, table.Random(PlayerSounds.HeadShotSnd), true )
	-- 		return
	-- 	end

	-- 	local index = PlayerSounds.Models[model]
	-- 	if !index then
	-- 		PlayerSounds.PlaySound( ply, table.Random(PlayerSounds["Male"]["Hurt"]), false )
	-- 	else
	-- 		PlayerSounds.PlaySound( ply, table.Random(PlayerSounds[index]["Hurt"]), false )
	-- 	end
	-- end
	-- usermessage.Hook( "PlayerSounds_ScalePlayerDamage", PlayerSounds.ScalePlayerDamage )
	function PlayerSounds.ScalePlayerDamage( pPlayer, strModel, bHead )
		local ply 	= pPlayer
		local model = strModel
		local head 	= bHead
		if not IsValid( ply ) then return end

		if head then
			PlayerSounds.PlaySound( ply, table.Random(PlayerSounds.HeadShotSnd), true )
			return
		end

		local index = PlayerSounds.Models[model]
		if not index then
			PlayerSounds.PlaySound( ply, table.Random(PlayerSounds["Male"]["Hurt"]), false )
		else
			PlayerSounds.PlaySound( ply, table.Random(PlayerSounds[index]["Hurt"]), false )
		end
	end
elseif SERVER then
	function PlayerSounds.PlayerDeathSound()
		return true
	end
	hook.Add( "PlayerDeathSound", "PlayerSounds_PlayerDeathSound", PlayerSounds.PlayerDeathSound )

	function PlayerSounds.PlayerSpawn( ply )
		ply.LastHurtHead = false
	end
	hook.Add( "PlayerSpawn", "PlayerSounds_PlayerSpawn", PlayerSounds.PlayerSpawn )

	
	function PlayerSounds.PlayerDeath( ply )
		if !IsValid( ply ) or ply.LastHurtHead then return end

		for _, v in ipairs(ents.FindInSphere(ply:GetPos(),PlayerSounds.Distance)) do
			if v:IsPlayer() then
				--See sv_networking.lua, GM.Net:PlayerSoundsDeath
				-- umsg.Start( "PlayerSounds_PlayerDeath", v )
				-- umsg.Entity( ply )
				-- umsg.String( ply:GetModel() )
				-- umsg.End()

				GAMEMODE.Net:PlayerSoundsDeath( v, ply )
			end
		end
	end
	hook.Add( "PlayerDeath", "PlayerSounds_PlayerDeath", PlayerSounds.PlayerDeath )

	function PlayerSounds.ScalePlayerDamage( ply, hitgroup, dmginfo )
		if !IsValid( ply ) then return end

		if hitgroup == HITGROUP_HEAD then
			ply.LastHurtHead = true
			timer.Simple( 0.05, function() if !IsValid(ply) then return end ply.LastHurtHead = false end )
		end

		if !ply.LastHurtSound or CurTime() - ply.LastHurtSound >= 0.70 then
			for _, v in ipairs(ents.FindInSphere(ply:GetPos(),PlayerSounds.Distance)) do
				if v:IsPlayer() then
					--See sv_networking.lua, GM.Net:PlayerSoundsScalePlayerDamage
					-- umsg.Start( "PlayerSounds_ScalePlayerDamage", v )
					-- umsg.Entity( ply )
					-- umsg.String( ply:GetModel() )
					-- umsg.Bool( ply.LastHurtHead or false )
					-- umsg.End()

					GAMEMODE.Net:PlayerSoundsScalePlayerDamage( v, ply )
				end
			end
			ply.LastHurtSound = CurTime()
		end
	end
	hook.Add( "ScalePlayerDamage", "PlayerSounds_ScalePlayerDamage", PlayerSounds.ScalePlayerDamage )
end