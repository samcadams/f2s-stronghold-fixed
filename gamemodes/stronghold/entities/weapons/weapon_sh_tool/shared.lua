local TOOL_ALTERNATEINPUT = CreateClientConVar( "sh_tool_altinput", "0", true, false )

SWEP.Author = "::B!G::"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.DrawWeaponInfoBox  	= false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShootSounds = { Sound( "weapons/alyx_gun/alyx_gun_fire3.wav" ), Sound( "weapons/alyx_gun/alyx_gun_fire4.wav" ) }

SWEP.ModeSound = Sound( "Weapon_Shotgun.Empty" )
SWEP.SelectSound = Sound( "npc/turret_floor/click1.wav" )
SWEP.DuringSelectionSound = Sound( "ui/buttonclick.wav" )

SWEP.Tool = {}
SWEP.ToolAngBetween = 0
SWEP.RunAngleSet	= "rpg"
SWEP.IronSightsPos 			= Vector (0, 0.1, 0)
SWEP.IronSightsAng 			= Vector (0, 0, 0)
SWEP.RunArmAngle  = Angle( -20, -20, 2 )
SWEP.RunArmOffset = Vector( -2, 0, 3 )

SWEP.ShootAnim				= 1
SWEP.DeployAnim				= 2
SWEP.ReloadAnim				= 5

function SWEP:Precache()
end

function SWEP:SetupDataTables()
	self:DTVar( "Int", 0, "FireMode" )
	self:SetFireMode( 0 )
end

function SWEP:Initialize()
	self:InitializeTools()
end

function SWEP:Deploy()
	self.Switched = true
	return true
end

function SWEP:InitializeTools()
	local tbl = {}

	local count = table.Count( self.Tool )
	self.ToolAngBetween = math.pi * 2 / count
	
	local sorted = {}
	for k, _ in pairs(self.Tool) do table.insert( sorted, k ) end
	table.sort( sorted, function(a,b) return a > b end )
	--PrintTable( sorted )
	
	for i, v in pairs(sorted) do
		tbl[v] = table.Copy( self.Tool[v] )
		tbl[v].SWEP = self
		tbl[v].Owner = self.Owner
		tbl[v].Weapon = self.Weapon
		tbl[v].RadialAngle = (i-2) * self.ToolAngBetween - math.pi/2
		--while tbl[v].RadialAngle < 0 do tbl[v].RadialAngle = tbl[v].RadialAngle + math.pi*2 end
		if tbl[v].Initialize then tbl[v]:Initialize() end
	end
	
	self.Tool = tbl
end
function SWEP:Think()
	if CLIENT then
		self:RadialThink()
	end
	
	self.Mode = self.Owner:GetInfo( "gmod_toolmode" )
	local mode = self:GetMode()
	local tool = self:GetToolObject()
	
	if !tool then return end
	
	tool:CheckObjects()
	
	self.last_mode = self.current_mode
	self.current_mode = mode
	
	if !tool:Allowed() then 
		self:GetToolObject( self.last_mode ):ReleaseGhostEntity() 
		return
	end
	
	if self.last_mode != self.current_mode then
		if !self:GetToolObject( self.last_mode ) then return end
		self:GetToolObject( self.last_mode ):Holster()
		self:SetFireMode( 0 )
	end
	
	self.Primary.Automatic = tool.LeftClickAutomatic or false
	self.Secondary.Automatic = tool.RightClickAutomatic or false
	self.RequiresTraceHit = tool.RequiresTraceHit or true
	
	tool:Think()
end

function SWEP:Authorize()
	local mode = self:GetMode()
	local tool = self:GetToolObject()
	if !tool then return end
	
	local ply = self:GetOwner()
	local pos = ply:GetShootPos()
	
	local trace = util.TraceLine( {start=pos,endpos=pos+(tool.TraceDistance or 200)*ply:GetAimVector(),mask=bit.bor(CONTENTS_SOLID,CONTENTS_MOVEABLE,CONTENTS_MONSTER,CONTENTS_WINDOW,CONTENTS_DEBRIS,CONTENTS_GRATE,CONTENTS_AUX),filter=ply} )
	
	if tool.NoAuthOnPlayer and IsValid( trace.Entity ) and trace.Entity:IsPlayer() then return end
	if tool.NoAuthOnWorld and trace.HitWorld then return end
	if tool.RequiresTraceHit and !trace.Hit then return end
	
	tool:CheckObjects()
	
	if !tool:Allowed() then return end
	if IsValid( trace.Entity ) and !gamemode.Call( "CanTool", self.Owner, trace, mode ) then return end
	
	return trace, tool
end

function SWEP:Reload()
	if !TOOL_ALTERNATEINPUT:GetBool() then
		if self:GetOwner():KeyDownLast( IN_RELOAD ) then return end
		self:EmitSound( self.ModeSound )
		
		if CLIENT then return end

		if self:GetFireMode() == 0 then
			self:SetFireMode( 1 )
		elseif self:GetFireMode() == 1 then
			self:SetFireMode( 0 )
		end
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown( IN_SPEED ) and self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) then return end
	
	local trace, tool = self:Authorize()
	if trace == nil then return end

	if TOOL_ALTERNATEINPUT:GetBool() then
		if !tool:LeftClick( trace ) then return end
	else
		if self:GetFireMode() == 0 then
			if !tool:LeftClick( trace ) then return end
		elseif self:GetFireMode() == 1 then
			if !tool:RightClick( trace ) then return end
		end
	end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone )
end

function SWEP:SecondaryAttack()
	if TOOL_ALTERNATEINPUT:GetBool() then
		if self.Owner:KeyDown( IN_SPEED ) and self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) then return end
		
		local trace, tool = self:Authorize()
		if trace == nil then return end
		
		if !tool:RightClick( trace ) then return end
		
		self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone )
	end
end

function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone )
	self:EmitSound( table.Random(self.ShootSounds), 70, math.random(98,102) )
	--self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetNormal( hitnormal )
		effectdata:SetEntity( entity )
		effectdata:SetAttachment( physbone )
	util.Effect( "ToolHit", effectdata )

	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetNormal( hitnormal )
		effectdata:SetEntity( self.Weapon )
		effectdata:SetAttachment( 1 )
	util.Effect( "ToolTracer", effectdata )
	
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment( 1 )
		util.Effect("ToolMuzzle", fx)
end

	
function SWEP:HUDShouldDraw( element )
	//return false to hide an item
	if self.Owner:KeyDown(IN_USE) then
	if (element == "CHudWeaponSelection") then
		return false
	else
		return true
	end
	end
end

function SWEP:Holster( ... )
	if CLIENT and self.Owner == LocalPlayer() then self:CloseMenu() end
	local tool = self:GetToolObject()
	if tool then tool:Holster( ... ) end
	if self.Owner:KeyDown(IN_USE) then
	return false
	else
	return true
	end
end

function SWEP:OnRemove( ... )
	if CLIENT and self.Owner == LocalPlayer() then self:CloseMenu() end
	local tool = self:GetToolObject()
	if tool and tool.OnRemove then tool:OnRemove( ... ) end
end

function SWEP:OwnerChanged()
	if CLIENT and self.Owner == LocalPlayer() then self:CloseMenu() end
end

function SWEP:SetFireMode( i )
	if CLIENT then return end
	self.dt.FireMode = i
end

function SWEP:GetFireMode()
	return self.dt.FireMode
end

function SWEP:GetMode()
	return self.Mode
end

function SWEP:GetToolObject( tool )
	local mode = tool or self:GetMode()
	if !self.Tool[mode] then return false end
	return self.Tool[mode]
end

include( "tool.lua" )

local IRONSIGHT_TIME = 0.1
local DashDelta = 0
function SWEP:GetViewModelPosition( pos, ang )
	if (not self.IronSightsPos) then return pos, ang 
	end

	local bIron = self.bInIronSight
	if self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED ) then
		if (!self.DashStartTime) then
			self.DashStartTime = CurTime()
		end
		DashDelta = math.Clamp( ((CurTime() - self.DashStartTime) / 0.15) ^ 1.2, 0, 1 )
	else
		if ( self.DashStartTime ) then
			self.DashEndTime = CurTime()
			self.DashStartTime = nil
		end
		if ( self.DashEndTime ) then
			DashDelta = math.Clamp( ((CurTime() - self.DashEndTime) / 0.1) ^ 1.2, 0, 1 )
			DashDelta = 1 - DashDelta
			if ( DashDelta == 0 ) then self.DashEndTime = nil end
		else
			DashDelta = 0
		end
	end

	if ( DashDelta != 0 ) then
		local Down = ang:Up() * -1
		local Right = ang:Right() 
		local Forward = ang:Forward() *2
		pos = pos + ( Down * (self.RunArmOffset.x) + Forward * (self.RunArmOffset.y) + Right * (self.RunArmOffset.z) ) * DashDelta
		local INERT = self.Owner:GetVelocity().z*0.1
		local RUNPOS = math.Clamp(self.Owner:GetAimVector().z*-10, -3,0.3) 
		local RUNPOS2 = math.Clamp(self.Owner:GetAimVector().z*-0.3, -1,0.3) 
		local NEGRUNPOS = math.Clamp(self.Owner:GetAimVector().z*4, -2,2) --ErrorNoHalt(NEGRUNPOS*self.RunArmAngle.pitch)
		local NEGRUNPOS2 = math.Clamp(self.Owner:GetAimVector().z*2, -0.5,2)
		
		if self.bInScope or self.Look == 0 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch  * DashDelta)
		elseif self.ModelRunAnglePreset	== 3 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * NEGRUNPOS2 )
		elseif self.ModelRunAnglePreset == 2 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.yaw * RUNPOS2 )
		elseif self.ModelRunAnglePreset	== 1 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * NEGRUNPOS )--ErrorNoHalt(self.RunArmAngle.pitch)
		elseif self.ModelRunAnglePreset	== 0 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * RUNPOS )
		end
		ang:RotateAroundAxis( Down,  self.RunArmAngle.yaw   * DashDelta )
		ang:RotateAroundAxis( Forward,  self.RunArmAngle.roll  * DashDelta ) 
		ang:RotateAroundAxis(Right, self.RunArmAngle.pitch * DashDelta)
	end
	
	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()
	end
	
	self.SwayScale = 0
	self.BobScale = 0
	--if !self.Owner:KeyDown(IN_ATTACK2) then self.SwayScale = 1 else self.SwayScale = 0.3 end
	local fIronTime = self.fIronTime or 0
	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end
	local Mul = 1.0
	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then Mul = 1 - Mul end
	end

	local Offset= self.IronSightsPos
	local scale = math.Clamp((CurTime() - self.Recoil)*20, -5, 1 )
	local scale2 = math.Clamp((CurTime() - self.Recoil)*10, -0, 2 )
	
	if (self.IronSightsAng) then
		ang = ang 
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul )
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	if self.RMod == 1 or self.RMod == 0 and self.Weapon:Clip1() == 0 and self.Primary.Ammo != "buckshot" then
		pos = pos + Offset.x * Right * (Mul+(scale*self.RSlide)-self.RSlide)
		pos = pos + Offset.y * Forward * ((Mul+(scale*self.RKick)-self.RKick)+scale2)
		pos = pos + Offset.z * Up * ((Mul+(scale*-self.RRise))+self.RRise)
	elseif self.RMod == 0 and self.Weapon:Clip1() != 0 then
		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
	end
 
	return pos, ang	
end