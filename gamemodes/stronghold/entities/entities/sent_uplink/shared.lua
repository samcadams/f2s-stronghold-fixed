--[[
	File: shared.lua
	For: FTS: Stronghold
	By: Ultra
]]--

ENT.Type 					= "anim"
ENT.Base 					= "base_gmodentity"
ENT.PrintName				= "Uplink"
ENT.Author					= "Ultra/RoaringCow"
ENT.AutomaticFrameAdvance 	= true 
ENT.m_iLastPos				= Vector( 0, 0, 0 )

AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create( "sent_uplink" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	
	return ent
end

function ENT:Initialize()
	if SERVER then
		self.m_cTerminal = g_UplinkTerm:New()
		self.m_cTerminal:SetUplinkEntity( self )
		self:SetUseType( SIMPLE_USE )
		self:CallOnRemove( "endtermsessions", function( eEnt )
			self.m_cTerminal:DropAllPlayers()
		end )
	end

	self.m_fOldSetPos 	= self.SetPos
	self.m_angCurrent 	= Angle( 0, 0, 0 )
	self.m_iDeposit		= 0
	self.m_iCurFunds 	= 0
	self.m_bRunning		= false
	self.m_iMode		= 0 --0/1
	self.Created 		= CurTime()

	self:SetModel( "models/uplink/uplink.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 15 )
	end
end

function ENT:Open()
	self.m_bOpen = true
	self:ResetSequence( self:LookupSequence("open") )
	timer.Simple( 2.5, function() self.m_bInputEnabled = true end )
end

function ENT:Close()
	self.m_bOpen = false
end

function ENT:SetPos( vec )
	self.m_fOldSetPos( vec )
	self.m_iLastPos = vec
end

function ENT:Use( eEnt )
	if not self.m_bInputEnabled then return end
	if not IsValid( eEnt ) or not eEnt:IsPlayer() then return end
	
	if SERVER then
		self.m_cTerminal:AddPlayer( eEnt )
	end
end

function ENT:Deposit( intAmount )
	self.m_iDeposit = self.m_iDeposit +intAmount
end

function ENT:GetDeposit()
	return self.m_iDeposit
end

function ENT:Withdrawal( intAmount )
	if intAmount > self.m_iCurFunds then return end
	if intAmount <= 0 then return end
	
	self.m_iCurFunds = self.m_iCurFunds -intAmount

	return intAmount
end

function ENT:SetRunning( bRun )
	self.m_bRunning = bRun
end

function ENT:Running()
	return self.m_bRunning
end

function ENT:SetMode( intMode )
	self.m_iMode = intMode
end

function ENT:GetMode()
	return self.m_iMode
end

function ENT:SetDishAngle( angTarget )
	self.m_angCurrent = angTarget
	self:ManipulateBoneAngles( 1, Angle(0, 0, self.m_angCurrent.r) )
	self:ManipulateBoneAngles( 4, Angle(0, self.m_angCurrent.y, 0) )
end

function ENT:GetDishAngle()
	return self.m_angCurrent
end

function ENT:LerpDisk( angTarget, funcCallback )
	self.m_bLerping 		= true
	self.m_angTarget 		= angTarget
	self.m_fLerpCallback 	= funcCallback
	self.m_iLerpTime 		= CurTime()
end

function ENT:CanDishSeeSky()
	local pos, ang = self:GetBonePosition( 4 )
	if not pos then return end
	
	local filter = player.GetAll()
	table.insert( filter, self )

	return util.QuickTrace(
		pos,
		ang:Forward() *9e9,
		filter
	).HitSky
end

function ENT:ThinkDish()
	if self.m_bLerping then
		local scaler = math.Clamp( CurTime() -self.m_iLerpTime, 0, 1 )
		self:SetDishAngle( LerpAngle(scaler, self.m_angCurrent, self.m_angTarget) )

		if scaler == 1 then	
			self.m_bLerping = false

			if type( self.m_fLerpCallback ) == "function" then
				self.m_fLerpCallback()
			end
		end
	end
end

function ENT:Think()
	self:NextThink( CurTime() )  
	self:ThinkDish()

	if self.m_bOpen then return true end

	if not self.m_iLastCheck then
		self.m_iLastCheck = CurTime()
	else
		if CurTime() >= self.m_iLastCheck then
			self.m_iLastCheck = CurTime() +0.5

			if self.m_iLastPos ~= self:GetPos() then
				self.m_iLastPos = self:GetPos()
			else
				self:SetMoveType( MOVETYPE_NONE )
				
				timer.Simple( 0.1, function()
					if not IsValid( self ) then return end
					self:Open()
				end )
			end
		end
	end
	
	return true
end