

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

local function DrawScrollingText( text, y, texwide )

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

end

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode 
		screen's rendertarget texture.
---------------------------------------------------------]]--
function SWEP:RenderScreen()
	
	local TEX_SIZE = 256
	local mode 	= gmod_toolmode:GetString()
	local NewRT = RTTexture
	local oldW = ScrW()
	local oldH = ScrH()
	local tr = util.TraceLine( {
	start = EyePos(),
	endpos = EyePos() + EyeAngles():Forward() * 30,
	filter = function( ent ) if ( ent:GetClass() == "sent_doormod" ) then return true end end
	} )
	
	-- Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", NewRT )
	
	local OldRT = render.GetRenderTarget();
	
	-- Set up our view for drawing to the texture
	render.SetRenderTarget( NewRT )
	render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
	cam.Start2D()
	
		-- Background
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )
		
		surface.SetFont( "GPScreen" )
		DrawScrollingText( "Gibson Penetrator", 32, TEX_SIZE )
		
		surface.SetFont("Info")
		surface.SetTextPos( 20, 30 )
		surface.DrawText("Owner: ")
		if IsValid(tr.Entity) then
		surface.DrawText(tr.Entity:GetOwner():GetName())
		else
		surface.DrawText(" N/A")
		end
		
		surface.SetFont("Info")
		surface.SetTextPos( 20, 50 )
		surface.DrawText("Current Security Level: ")
		if IsValid(tr.Entity) then
		surface.DrawText(tr.Entity.Level)
		if self.Marker then
		surface.DrawText("*")
		end
		else
		surface.DrawText(" N/A")
		end
		
		surface.SetFont("Info")
		surface.SetTextPos( 20, 70 )
		surface.DrawText("Status: ")
		if IsValid(tr.Entity) and self.Owner:KeyDown(IN_ATTACK2)then
			surface.DrawText("Connected")
		else
			surface.DrawText("No Connection")
		end
		
		if self.Marker then
			surface.SetFont("Info2")
			surface.SetTextPos( 20, 100 )
			surface.DrawText("Enemy communications")
			surface.SetTextPos( 20, 120 )
			surface.DrawText("equipment nearby.")
			surface.SetTextPos( 20, 140 )
			surface.DrawText("Security firmware")
			surface.SetTextPos( 20, 160 )
			surface.DrawText("has been upgraded.")
		end
		-- Give our toolmode the opportunity to override the drawing
		--[[if ( self:GetToolObject() and self:GetToolObject().DrawToolScreen ) then 
		
			self:GetToolObject():DrawToolScreen( TEX_SIZE, TEX_SIZE )
		
		else
			
			surface.SetFont( "GModToolScreen" )
			DrawScrollingText( "#Tool_"..mode.."_name", 32, TEX_SIZE )
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( surface.GetTextureID( "screen/"..mode ) )
			surface.DrawTexturedRect( 0, 32, 256, 256 )
				
		end]]

	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )
	
end
