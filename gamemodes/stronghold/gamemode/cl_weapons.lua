--[[
	File: cl_weapons.lua
	For: F2S: Stronghold
	By: Ultra
]]--

local tblWepCache = {}
function GM:UpdateCachedPlayerWeapons()
	--Cleanup dead players
	for k, tbl in pairs( tblWepCache ) do
		if not IsValid( tbl.Player ) then
			for str, ent in pairs( tbl.ClientModels ) do
				if IsValid( ent ) then
					ent:Remove()
				end

				tbl.ClientModels[str] = nil
			end

			tblWepCache[k] = nil
		end
	end


	local pcache
	for _, pl in pairs( player.GetAll() ) do
		if not tblWepCache[pl:EntIndex()] then
			tblWepCache[pl:EntIndex()] = { Player=pl, WeaponStrings={}, ClientModels={}, Refresh=false }
		end

		pcache = nil; pcache = tblWepCache[pl:EntIndex()]

		if pl:Alive() then
			--Cleanup old strings
			for str, _ in pairs( pcache.WeaponStrings ) do
				for _, wep in pairs( pl:GetWeapons() ) do
					if pcache.WeaponStrings[wep.WorldModel] then
						continue
					end

					pcache.WeaponStrings[str] = nil
					pcache.Refresh = true
				end
			end

			--Get player's weapons
			local strWep
			for _, wep in pairs( pl:GetWeapons() ) do
				strWep = wep.WorldModel

				if not pcache.WeaponStrings[strWep] then
					pcache.WeaponStrings[strWep] = {
						Attach 			= wep.Attach,
						AttachVector 	= wep.AttachVector,
						AttachAngle 	= wep.AttachAngle,
						Owner 			= wep.Owner
					}

					pcache.Refresh = true
				end
			end

			--Cleanup old models
			for str, ent in pairs( pcache.ClientModels ) do
				if not IsValid( ent ) then
					pcache.ClientModels[str] = nil
				elseif not pcache.WeaponStrings[str] then
					ent:Remove()
					pcache.ClientModels[str] = nil
				end
			end

			--If alive and refresh update client models
			if pcache.Refresh then
				--Remove old models
				for str, ent in pairs( pcache.ClientModels ) do
					if IsValid( ent ) then
						pcache.ClientModels[str]:Remove()
					end

					pcache.ClientModels[str] = nil
				end

				--Make new models
				for str, data in pairs( pcache.WeaponStrings ) do
					if not data.Attach then continue end
					pcache.ClientModels[str] = ClientsideModel( str, RENDERGROUP_BOTH  )
					pcache.ClientModels[str]:SetRenderMode( RENDERMODE_TRANSALPHA )
				end

				pcache.Refresh = false
			end
		end
	end
end

function GM:WeaponsAttachedThink()
	self:UpdateCachedPlayerWeapons()

	for _, pl in pairs( player.GetAll() ) do
		local parent 	= pl:Alive() and pl or pl:GetRagdollEntity()
		local activewep = pl:GetActiveWeapon()
		local pcache 	= tblWepCache[pl:EntIndex()]
		
		if not pcache then continue end
		if IsValid( activewep ) and pl:Alive() then
			pcache.LastActive = activewep.WorldModel
		end

		for str, ent in pairs( pcache.ClientModels ) do
			if pl:Alive() then
				ent:SetNoDraw( pcache.LastActive == str or not IsValid(parent) or pl == LocalPlayer() )
			else
				ent:SetNoDraw( pcache.LastActive == str )
			end

			if IsValid( parent ) then
				ent:SetColor( parent:GetColor() )
			else
				ent:SetColor(Color(0,0,0,0))
			end

			local attach = pcache.WeaponStrings[str]
			if attach and attach.Attach then
				if IsValid( parent ) and IsValid( ent ) then
					local BonePos, BoneAng 		= parent:GetBonePosition( parent:LookupBone(attach.Attach) )
					local up, forward, right 	= attach.AttachVector.x, attach.AttachVector.y, attach.AttachVector.z
					local pitch, yaw, roll 		= attach.AttachAngle.p, attach.AttachAngle.y, attach.AttachAngle.r
					
					local setPos, setAng = LocalToWorld( BonePos, BoneAng, attach.AttachVector, attach.AttachAngle )
					
					if BonePos and BoneAng then
						--ent:SetPos(setPos)
						--ent:SetAngles(setAng)
						ent:SetPos( BonePos +(BoneAng:Up() *up) +(BoneAng:Forward() *forward) +(BoneAng:Right() *right) )
						BoneAng:RotateAroundAxis( BoneAng:Up(),  pitch)
						BoneAng:RotateAroundAxis( BoneAng:Forward(),  yaw)
						BoneAng:RotateAroundAxis( BoneAng:Right(), roll)
						ent:SetAngles(BoneAng)
					end
				end
			end
		end
	end
end