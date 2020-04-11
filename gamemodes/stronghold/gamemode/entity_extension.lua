--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

--[[
	GM13 Changes
	
	Added:
	Removed:
	Updated:
	Changed:
		Cleaned Code
]]--

local meta = FindMetaTable( "Entity" )
if !meta then return end

AccessorFuncNW( meta, "m_fMaxHealth", "MaxHealth", 0, FORCE_NUMBER )
AccessorFuncNW( meta, "m_iTeamIndex", "TeamIndex", 0, FORCE_NUMBER )
AccessorFuncNW( meta, "m_entOwnerEnt", "OwnerEnt", NULL, FORCE_ENTITY )
AccessorFuncNW( meta, "m_strOwnerUID", "OwnerUID", "", FORCE_STRING )

local PLAYER_COLOR_MULTIPLIER = 0.80
function meta:GetPlayerColor()
	local ply = self:GetOwnerEnt()
	if IsValid( ply ) and ply:IsPlayer() then
		local col = team.GetColor( ply:Team() )
		return Vector( col.r / 255 * PLAYER_COLOR_MULTIPLIER, col.g / 255 * PLAYER_COLOR_MULTIPLIER, col.b / 255 * PLAYER_COLOR_MULTIPLIER )
	end
	return Vector( 1, 1, 1 )
end

if !meta.oldSetHealth then
	meta.oldSetHealth = meta.SetHealth

	function meta:SetHealth( i )
		self:oldSetHealth( i )
		self:SetNWFloat( "m_fHealth", tonumber(i) or 0 )
	end
end

if !meta.oldHealth then
	meta.oldHealth = meta.Health

	function meta:Health()
		if self:IsPlayer() then
			return self:oldHealth()
		end

		return self:GetNWFloat( "m_fHealth", 0 )
	end

	meta.GetHealth = meta.Health
end

function meta:FixHealthColor()
	local hp, max 	= self:GetHealth(), self:GetMaxHealth()
	local scale 	= math.Clamp( hp/max, 0, 1 )

	if self.m_tblBaseColor then
		self:SetColor( Color(self.m_tblBaseColor.r*scale,self.m_tblBaseColor.g*scale,self.m_tblBaseColor.b*scale,255) )
	elseif self:GetClass() != "bfgm_sent_barricade" then
		self:SetColor( Color(255*scale,255*scale,255*scale,255) )
	end
end

function meta:IsColliding( ent, filter )
	filter = table.Add( filter or {}, {self,game.GetWorld()} )

	local mins, maxs, center 	= self:OBBMins(), self:OBBMaxs(), self:OBBCenter()
	local hmins, hmaxs 			= Vector( -0.5, -0.5, -0.5 ), Vector( -0.5, -0.5, -0.5 )

	local tracepositions = {
		{ start=Vector(mins.x,center.y,center.z), endpos=Vector(maxs.x,center.y,center.z), filter=filter, mins=hmins, maxs=hmaxs },
		{ start=Vector(center.x,mins.y,center.z), endpos=Vector(center.x,maxs.y,center.z), filter=filter, mins=hmins, maxs=hmaxs },
		{ start=Vector(center.x,center.y,mins.z), endpos=Vector(center.x,center.y,maxs.z), filter=filter, mins=hmins, maxs=hmaxs },
		
		{ start=mins,                         endpos=maxs,                         filter=filter, mins=hmins, maxs=hmaxs },
		{ start=Vector(maxs.x,mins.y,maxs.z), endpos=Vector(mins.x,maxs.y,mins.z), filter=filter, mins=hmins, maxs=hmaxs },
		{ start=Vector(mins.x,mins.y,maxs.z), endpos=Vector(maxs.x,maxs.y,mins.z), filter=filter, mins=hmins, maxs=hmaxs },
		{ start=Vector(maxs.x,mins.y,mins.z), endpos=Vector(mins.x,maxs.y,maxs.z), filter=filter, mins=hmins, maxs=hmaxs },
	}
	
	for _, v in ipairs( tracepositions ) do
		v.start 	= self:LocalToWorld( v.start )
		v.endpos 	= self:LocalToWorld( v.endpos )
		local trace = util.TraceHull( v )
		
		if trace.Entity == ent then
			return true
		end
	end

	return false
end

function meta:Dissolve()
	if self:IsPlayer() then return end

	local dissolver = ents.Create( "env_entity_dissolver" )
	dissolver:SetPos( self:LocalToWorld(self:OBBCenter()) )
	dissolver:SetKeyValue( "dissolvetype", 0 )
	dissolver:Spawn()
	dissolver:Activate()
	
	local name = "Dissolving_".. math.random()
	self:SetName( name )
	dissolver:Fire( "Dissolve", name, 0 )
	dissolver:Fire( "Kill", self, 0.10 )
end

function meta:BuildingSolidify()
	if !IsValid( self ) then return end

	local wait 			= false
	local pos 			= self:LocalToWorld( self:OBBCenter() )
	local radius_sqr 	= self:BoundingRadius()
	radius_sqr 			= radius_sqr * radius_sqr
	
	for _, ply in ipairs( player.GetAll() ) do
		if (ply:GetPos()-pos):LengthSqr() < radius_sqr and (ply:IsColliding( self ) or self:IsColliding( ply )) then
			wait = true
			break
		end
	end
	
	if wait then
		if IsValid( self.Owner ) then
			self.Owner:SendMessage( "Biological obstruction, can not solidify prop!", "Prop spawn", false )
		end
		
		timer.Simple( 1, function() self:BuildingSolidify() end )
	else
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
	end
end