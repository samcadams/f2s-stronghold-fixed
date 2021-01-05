include("shared.lua")

SWEP.FOVM = 1 
BlendSpeed =0
local Reloading = false
Set = false
local Mul = 0
local GMul = 0
local AMul = Angle(0,0,0)
local VMul = Vector(0,0,0)
local RunMul = 0
local EDIT = false
local LastMag = 0
local RandKick = 0
local OrigMul = Vector(0,0,0)
local PKick = 0
local PKickOff = 0
local veldepend = {pitch = 0, yaw = 0, roll = 0}
local LastRollVel = 0
local LastEA = 0
local Speed = 0
local Moving = 0
local CanFire
local Finished = true
local LastLoad = 0
local LastEAng = Angle(0,0,0)
local LastBoneAng = Angle(0,0,0)
local LerpTurnSpeed = Angle(0,0,0)
local RanDir = 0
local DisableKick = false
local BoneAngSpeed = Angle(0,0,0)
local LBoneAngSpeed = Angle(0,0,0)
local WAT = false
local Rscale = 0
local Rscale2 = 0
local Claws = 0
SWEP.ADSOFF = false
SWEP.Marker = false
SWEP.Shell = "models/shells/shell_9mm.mdl"
SWEP.ShellSize = 0
SWEP.EjectPos = Vector(0,0,0)
SWEP.Deployed = true

function SWEP:PreDrawViewModel()
	render.SetBlend(0)
end
local Reduce = 0
local Resist = 0
function SWEP:PostDrawViewModel()
	if self.LastClip<self:Clip1() then
	end

	render.SetBlend(1)
	VM, EP, EA, FT, CT = self.Owner:GetViewModel(), EyePos(), EyeAngles(), FrameTime(), CurTime()
	vel = self.Owner:GetVelocity()
	len = vel:Length()
	cyc = cyc and cyc or 0
	
	if vm == null or self.Switched then
		if vm and self.Switched then
			vm:Remove()
		end
		
		vm = ClientsideModel(self.ViewModel)
		
		vm:SetCycle(cyc)
		vm:SetSequence(self.DeployAnim)
		vm:SetPlaybackRate(1)
		Reloading = false
		DisableKick = true
		WAT = false
		self.Deployed = true
	end 
	
	self.VM = vm
	
	if self.ViewModelFlip then
		local scale = Vector( 1, -1, 1 )
		local mat = Matrix()
		mat:Scale( scale )
		vm:EnableMatrix( "RenderMultiply", mat )
		render.CullMode(MATERIAL_CULLMODE_CW)--Fix Flipped model textures.
	end	
		
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	
	if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyPressed(IN_USE) then
		if EDIT then 
			EDIT = false
			self.DrawCrosshair = false
		else 
			EDIT = true
		end
	end
		
	CanFire = (CurTime()-self:GetNextPrimaryFire())>=-0.3 and true or false
	
	if self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !Running and !Reloading and self.Owner:GetColor().a == 255 and self.Primary.Ammo != "grenade" and !self.ADSOFF and !self.Deployed or EDIT then
		Mul = Lerp( FT * 20, Mul, -1 )
		OrigMul = LerpVector( FT * 20, OrigMul, Vector(0,0,0) )
		if !self.AlwaysAnim then
		local idle = self.IdleAnim or 0
			vm:SetCycle(cyc)
			vm:SetSequence(idle)
			vm:SetPlaybackRate(1)
		end
	else
		Mul = Lerp( FT * 20, Mul, 0 )
		OrigMul = LerpVector( FT * 20, OrigMul, self.Origin )
	end
	
	if Mul < -0.85 then 
		self.RDDraw = true
	else
		self.RDDraw = false
	end
	
	if !self.RRise then self.RRise = 0 end
	if self.RunAngleSet == "pistol" then PKick = 1 PKickOff = 1 else PKick = self.RRise*5 PKickOff = 0 end
	if !self.RSlide then self.RSlide = 0 end
	
	TurnSpeed = EyeAngles() - LastEAng
	LerpTurnSpeed = LerpTurnSpeed + TurnSpeed
	LerpTurnSpeed = LerpAngle(FT*10, LerpTurnSpeed,Angle(0,0,0))
	
	--ADS Recoil
	Reduce = self.SMG and 0.5 or 1
	EA = EA + Angle(scale*5*PKick*PKickOff,-scale*RandKick*math.Rand(-0.04/self.Primary.Recoil,0.04/self.Primary.Recoil),0)

	--ADS Angles
	EA:RotateAroundAxis( EA:Up(),  (self.ADSAngle.p*-Mul))
	EA:RotateAroundAxis( EA:Forward(),  (self.ADSAngle.y*-Mul))
	EA:RotateAroundAxis( EA:Right(), self.ADSAngle.r*-Mul)
	
	--ADS Position/Recoil
	EP = EP + EA:Right() * (self.ADSPos.x+(scale*(self.RSlide*10))) * (Mul) 
	EP = EP + EA:Right() * (LerpTurnSpeed.y*0.03*(1.1+Mul))
	EP = EP + EA:Forward() * (self.ADSPos.y+(scale*(PKickOff+1))) * -Mul
	EP = EP + EA:Up() * (self.ADSPos.z+((scale)*PKick))* -Mul
	EP = EP + EA:Up() * (LerpTurnSpeed.p*0.03*(1.1+Mul))
	
	if !Reloading and self.Owner:KeyDown(IN_RELOAD) and self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
		Reloading = true
		vm:SetCycle(cyc)
		vm:SetSequence(self.ReloadAnim)
		vm:SetPlaybackRate(1)
		self.ResetBolt = true
		WepFired = false
	end
	

	if self:Clip1() < self.LastClip then
		DisableKick = false
		RanDir = math.Rand(self.Primary.Recoil*0.1,-self.Primary.Recoil*0.1)
		if self.FireOne then
		self:ShellEject(LocalPlayer())
		Resist = math.Clamp(Resist - 0.14,0.2,1.3)
		end
	end
	Resist = math.Clamp(Resist+(FT),0,1)
	
	if self.Primary.Ammo != "buckshot" and self.FireOne and self.AlwaysAnim and self.FOVM > 0.3 or self.Primary.Ammo == "grenade" and self.Owner:KeyPressed(IN_ATTACK2) or self.Primary.Ammo == "grenade" and self.Owner:KeyPressed(IN_ATTACK) then
		vm:SetCycle(cyc)
		vm:SetSequence(self.ShootAnim)
		self:ShootEffects()
		vm:SetPlaybackRate(1)
		Reloading = false
	end

	if self.Primary.Ammo == "buckshot" and Reloading and self.Owner:KeyPressed(IN_ATTACK) then
		vm:SetCycle(cyc)
		vm:SetSequence(self.ShootAnim)
		self:ShootEffects()
		vm:SetPlaybackRate(1)
		Reloading = false
	end
	
	if self.Primary.Ammo == "grenade" and self.Owner:KeyReleased(IN_ATTACK) or self.Primary.Ammo == "grenade" and self.Owner:KeyReleased(IN_ATTACK2) then
		vm:SetCycle(cyc)
		vm:SetSequence(self.ReloadAnim)
		vm:SetPlaybackRate(1)
		timer.Simple(0.5, function() 
			if IsValid(self) then
			if self.Primary.Ammo == "grenade" then
				vm:SetCycle(cyc)
				vm:SetSequence(self.DeployAnim)
				vm:SetPlaybackRate(1)
			end
			end
		end)
	end	
	

	self:AimRecoil()
	
	if WepFired or self:Clip1() < self.LastClip and !self.ShellReloadAnim then
		Reloading = false
		self.ResetBolt = false
	end
	
	self:SwayCalc()
	self:RunAnims()
	
	EP = (EP + (EA:Forward()*OrigMul.x) + (EA:Up()*OrigMul.y) + (EA:Right()*OrigMul.z) )
	EA = EA
	vm:SetNoDraw(true)
	vm:SetRenderOrigin(EP)
	vm:SetRenderAngles(EA)
	vm:FrameAdvance(FT)
	vm:SetupBones()
	vm:SetParent(VM)
	vm:DrawModel()
	
	self:ShotgunReload()
	
	
	self:BoltMovement()
	render.CullMode(MATERIAL_CULLMODE_CCW)--Set it back so the rest of the world works.
	BlendSpeed = Lerp(FT * 3, BlendSpeed, 12)
	if !Set then 
		self:SetAttachments()
		Set = true
	end
	
	self:UpdateStuff()
	LastEAng = EyeAngles()
	self.FireOne = false
	
	if self.Owner:KeyDown(IN_ATTACK2) and !Running and !Reloading then 
		Claws = Lerp(FT*20, Claws, 1)
	else
		Claws = Lerp(FT*20, Claws, 0 )
	end
	
	if self.Owner:KeyPressed(IN_ATTACK) and !Running and self:Clip1() > 0 then 
		Claws = Lerp(FT*100, Claws, 0)
	end
	
	if self.Hacker then 
		vm:SetPoseParameter("active", Claws)
	end
	
	self.Switched = false
	
	if self:Clip1() == self.Primary.ClipSize and self.Primary.Ammo != "buckshot" or self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) <= 0 then
		Reloading = false	
	end
	
	--Don't Ironsight until you're done deploying OR have an rds sight while bolt actioning.
	if self.AlwaysAnim and self.VElements.rds then
		if self:GetNextPrimaryFire() > CurTime() and self.AlwaysAnim and self.VElements.rds then
			self.Deployed = false
			self.ADSOFF = true
		else
			self.ADSOFF = false
		end
	else
		if (self:GetNextPrimaryFire() - CurTime()) < 0 and self.Deployed then 
			self.Deployed = false
			self.ADSOFF = true
		else
			self.ADSOFF = false
		end
	end
end

function SWEP:ShellEject( ply )
	if self.Hacker or self.Scanner then return end
	timer.Simple(self.EjectDelay or 0, function()
	if self.EjectPos then
		if self.PrintName == "D.EAGLE .44" and self.Owner:KeyDown(IN_ATTACK2) then
			self.EjectPos = Vector(5,-3,8) --Shells clip through the screen unless we move it away when the sights are raised.
		elseif self.PrintName == "D.EAGLE .44" then
			self.EjectPos = Vector(5,-3,4)
		end
		local prop = ents.CreateClientProp()
		prop:SetModel(self.Shell)
		prop:SetPos(vm:GetPos()+vm:GetAngles():Right()*self.EjectPos.x+vm:GetAngles():Up()*self.EjectPos.y+vm:GetAngles():Forward()*self.EjectPos.z)
		prop:Spawn()
		prop:SetAngles(ply:EyeAngles())
		prop:PhysicsInitBox(Vector(-5,-1,-1),Vector(5,1,1))
		prop:SetSolid(SOLID_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		prop:SetModelScale(1+self.ShellSize)
		local phys = prop:GetPhysicsObject()
		phys:Wake()
		
		phys:SetMaterial("gmod_silent")
		phys:ApplyForceOffset(ply:EyeAngles():Right()*-(50*self.EjectDir.x+math.Rand(-10,10))
		+ply:EyeAngles():Up()*(20*self.EjectDir.y+math.Rand(-2,2))
		+ply:EyeAngles():Forward()*(2*self.EjectDir.z+math.Rand(-5,5))
		,prop:GetPos()+prop:GetAngles():Forward()*2)

		prop:AddCallback("PhysicsCollide", Collide)
		timer.Simple(5, function() prop:Remove() end)
	end
	end)

end

function Collide( entity, data )
	if ( data.Speed > 250 ) then
		if entity:GetModel() == "models/shells/shell_12gauge.mdl" then
		sound.Play( "weapons/fx/tink/shotgun_shell"..math.random(1,3)..".wav", entity:GetPos(), 75, 100, 0.3 )
		else
		sound.Play( "player/pl_shell"..math.random(1,3)..".wav", entity:GetPos(), 75, 100, 0.3 )
		end
	end
end

local CamMod = 0
function SWEP:CalcView(ply, pos, ang, fov)
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	
	if self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !Running and !Reloading and self.Zoom > 0 then
		self.FOVM = Lerp(FT*12, self.FOVM, self.Zoom)
	elseif FT then
		self.FOVM = Lerp(FT*12, self.FOVM, 1) --1 means full base fov
	end
	--print(self.FOVM)
	fov = (LocalPlayer():GetFOV() * self.FOVM) --Multiplies base fov (ie 100) by sliding lerp to percentage (1 -> 0.2)

	if !vm then return end
	local bone = vm:LookupBone("v_weapon.Left_Hand")
	if !printed then
		for i=1,vm:GetBoneCount() do
			printed= true
		end
	end
	
	if bone then
		local m = vm:GetBoneMatrix(bone)
		
		if Reloading or WAT and RunMul < 0.01 then
			CamMod = 1
		else
			CamMod = 0
		end
		if m then
		BoneAngSpeed = m:GetAngles()-LastBoneAng
		LBoneAngSpeed = LBoneAngSpeed + (BoneAngSpeed-Angle(TurnSpeed.x,TurnSpeed.y,0))*CamMod
		LBoneAngSpeed = LerpAngle(FT*5,LBoneAngSpeed, Angle(0,0,0))
		ang = ang + Angle(((LBoneAngSpeed.p*0.1)),((LBoneAngSpeed.y*0.1)),0)
		
		LastBoneAng = m:GetAngles()
		end
	end
	return pos, ang, fov
end
local ClientTime = 0
function SWEP:AimRecoil()
	ang = self.Owner:EyeAngles()
	ang.p = ang.p + (math.sin(CurTime()*3))*0.0005
	ang.y = ang.y + (math.sin(CurTime()*2))*0.001
	
	local HipShot = self.Owner:KeyDown(IN_ATTACK2) and 2 or 1

	if !Reloading and !DisableKick then
		ang.p = ang.p + Rscale*(FT*25)
		ang.y = ang.y + (Rscale)*RanDir*(FT*250)
	end

	self.Owner:SetEyeAngles(ang)	
end


function SWEP:SetAttachments() 
	if self.EjectBone then 
		self.ShellAttachment = VM:LookupBone("v_weapon."..self.EjectBone) 
	end
	self:CreateModels(self.VElements) // create viewmodels
	Set = false
	
	if self.Primary.Ammo == "ar2" then
		self.Shell = "models/shells/shell_762nato.mdl"
	elseif self.Primary.Ammo == "buckshot" then
		self.Shell = "models/shells/shell_12gauge.mdl"
	elseif self.fiveseven then
		self.Shell = "models/shells/shell_57.mdl"
	else
		self.Shell = "models/shells/shell_9mm.mdl"
	end
end

function SWEP:CreateModels( tab )
    if (!tab) or !vm then return end

    for k, v in pairs( tab ) do
        if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
                string.find(v.model, ".mdl") and file.Exists (v.model,"GAME") ) then

            v.modelEnt = ClientsideModel(v.model)
            if (IsValid(v.modelEnt)) then
                v.modelEnt:SetPos(vm:GetPos())
                v.modelEnt:SetAngles(vm:GetAngles())
                v.modelEnt:SetParent(VM)
				v.modelEnt:FrameAdvance(FT)
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

function SWEP:OnRemove()
    self:RemoveModels()     
end

SWEP.vRenderOrder = nil
function SWEP:UpdateStuff()
    if !IsValid(vm) then return end
	
    if (!self.VElements) then return end
     
    if vm.BuildBonePositions ~= self.BuildViewModelBones then
        vm.BuildBonePositions = self.BuildViewModelBones
    end

    if (self.ShowViewModel == nil or self.ShowViewModel) then
        vm:SetColor( Color(255,255,255,255) )
		vm:SetRenderMode( RENDERMODE_NORMAL )
    else
        vm:SetColor( Color(255,255,255,1) )
		vm:SetRenderMode( RENDERMODE_TRANSALPHA )
    end
     
    if (!self.vRenderOrder) then
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
            ang.r = -ang.r 
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
	
	if self.FireSelect == 1 then
    self.Primary.Automatic = self:GetNWBool( "FireMode", true )
	end
end

function SWEP:ShotgunReload()
	if !Reloading or !self.ShellReloadAnim then return end
	if self:Clip1() > self.LastClip and self.ShellReloadAnim then
		vm:SetCycle(cyc)
		vm:SetSequence(self.ShellReloadAnim)
		vm:SetPlaybackRate(1)
		Finished = false
		LastLoad = CurTime()
	elseif (self:Clip1() == self.Primary.ClipSize or self:Ammo1() ==0) and !Finished and CurTime() >= (LastLoad+0.3) then
		vm:SetCycle(cyc)
		vm:SetSequence(self.FinishReloadAnim)
		vm:SetPlaybackRate(1)	
		Finished = true
		Reloading = false
	end

end


function SWEP:IronsMan(Ent)
	local Front = Ent:LookupBone("Front")
	Ent:ManipulateBonePosition(  Front,  Vector(0,0,500) )
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

function SWEP:RunAnglePreset() --Preset run angles for rifles/pistols/retardedbackwardsmodeledbullshitbecausewhoevermodeledthecssweaponsisfuckingretardedandshoulddie.
	if self.RunAngleSet == "pistol" then
		self.RunArmAngle  = Angle( 8, 0, 0 )
		self.RunArmOffset = Vector( -5, 0, -13 )
	end
	if self.RunAngleSet == "smg" then
		self.RunArmAngle  = Angle( 2, 8, 0 )
		self.RunArmOffset = Vector( -5, 10, -10 )
	end
	if self.RunAngleSet == "rpg" then
		self.RunArmAngle  = Angle( -3, 3, 0 )
		self.RunArmOffset = Vector( 0, 0, -5 )
	end
	if !self.RunAngleSet then
		self.RunArmAngle  = Angle( 2, 8, 0 )
		self.RunArmOffset = Vector( -5, 10, -5 )
	end
end

local StrafeSway = 0
function SWEP:RunAnims()
	self:RunAnglePreset()
	local ang = VM:GetAngles()
	local Down = EA:Up()
	local Right = EA:Right() 
	local Forward = EA:Forward()
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	if Running or self.Owner:GetColor().a < 255 then
		AMul = LerpAngle(FT*2, AMul, self.RunArmAngle)
		VMul = LerpVector(FT*2,VMul, self.RunArmOffset)
		RunMul = Lerp(FT*10, RunMul, 1)
	else
		AMul = LerpAngle(FT*10, AMul, Angle(0,0,0))
		VMul = LerpVector(FT*10,VMul, Vector(0,0,0))
		RunMul = Lerp(FT*10, RunMul, 0)
	end

	local ADSMod = 1+Mul
	if self.Hacker then
		ADSMod = 1
	end
	
	local RPGFIX = self.RunAngleSet == "rpg" and -1 or 1
	
	veldepend.roll = math.Clamp((vel:DotProduct(EA:Right()) * 0.04) * len / self.Owner:GetWalkSpeed(), -5, 5)
	StrafeSway = StrafeSway + veldepend.roll
	StrafeSway = Lerp(FT*10, LastRollVel, veldepend.roll)
	local EASpeed = self.Owner:EyeAngles().y-LastEA
	local LEASpeed = Lerp(FT*10,EASpeed, 0)
	EA:RotateAroundAxis( Down,  self.RunArmAngle.yaw *AMul.yaw)
	EA:RotateAroundAxis( Forward,  self.RunArmAngle.roll*AMul.roll+(StrafeSway*ADSMod) ) 
	EA:RotateAroundAxis( Right, self.RunArmAngle.pitch*AMul.pitch*RPGFIX)
	EP = (EP + (EA:Forward()*VMul.z) + (EA:Up()*VMul.x) + (EA:Right()*VMul.y) )
	
	LastEA = self.RunArmAngle.yaw *AMul.yaw
	LastRollVel = self.RunArmAngle.roll*AMul.roll+StrafeSway
end

function SWEP:BoltMovement()
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	scale = Lerp(RealFrameTime() * 20, scale, 0)
	Rscale = Lerp(RealFrameTime() * 20, Rscale, 0)
	Rscale2 = Lerp(RealFrameTime() *9, Rscale2, 0)
	
	/*Bolt Movement*/
		if self.BoltBone then
			local VM = vm
			local Slide = VM:LookupBone("v_weapon."..self.BoltBone)
			
			local Cap = self.SlideLockPos and -1.5 or -3
			local Length = self.SlideLockPos and 0.14*self.Primary.Recoil or 0.06
			local Speed = self.SlideLockPos and 10 or 40
			Recoil = math.Clamp(Recoil + Speed*RealFrameTime(),Cap,0)
			if self.SlideLockPos and Slide then
				VM:ManipulateBonePosition(  Slide, self.SlideLockPos*-Recoil )
			elseif Slide then
				VM:ManipulateBonePosition(  Slide,  Vector(0,0,Recoil) )
			end
			
			if self:Clip1() == 0 and self.SlideLockPos then
				VM:ManipulateBonePosition(  Slide,  self.SlideLockPos )
			end
			
			if self.ResetBolt and Slide then
				VM:ManipulateBonePosition(  Slide,  Vector(0,0,0) )
			end	
		end
	/*Bolt Movement*/

	
	if self:Clip1()<self.LastClip and !Reloading and !self.Switched and self.FireOne  then
		Disable = self.Owner:KeyDown(IN_ATTACK2) and 1 or 0
		Recoil = self.SlideLockPos and -1.5 or -3
		Recoil = Recoil*Disable
		scale = self.Primary.Recoil*-10*Disable
		Rscale = self.Primary.Recoil*-10*Reduce
		Rscale2 = self.Primary.Recoil*-10*Reduce
		RandKick = math.Rand(-1,1)
		self:ShootEffects()
		if self.FOVM > 0.3 then
		vm:SetCycle(cyc)
		vm:SetSequence(self.ShootAnim)
		vm:SetPlaybackRate(1)
		end
		Reloading = false
	end
	self.LastClip = self:Clip1()
end
local WalkTimer = 0
local Frames = 0
function SWEP:SwayCalc()
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	local ADSMod = self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !Running and !self.Hacker and 0.1 or 1
	
	if self.Owner:IsOnGround() then
		GMul = Lerp( FT * 10, GMul, 1 ) else
		GMul = Lerp( FT * 10, GMul, 0 )
	end
	if Running then 
		Speed = Lerp( FT * 10, Speed, 2 ) else
		Speed = Lerp( FT * 10, Speed, 1 )
	end
	
	WalkTimer = WalkTimer + self.Owner:GetVelocity():Length()*(FT*0.01)*Speed
	WalkTimer = Lerp(FT*10, WalkTimer,0)
	Frames = RealTime()
	if self.Scanner then
		Mul = 0
	end
				---------------------Walking Bob-----------------------					--------Not Moving Bob/Breathing--------
	EP = EP + ((EA:Right() * math.sin((Frames*15)/2)*(Speed*Speed)*WalkTimer)*ADSMod)*GMul + ((EA:Right()*math.sin(Frames*2))*0.05)*(Mul+1)
	EP = EP + ((EA:Up() * math.sin((Frames*15))*WalkTimer)*ADSMod)*GMul		 + ((EA:Up()*math.sin(Frames*3))*0.05)*(Mul+1)
	--Extra Wiggle
	EA:RotateAroundAxis( EA:Forward(),  ((math.sin((Frames*15))*WalkTimer)*ADSMod)*GMul*5 )
end
local Spin = 0
function SWEP:BaseMarkerDetect()
	self.Marker = false
	for _, x in ipairs(ents.FindByClass("sent_basemarker")) do
		if x:GetPos():Distance(LocalPlayer():GetPos()) <500 then
			self.Marker = true
		end
	end
end

function SWEP:CircleMath( ang, radius, offX, offY )
	ang =  math.rad( ang+Spin )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

local centerX, centerY = 200, 500
local PetalSize = 30
local Rotate = 0
local LastRemove = 0
local Randy = 0
function SWEP:DrawHackBlossom(v,bloom)
if Mul > -0.9999 then return end
	v.BounceTimer = v.BounceTimer + FT*2
	v.radius = bloom+(math.sin(v.BounceTimer))*(15)
	Rotate = Rotate + 0.1
	local ConeVis = 11
	for degrees = 1, 360, v.interval do --Start at 1, go to 360, and skip forward at even intervals.
		local x, y = self:CircleMath( degrees, v.radius, 
		((v:GetPos():ToScreen().x*(Mul*-1)))-ScrW()*(Mul+1), 
		((v:GetPos():ToScreen().y*(Mul*-1)))-ScrH()*(Mul+1) )
		
		surface.SetDrawColor(0, 0, 0, bloom*-Mul)	
		surface.SetTexture(surface.GetTextureID("vgui/hud/autoaim"))
		surface.DrawTexturedRectRotated(x,y, PetalSize+((ScrW()*3)*(Mul+1)), PetalSize+((ScrH()*3)*(Mul+1)),Rotate)

		local OnTarget = x >= ScrW()/2-ConeVis and x <= ScrW()/2+ConeVis and y >= ScrH()/2-ConeVis and y <= ScrH()/2+ConeVis
		
		if self.Owner:KeyPressed(IN_ATTACK) then
			if Mul < -0.9999 and OnTarget and self:Clip1() > 0 then
				Hit = true
				if !table.HasValue(v.petalid,tostring(degrees)) then
					table.insert(v.petalid, tostring(degrees))
				end
			end
		end

		if table.HasValue(v.petalid,tostring(degrees)) then
			surface.DrawTexturedRectRotated(x,y, PetalSize+((ScrW()*3)*(Mul+1))-10, PetalSize+((ScrH()*3)*(Mul+1))-10,0)
		end
			if table.Count(v.petalid) == v.Petals then
			v.petalid = {}
			v.Petals = v.Petals + 1
			v.interval = 360 / v.Petals
			v.Level = v.Level -1
			if v.Level > 0 then
				--surface.PlaySound("buttons/combine_button1.wav")
				sound.Play( "buttons/combine_button1.wav", v:GetPos(), 75, 150, 1 )
			else
				--surface.PlaySound("buttons/button24.wav")
				sound.Play( "buttons/button24.wav", v:GetPos(), 75, 100, 1 )
				net.Start("ActivateDoor")
				net.WriteEntity( v )
				net.SendToServer()
			end
		end
	end
end
local DMScreenPos = {}
local DrawLine = 1
function SWEP:Hacking()
	local ConeVis = 100 --Size of the cone that can see/activate door modules.
	for _, v in ipairs(ents.FindInSphere(self.Owner:EyePos(),500)) do
		if v:GetClass() == "sent_doormod" then
			local AddPetals = self.Marker and 1 or 0
			--Set up device tables.
			if !v.BounceTimer then v.BounceTimer = 0 end
			if !v.Bulge then v.Bulge = 0 end
			if !v.petalid then v.petalid = {} end
			if !v.Petals or v.Level == 3 then 
				v.Petals = 6 + AddPetals
				v.interval = 360 / v.Petals
				v.Level = 3
			end

			if v.Level >0 and Mul < -0.9999 and v:GetPos():ToScreen().x >= ScrW()/2-ConeVis and v:GetPos():ToScreen().x <= ScrW()/2+ConeVis and
				v:GetPos():ToScreen().y >= ScrH()/2-ConeVis and v:GetPos():ToScreen().y <= ScrH()/2+ConeVis and self.Owner:EyePos():Distance(v:GetPos()) <= 30 then
				surface.SetDrawColor(255, 150, 0, 150*-Mul)
				v.Bulge = Lerp(FT*20, v.Bulge, 50)
				if v.Bulge < 45 and v.Bulge > 5 then
					DrawLine = 0
					sound.Play( "npc/turret_floor/deploy.wav", v:GetPos(), 50, 155, 0.5 )
				end
				if CurTime() > LastRemove and table.Count(v.petalid) > 0 then 
					table.remove(v.petalid, math.random(1,table.Count(v.petalid)) )
					LastRemove = CurTime() + 2
					sound.Play( "buttons/button16.wav", v:GetPos(), 50, 150, 1 )
					if !v.petalid and v.Level <3 then
						v.Petals = v.Petals - 1
					end
				end
				else
					surface.SetDrawColor(255, 255, 255, 150*-Mul)
					v.Bulge = Lerp(FT*20, v.Bulge, 0)
					v.petalid ={}
					
					v.Level = 3
				if v.Bulge < 45 and v.Bulge > 5 then
					sound.Play( "npc/turret_floor/retract.wav", v:GetPos(), 75, 155, 0.5 )
					DrawLine = 1
				end
			end

			surface.SetTexture(surface.GetTextureID("vgui/hud/xbox_reticle"))
			surface.DrawTexturedRect(((v:GetPos():ToScreen().x*(Mul*-1))-25)-ScrW()*(Mul+1)-v.Bulge/2,((v:GetPos():ToScreen().y*(Mul*-1))-25)-ScrH()*(Mul+1)-v.Bulge/2, v.Bulge+50+((ScrW()*3)*(Mul+1)), v.Bulge+50+((ScrH()*3)*(Mul+1)))
			self:DrawHackBlossom(v,v.Bulge)
			
			DMPos = v
			if !table.HasValue(DMScreenPos, DMPos) then
				table.insert(DMScreenPos, DMPos)
			end
		end
		if v:GetClass() == "sent_basemarker" then
			for k,x in pairs(DMScreenPos) do
			if !IsValid(x) then
			table.RemoveByValue(DMScreenPos,x)
			return end
			if !x.ScrPosX then x.ScrPosX, x.ScrPosY = 0,0 end
				if v:GetPlayerOwner() == x:GetOwner() or v:GetPlayerOwner():Team() == x:GetOwner():Team() and x:GetOwner():Team() != 50 then
					local pos = v:GetPos()+(v:GetUp()*30)
					surface.SetDrawColor(255, 255*DrawLine, 255*DrawLine, 50*-Mul)
					x.ScrPos = Vector(x:GetPos():ToScreen().x, x:GetPos():ToScreen().y, 0 )
					if self.Owner:KeyDown(IN_ATTACK2) then
						x.ScrPosX = Lerp( FT*(20*-Mul), x.ScrPosX, x.ScrPos.x )
						x.ScrPosY = Lerp( FT*(20*-Mul), x.ScrPosY, x.ScrPos.y )
					else
						x.ScrPosX = Lerp( FT*(20*-Mul), x.ScrPosX, pos:ToScreen().x )
						x.ScrPosY = Lerp( FT*(20*-Mul), x.ScrPosY, pos:ToScreen().y  )
					end
					surface.DrawLine( pos:ToScreen().x, pos:ToScreen().y, x.ScrPosX, x.ScrPosY )
					x.Speed = 55
					Spin = Spin +(FT*x.Speed)
					surface.SetDrawColor(255, 150*DrawLine, 0*DrawLine, 200*-Mul)
					surface.SetTexture(surface.GetTextureID("vgui/hud/xbox_reticle"))
					surface.DrawTexturedRectRotated(((pos:ToScreen().x*(Mul*-1))),((pos:ToScreen().y*(Mul*-1))), 100+((ScrW()*6)*(Mul+1)), 100+((ScrH()*6)*(Mul+1)),-Rotate*5*(DrawLine-1))
					surface.DrawTexturedRectRotated(((pos:ToScreen().x*(Mul*-1))),((pos:ToScreen().y*(Mul*-1))), 50+((ScrW()*6)*(Mul+1)), 50+((ScrH()*6)*(Mul+1)),Rotate*5*(DrawLine-1))
				end
			end
		end
	end
end

SWEP.Object = nil
SWEP.Target = {}
SWEP.Connected = false
function SWEP:DrawHUD()
	if self.Hacker then
	self:Hacking()
	end	
	self:BaseMarkerDetect()
	if self.VElements and self.VElements.scope then

			if self.Owner:KeyDown(IN_ATTACK2) !=self.LastIron then
				self.LastIron = self.bInIronSight
				self.IronTime = CurTime()
			end

		if self.VElements.scope and !self.Acog and !self.AugRet then
			-- Draw the crosshair
			surface.SetDrawColor(0,0,0,255*-Mul+1)
			surface.DrawRect(0,ScrH()*0.5,ScrW(),1)
			surface.DrawRect(ScrW()*0.5,0,1,ScrH())

			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
			--end
		end
		
		if self.UseScope and self.AugRet then
			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())
			
			surface.SetDrawColor(255, 255, 255, 255*-Mul+1)
			surface.SetTexture(surface.GetTextureID("scope/augret"))
			surface.DrawTexturedRect(ScrW()*0.5-16, ScrH()*0.5-16, 32, 32)

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
			--end
		end
				
		if self.UseScope and self.Acog then
			-- Draw the crosshair
			surface.SetDrawColor(200, 0, 0, 255*-Mul+1)
			surface.DrawRect(ScrW()*0.5-1,ScrH()*0.5+10, 2,10)
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
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
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())
			
			surface.SetDrawColor(200, 0, 0, 255*-Mul+1)
			surface.SetTexture(surface.GetTextureID("scope/acog_reticle"))
			surface.DrawTexturedRect(ScrW()*0.5-8, ScrH()*0.5-8, 16, 16)

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
		end
	end
		
	if !self.RDot then 
		local params = {
		["$basetexture"] = "sprites/glow1",
		["$additive"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		}
		local params2 = {
		["$basetexture"] = "sprites/glow07",
		["$additive"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		}
		self.RDot = CreateMaterial("RedDot6","UnlitGeneric",params)
		self.RDot2 = CreateMaterial("RedDot7","UnlitGeneric",params2)
	end
	
	local x = (ScrW() / 2.0) + 1
	local y = (ScrH() / 2.0) + 1
	local ZF = 1
	local MD = scale*2*ZF
	local Pistol = self.RunAngleSet == "pistol" and 1 or 0
	if self.VElements and self.VElements.rds and self.RDDraw or self.RunAngleSet == "rpg" and self.RDDraw and !self.Hacker then
		if !self.DotVis and AMul.p < 0.08 or self.DotVis and scale > self.DotVis*0.03 and AMul.p < 0.05 then
			surface.SetDrawColor(math.Rand(200,255),150,150,255)
			surface.SetMaterial(self.RDot2)
			surface.DrawTexturedRect( x-(16)/2, y-(16)/2+(scale*300*Pistol), 16, 16)
		end
	end
	
	if self.Hacker then
	surface.SetDrawColor(255,255,255,50)
	surface.SetTexture(surface.GetTextureID("sprites/hud/v_crosshair1"))
	surface.DrawTexturedRectRotated( x, y, 32, 32, 0)
	end
	
	if self.RunAngleSet == "rpg" and !self.Hacker then
		-- Put the texture
		surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
		surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
		local Size = surface.GetTextureSize(surface.GetTextureID("scope/scope_normal"))
		surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()/2)*0.5,ScrH()*0.25, ScrH()/2, ScrH()/2)

		-- Fill in everything else
		surface.SetDrawColor(0, 0, 0, 255*-Mul+1)
		surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()/2)*0.5, ScrH())
		surface.DrawRect(((ScrW()*0.5)-(ScrH()/2)*0.5)+ScrH()/2,0, ScrW(), ScrH())
		surface.DrawRect(((ScrW()*0.5)-(ScrH()/2)*0.5),ScrH()/2+ScrH()/4, ScrH()/2, ScrH())
		surface.DrawRect(((ScrW()*0.5)-(ScrH()/2)*0.5),0, ScrH()/2, ScrH()/4)
	end
		if EDIT then
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,ScrH()*0.5,ScrW(),1)
		surface.DrawRect(ScrW()*0.5,0,1,ScrH())
	end
	--[[if self.EjectPos then --Eject Position helper.
		render.SetMaterial( Material( "color" ) )
		local wat = (vm:GetPos()+vm:GetAngles():Right()*self.EjectPos.x+vm:GetAngles():Up()*self.EjectPos.y+vm:GetAngles():Forward()*self.EjectPos.z):ToScreen()
		surface.SetDrawColor(255, 255, 255,255)
		surface.SetTexture(surface.GetTextureID("vgui/hud/autoaim"))
		surface.DrawTexturedRect(wat.x, wat.y, 50, 50 )
	end]]
end

