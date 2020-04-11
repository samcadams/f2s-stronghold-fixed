

local matScreen 	= Material( "models/weapons/v_toolgun/screen" )
local txidScreen	= surface.GetTextureID( "models/weapons/v_toolgun/screen" )
local txRotating	= surface.GetTextureID( "pp/fb" )

local txBackground	= surface.GetTextureID( "skybox/sky_borealis01dn" )


// GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture 	= GetRenderTarget( "GModToolgunScreen", 256, 256 )

surface.CreateFont( "GPScreen", {
	font = "Calibri",
	size = 32,
	weight = 10
} )
surface.CreateFont( "Info", {
	font = "Calibri",
	size = 24,
	weight = 10
} )

surface.CreateFont( "Info2", {
	font = "Calibri",
	size = 20,
	weight = 10
} )

--[[local function DrawScrollingText( text, y, texwide )

		local w, h = surface.GetTextSize( text  )
		w = w + 32
		
		local x = 0--math.fmod( CurTime() * 20, w ) * -1;
		
		--while ( x < texwide ) do
		
			surface.SetTextColor( 0, 0, 0, 255 )
			surface.SetTextPos( x+5, -3 )
			surface.DrawText( text )
				
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( x+5, -5 )
			surface.DrawText( text )
			
			x = x + w
			
		--end

end]]

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode 
		screen's rendertarget texture.
---------------------------------------------------------]]--
local found = 0
local ping = 0
local fade = 255
function SWEP:RenderScreen()
	
	local TEX_SIZE = 256
	local mode 	= gmod_toolmode:GetString()
	local NewRT = RTTexture
	local oldW = ScrW()
	local oldH = ScrH()

	-- Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", NewRT )
	
	local OldRT = render.GetRenderTarget();
	
	-- Set up our view for drawing to the texture
	render.SetRenderTarget( NewRT )
	render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
	cam.Start2D()
	
	if !self.Owner:KeyDown(IN_ATTACK2) then
		fade = Lerp(FrameTime()*20,fade,255)
	else
		fade = Lerp(FrameTime()*20,fade,0)
	end
	local Running = self.Owner:KeyDown( bit.bor(IN_FORWARD,IN_BACK,IN_MOVELEFT,IN_MOVERIGHT) ) and self.Owner:KeyDown( IN_SPEED )
		if self.Owner:KeyDown(IN_ATTACK2) and self.Owner:KeyPressed(IN_ATTACK) and self:Clip1() >0 and !Running and self.Owner:GetColor().a > 254 then
		ping = 255
		end

		-- Background
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )
		
		surface.SetTextColor( 255, 255, 255, fade )
		surface.SetFont("Info")
		surface.SetTextPos( 10, 10 )
		surface.DrawText("Bounties Found: "..found)
		found = 0
		surface.SetTextPos( 10, 40 )
		surface.DrawText("Hold secondary fire to enter")
		surface.SetTextPos( 10, 60 )
		surface.DrawText("scan mode.")
		surface.SetTextPos( 10, 90 )
		surface.DrawText("While in scan mode, press")
		surface.SetTextPos( 10, 110 )
		surface.DrawText("fire to ping for bountied")
		surface.SetTextPos( 10, 130 )
		surface.DrawText("players.")
		
		surface.SetTextPos( 10, 160 )
		surface.DrawText("Bountied players will show")
		surface.SetTextPos( 10, 180 )
		surface.DrawText("as blips on this screen if")
		surface.SetTextPos( 10, 200 )
		surface.DrawText("they are in front of you.")
		
		surface.SetTextColor( 255, 255, 255, 255-fade )
		surface.SetFont("Info")
		surface.SetTextPos( 10, 10 )
		surface.DrawText("SCAN MODE - ")
		
		surface.SetTextColor( 150, 255, 150, ping )
		surface.SetFont("Info")
		surface.SetTextPos( 130, 10 )
		surface.DrawText("PINGING")
		local dist = 0
		ping = Lerp(FrameTime()*10, ping,0)
			for k,v in pairs(player.GetAll()) do
				if v.bounty and v.bounty > 0 and v !=LocalPlayer() and v:Alive() then
					found = found + 1
					dist = v:GetPos():Distance(EyePos())*0.1
						Scr = (v:GetPos()+Vector(0,0,50)):ToScreen()
					surface.DrawCircle( (TEX_SIZE/oldW)*Scr.x, (TEX_SIZE/oldH)*Scr.y, (255-ping+dist)*0.2, Color(255,255,255,ping*(v.bounty*0.001)) )
					for x,m in pairs(ents.FindByClass("sent_spawnpoint")) do
					print(v,m.Owner)
						Scr2 = (m:GetPos()+Vector(0,0,50)):ToScreen()
						if m.Owner == v then
							surface.SetDrawColor( Color(0,255,255,ping*(v.bounty*0.001)))
							surface.DrawRect( (TEX_SIZE/oldW)*Scr2.x, (TEX_SIZE/oldH)*Scr2.y, (255-dist)*0.1,(255-dist)*0.1)
						end
					end
				end
			end
		
	

	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )
	
end
