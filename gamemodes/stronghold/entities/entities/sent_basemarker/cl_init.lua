include('shared.lua')
ENT.Door = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Sent = false


function ENT:Initialize()
surface.CreateFont( "CommScreen", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 300,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
	for _, v in ipairs(self.GModels) do
		v:Remove()
	end
	self.GModels = {}
	
end
local alpha2 = 0
function draw.circle( x, y, radius, seg ) 
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function ENT:DoorModDetect()
	self.Door = false
	for _, x in ipairs(ents.FindByClass("sent_doormod")) do
		if x:GetPos():Distance(self:GetPos()) <500 then
			self.Door = true
		end
	end
end

ENT.circle = 0 
function ENT:circleMath( ang, radius, offX, offY )
	ang =  math.rad( ang-88+self.circle )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

function ENT:circleMath2( ang, radius, offX, offY )
	ang =  math.rad( ang-88-self.circle )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

function ENT:circleMathStatic( ang, radius, offX, offY )
	ang =  math.rad( ang+90 )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

ENT.expand = 360
ENT.rise = 360
local mx, my = 0,0
ENT.models = false
ENT.GModels = {}
function ENT:Draw()
	self:DrawModel()
	
end

function ENT:DrawTranslucent()
if self:GetPos():Distance(LocalPlayer():GetPos()) > 100 then return end
	cam.Start3D2D( self:GetPos()+self:GetAngles():Forward()*-15+self:GetAngles():Up()*47.3, self:GetAngles()+Angle(0,-90,90), 0.01 )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		--surface.Drawself.circle( 0, 0, 10, Color( 255, 255, 255, 255 ) )
		draw.NoTexture()
		draw.circle( 0, 0, 500, 30 )
	local interval = 1
	local radius = 450
	local alpha = 0
	local alpha2 = 255
	local size = 180
	self.circle = self.circle + (200 * FrameTime())
	if self.circle >= 360 then
		self.circle = 0
	end
	--print(10 * FrameTime())
	for degrees = 1, size, interval do
		local x, y = self:circleMath( degrees, radius, 
		-10, 
		0 )
	alpha = alpha + 1.4
	surface.SetDrawColor( Color( 0, 0, 0, alpha ) )
	surface.DrawRect( x, y, 10, 10 )
	end
	for degrees = 1, size, interval do
		local x, y = self:circleMath2( degrees, radius+20, 
		-10, 
		0 )
	alpha2 = alpha2 - 1.4
	surface.SetDrawColor( Color( 0, 0, 0, alpha2 ) )
	surface.DrawRect( x, y, 10, 10)
	end
	
	
	surface.SetFont( "CommScreen" )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.SetTextPos( -400, -200 )
	surface.DrawText( "Security Status" )
	surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
	surface.DrawRect( -320, -50, 650, 130)
	if self.Door then
		surface.SetTextPos( -300, -50 )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.DrawText( "Active" )
	else
		surface.SetTextPos( -300, -50 )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.DrawText( "N/A" )
	end
	surface.SetTextPos( -400, 100 )
	surface.SetTextColor( 0, 0, 0, 255 )
	if self:GetUsing() then
		surface.DrawText( "Select Deposit" )
	else
		surface.SetTextPos( -200, 100 )
		surface.DrawText( "$"..math.Round(self:GetCash(),2) )
	end
		

	
	--surface.DrawText("Set Deposit")
	cam.End3D2D()
	self:DoorModDetect()
	self:ModelManip()
end

local ConeVis = ScrW()*0.02
local val = 0

function ENT:ModelManip()
	--print(self.rise)
	local val = 1100
	if self:GetUsing() then
		self.rise = Lerp(FrameTime()*4,self.rise, 36)
	else
		self.rise = Lerp(FrameTime()*4,self.rise, 360)
	end
	
	if self.rise <= 40 then
		self.expand = Lerp(FrameTime()*4,self.expand, 36)
	else
		self.expand = Lerp(FrameTime()*4,self.expand, 360)
		self.Sent = false
	end
	
	if self.expand  <= 37 then
		alpha2 = Lerp(FrameTime()*4,alpha2, 255)
	else
		alpha2 = Lerp(FrameTime()*4,alpha2, 0)
	end
	

	--print(self:GetUsing())

	if !self.models then
		for degrees = 1, 360, 36 do
			Gmodel = ClientsideModel("models/hunter/tubes/self.circle2x2.mdl")
			Gmodel:SetModelScale(0.02)
			Gmodel:SetMaterial("models/debug/debugwhite")
			Gmodel:SetRenderMode( RENDERMODE_TRANSALPHA )
			Gmodel:SetColor(Color(0,0,0,0))
			Gmodel:SetAngles(self:GetAngles()+Angle(90,180,0))
			val = val - 100
			Gmodel.value = val
			table.insert(self.GModels, Gmodel)
		end
		self.models = true
		Cmodel = ClientsideModel("models/hunter/tubes/self.circle2x2.mdl")
			Cmodel:SetModelScale(0.02)
			Cmodel:SetMaterial("models/debug/debugwhite")
			Cmodel:SetRenderMode( RENDERMODE_TRANSALPHA )
			Cmodel:SetColor(Color(0,0,0,0))
			Cmodel:SetAngles(self:GetAngles()+Angle(90,180,0))
	end
	Cmodel:SetPos((self:GetPos()+self:GetAngles():Forward()*-12*alpha2*0.005+(self:GetAngles():Up()*47.3)+((self:GetAngles():Right()))+self:GetAngles():Right()*-1)+Vector(0,0,-3))

	if IsValid(self:GetActivator()) and Cmodel:GetPos():ToScreen().x >= ScrW()/2-ConeVis and Cmodel:GetPos():ToScreen().x <= ScrW()/2+ConeVis and
		Cmodel:GetPos():ToScreen().y >= ScrH()/2-ConeVis and Cmodel:GetPos():ToScreen().y <= ScrH()/2+ConeVis and self:GetActivator():EyePos():Distance(Cmodel:GetPos()) <= 50 then
		Cmodel:SetModelScale(Lerp(FrameTime()*10, Cmodel:GetModelScale(), 0.04))
		if self.expand  <= 37 and self:GetUsePressed() then
			net.Start( "CTowerD" )
				net.WriteEntity( self )
				net.WriteFloat( -1 )
			net.SendToServer()
		end
	else
		Cmodel:SetModelScale(Lerp(FrameTime()*10, Cmodel:GetModelScale(), 0.02))
	end
	cam.Start3D2D(Cmodel:GetPos(),self:GetAngles()+Angle(0,-90,90), Cmodel:GetModelScale()*0.4)
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	--draw.self.circle( 0, 0, 160, 30 )
	
	--draw.self.circle( 0, 0, 150, 30 )
	draw.NoTexture()
	local w,h=surface.GetTextSize( "Cancel")
	surface.SetTextPos(5- w/2,80-h )
	surface.SetTextColor( Color( 255, 255, 255, alpha2 ) )
	surface.SetTextColor( Color( 0, 0, 0, 255 ) )
	surface.DrawText( "Cancel" )
	cam.End3D2D()
	local degreeTableX = {}
	local degreeTableY = {}
	for degrees = 1, 360, self.expand do
	mx,my = self:circleMathStatic( degrees, 100, -10, 0 )
		table.insert(degreeTableX,mx)
		table.insert(degreeTableY,my)
	end
	--PrintTable(degreeTableX)
	--PrintTable(self.GModels)
	
	
	for k, m in ipairs(self.GModels) do
		local kx = degreeTableX[k] or degreeTableX[1]
		local ky = degreeTableY[k] or degreeTableY[1]
		
		if IsValid(m) and IsValid(self:GetActivator()) and self.rise < 355 then
			m:SetPos((self:GetPos()+self:GetAngles():Forward()*-12+(self:GetAngles():Up()*47.3)+((self:GetAngles():Right())*kx*0.1)+self:GetAngles():Right()*1)+Vector(0,0,2+ky*0.1-(self.rise*0.03)))
			if m:GetPos():ToScreen().x >= ScrW()/2-ConeVis and m:GetPos():ToScreen().x <= ScrW()/2+ConeVis and
				m:GetPos():ToScreen().y >= ScrH()/2-ConeVis and m:GetPos():ToScreen().y <= ScrH()/2+ConeVis and self:GetActivator():EyePos():Distance(m:GetPos()) <= 50 then
				m:SetModelScale(Lerp(FrameTime()*10, m:GetModelScale(), 0.05))
				if self.expand  <= 37 and self:GetUsePressed() and !self.Sent then
					if self:GetActivator():GetMoney() >= m.value then
					net.Start( "CTowerD" )
						net.WriteEntity( self )
						net.WriteFloat( m.value )
					net.SendToServer()
					self.Sent = true
					else
						sound.Play( "buttons/button16.wav", m:GetPos(), 50, 150, 1 )
					end
				end
			else
				m:SetModelScale(Lerp(FrameTime()*10, m:GetModelScale(), 0.02))
			end
			cam.Start3D2D(m:GetPos(),self:GetAngles()+Angle(0,-90,90), m:GetModelScale()*0.4)
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			draw.circle( 0, 0, 160, 30 )
			surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
			draw.circle( 0, 0, 150, 30 )
			draw.NoTexture()
			local w,h=surface.GetTextSize( tostring(m.value))
			surface.SetTextPos(5- w/2,80-h )
			surface.SetTextColor( Color( 255, 255, 255, alpha2 ) )
			surface.DrawText( m.value )
			
			cam.End3D2D()
		end 
		
	end 
	
	degreeTableX = {}
	degreeTableY = {}
	--GModels = {}
end

function ENT:OnRemove()
	if self.GModels then
		for _, v in ipairs(self.GModels) do
			print("wat",v)
			v:Remove()
		end
	end
	self.GModels = nil
end