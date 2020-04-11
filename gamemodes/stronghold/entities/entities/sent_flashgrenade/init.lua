AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Use( ply )
	ply:PickupObject( self )
end

function ENT:Think()
	if !self.Flashed and CurTime() - self.Created >= self.dt.Duration then
		self:Flash()
		timer.Simple( 10,
			function()
				if IsValid( self ) then 
					self:Remove()
				end
			end )
		self.Flashed = true
	end
end

local FlashSnd = Sound( "Flashbang.Explode" )
local FlashDistance = 750
function ENT:Flash()
	self:EmitSound( FlashSnd )
	
	local effectdata = EffectData( )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "flash_smoke", effectdata, true, true )

	local pos = self:LocalToWorld( self:OBBCenter() )
	for _, v in ipairs(player.GetAll()) do
		local epos = v:EyePos()
		local tr = util.TraceLine( {start=epos,endpos=pos,filter=v} )
		local norm = (pos-epos)
		local dist = norm:Length()
		if dist <= FlashDistance and (tr.Entity == self or (tr.HitPos-pos):Length() <= 1) then
			local t = (-dist/FlashDistance+1) * 8
			local ang = math.deg( math.acos(norm:DotProduct(v:GetAimVector()) / dist) )
			net.Start( "sh_flashed" )
				net.WriteFloat( math.Clamp(t*(-ang/181+1),0,8) )
			net.Send( v )
			if dist < FlashDistance*0.60 then
				v:SetDSP( 34, false )
			end
		end
	end
	self:SetColor( Color(0,0,0,255) )
end