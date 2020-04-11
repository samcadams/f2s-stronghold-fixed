--[[
	File: cl_init.lua
	For: FTS: Stronghold
	By: Ultra
]]--

include "shared.lua"

function ENT:Draw()
	self:DrawModel()
end

--[[
hook.Add( "HUDPaint", "ASfsaff", function()
	for _, ent in pairs( ents.GetAll() ) do
		if ent:GetClass() ~= "sent_uplink" then continue end
		
		local pos, ang = ent:GetBonePosition( 4 )
		if not pos then return end

		local dish = pos:ToScreen()
		pos = pos +ang:Forward() *20
		local target = pos:ToScreen()

		local filter = player.GetAll()
		table.insert( filter, self )
		local t = util.QuickTrace(
			pos,
			ang:Forward() *9e9,
			filter
		).HitPos

		local hit = t:ToScreen()

		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawRect( dish.x, dish.y, 5, 5 )
		surface.DrawRect( target.x, target.y, 5, 5 )
		surface.DrawRect( hit.x, hit.y, 10, 10 )
	end
end )]]--