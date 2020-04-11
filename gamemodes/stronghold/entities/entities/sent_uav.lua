AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable	= true
ENT.PrintName	= "Drone"
ENT.ClassName	= "Drone"
ENT.Dissolving 	= false
ENT.RSpeed = 0

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/stronghold/drone.mdl" ) 
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetName("Drone")
		
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableDrag( true )
			phys:EnableGravity( true )
			phys:SetMass( 10 )
			phys:Wake()
		end
	end
		self:SetHealth( 100 )
	
	self.MuzzleBone = self:LookupBone("Muzzle")

	--Logic
	self.m_bStart 				= false
	self.m_bStarted				= false
	self.m_bAfterBurning		= false
	self.m_bCrashed				= false
	self.m_intFuel				= 100
	self.m_intFuelUsageRate 	= 0.25 --per second
	self.m_intStartTime			= 0.5 --seconds to last in the start sequence
	self.m_intHealth 			= 100
	self.m_intThrust 			= 300
	self.m_intThrustAfterBurner = 500
	self.m_intThrustDelta		= 6 --seconds
	self.m_intCurThrust			= self.m_intThrust
	
	self.LastAng 				= 0
	self.LastAng2 				= 0
	self.Ang 					= 0
	self.lastbul				= 0
	self.Ammo 					= 100
	self:SetNWFloat("NetAmmo", self.Ammo)
	self:SetNWFloat("NetFuel", self.m_intFuel)

	--Sounds
	self.m_tSnds			= { Playing = {} }
	self.m_csndStartup 		= CreateSound( self, "stronghold/uav/uav_start.wav" )
	self.m_csndRun 			= CreateSound( self, "stronghold/uav/uav_jet.wav" )
	self.m_csndAfterBurn	= CreateSound( self, "stronghold/uav/uav_burner.wav" )
	self.m_csndShutdown		= CreateSound( self, "stronghold/uav/uav_shutdown.wav" )
	
	self.m_csndStartup:SetSoundLevel( 95 )
	self.m_csndRun:SetSoundLevel( 95 )
	self.m_csndAfterBurn:SetSoundLevel( 95 )
	
	self.m_intSndStartLen	= 16.88
	self.DopplerPitch	= 100
	if CLIENT then
		self.AmbientSound = CreateSound( self, Sound( "stronghold/uav/uav_AB.wav" ) )
		self.AmbientSound:Play()
	end
end

function ENT:SetPlayer( pPlayer )
	self.m_pPlayer = pPlayer
	pPlayer:AddFlags( "128" )
	if SERVER then
		self:SetNWEntity( "player", self.m_pPlayer )
	end
end

function ENT:GetPlayer()
	return SERVER and self.m_pPlayer or self:GetNWEntity( "player" )
end

function ENT:Drive( pPlayer )
	self:SetPlayer( pPlayer )
	--self.startpoint = pPlayer:GetPos()+pPlayer:GetAngles():Up() * 200
	
	pPlayer:SetNWEntity( "drone", self )
	self.m_bStart = true
end

function ENT:StopDriving()
	self:StopSounds()
	self:GetPlayer():SetNWEntity( "drone", NULL )
	self:SetNWBool( "started", false )
	self:SetNWEntity( "player", NULL )
	self:SetPlayer( nil )
	self.m_bStart = false
	self.m_bStarted = false
end

-- Sounds
function ENT:ComputeSounds()
	self.AmbientSound:ChangePitch(self.DopplerPitch,0)
end

local LastDistance = 0
function ENT:AdjustSoundPitch()
	local DronePos = self:GetPos()
	local PlyPos = LocalPlayer():GetPos()
	local Distance = DronePos:Distance(PlyPos)
	self.RSpeed = Distance - LastDistance
	self.RSpeed = self.RSpeed * 10
	self.DopplerPitch = 180 - self.RSpeed
	
	LastDistance = Distance
end

function ENT:StopSounds()
	self.m_csndStartup:Stop()
	self.m_csndRun:Stop()
	self.m_csndAfterBurn:Stop()
end

-- User input
function ENT:ThinkKeys()
	if not self.m_bStarted then return end
	
	--Check for afterburner
	if self.m_bAfterBurning ~= self.m_pPlayer:KeyDown( IN_SPEED ) then
		self.m_bAfterBurning = self.m_pPlayer:KeyDown( IN_SPEED )
		self:SetNWBool( "afterburner", self.m_bAfterBurning )

		if not self.m_bAfterBurning and self.m_intBurnTimer then
			self.m_intBurnTimer = nil
		end
	end
end

function ENT:ThinkFlightLogic()
	if not self.m_bStart then return end
	
	--Startup logic
	if not self.m_bStarted then
		if not self.m_intStartBegin then
			self.m_intStartBegin = CurTime() +self.m_intStartTime
		end

		if CurTime() > self.m_intStartBegin then
			self.m_bStarted = true
			self.m_intStartBegin = nil
			self:SetNWBool( "started", true )
			self:GetPhysicsObject():Wake()
		else
			return
		end
	end

	--Fuel logic
	if not self.m_intLastFuelCalc then
		self.m_intLastFuelCalc = CurTime() +1
	end

	if CurTime() > self.m_intLastFuelCalc then
		self.m_intFuel = self.m_intFuel -self.m_intFuelUsageRate
		self.m_intLastFuelCalc = CurTime() +1
		self:SetNWFloat("NetFuel", self.m_intFuel)

		if self.m_intFuel <= 0 then
			self.m_bCrashed = true
			timer.Simple( 3.5, function() if IsValid( self ) then self:StopDriving() end end)
			self:GetPhysicsObject():EnableDrag( false )
			self:GetPhysicsObject():EnableGravity( true )
			self:GetPhysicsObject():SetMass( 10 )
			self:SetNWBool( "started", false )
			self:SetNWBool( "crashed", true )
		end
	end

	--extra thrust from afterburner
	if self.m_bAfterBurning and self.m_intCurThrust ~= self.m_intThrustAfterBurner then
		if not self.m_intBurnTimer then
			self.m_intBurnTimer = CurTime()
			self.m_intBurnEndTimer = nil
		end

		local scaler = math.Clamp( (CurTime() -self.m_intBurnTimer) /self.m_intThrustDelta, 0, 1 )
		self.m_intCurThrust = Lerp( scaler, self.m_intCurThrust, self.m_intThrustAfterBurner )
	elseif not self.m_bAfterBurning and self.m_intCurThrust ~= self.m_intThrust then
		if not self.m_intBurnEndTimer then
			self.m_intBurnEndTimer = CurTime()
			self.m_intBurnTimer = nil
		end
		
		local scaler = (CurTime() -self.m_intBurnEndTimer) /self.m_intBurnEndTimer *(self.m_intThrustDelta *self.m_intThrustDelta)
		self.m_intCurThrust = Lerp( scaler, self.m_intCurThrust, self.m_intThrust )		
	end
end

function ENT:PhysicsUpdate( phys )
	
	if not self:GetNWBool( "started" ) then 
	--self:SetPos(self:GetPlayer():EyePos())
	--self:SetAngles(self:GetPlayer():GetAimVector():Angle())
	return end
	
	local pl, vel, ang = self:GetPlayer(), phys:GetVelocity(), self:GetAngles()
	vel = ang:Forward() *self.m_intCurThrust
	Drag = self.m_bAfterBurning and 0.5 or 1
	
	if not IsValid( pl ) then return end
	
	if pl:EyeAngles().y <= 0 then Fixit  = -1 else Fixit  = 1 end
	if pl:EyeAngles().x <= 0 then Fixit2 = -1 else Fixit2 = 1 end
	
	local roll 		= pl:KeyDown( IN_MOVELEFT ) and -25 or pl:KeyDown( IN_MOVERIGHT ) and 25 or 0
	local pitchmod  = pl:KeyDown( IN_FORWARD )  and 6   or pl:KeyDown( IN_BACK )      and -6 or 0
	
	local pitch = math.Clamp(((((pl:EyeAngles().x * Fixit2) - self.LastAng2 ) * Fixit2) * 4)+pitchmod, -6 , 6)
	local yaw   = math.Clamp( (((pl:EyeAngles().y * Fixit ) - self.LastAng  ) * Fixit )	* 2			  , -6 , 6)

	phys:AddAngleVelocity( Vector(roll*Drag, pitch*Drag, yaw*Drag ))
	self.LastAng = pl:EyeAngles().y*Fixit
	self.LastAng2 = pl:EyeAngles().x*Fixit2
	phys:SetVelocity( vel )
	phys:SetDamping( 0, 5 )
	
	if self:GetPos():Distance(self.m_pPlayer:EyePos()) < 50 then
	self.m_pPlayer:GiveAmmo(1,"grenade",true)
	self:Remove()
	end
	
	self:GunThink()
end

function ENT:Draw()
	self:DrawModel()
	
	self:EngineEffects()
	
end

function ENT:EngineEffects()
	--if !CLIENT then return end
	
	local LEPos, LEAng = self:GetBonePosition(self:LookupBone("LeftEngine"))
	local REPos, REAng = self:GetBonePosition(self:LookupBone("RightEngine"))

	// setup our variables
	local vOffset1, vOffset2 = LEPos-LEAng:Forward()*14+LEAng:Up()*1+LEAng:Right()*2.55, REPos-LEAng:Forward()*15+LEAng:Up()*-1+LEAng:Right()*2.55
	local vNormal1, vNormal2 = LEAng:Forward(), REAng:Forward()
	
	local vPoint = vOffset1
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	effectdata:SetNormal(self:GetForward())
	effectdata:SetAngles(self:GetAngles())
	effectdata:SetScale(1)
	util.Effect( "Engine", effectdata )
	
	if self:Health() <= 50 then
		local R = math.random(0,50)
		local R2 = math.random(0,1)
		if R2 == 1 and R > self:Health() then
			util.Effect( "enginedamage", effectdata )
		end
	end
end

function ENT:ThinkAnims()
	if self.m_bAnimDone then
		self:SetCycle( 1 )
	end

	if not self:GetNWBool( "started" ) then return end
	if not self.m_intAnimStartTime then
		self:SetSequence( self:LookupSequence("deploy") )
		self.m_intAnimStartTime = CurTime()
	end

	if not self.m_bAnimDone then
		local animtime = self:SequenceDuration( self:LookupSequence("deploy") )
		local scaler = math.Clamp( (CurTime() -self.m_intAnimStartTime) /animtime, 0, 1 )

		self:SetCycle( scaler )

		if scaler == 1 then
			self.m_bAnimDone = true
		end
	end
end

function ENT:Think()
	if CLIENT then
		self:ComputeSounds()
		self:AdjustSoundPitch()
	elseif SERVER then
		self:ThinkKeys()
		self:ThinkFlightLogic()
		if !IsValid(self.m_pPlayer) or !self.m_pPlayer:Alive() then
			self:Dissolve()
			self.Dissolving = true
		end
	end
	
	self:ThinkAnims()
	self:NextThink(0)

end

function ENT:GunThink()
	local delay = 0.1
	local spread = 0.005
	if self:GetNWBool( "crashed" ) then return end
	local MuzzlePos, MuzzleAng = self:GetPos(),self:GetAngles()
	local MuzzleVector = self:GetAngles():Forward()
	local bulletInfo = {}
	bulletInfo.Src 	= MuzzlePos -- Source
	bulletInfo.Dir 	= MuzzleVector -- Dir of bullet
	bulletInfo.Spread 	= Vector( spread, spread, 0 )	 -- Aim Cone
	bulletInfo.Tracer	= 1 -- Show a tracer on every x bullets 
	bulletInfo.Force	= 1 -- Amount of force to give to phys objects
	bulletInfo.Damage	= 33
	bulletInfo.AmmoType = "Pistol"
	bulletInfo.Attacker = self:GetPlayer()

	if self:GetPlayer():KeyDown( IN_ATTACK ) and self.lastbul <= CurTime()-delay and self.Ammo >= 1 then
		self:FireBullets(bulletInfo)
		self.Ammo = self.Ammo - 1
		self:SetNWFloat("NetAmmo", self.Ammo)
		sound.Play( "NPC_FloorTurret.Shoot", self:GetPos(), 100, 100 )
		self.lastbul = CurTime()
		
		local vPoint = self:GetPos()+self:GetForward()*20+self:GetUp()*-2
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		effectdata:SetNormal(self:GetForward())
		effectdata:SetAngles(self:GetAngles())
		effectdata:SetStart(self:GetPos())
		effectdata:SetScale(1)
		util.Effect( "MuzzleEffect", effectdata )
		
		local vPoint = self:GetPos()+self:GetUp()*-5
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		effectdata:SetNormal(self:GetUp())
		effectdata:SetAngles(self:GetAngles()+Angle(90,0,0))
		effectdata:SetStart(self:GetPos())
		util.Effect( "EjectBrass_9mm", effectdata )
		
	elseif self:GetPlayer():KeyDown( IN_ATTACK ) and self.lastbul <= CurTime()-delay and self.Ammo == 0 then
		sound.Play( "weapons/pistol/pistol_empty.wav", self:GetPos(), 100, 50 ) 
		self.lastbul = CurTime()
	end
end

function ENT:DoDamage( dmginfo )
	self:SetHealth(self:Health() - (dmginfo:GetDamage()*4))
	if self:Health() <= 0 then
		local vPoint = self:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		if self.Dissolving then return end
		util.Effect( "Explosion", effectdata )
		self:Remove()
	end
end

function ENT:OnRemove()
	self:StopSounds()
	if IsValid(self.m_pPlayer) then
		self.m_pPlayer:RemoveFlags("128")
	end
	if self.AmbientSound then
		self.AmbientSound:Stop()
	end
end

function ENT:PhysicsCollide( data, phys )
	local tr = util.TraceLine( {
	start = self:GetPos() -(data.HitNormal *16),
	endpos = self:GetPos() +(data.HitNormal *1024),
	filter = function( ent ) if ( ent:GetClass() == "sent_uav" ) then return false end end
	} )
	
	local hardbang = data.OurOldVelocity:Length()-100 > self:GetVelocity():Length()
	if hardbang and tr.HitTexture != "TOOLS/TOOLSINVISIBLE" and !tr.HitSky then
		self:TakeDamage(self:GetVelocity():Length()*0.1)
	end
	
	if data.HitEntity == self.m_pPlayer then 
	self.m_pPlayer:GiveAmmo(1,"grenade",true)
	self:Remove()
	
	end
end
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if SERVER then
	--[[concommand.Add( "testdrive", function(pl)
		if pl.IsDriving then
			pl.IsDriving = false

			if IsValid( pl.UAV ) then
				pl.UAV:StopDriving()
				pl.UAV:Remove()
				pl.UAV = nil
			else
			
			end
		else
			pl.IsDriving = true

			pl.UAV = ents.Create "sent_uav"
			--pl.UAV:SetPos( pl:GetPos() +(pl:GetAngles():Forward() *64) )
			pl.UAV:Spawn()
			pl.UAV:Activate()
			pl.UAV:Drive( pl )
		end
	end )]]

	hook.Add( "SetupPlayerVisibility", "drone", function( pPlayer )
		if pPlayer.IsDriving and IsValid( pPlayer.UAV ) then
			AddOriginToPVS( pPlayer.UAV:GetPos() )
		end
	end  )

	hook.Add( "EntityTakeDamage", "drone", function( target, damage )
		if target:GetClass() ~= "sent_uav" then return end
		target:DoDamage( damage )
	end )
else

	hook.Add( "ShouldDrawLocalPlayer", "showply", function(pPlayer)
	if not IsValid( pPlayer:GetNWEntity("drone") ) then return false end
	if pPlayer:KeyDown( IN_JUMP ) then return false end	
	return true end)
	
	local lastFrame, lastPos = Angle(0, 0, 0), Vector(0)
	hook.Add( "CalcView", "dronestuff", function( pPlayer, vecPos, angAng, intFOV, intNearZ, intFarZ )
		
		if not IsValid( pPlayer:GetNWEntity("drone") ) then 
		lastFrame = pPlayer:EyeAngles() 
		lastPos = pPlayer:EyePos() 
		return end
		
		if pPlayer:KeyDown( IN_JUMP ) then return end
		
		local view, ent = {}, pPlayer:GetNWEntity("drone")
		view.origin = ent:GetPos() +(ent:GetAngles():Forward() *-50) +(ent:GetAngles():Up() *16)
		view.angles = LerpAngle( FrameTime() *10, lastFrame, ent:GetAngles() )
		view.origin = LerpVector( FrameTime() *10, lastPos, view.origin )
		view.fov = fov

		lastFrame = view.angles
		lastPos = view.origin

		return view
	end )

	hook.Add( "HUDPaint", "asdf", function()
		if not IsValid( LocalPlayer():GetNWEntity("drone") ) then return end
		local ply = LocalPlayer()
		local self = LocalPlayer():GetNWEntity("drone") 
		local tracestart = self:LocalToWorld( self:OBBCenter() )
		local endpos = tracestart + (self:GetForward() * 12000)
		local tracedata = {}
		tracedata.start	= tracestart
		tracedata.endpos 	= endpos
		tracedata.filter	= { self }
		

		local XHairCD = 5 
		local XHairLength = XHairCD + 25
		local XHairOpacity = 100
		
		local traceres 		= util.TraceLine( tracedata )
		
		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect((ScrW()*0.5)-40, (ScrH()*0.5)-20,80,40)

		local hit = traceres.HitPos
		if hit then
			local Ret = hit:ToScreen()
			surface.SetDrawColor( 255, 255, 255, XHairOpacity)
			surface.DrawLine( Ret.x +XHairCD, Ret.y , Ret.x + XHairLength, Ret.y  )
			surface.DrawLine( Ret.x , Ret.y +XHairCD , Ret.x , Ret.y + XHairLength*0.5 )
			surface.DrawLine( Ret.x -XHairCD, Ret.y , Ret.x - XHairLength, Ret.y  )
			surface.DrawLine( Ret.x , Ret.y -XHairCD , Ret.x , Ret.y - XHairLength*0.5 )
			surface.DrawLine( Ret.x , Ret.y -XHairCD , Ret.x , Ret.y - XHairLength*0.5 )
			
			surface.SetDrawColor( 255, 255, 255, XHairOpacity)
			surface.DrawLine( Ret.x +XHairCD, Ret.y , Ret.x + XHairLength, Ret.y  )
			surface.DrawLine( Ret.x , Ret.y +XHairCD , Ret.x , Ret.y + XHairLength*0.5 )
			surface.DrawLine( Ret.x -XHairCD, Ret.y , Ret.x - XHairLength, Ret.y  )
			surface.DrawLine( Ret.x , Ret.y -XHairCD , Ret.x , Ret.y - XHairLength*0.5 )
			surface.DrawLine( Ret.x , Ret.y -XHairCD , Ret.x , Ret.y - XHairLength*0.5 )
		end
		
		--Ammo Bar
		local ABH, ABW = ScrH()*0.9, ScrW()*0.94
		local ATH, ATW = ScrH()*0.89, ScrW()*0.94
		
		local getAmmo = self:GetNWFloat("NetAmmo",0)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect((ABW)+1-getAmmo, (ABH)-19,getAmmo,10)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect((ScrW(ABW)*0.94)-getAmmo, (ABH)-20,getAmmo,10)
		
		surface.SetFont( "Default" )
		surface.SetTextColor(0,0,0,255)
		surface.SetTextPos( (ATW)-34, (ATH)-21 )
		surface.DrawText("Ammo")
		
		surface.SetFont( "Default" )
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos( (ATW)-35, (ATH)-22 )
		surface.DrawText("Ammo")
		------------------------------------------------------
		--Fuel Bar
		local FBH, FBW = ScrH()*0.89, ScrW()*0.94
		local FTH, FTW = ScrH()*0.88, ScrW()*0.945
		
		local getFuel = self:GetNWFloat("NetFuel",0)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect((FBW)+1-getFuel, (FBH)-19*2-1,getFuel,10)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect((FBW)-getFuel, (FBH)-20*2,getFuel,10)
		
		surface.SetFont( "Default" )
		surface.SetTextColor(0,0,0,255)
		surface.SetTextPos( (FTW)-34, (FTH)-21*2 )
		surface.DrawText("Fuel")
		
		surface.SetFont( "Default" )
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos( (FTW)-35, (FTH)-22*2+1 )
		surface.DrawText("Fuel")
		-------------------------------------------------------
		if ply:EyeAngles().x == 89 then
			ply:SetEyeAngles(Angle(-89,ply:EyeAngles().y,ply:EyeAngles().z)) 
		elseif ply:EyeAngles().x == -89 then 
			ply:SetEyeAngles(Angle(89,ply:EyeAngles().y,ply:EyeAngles().z))
		end 
		
	end )
end
