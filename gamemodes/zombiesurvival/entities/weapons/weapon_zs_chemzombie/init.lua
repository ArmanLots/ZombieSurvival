INC_SERVER()

SWEP.NextAura = 0
function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if self.NextAura <= CurTime() then
		self.NextAura = CurTime() + 0.5

		local origin = self:GetOwner():LocalToWorld(self:GetOwner():OBBCenter())
		for _, ent in pairs(ents.FindInSphere(origin, 60)) do
			if ent and ent:IsValidLivingHuman() and ent:IsBarricadeProp() and TrueVisible(origin, ent:NearestPoint(origin)) then
				ent:PoisonDamage(4, self:GetOwner(), self)
			end
		end
	end
end
