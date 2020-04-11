-- THIS TOOL IS NOT COMPATABLE WITH THE GMOD TOOL GUN
TOOL.Category	= ""
TOOL.Name		= "Prop Spawner/Stacker"
TOOL.Command	= nil
TOOL.ConfigName	= nil

if CLIENT then TOOL.SelectIcon = surface.GetTextureID( "tool/propspawn" ) end
TOOL.HideAuth = true

TOOL.ClientConVar["model"] = "models/props_junk/wood_crate001a.mdl"
TOOL.ClientConVar["pitch"] = "0"
TOOL.ClientConVar["yaw"]   = "0"
TOOL.ClientConVar["roll"]  = "0"
TOOL.ClientConVar["dist"]  = "200"
TOOL.ClientConVar["snapdegrees"] = "45"
TOOL.ClientConVar["sensitivity"] = "0.025"
TOOL.ClientConVar["stackdir"] = 1

if CLIENT then
	language.Add( "Tool_propspawn_name", "Prop Spawner" )
	language.Add( "Tool_propspawn_desc", "Spawn a prop with a specified model" )
	language.Add( "Tool_propspawn_0", "Primary to spawn a prop. Secondary to stack" )
end

local function round( x, interval, total )
	if interval == 0 then
		return (x-math.floor(x) >= 0.50 and math.ceil(x) or math.floor(x))
	else
		return round( (x/total) * (total/interval), 0 ) * interval
	end
end

local function angnorm( ang )
	while ang.p < 0 do ang.p = ang.p + 360 end
	while ang.y < 0 do ang.y = ang.y + 360 end
	while ang.r < 0 do ang.r = ang.r + 360 end
	return ang
end

function TOOL:Initialize()
	self.THINK_LAST = 0
	self.USE_LAST = 0
	self.TRACE = nil
end

function TOOL:LeftClick( trace )
	if CLIENT then return true end
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	
	if --[[!trace.Hit or]] !gamemode.Call( "PlayerSpawnProp", ply, model ) then return false end
	
	local ent = ents.Create( "prop_physics" )
	if IsValid( ent ) then
		ent:SetModel( model )
		ent:Spawn()
		ent.Owner = ply
		ent.StackBTime = 1
		
		local physobj = ent:GetPhysicsObject()
		if IsValid( physobj ) then
			physobj:Wake()
			physobj:EnableMotion( false )
		end
		
		FixInvalidPhysicsObject( ent )
		
		local TargetAngle
		local TargetPos
		local AngleOffset = GAMEMODE.SpawnAngleOffset[model] or Angle( 0, 0, 0 )
		local PosOffset = GAMEMODE.SpawnPositionOffset[model] or 0
		
		local snapdegrees = self:GetClientNumber( "snapdegrees", 45 )
		TargetAngle = Angle( self:GetClientNumber("pitch",0), self:GetClientNumber("yaw",0), self:GetClientNumber("roll",0) ) + Angle( 0, ply:GetAngles().y, 0 )
		
		TargetAngle:RotateAroundAxis( TargetAngle:Right(), AngleOffset.p )
		TargetAngle:RotateAroundAxis( TargetAngle:Up(), AngleOffset.y )
		TargetAngle:RotateAroundAxis( TargetAngle:Forward(), AngleOffset.r )
		
		if ply:KeyDown( IN_SPEED ) --[[self.LOCKED_TO_WORLD]] --[[ply:KeyDown( IN_USE ) and ply:KeyDown( IN_SPEED )]] then
			TargetAngle = angnorm( TargetAngle )
			TargetAngle.p = round( TargetAngle.p, snapdegrees, 360 )
			TargetAngle.y = round( TargetAngle.y, snapdegrees, 360 )
			TargetAngle.r = round( TargetAngle.r, snapdegrees, 360 )
		end
		
		TargetPos = trace.HitPos
		if self.TRACE.Hit and math.abs(self.TRACE.HitNormal.z) > 0.7 then
			TargetPos = TargetPos - PosOffset * TargetAngle:Forward()
		end
		
		local mins, maxs, center = ent:OBBMins(), ent:OBBMaxs(), ent:OBBCenter()
		if math.abs(trace.HitNormal.z) > 0.7 then
			if trace.HitNormal.z > 0 then
				TargetPos = TargetPos - (TargetAngle:Forward()*center.x + TargetAngle:Right()*center.y + TargetAngle:Up()*mins.z)
			else
				TargetPos = TargetPos - (TargetAngle:Forward()*center.x + TargetAngle:Right()*center.y + TargetAngle:Up()*maxs.z)
			end
		else
			TargetPos = TargetPos - (TargetAngle:Forward()*center.x + TargetAngle:Right()*center.y + TargetAngle:Up()*center.z)
		end
		
		ent:SetPos( TargetPos )
		ent:SetAngles( TargetAngle )
		
		local physobj = ent:GetPhysicsObject()
		if IsValid( physobj ) then physobj:EnableMotion( false ) end
		ent:SetMoveType( MOVETYPE_NONE )
		ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		
		for _, v in ipairs(ents.FindInSphere(ent:LocalToWorld(ent:OBBCenter(v)),ent:BoundingRadius())) do
			if v:IsPlayer() then
				if v:IsPlayer() and v:IsColliding( ent ) or ent:IsColliding( v ) then
					ply:SendMessage( "Biological obstruction detected!", "Prop spawn", false )
					ent:Remove()
					break
				end
			end
		end
		
		for _, v in ipairs(GAMEMODE.SpawnPoints) do
			if PlayerHullIsColliding( v:GetPos(), false, ent ) then
				ply:SendMessage( "Unknown obstruction detected!", "Prop spawn", false )
				ent:Remove()
				break
			end
		end
		
		ent.CanRepair = false
		
		if ply:GetGroundEntity().StackBTime then
			ent.StackBTime = ent.StackBTime + ply:GetGroundEntity().StackBTime
			if ply:GetGroundEntity().StackBTime > 0 then
				ply:SendMessage( "Unrecognized coordinates; triangulating position, build time may be affected.", "Prop spawn", true )
				ent.BuildTime = (ent.StackBTime*10)-9
			end
		else
			ent.BuildTime = 1
		end	
		
		for _, v in ipairs(ents.FindInSphere(ent:GetPos(),200)) do

			if v:GetClass() == "prop_physics" and IsValid( v.Owner ) and (ent.Owner != v.Owner) or v:GetClass() == "sent_spawnpoint" and IsValid( v.Owner ) and (ent.Owner != v.Owner) then
				if v.Owner:Team() != ent.Owner:Team() or (v.Owner:Team() == 50) then 
					
					ent.BuildTime = (51-math.Clamp(((v:GetPos()-ent:GetPos()):Length()),1,50))+(ent.StackBTime*10)-9
					if v:GetClass() == "sent_spawnpoint" then
						ply:SendMessage( "Enemy Mobile Spawn Point nearby, build time may be affected.", "Prop spawn", false )
					else
						ply:SendMessage( "Enemy structure nearby, build time may be affected.", "Prop spawn", false )
					end
					break
				end
			end
		end
		
		if !ply:IsOnGround() then 
			ply:SendMessage( "Cannot get coordinates.", "Prop spawn", false )
			ent:Remove() 
		end

		
		gamemode.Call( "PlayerSpawnedProp", ply, model, ent )
	
		DoPropSpawnedEffect( ent )

		undo.Create( "Prop" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Prop ("..tostring(model)..")" )
	end
	if IsValid( ent ) and ply:IsOnGround() then ply:SendMessage( "Constructing prop...", "Prop spawn", true ) end
	self.SWEP:SetNextPrimaryFire( CurTime() + 0.50 )
	return IsValid( ent )
end

local ERROR_SOUND = Sound( "buttons/button10.wav" )
function TOOL:RightClick( trace )
	if CLIENT then return true end
	
	local validprop = IsValid( self.TRACE.Entity ) and self.TRACE.Entity:GetClass() == "prop_physics"
	
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	if !ply:GetGroundEntity() then return end
	if self.SWEP:GetFireMode() == 1 and validprop then model = self.TRACE.Entity:GetModel() end
	if !model then return false end
	
	if --[[!trace.Hit or]] !gamemode.Call( "PlayerSpawnProp", ply, model ) then return false end
	
	if validprop then
		local ent = ents.Create( "prop_physics" )
		if !IsValid( ent ) then return false end
		ent:SetModel( model )
		
		ent:SetMoveType( MOVETYPE_NONE )
		ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		local TargetAngle
		local TargetPos

		local pos, ang = trace.Entity:GetPos(), trace.Entity:GetAngles()
		local mins, maxs, center = trace.Entity:OBBMins(), trace.Entity:OBBMaxs()
		TargetAngle = ang
		local stackdir = self:GetClientNumber( "stackdir", 1 )
		local stackvec = Vector( 0, 0, 1 )
		local stacksize = 1
		if stackdir == 1 then
			TargetPos = pos + (maxs.x-mins.x-1) * ang:Forward()
			stackvec = ang:Forward()
			stacksize = maxs.x-mins.x
		elseif stackdir == 2 then
			TargetPos = pos - (maxs.x-mins.x-1) * ang:Forward()
			stackvec = ang:Forward()
			stacksize = maxs.x-mins.x
		elseif stackdir == 3 then
			TargetPos = pos - (maxs.y-mins.y-1) * ang:Right()
			stackvec = ang:Right()
			stacksize = maxs.y-mins.y
		elseif stackdir == 4 then
			TargetPos = pos + (maxs.y-mins.y-1) * ang:Right()
			stackvec = ang:Right()
			stacksize = maxs.y-mins.y
		elseif stackdir == 5 then
			TargetPos = pos + (maxs.z-mins.z-1) * ang:Up()
			stackvec = ang:Up()
			stacksize = maxs.z-mins.z
		elseif stackdir == 6 then
			TargetPos = pos - (maxs.z-mins.z-1) * ang:Up()
			stackvec = ang:Up()
			stacksize = maxs.z-mins.z
		end

		ent:SetPos( TargetPos )
		ent:SetAngles( TargetAngle )

		local start = ent:LocalToWorld( ent:OBBCenter() )
		local stack_trace = util.TraceHull( {start=start,endpos=start+stacksize*stackvec,mins=Vector(-0.5,-0.5,-0.5),maxs=Vector(0.5,0.5,0.5),filter=ent} )
		if IsValid( stack_trace.Entity ) and string.lower(stack_trace.Entity:GetModel()) == string.lower(model) and (stack_trace.Entity:GetPos()-TargetPos):Length() < 0.10 then
			ent:Remove()
			self:GetOwner():SendLua( [[surface.PlaySound("]]..ERROR_SOUND..[[")]] )
			return false
		elseif stack_trace.HitWorld then
			for _, v in ipairs(ents.FindInSphere(start,3)) do
				if v != ent and string.lower(v:GetModel()) == string.lower(model) and (v:GetPos()-TargetPos):Length() < 0.10 then
					ent:Remove()
					self:GetOwner():SendLua( [[surface.PlaySound("]]..ERROR_SOUND..[[")]] )
					return false
				end
			end
		end

		ent:Spawn()
		ent.Owner = ply
		ent.StackBTime = 1

		FixInvalidPhysicsObject( ent )

		for _, v in ipairs(ents.FindInSphere(ent:LocalToWorld(ent:OBBCenter(v)),ent:BoundingRadius())) do
			if v:IsPlayer() then
				if v:IsColliding( ent ) or ent:IsColliding( v ) then
					ply:SendMessage( "Obstruction detected!", "Prop spawn", false )
					ent:Remove()
					return
				end
			end
		end
		if ply:GetGroundEntity().StackBTime then 
			ent.StackBTime = ent.StackBTime + self.TRACE.Entity.StackBTime
			ent.BuildTime = (ent.StackBTime*10)-9
			ply:SendMessage( "Unrecognized coordinates; triangulating position, build time may be affected.", "Prop spawn", true )
		else
			ent.BuildTime = ent.StackBTime
		end
		ent.CanRepair = false
		for _, v in ipairs(ents.FindInSphere(ent:GetPos(),200)) do

			if v:GetClass() == "prop_physics" and IsValid( v.Owner ) and(ent.Owner != v.Owner) then
				if v.Owner:Team() != ent.Owner:Team() or (v.Owner:Team() == 50) then 
				
					ent.BuildTime = (51-(math.Clamp((v:GetPos()-ent:GetPos()):Length(),1,200)*0.25))+((ent.StackBTime*10)-9)
					ply:SendMessage( "Enemy structure nearby, build time may be affected.", "Prop spawn", false )
					break
				end
			end
		end
		
		if !ply:IsOnGround() then 
			ply:SendMessage( "Cannot get coordinates.", "Prop spawn", false )
			ent:Remove() 
		end
		
		gamemode.Call( "PlayerSpawnedProp", ply, model, ent )
		
		DoPropSpawnedEffect( ent )

		undo.Create( "Prop" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Prop ("..tostring(model)..")" )

		local physobj = ent:GetPhysicsObject()
		if IsValid( physobj ) then
			physobj:EnableMotion( false )
		end
	end
	
	return true
end

local LAST_CMD = nil
if CLIENT then
	hook.Add( "CreateMove", "propspawn_SetupMove", function(cmd)
		LAST_CMD = cmd
		MOUSEX = cmd:GetMouseX()
		MOUSEY = cmd:GetMouseY()
	end )
end

local RESET_ACCEPTTIME = 0.20
local lastx, lasty = 0,0
local Dist = 200
local LastTD = 0
function TOOL:Think()
	if LastTD != self.TraceDistance then
		self.TraceDistance = self:GetClientNumber("dist")
	end
	
	local curtime = CurTime()
	
	local ply = self:GetOwner()
	local shootpos = ply:GetShootPos()
	self.TRACE = util.TraceLine( {start=shootpos,endpos=shootpos+self:GetClientNumber("dist")*ply:GetAimVector(),filter=ply} )

	if !IsValid( self.GhostEntity ) then
		self:MakeGhostEntity( self:GetClientInfo("model"), Vector(0,0,0), Angle(0,0,0) )
	end
	self:UpdateGhostEntity()

	if !CLIENT then return end
	
	-- TODO: Move to serverside
	
	local firemode = self.SWEP:GetFireMode()
	if firemode == 1 then
		local delta = curtime - self.USE_LAST
		if delta > 0 and ply:KeyDown( IN_USE ) and !ply:KeyDownLast( IN_USE ) then
			local stackdir = self:GetClientNumber( "stackdir" )
			stackdir = stackdir + 1
			if stackdir > 6 then stackdir = 1 end
			RunConsoleCommand( "propspawn_stackdir", stackdir )
			surface.PlaySound( self.SWEP.SelectSound )
			self.USE_LAST = curtime
		end
		return
	end

	local ang = Angle( self:GetClientNumber("pitch",0), self:GetClientNumber("yaw",0), self:GetClientNumber("roll",0) )
	local old_pitch, old_yaw, old_roll, old_dist = ang.p, ang.y, ang.r, Dist
	
	if ply:KeyDown( IN_SPEED ) and !ply:KeyDownLast( IN_SPEED ) then
		local snapdegrees = self:GetClientNumber( "snapdegrees", 45 )
		ang = angnorm( ang )
		ang.p = round( ang.p, snapdegrees, 360 )
		ang.y = round( ang.y, snapdegrees, 360 )
		ang.r = round( ang.r, snapdegrees, 360 )
	end
	
	if ply:KeyDown( IN_USE ) then
		if !ply:KeyDownLast( IN_USE ) then
			local delta = curtime - self.USE_LAST
			if delta > 0 and delta < RESET_ACCEPTTIME then
				RunConsoleCommand( "propspawn_pitch", 0 )
				RunConsoleCommand( "propspawn_yaw", 0 )
				RunConsoleCommand( "propspawn_roll", 0 )
				return
			end
			self.USE_LAST = curtime
		end

		local cmd = LAST_CMD
		local x, y = MOUSEX, MOUSEY
		local sens = self:GetClientNumber( "sensitivity" )
		ang:RotateAroundAxis( Vector(0,0,1), x*sens )
		ang:RotateAroundAxis( Vector(0,-1,0), y*sens )
	end
	if ply:KeyDown(IN_USE) then
		if input.WasMousePressed(MOUSE_WHEEL_UP) then
			Dist = math.Clamp(Dist + 1,50,200)
		elseif input.WasMousePressed(MOUSE_WHEEL_DOWN) then
			Dist = math.Clamp(Dist - 1,50,200)
		end
	end
	
	if old_pitch != ang.p then RunConsoleCommand( "propspawn_pitch", ang.p ) end
	if old_yaw != ang.y then RunConsoleCommand( "propspawn_yaw", ang.y ) end
	if old_roll != ang.r then RunConsoleCommand( "propspawn_roll", ang.r ) end
	if old_dist != Dist then RunConsoleCommand( "propspawn_dist", Dist ) end
	LastTD = self.TraceDistance
end

function TOOL:UpdateGhostEntity()
	if self.GhostEntity == nil then return end
	if !self.GhostEntity:IsValid() then self.GhostEntity = nil return end
	local ply = self:GetOwner()
	
	local validprop = IsValid( self.TRACE.Entity ) and self.TRACE.Entity:GetClass() == "prop_physics"
	
	local model = self:GetClientInfo( "model" )
	if self.SWEP:GetFireMode() == 1 and validprop then model = self.TRACE.Entity:GetModel() end
	if self.GhostEntity:GetModel() != model then self.GhostEntity:SetModel( model ) end
	
	local TargetAngle
	local TargetPos
	local AngleOffset = GAMEMODE.SpawnAngleOffset[model] or Angle( 0, 0, 0 )
	local PosOffset = GAMEMODE.SpawnPositionOffset[model] or 0
		
	if self.SWEP:GetFireMode() == 0 then
		self.GhostEntity:SetColor( Color(255,255,255,150) )
		local snapdegrees = self:GetClientNumber( "snapdegrees", 45 )

		TargetAngle = Angle( self:GetClientNumber("pitch",0), self:GetClientNumber("yaw",0), self:GetClientNumber("roll",0) ) + Angle( 0, ply:GetAngles().y, 0 )
		
		TargetAngle:RotateAroundAxis( TargetAngle:Right(), AngleOffset.p )
		TargetAngle:RotateAroundAxis( TargetAngle:Up(), AngleOffset.y )
		TargetAngle:RotateAroundAxis( TargetAngle:Forward(), AngleOffset.r )
		
		if ply:KeyDown( IN_SPEED ) --[[self.LOCKED_TO_WORLD]] --[[ply:KeyDown( IN_USE ) and ply:KeyDown( IN_SPEED )]] then
			TargetAngle = angnorm( TargetAngle )
			TargetAngle.p = round( TargetAngle.p, snapdegrees, 360 )
			TargetAngle.y = round( TargetAngle.y, snapdegrees, 360 )
			TargetAngle.r = round( TargetAngle.r, snapdegrees, 360 )
		end

		TargetPos = self.TRACE.HitPos
		if self.TRACE.Hit and math.abs(self.TRACE.HitNormal.z) > 0.7 then
			TargetPos = TargetPos - PosOffset * TargetAngle:Forward()
		end
		
		local mins, maxs, center = self.GhostEntity:OBBMins(), self.GhostEntity:OBBMaxs(), self.GhostEntity:OBBCenter()
		if math.abs(self.TRACE.HitNormal.z) > 0.7 then
			if self.TRACE.HitNormal.z > 0 then
				TargetPos = TargetPos - (TargetAngle:Forward()*center.x + TargetAngle:Right()*center.y + TargetAngle:Up()*mins.z)
			else
				TargetPos = TargetPos - (TargetAngle:Forward()*center.x + TargetAngle:Right()*center.y + TargetAngle:Up()*maxs.z)
			end
		else
			TargetPos = TargetPos - (TargetAngle:Forward()*center.x + TargetAngle:Right()*center.y + TargetAngle:Up()*center.z)
		end
	elseif validprop then
		self.GhostEntity:SetColor( Color(255,255,255,150) )
		local pos, ang = self.TRACE.Entity:GetPos(), self.TRACE.Entity:GetAngles()
		local mins, maxs, center = self.TRACE.Entity:OBBMins(), self.TRACE.Entity:OBBMaxs()
		TargetAngle = ang
		local stackdir = self:GetClientNumber( "stackdir", 1 )
		if stackdir == 1 then
			TargetPos = pos + (maxs.x-mins.x-1) * ang:Forward()
		elseif stackdir == 2 then
			TargetPos = pos - (maxs.x-mins.x-1) * ang:Forward()
		elseif stackdir == 3 then
			TargetPos = pos - (maxs.y-mins.y-1) * ang:Right()
		elseif stackdir == 4 then
			TargetPos = pos + (maxs.y-mins.y-1) * ang:Right()
		elseif stackdir == 5 then
			TargetPos = pos + (maxs.z-mins.z-1) * ang:Up()
		elseif stackdir == 6 then
			TargetPos = pos - (maxs.z-mins.z-1) * ang:Up()
		end
	else
		self.GhostEntity:SetColor( Color(255,255,255,0) )
		return
	end
	
	self.GhostEntity:SetPos( TargetPos )
	self.GhostEntity:SetAngles( TargetAngle )
	
	
end

function TOOL:Holster()
	if IsValid( self.GhostEntity ) then
		self.GhostEntity:Remove()
	end
	self.GhostEntity = nil
	return true
end

function TOOL:OnRemove()
	if IsValid( self.GhostEntity ) then
		self.GhostEntity:Remove()
	end
	self.GhostEntity = nil
end

function TOOL:FreezeMovement()
	return self:GetOwner():KeyDown( IN_USE ) and self.SWEP:GetFireMode() == 0
end

function TOOL:DrawHUD()
	if self.SWEP:GetFireMode() == 0 and self.Owner:KeyDown(IN_USE) then
	--draw.SimpleText("Garry broke prop rotating yay!", "debugfixed", ScrW()/2, ScrH()/2+20, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	--draw.SimpleText("It SHOULD work now.", "debugfixed", ScrW()/2, ScrH()/2+40, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	if self.SWEP:GetFireMode() != 1 then return end
	
	local str = "<ERROR>"
	local col = Color( 100, 100, 100, 220 )
	local stackdir = self:GetClientNumber( "stackdir" )
	if stackdir == 1 then
		str  = "Front"
		col.r = 255
	elseif stackdir == 2 then
		str  = "Back"
		col.r = 255
	elseif stackdir == 3 then
		str  = "Left"
		col.g = 255
	elseif stackdir == 4 then
		str  = "Right"
		col.g = 255
	elseif stackdir == 5 then
		str  = "Up"
		col.b = 255
	elseif stackdir == 6 then
		str  = "Down"
		col.b = 255
	end
	
	--[[surface.SetTextColor( col )
	surface.SetFont( "DermaDefault" )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextPos( round(ScrW()/2-tw/2,0), ScrH()/2+16 )
	surface.DrawText( str )]]
	draw.SimpleTextOutlined( str, "DermaDefault", ScrW()*0.50, ScrH()*0.50+16, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255) )
	
	if self.TRACE and IsValid( self.TRACE.Entity ) then
		local forward = self.TRACE.Entity:GetForward()
		local right = self.TRACE.Entity:GetRight()
		local up = self.TRACE.Entity:GetUp()
		
		local pos = self.TRACE.Entity:LocalToWorld( self.TRACE.Entity:OBBCenter() )
		local pos_scr = pos:ToScreen()
		
		local endpos = (pos + 3 * forward):ToScreen()
		surface.SetDrawColor( 255, 000, 000, 255 )
		surface.DrawLine( pos_scr.x, pos_scr.y, endpos.x, endpos.y )
		
		endpos = (pos + 3 * right):ToScreen()
		surface.SetDrawColor( 000, 255, 000, 255 )
		surface.DrawLine( pos_scr.x, pos_scr.y, endpos.x, endpos.y )
		
		endpos = (pos + 3 * up):ToScreen()
		surface.SetDrawColor( 000, 000, 255, 255 )
		surface.DrawLine( pos_scr.x, pos_scr.y, endpos.x, endpos.y )
		
		if stackdir == 1 then
			pos_scr = (pos + 3 * forward):ToScreen()
			endpos = (pos + 4 * forward):ToScreen()
		elseif stackdir == 2 then
			pos_scr = (pos - 3 * forward):ToScreen()
			endpos = (pos - 4 * forward):ToScreen()
		elseif stackdir == 3 then
			pos_scr = (pos - 3 * right):ToScreen()
			endpos = (pos - 4 * right):ToScreen()
		elseif stackdir == 4 then
			pos_scr = (pos + 3 * right):ToScreen()
			endpos = (pos + 4 * right):ToScreen()
		elseif stackdir == 5 then
			pos_scr = (pos + 3 * up):ToScreen()
			endpos = (pos + 4 * up):ToScreen()
		elseif stackdir == 6 then
			pos_scr = (pos - 3 * up):ToScreen()
			endpos = (pos - 4 * up):ToScreen()
		end
		surface.SetDrawColor( 255, 0, 255, 255 )
		surface.DrawLine( pos_scr.x, pos_scr.y, endpos.x, endpos.y )
	end
end