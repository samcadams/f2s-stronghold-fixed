--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	Changes
	
	UNKNOWN - UNKNOWN:
		Added:
		Removed:
		Updated:
			net code
		Changed:
			cleaned code
	
	TehBigA - 10/23/12:
		Fixed 'else' statement that changed the hat's parent to the ragdoll to prevent being set as nil
]]--

local hats = {}

function GM:HatEffectsThink()
	for k, e in pairs( hats ) do
		if not IsValid( e ) then
			hats[k] = nil
			continue
		end

		if not IsValid( e.ply ) then
			e:Remove()
			hats[k] = nil
		end
	end

	for _, ply in ipairs( player.GetAll() ) do
		if IsValid( ply.Hat ) then
			local ragdoll = ply:GetRagdollEntity()
			local parent = ply.Hat:GetParent()
			--print(ragdoll)
			if ply:Alive() then
				if parent ~= ply then ply.Hat:SetParent( ply ) parent = ply end
			elseif IsValid( ragdoll ) then
				if parent == ply then ply.Hat:SetParent( ragdoll ) parent = ragdoll end
			end
			
			local hatpos, hatang = ply:GetHatPos(), ply:GetHatAng()

			if IsValid( parent ) then
				local index = parent:LookupBone( "ValveBiped.Bip01_Head1" )
				local pos, ang = parent:GetBonePosition( index )
				local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
				
				ang:RotateAroundAxis( right, 	-90 )
				ang:RotateAroundAxis( forward, 	90 )
				ang:RotateAroundAxis( forward, 	hatang.y )
				ang:RotateAroundAxis( right, 	hatang.r )
				ang:RotateAroundAxis( up, 		hatang.p )
				
				ply.Hat:SetPos( pos +hatpos.x *right +hatpos.y *up +hatpos.z *forward )
				ply.Hat:SetAngles( ang )
			end
			
			if (ply == LocalPlayer() and ply:Alive()) or IsValid( LocalPlayer():GetObserverTarget() or nil ) then
				ply.Hat:SetNoDraw( true )
			else
				ply.Hat:SetNoDraw( false )
			end
		end
	end
end

hook.Add( "sh_hat", "cl_hats", function( pPlayer, bEnable, strHat )
	if not IsValid( pPlayer ) then return end
	
	if bEnable then
		local tbl = GAMEMODE.ValidHats[strHat]
		
		if not tbl then
			if IsValid( pPlayer.Hat ) then pPlayer.Hat:Remove() end
			pPlayer.Hat = nil
			pPlayer.HatID = nil
			
			return
		end
		
		pPlayer.HatID = strHat
	
		if not IsValid( pPlayer.Hat ) then
			pPlayer.Hat = ClientsideModel( tbl.model )
			pPlayer.Hat.ply = pPlayer
			table.insert( hats, pPlayer.Hat )

			--pPlayer.Hat:SetModel( tbl.model )
			--pPlayer.Hat:Spawn()
			
			if pPlayer == LocalPlayer() then
				pPlayer.Hat:SetNoDraw( true )
			end
		elseif pPlayer.Hat:GetModel() ~= tbl.model then
			pPlayer.Hat:SetModel( tbl.model )
		end
		
		pPlayer:SetHatPos( tbl.pos )
		pPlayer:SetHatAng( tbl.ang )
	else
		if IsValid( pPlayer.Hat ) then pPlayer.Hat:Remove() end
		pPlayer.Hat = nil
		pPlayer.HatID = nil
	end
end )