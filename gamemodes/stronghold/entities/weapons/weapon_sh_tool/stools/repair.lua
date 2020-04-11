local HEALTH_BAR = CreateClientConVar( "sh_repair_healthbar", "1", true, false )
local HEALTH_NUM = CreateClientConVar( "sh_repair_healthnum", "1", true, false )

local SND_SPARK = Sound( "weldspark.wav" )
local SND_SHOCK = Sound( "npc/scanner/scanner_electric1.wav" )

TOOL.Category			= "Fight To Survive"
TOOL.Name				= "Repair/Damage"
TOOL.Command			= nil
TOOL.ConfigName			= ""

if CLIENT then TOOL.SelectIcon = surface.GetTextureID( "tool/repair" ) end
TOOL.LeftClickAutomatic	= true
TOOL.RightClickAutomatic = true
TOOL.NoAuthOnWorld = true
TOOL.NoAuthOnPlayer = false
TOOL.RequiresTraceHit = true
TOOL.TraceDistance = 50

if CLIENT then
	language.Add( "Tool_repair_name", "Repair Tool" )
	language.Add( "Tool_repair_desc", "Repair/Damage anything damagable." )
	language.Add( "Tool_repair_0", "Primary to repair. Secondary to deal damage." )
end

function TOOL:LeftClick( tr )
	if !self.NextRepairTime then self.NextRepairTime = CurTime() end
	if self.NextRepairTime >= CurTime() then return false end
	
	if IsValid( tr.Entity ) and !tr.Entity:IsPlayer() then
		local hp, max = tr.Entity:Health(), tr.Entity:GetMaxHealth()
		local effectpos = tr.HitPos + 2 * tr.HitNormal
		if max > 0 and hp < max then
			if SERVER then
				if tr.Entity.CanRepair then
					tr.Entity:SetHealth( math.min(max,hp+4) )
					if tr.Entity:IsOnFire() then tr.Entity:Extinguish() end
					
					local c = 255 * (tr.Entity:Health() / max)
					if !GAMEMODE.BuildingProps[tr.Entity] then tr.Entity:SetColor( Color(c,c,c,255) ) end
					sound.Play( SND_SPARK, tr.HitPos - 2 * tr.HitNormal, 60, 100+math.random(0,10), 1 )
				end
			end
			
		
			local effect = EffectData()
				effect:SetNormal( tr.HitNormal )
				effect:SetStart( effectpos )
				effect:SetOrigin( effectpos )
				effect:SetMagnitude( 1 )
				effect:SetRadius( 1 )
				effect:SetScale( math.Rand(1,2))
			util.Effect( "Sparks", effect )
			util.Effect( "RepairHit", effect )
		end
	end
	self.NextRepairTime = CurTime() + 0.02
	return false
end

function TOOL:RightClick( tr )
	if !self.NextRepairTime then self.NextRepairTime = CurTime() end
	if self.NextRepairTime >= CurTime() then return false end
    
	if IsValid( tr.Entity ) then
		local effectpos = tr.HitPos + 2 * tr.HitNormal
		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker( self:GetOwner() )
			dmginfo:SetInflictor( self:GetSWEP() )
			if tr.Entity:IsPlayer() then
				dmginfo:SetDamage( 25 )
			else
				dmginfo:SetDamage( 2 )
			end
			tr.Entity:TakeDamageInfo( dmginfo )
			sound.Play( SND_SPARK, tr.HitPos - 2 * tr.HitNormal, 60, 100+math.random(0,10), 1 )
		end
		
		local effect = EffectData()
			effect:SetNormal( tr.HitNormal )
			effect:SetStart( effectpos )
			effect:SetOrigin( effectpos )
			effect:SetMagnitude( 1 )
			effect:SetRadius( 1 )
			effect:SetScale( math.Rand(1,2) )
		util.Effect( "Sparks", effect )
		util.Effect( "RepairHit", effect )
	end
	
	self.NextRepairTime = CurTime() + 0.02
	return false
end

function TOOL:Think()
	if !SERVER then return end
	if !self.NextShockTime then self.NextShockTime = CurTime() end
	if self.NextShockTime > CurTime() then return end
	
	local ply = self:GetOwner()
	if ply:KeyDown( IN_USE ) and !ply:KeyDownLast( IN_USE ) then
		local trace, _ = self.SWEP:Authorize()
		if trace then
		
			self.NextShockTime = CurTime() + 1.25
			trace.Entity:EmitSound( SND_SHOCK )
			
			local pos = trace.Entity:LocalToWorld( trace.Entity:OBBCenter() )
			for _, v in ipairs(ents.FindInSphere(pos,trace.Entity:BoundingRadius()+50)) do
				if v:IsPlayer() and v != ply and (ply:Team() == 50 or ply:Team() != v:Team()) then
					local plypos = v:LocalToWorld( v:OBBCenter() )
					if (plypos-trace.Entity:NearestPoint(plypos)):Length() <= 50 then
						v:TakeDamage( 10, trace.Entity, ply )
					end
				end
			end
			
		end
	end
end

if CLIENT then
	function TOOL:DrawHUD()
		local ply = self:GetOwner()
		local ownerpos, team_index = ply:EyePos(), ply:Team()
		for _, v in ipairs(ents.FindInSphere(ownerpos,200)) do
			if IsValid( v ) and !v:IsPlayer() then
				local pos = v:LocalToWorld( v:OBBCenter() )
				if v:GetMaxHealth() > 1 then
					pos = pos:ToScreen()
					pos.x, pos.y = math.floor( pos.x ), math.floor( pos.y )
					
					if pos.visible and HEALTH_BAR:GetBool() then
						draw.RoundedBox( 4, pos.x-16, pos.y-6, 32, 12, Color(180,180,180,255) )
						local health = v:Health()/v:GetMaxHealth()
						local hw = math.floor( 28*health )
						local c = Color( 255*(-health+1), 255*health, 0, 255 )
						surface.SetDrawColor( c.r, c.g, c.b, c.a )
						surface.DrawRect( pos.x-14, pos.y-4, hw, 8 )
						if health < 1 then
							surface.SetDrawColor( 0, 0, 0, 255 )
							surface.DrawRect( pos.x-14+hw, pos.y-4, 28-hw, 8 )
						end
					end
					if HEALTH_NUM:GetBool() then draw.SimpleTextOutlined( math.floor(v:Health()).."/"..v:GetMaxHealth(), "DermaDefault", pos.x, pos.y+18, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0,255) ) end
				end
			end
		end
	end
end