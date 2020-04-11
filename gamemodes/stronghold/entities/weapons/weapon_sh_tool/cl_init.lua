gmod_toolmode = CreateClientConVar( "gmod_toolmode", "propspawn", true, true )
local TOOL_RADIAL_SHOWMOUSE = CreateClientConVar( "sh_tool_radialshowmouse", "0", true, false )
local TOOL_RADIAL_MODE = CreateClientConVar( "sh_tool_radialmode", "1", true, false )
local TOOL_RADIAL_SPEED = CreateClientConVar( "sh_tool_radialmode_speed", "0.15", true, false )
local TOOL_ALTERNATEINPUT = CreateClientConVar( "sh_tool_altinput", "0", true, false )

include( "shared.lua" )
include( "cl_viewscreen.lua" )

SWEP.PrintName          = "TOOL GUN"
SWEP.Slot               = 5
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.Switched			= true	

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_tool" )

SWEP.MenuOpen = false
SWEP.MenuCurAngle = 90
SWEP.MenuTargetAngle = 90
local LastEAng = Angle(0,0,0)
local LerpTurnSpeed = Angle(0,0,0)
local TurnSpeed = 0
local RandKick = 0
local OrigMul = Vector(0,0,0)

local hide = {
	CHudWeaponSelection = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) and LocalPlayer():KeyDown(IN_USE) then return false end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

function SWEP:PreDrawViewModel()
	render.SetBlend(0)
end

function SWEP:PostDrawViewModel()
	render.SetBlend(1)
	VM, EP, EA, FT, CT = self.Owner:GetViewModel(), EyePos(), EyeAngles(), FrameTime(), CurTime()
	vel = self.Owner:GetVelocity()
	len = vel:Length()
	cyc = cyc and cyc or 0
	
	if vm:GetModel() != self.ViewModel then
		self.Switched = true
	end
	
	if vm == null or self.Switched then
		if vm and self.Switched then
			vm:Remove()
		end
		
		vm = ClientsideModel(self.ViewModel)
		self.Switched = false
		vm:SetCycle(cyc)
		vm:SetSequence(self.DeployAnim)
		vm:SetPlaybackRate(1)
		Reloading = false
		DisableKick = true
		WAT = false
	end 
	

	self.VM = vm
		
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
	
	--[[if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyPressed(IN_USE) then
		if EDIT then 
			EDIT = false
			self.DrawCrosshair = false
		else 
			EDIT = true
			self.DrawCrosshair = true
		end
	end]]
		
	CanFire = (CurTime()-self:GetNextPrimaryFire())>=-0.3 and true or false
	
	if !self.RRise then self.RRise = 0 end
	if self.RunAngleSet == "pistol" then PKick = 1 PKickOff = 1 else PKick = self.RRise*5 PKickOff = 0 end
	if !self.RSlide then self.RSlide = 0 end
	
	TurnSpeed = EyeAngles() - LastEAng
	LerpTurnSpeed = LerpTurnSpeed + TurnSpeed
	LerpTurnSpeed = LerpAngle(FT*10, LerpTurnSpeed,Angle(0,0,0))
	
	EP = EP + EA:Right() * (LerpTurnSpeed.y*0.03)
	EP = EP + EA:Up() * (LerpTurnSpeed.p*0.03)
	
	if !Reloading and self.Owner:KeyDown(IN_RELOAD) and self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
		Reloading = true
		vm:SetCycle(cyc)
		vm:SetSequence(self.ReloadAnim)
		vm:SetPlaybackRate(1)
		self.ResetBolt = true
		WepFired = false
	end
	
	if self.FireOne and !self.Owner:KeyDown(IN_ATTACK2) then
		vm:SetCycle(cyc)
		vm:SetSequence(self.ShootAnim)
		self:ShootEffects()
		vm:SetPlaybackRate(1)
		Reloading = false

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
		
	BlendSpeed = Lerp(FT * 3, BlendSpeed, 12)
	if !Set then 
		--self:SetAttachments()
		Set = true
	end
	
	LastEAng = EyeAngles()
end
local GMul = 0
local Speed = 0
local WalkTimer = 0
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
				---------------------Walking Bob-----------------------					--------Not Moving Bob/Breathing--------
	EP = EP + ((EA:Right() * math.sin((Frames*15)/2)*(Speed*Speed)*WalkTimer))*GMul + ((EA:Right()*math.sin(Frames*2))*0.05)
	EP = EP + ((EA:Up() * math.sin((Frames*15))*WalkTimer))*GMul		 + ((EA:Up()*math.sin(Frames*3))*0.05)
	--Extra Wiggle
	EA:RotateAroundAxis( EA:Forward(),  ((math.sin((Frames*15))*WalkTimer))*GMul*5 )
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
local AMul = Angle(0,0,0)
local VMul = Vector(0,0,0)
local StrafeSway = 0
local RunMul = 0
local veldepend = {pitch = 0, yaw = 0, roll = 0}
local LastRollVel = 0
local LastEA = 0
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
	
	local RPGFIX = self.RunAngleSet == "rpg" and -1 or 1
	
	veldepend.roll = math.Clamp((vel:DotProduct(EA:Right()) * 0.04) * len / self.Owner:GetWalkSpeed(), -5, 5)
	StrafeSway = StrafeSway + veldepend.roll
	StrafeSway = Lerp(FT*10, LastRollVel, veldepend.roll)
	local EASpeed = self.Owner:EyeAngles().y-LastEA
	local LEASpeed = Lerp(FT*10,EASpeed, 0)
	EA:RotateAroundAxis( Down,  self.RunArmAngle.yaw *AMul.yaw)
	EA:RotateAroundAxis( Forward,  self.RunArmAngle.roll*AMul.roll+(StrafeSway) ) 
	EA:RotateAroundAxis( Right, self.RunArmAngle.pitch*AMul.pitch*RPGFIX)
	EP = (EP + (EA:Forward()*VMul.z) + (EA:Up()*VMul.x) + (EA:Right()*VMul.y) )
	
	LastEA = self.RunArmAngle.yaw *AMul.yaw
	LastRollVel = self.RunArmAngle.roll*AMul.roll+StrafeSway
end

local function round( x, interval, total )
	if interval == 0 then
		return (x-math.floor(x) >= 0.50 and math.ceil(x) or math.floor(x))
	else
		return round( (x/total) * (total/interval), 0 ) * interval
	end
end

local MAT_CROSSHAIR = surface.GetTextureID( "sprites/hud/v_crosshair2" )
function SWEP:DrawHUD()
	local sw, sh = ScrW()/640, ScrH()/480
	local x, y, w, h = ScrW()-math.floor(sw*150), math.floor(sh*432), math.floor(sw*136), math.max( 67, math.floor(sh*36) )
	local firemode = self:GetFireMode()
	local _, th = surface.GetTextSize( "ABC123" )
	local mode = self:GetMode()
	local tool = self:GetToolObject( mode )
	local str_fm = (firemode == 0 and "PRIMARY" or "SECONDARY")
	local tw, th = surface.GetTextSize( str_fm )
	
	self:RadialDrawHUD()
	
	-- Info box
	--[[surface.SetFont( "DermaDefaultBold" )
	
	th = math.floor( th )
	surface.SetTextColor( 255, 220, 0, 220 )
	
	draw.RoundedBox( 8, x, y, w, h, Color(0,0,0,76) )
	draw.RoundedBox( 4, x+6, y+6, w-12, th+4, Color(0,0,0,100) )
	draw.RoundedBox( 4, x+6, y+th+16, w-12, h-th-22, Color(0,0,0,100) )
	

	surface.SetTextPos( x+10, math.floor(y+2+th/2) )
	surface.DrawText( "TOOL MODE: " )
	surface.DrawText( !tool and "None" or (tool.Name and tool.Name or "#"..mode) )
	

	surface.SetTextPos( x+w-tw-9, math.floor(y+2+th/2) )
	surface.DrawText( str_fm )
	
	if tool then
		surface.SetTextPos( x+10, y+th+19 )
		surface.DrawText( "#Tool_"..mode.."_desc" )
		
		surface.SetFont( "DermaDefault" )
		local _, th2 = surface.GetTextSize( "ABC123" )
		surface.SetTextPos( x+14, y+th+th2+20 )
		surface.DrawText( (tool:GetStage()+1)..": " )
		surface.DrawText( "#Tool_"..mode.."_"..tool:GetStage() )
	end]]
	
	-- Crosshair
	local col = Color( 255, 255, 255, 220 )
	if tool and !tool.HideAuth then
		local trace, _ = self:Authorize()
		if trace != nil then
			col = Color( 100, 255, 100, 220 )
		else
			col = Color( 255, 100, 100, 220 )
		end
	end
	
	if !self.MenuOpen or !TOOL_RADIAL_SHOWMOUSE:GetBool() or TOOL_RADIAL_MODE:GetInt() != 1 then
		x, y = ScrW()/2, ScrH()/2
	else
		x, y = gui.MousePos()
		local cx, cy = ScrW()/2, ScrH()/2
		local dist, dist_max = math.Distance( x, y, cx, cy ), ScrH()/1050*80
		if dist > dist_max then
			local norm = Vector( x-cx, cy-y, 0 ):GetNormal()
			x, y = cx+norm.x*dist_max, cy-norm.y*dist_max
		end
	end
	surface.SetTexture( MAT_CROSSHAIR )
	surface.SetDrawColor( col )
	if !self.MenuOpen then
		surface.DrawTexturedRectRotated( x, y, 32, 32, (firemode == 0 and 0 or 90) )
	else
		surface.DrawTexturedRectRotated( x, y, 32, 32, 0 )
		surface.DrawTexturedRectRotated( x, y, 32, 32, 90 )
	end
	
	if firemode == 0 or self.MenuOpen then
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( x-2, y-2, 4, 4 )
		surface.SetDrawColor( col )
		surface.DrawRect( x-1, y-1, 2, 2 )
	elseif firemode == 1 then
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( x-4, y-2, 8, 4 )
		surface.SetDrawColor( col )
		surface.DrawRect( x-3, y-1, 2, 2 )
		surface.DrawRect( x+1, y-1, 2, 2 )
	end
	
	if tool then tool:DrawHUD() end
end

function SWEP:SetStage( ... )
	if !self:GetToolObject() then return end
	return self:GetToolObject():SetStage( ... )
end

function SWEP:GetStage( ... )
	if !self:GetToolObject() then return end
	return self:GetToolObject():GetStage( ... )
end

function SWEP:ClearObjects( ... )
	if !self:GetToolObject() then return end
	self:GetToolObject():ClearObjects( ... )
end

function SWEP:StartGhostEntities( ... )
	if !self:GetToolObject() then return end
	self:GetToolObject():StartGhostEntities( ... )
end

function SWEP:FreezeMovement()
	local mode = self:GetMode()
	if !self:GetToolObject() then return self.MenuOpen end
	return self:GetToolObject():FreezeMovement() or self.MenuOpen
end

--[[
	RADIAL MENU
]]

local MOUSE_CHECK_DIST = 80
local MOUSE_CUR_DIST = 0
local CUR_SELECTION, LAST_SELECTION = nil
function SWEP:RadialThink()
	if !self.MenuOpen then return end
	
	local sscale = ScrH() / 1050
	local radialmode = TOOL_RADIAL_MODE:GetInt()
	if radialmode == 1 then
		if self.MenuOpen then
			local mx, my = gui.MousePos()
			local cx, cy = ScrW()/2, ScrH()/2
			MOUSE_CUR_DIST = math.Distance( mx, my, cx, cy )
			--if MOUSE_CUR_DIST > sscale*48 then
				local norm = Vector( mx-cx, cy-my, 0 ):GetNormal()
				self.MenuTargetAngle = norm:Angle().y
				if MOUSE_CUR_DIST > MOUSE_CHECK_DIST*sscale then
					gui.SetMousePos( cx+norm.x*(MOUSE_CHECK_DIST*sscale), cy-norm.y*(MOUSE_CHECK_DIST*sscale) )
				end
			--end
		end
		self.MenuCurAngle = math.ApproachAngle( self.MenuCurAngle, self.MenuTargetAngle, 15*(math.AngleDifference(self.MenuCurAngle,self.MenuTargetAngle)/180) )
	else
		local cmd = self.Owner:GetCurrentCommand()
		self.MenuCurAngle = self.MenuCurAngle - (radialmode == 2 and cmd:GetMouseX() or cmd:GetMouseY()) * TOOL_RADIAL_SPEED:GetFloat()
		if self.MenuCurAngle < 0 then self.MenuCurAngle = self.MenuCurAngle + 360 end
	end
	
	CUR_SELECTION, _ = self:GetCurrentSelection()
	if LAST_SELECTION != nil and CUR_SELECTION != LAST_SELECTION then
		surface.PlaySound( self.DuringSelectionSound )
	end
	LAST_SELECTION = CUR_SELECTION
end

local TEX_RADIALBG = surface.GetTextureID( "tool/tool_radialbg" )
local TEX_RADIALSELECT = surface.GetTextureID( "tool/tool_radialselect" )
local TEX_RADIALMOUSE = surface.GetTextureID( "sprites/hud/v_crosshair1" )
local expand = 0
local mul = 0
function SWEP:RadialDrawHUD()
	if self.MenuOpen then
		expand = Lerp(FrameTime()*20,expand,256)
		mul = Lerp(FrameTime()*20,mul,1)
	else
		expand = Lerp(FrameTime()*20,expand,0)
		mul = Lerp(FrameTime()*20,mul,0)
	end
	--if !self.MenuOpen then return end

	local sscale = ScrH() / 1050
	local sx, sy = ScrW()/2, ScrH()/2
	local size, size_half, center, label = expand*sscale, 128*sscale, 85*sscale, 150*sscale

	surface.SetDrawColor( 0, 0, 0, expand/1.1 )
	surface.SetTexture( TEX_RADIALBG )
	surface.DrawTexturedRectRotated( sx, sy, size, size,0 )
	--if MOUSE_CUR_DIST > sscale*48 or TOOL_RADIAL_MODE:GetInt() != 1 then
	surface.SetDrawColor( 255, 255, 255, math.Clamp(MOUSE_CUR_DIST*MOUSE_CUR_DIST*MOUSE_CUR_DIST*0.001,0,255) )
		surface.SetTexture( TEX_RADIALSELECT )
		surface.DrawTexturedRectRotated( sx, sy, math.Clamp(size*(MOUSE_CUR_DIST*0.012),0,255), math.Clamp(size*(MOUSE_CUR_DIST*0.012),0,255), self.MenuCurAngle )
	--end

	local i, count = 0, table.Count( self.Tool )
	for k, v in pairs(self.Tool) do
		if v.AllowedCVar == 0 or v.AllowedCVar:GetBool() then
			local brightness = (k == CUR_SELECTION and 255 or 230)
			if !v.puff then
			v.puff = 0
			end
			if brightness == 255 then
				v.puff = Lerp(FrameTime()*20,v.puff, 10)
			else
				v.puff = Lerp(FrameTime()*20,v.puff, 0)
			end
			local ang = v.RadialAngle
			local vx, vy = math.cos(ang), math.sin(ang)
			local x, y = sx-vx*center*mul, sy+vy*(center-1)*mul
			
			local lx, ly = math.cos( ang+self.ToolAngBetween/2 ), math.sin( ang+self.ToolAngBetween/2 )
			surface.SetDrawColor( 150, 150, 150, expand )
			surface.DrawLine( sx+lx*64*sscale*mul, sy+ly*64*sscale*mul, sx+lx*94*sscale*mul, sy+ly*94*sscale*mul )
			
			surface.SetDrawColor( brightness, brightness, brightness, expand )
			surface.SetTexture( v.SelectIcon or self.WepSelectIcon )
			surface.DrawTexturedRectRotated( x, y, expand/4+v.puff-9.9, expand/4+v.puff-9.9, 0 )
			
			surface.SetFont( "DermaDefaultBold" )
			local tw, th = surface.GetTextSize( v.Name )
			local tx, ty = sx-vx*label-tw/2-tw/4*vx, sy+vy*label-th/2-th*vy
			
			surface.SetTextColor( 0, 0, 0, expand )
			for _x=-1, 1 do
				for _y=-1, 1 do
					surface.SetTextPos( tx+_x, ty+_y )
					surface.DrawText( v.Name )
				end
			end
			--[[surface.SetTextPos( tx-1, ty-1 )
			surface.DrawText( v.Name )
			surface.SetTextPos( tx-1, ty+1 )
			surface.DrawText( v.Name )
			surface.SetTextPos( tx+1, ty-1 )
			surface.DrawText( v.Name )
			surface.SetTextPos( tx+1, ty+1 )
			surface.DrawText( v.Name )]]
			
			surface.SetTextColor( brightness, brightness, brightness, expand )
			surface.SetTextPos( tx, ty )
			surface.DrawText( v.Name )
			
			--draw.SimpleTextOutlined( v.Name, "DefaultBold", math.floor(x-tw/2), math.floor(y), Color(brightness,brightness,brightness,220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20,220) )
			
			i = i + 1
		end
	end
end

function SWEP:GetCurrentSelection()
	local sscale = ScrH() / 1050
	local radialmenu = TOOL_RADIAL_MODE:GetInt() != 1
	local selection, selectionang = self:GetMode(), -1
	
	if MOUSE_CUR_DIST > sscale*48 or radialmenu then
		local selang = -1
		local i, count = 0, table.Count( self.Tool )
		for k, v in pairs(self.Tool) do
			local ang = math.deg( v.RadialAngle - self.ToolAngBetween/2 )
			local diff = math.AngleDifference( (!radialmenu and self.MenuTargetAngle or self.MenuCurAngle), ang )
			if selang == -1 or diff < selang then
				selang = diff
				selection = k
				selectionang = math.deg( v.RadialAngle ) + 180 -- I'm not sure what is going on here but WHAT EVER
			end
			i = i + 1
		end
	end
	
	return selection, math.NormalizeAngle( selectionang )
end

function SWEP:OpenMenu()
	if self.MenuOpen then return end

	if TOOL_RADIAL_MODE:GetInt() == 1 then
		vgui.GetWorldPanel():SetCursor( "blank" )
		gui.EnableScreenClicker( true )
		gui.SetMousePos( ScrW()/2, ScrH()/2 )
	else
		local sel, ang = self:GetCurrentSelection()
		self.MenuTargetAngle = ang
		self.MenuCurAngle = ang
	end
	
	self.MenuOpen = true
end

function SWEP:CloseMenu()
	if !self.MenuOpen then return end

	self.MenuOpen = false

	-- Check for selection
	local selection, _ = self:GetCurrentSelection()
	if selection != self:GetMode() then
		RunConsoleCommand( "gmod_toolmode", selection )
		surface.PlaySound( self.SelectSound )
	end

	if TOOL_RADIAL_MODE:GetInt() == 1 then
		gui.EnableScreenClicker( false )
		vgui.GetWorldPanel():SetCursor( "" )
	end
end

local function KeyPress( ply, key )
	if not IsValid( ply ) then return end
	local weapon = ply:GetActiveWeapon()

	if not IsValid( weapon ) or weapon:GetClass() ~= "weapon_sh_tool" then return end
	local altinput = TOOL_ALTERNATEINPUT:GetBool()
	
	if weapon.OpenMenu and (altinput and key == IN_RELOAD) or (!altinput and key == IN_ATTACK2) then
		weapon:OpenMenu()
	end
end
hook.Add( "KeyPress", "tool_KeyPress", KeyPress )

local function KeyRelease( ply, key )
	if not IsValid( ply ) then return end
	local weapon = ply:GetActiveWeapon()

	if not IsValid( weapon ) or weapon:GetClass() ~= "weapon_sh_tool" then return end
	local altinput = TOOL_ALTERNATEINPUT:GetBool()
	
	if weapon.CloseMenu and (altinput and key == IN_RELOAD) or (!altinput and key == IN_ATTACK2) then
		weapon:CloseMenu()
	end
end
hook.Add( "KeyRelease", "tool_KeyRelease", KeyRelease )