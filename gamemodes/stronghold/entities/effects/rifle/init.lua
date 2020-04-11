function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	if !IsValid(self.WeaponEnt) then return end
	local OwnerAim = self.WeaponEnt:GetOwner():GetAimVector()
	local tr = util.QuickTrace(self.WeaponEnt:GetOwner():EyePos(), OwnerAim*10000,self.WeaponEnt:GetOwner())
	local Ntr = util.TraceLine( {
	start = self.WeaponEnt:GetOwner():GetShootPos(),
	endpos = LocalPlayer():EyePos(),
	} )

	local SnapSpotPlane = util.IntersectRayWithPlane( self.WeaponEnt:GetOwner():GetShootPos(), OwnerAim, LocalPlayer():EyePos(), Ntr.Normal )

	if SnapSpotPlane and self.WeaponEnt:GetOwner():GetShootPos():Distance(SnapSpotPlane) < tr.StartPos:Distance(tr.HitPos) then
		if SnapSpotPlane:Distance(LocalPlayer():EyePos()) < 250 then
			sound.Play( "stronghold/whiz.mp3", SnapSpotPlane, 60, math.random( 90, 100 ), 1 )
		end
	end
end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end