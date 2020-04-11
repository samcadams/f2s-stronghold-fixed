

local matScreen 	= Material( "models/weapons/v_toolgun/screen" )
local txidScreen	= surface.GetTextureID( "models/weapons/v_toolgun/screen" )
local txRotating	= surface.GetTextureID( "pp/fb" )

local txBackground	= surface.GetTextureID( "tool/BG" )


// GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture 	= GetRenderTarget( "GModToolgunScreen", 256, 256 )

surface.CreateFont( "GModToolScreen", {
	font = "Arial Black",
	size = 64,
	weight = 100
} )

local function DrawScrollingText( text, y, texwide )

		local w, h = surface.GetTextSize( text  )
		w = w + 32
		
		local x = math.fmod( CurTime() * 200, w ) * -1;
		
		while ( x < texwide ) do
		
			surface.SetTextColor( 0, 0, 0, 255 )
			surface.SetTextPos( x+3, -4 )
			surface.DrawText( text )
				
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( x, -8 )
			surface.DrawText( text )
			
			x = x + w
			
		end

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
		
		-- Give our toolmode the opportunity to override the drawing
		if ( self:GetToolObject() and self:GetToolObject().DrawToolScreen ) then 
		
			self:GetToolObject():DrawToolScreen( TEX_SIZE, TEX_SIZE )
		
		else
			
			surface.SetFont( "GModToolScreen" )
			DrawScrollingText( "#Tool_"..mode.."_name", 32, TEX_SIZE )
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( surface.GetTextureID( "tool/screen/"..mode ) )
			surface.DrawTexturedRect( 76, 100, 100, 100 )
				
		end

	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )
	
end
