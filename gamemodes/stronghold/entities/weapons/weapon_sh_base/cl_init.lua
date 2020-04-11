include("shared.lua")

function SWEP:SetAttachments() 
	
	self:CreateModels(self.VElements) // create viewmodels
	self:CreateModels(self.WElements) // create worldmodels
	
	// init view model bone build function
	--[[self.BuildViewModelBones = function( s )
		if LocalPlayer():GetActiveWeapon() == self and self.ViewModelBonescales then
			for k, v in pairs( self.ViewModelBonescales ) do
				local bone = s:LookupBone(k)
				if (!bone) then continue end
				local m = s:GetBoneMatrix(bone)
				if (!m) then continue end
				m:Scale(v)
				s:SetBoneMatrix(bone, m)
				print("WAT")
			end
		end
	end]]
end
 
 
function SWEP:OnRemove()
    self:RemoveModels()     
end

SWEP.vRenderOrder = nil
function SWEP:ViewModelDrawn()
     
    local vm = self.Owner:GetViewModel()
    if !IsValid(vm) then return end
     
    if (!self.VElements) then return end
     
    if vm.BuildBonePositions ~= self.BuildViewModelBones then
        vm.BuildBonePositions = self.BuildViewModelBones
    end

    if (self.ShowViewModel == nil or self.ShowViewModel) then
        vm:SetColor( Color(255,255,255,255) )
		vm:SetRenderMode( RENDERMODE_NORMAL )
    else
        -- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
        vm:SetColor( Color(255,255,255,1) )
		vm:SetRenderMode( RENDERMODE_TRANSALPHA )
    end
     
    if (!self.vRenderOrder) then
         
        -- we build a render order because sprites need to be drawn after models
        self.vRenderOrder = {}

        for k, v in pairs( self.VElements ) do
            if (v.type == "Model") then
                table.insert(self.vRenderOrder, 1, k)
            elseif (v.type == "Sprite" or v.type == "Quad") then
                table.insert(self.vRenderOrder, k)
            end
        end
         
    end

    for k, name in ipairs( self.vRenderOrder ) do
     
        local v = self.VElements[name]
        if (!v) then self.vRenderOrder = nil break end
		
        local model = v.modelEnt
        local sprite = v.spriteMaterial
         
        if (!v.bone) then continue end
        local bone = vm:LookupBone(v.bone)
        if (!bone) then continue end
         
        local pos, ang = Vector(0,0,0), Angle(0,0,0)
        local m = vm:GetBoneMatrix(bone)
        if (m) then
            pos, ang = m:GetTranslation(), m:GetAngles()
        end
         
        if (self.ViewModelFlip) then
            ang.r = -ang.r // Fixes mirrored models
        end
         
        if (v.type == "Model" and IsValid(model)) then

            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            model:SetAngles(ang)
			model:SetLegacyTransform(true)
            model:SetModelScale(v.size,0)
            
            if (v.material == "") then
                model:SetMaterial("")
            elseif (model:GetMaterial() != v.material) then
                model:SetMaterial( v.material )
            end
             
            if (v.skin and v.skin != model:GetSkin()) then
                model:SetSkin(v.skin)
            end
             
            if (v.bodygroup) then
                for k, v in pairs( v.bodygroup ) do
                    if (model:GetBodygroup(k) != v) then
                        model:SetBodygroup(k, v)
                    end
                end
            end
             
            if (v.surpresslightning) then
                render.SuppressEngineLighting(true)
            end
             
            render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
            render.SetBlend(v.color.a/255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
             
            if (v.surpresslightning) then
                render.SuppressEngineLighting(false)
            end
             
        elseif (v.type == "Sprite" and sprite) then
             
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
             
        elseif (v.type == "Quad" and v.draw_func) then
             
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
             
            cam.Start3D2D(drawpos, ang, v.size)
                v.draw_func( self )
            cam.End3D2D()
        end
         
    end
    
end

SWEP.wRenderOrder = nil
function SWEP:DrawWorldModel()
     
    if (self.ShowWorldModel == nil or self.ShowWorldModel) then
        self:DrawModel()
    end
     
    if (!self.WElements) then return end
     
    if (!self.wRenderOrder) then

        self.wRenderOrder = {}

        for k, v in pairs( self.WElements ) do
            if (v.type == "Model") then
                table.insert(self.wRenderOrder, 1, k)
            elseif (v.type == "Sprite" or v.type == "Quad") then
                table.insert(self.wRenderOrder, k)
            end
        end

    end
     
    local opos, oang = self:GetPos(), self:GetAngles()
    local bone_ent

    if (IsValid(self.Owner)) then
        bone_ent = self.Owner
    else
        // when the weapon is dropped
        bone_ent = self
    end
     
    local bone = bone_ent:LookupBone("ValveBiped.Bip01_R_Hand")
    if (bone) then
        local m = bone_ent:GetBoneMatrix(bone)
        if (m) then
            opos, oang = m:GetTranslation(), m:GetAngle()
        end
    end
     
    for k, name in pairs( self.wRenderOrder ) do
     
        local v = self.WElements[name]
        if (!v) then self.wRenderOrder = nil break end
     
        local model = v.modelEnt
        local sprite = v.spriteMaterial

        local pos, ang = Vector(opos.x, opos.y, opos.z), Angle(oang.p, oang.y, oang.r)

        if (v.type == "Model" and IsValid(model)) then

            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            model:SetAngles(ang)
            model:SetModelScale(v.size)
             
            if (v.material == "") then
                model:SetMaterial("")
            elseif (model:GetMaterial() != v.material) then
                model:SetMaterial( v.material )
            end
             
            if (v.skin and v.skin != model:GetSkin()) then
                model:SetSkin(v.skin)
            end
             
            if (v.bodygroup) then
                for k, v in pairs( v.bodygroup ) do
                    if (model:GetBodygroup(k) != v) then
                        model:SetBodygroup(k, v)
                    end
                end
            end
             
            if (v.surpresslightning) then
                render.SuppressEngineLighting(true)
            end
             
            render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
            render.SetBlend(v.color.a/255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
             
            if (v.surpresslightning) then
                render.SuppressEngineLighting(false)
            end
             
        elseif (v.type == "Sprite" and sprite) then
             
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
             
        elseif (v.type == "Quad" and v.draw_func) then
             
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
             
            cam.Start3D2D(drawpos, ang, v.size)
                v.draw_func( self )
            cam.End3D2D()

        end
         
    end
	
	
     
end

function SWEP:CreateModels( tab )
	
    if (!tab) then return end
    // Create the clientside models here because Garry says we can't do it in the render hook
    for k, v in pairs( tab ) do
        if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
                string.find(v.model, ".mdl") and file.Exists (v.model,"GAME") ) then

            v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
            if (IsValid(v.modelEnt)) then
                v.modelEnt:SetPos(self:GetPos())
                v.modelEnt:SetAngles(self:GetAngles())
                v.modelEnt:SetParent(self)
                v.modelEnt:SetNoDraw(true)
                v.createdModel = v.model
				if v.modelEnt:LookupBone("Front") then
					self:IronsMan(v.modelEnt)
				end
            else
                v.modelEnt = nil
            end
             
        elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
            and file.Exists ("../materials/"..v.sprite..".vmt", "GAME")) 
			then
             
            local name = v.sprite.."-"
            local params = { ["$basetexture"] = v.sprite }
            // make sure we create a unique name based on the selected options
            local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
            for i, j in pairs( tocheck ) do
                if (v[j]) then
                    params["$"..j] = 1
                    name = name.."1"
                else
                    name = name.."0"
                end
            end

            v.createdSprite = v.sprite
            v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
             
        end
    end
     
end

function SWEP:IronsMan(Ent)
	local Front = Ent:LookupBone("Front")
	Ent:ManipulateBonePosition(  Front,  Vector(0,0,500) )
	print(Ent:LookupBone("Front"))
end

function SWEP:RemoveModels()
    if (self.VElements) then
        for k, v in pairs( self.VElements ) do
            if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
        end
    end
    if (self.WElements) then
        for k, v in pairs( self.WElements ) do
            if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
        end
    end
    self.VElements = nil
    self.WElements = nil
end

local SCOPEFADE_TIME = 0.2
function SWEP:DrawHUD()
	if self.VElements and self.VElements.scope then

			if self.bInIronSight !=self.LastIron then
				self.LastIron = self.bInIronSight
				self.IronTime = CurTime()
			end

		--if !self.bInIronSight then return end
		local In = (math.Clamp( ((CurTime()-self.IronTime)/SCOPEFADE_TIME), 0, 1 ))
		local Out = (math.Clamp( ((CurTime()-self.IronTime)/(SCOPEFADE_TIME*0.5)), 0, 1 )-1)*-1
		local scale = self.bInIronSight and In or 
		!self.bInIronSight and Out

		if self.VElements.scope and !self.Acog and !self.AugRet then
			-- Draw the crosshair
			surface.SetDrawColor(0,0,0,255*scale)
			surface.DrawRect(0,ScrH()*0.5,ScrW(),1)
			surface.DrawRect(ScrW()*0.5,0,1,ScrH())

			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
			--end
		end
		
		if self.UseScope and self.AugRet then
			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())
			
			surface.SetDrawColor(255, 255, 255, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/augret"))
			surface.DrawTexturedRect(ScrW()*0.5-16, ScrH()*0.5-16, 32, 32)

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
			--end
		end
				
		if self.UseScope and self.Acog then
			-- Draw the crosshair
			surface.SetDrawColor(200, 0, 0, 255*scale)
			surface.DrawRect(ScrW()*0.5-1,ScrH()*0.5+10, 2,10)
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(ScrW()*0.5-1,ScrH()*0.5+20, 2,110)
			surface.DrawRect(ScrW()*0.5-15,ScrH()*0.5+20, 30,1)
			surface.DrawRect(ScrW()*0.5-13,ScrH()*0.5+40, 26,1)
			surface.DrawRect(ScrW()*0.5-5,ScrH()*0.5+70, 10,1)
			surface.DrawRect(ScrW()*0.5-3,ScrH()*0.5+130, 6,1)
			
			surface.DrawRect(ScrW()*0.55,ScrH()*0.5+8, ScrW()*0.45,2)
			surface.DrawRect(0,ScrH()*0.5+8, ScrW()*0.45,2)
			
			surface.DrawRect(ScrW()*0.55,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.55+40,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.55+80,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.55+120,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.55+160,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.55+200,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.55+240,ScrH()*0.5-10, 1,40)
			
			
			surface.DrawRect(ScrW()*0.45,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.45-40,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.45-80,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.45-120,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.45-160,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.45-200,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.45-240,ScrH()*0.5-10, 1,40)
			

			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())
			
			surface.SetDrawColor(200, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/acog_reticle"))
			surface.DrawTexturedRect(ScrW()*0.5-8, ScrH()*0.5-8, 16, 16)

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
		end
		end
		self:Crosshair()
end

