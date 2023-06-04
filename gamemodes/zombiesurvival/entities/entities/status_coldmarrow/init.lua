INC_SERVER()

function ENT:Think()
	local owner = self:GetOwner()

	if self.DieTime <= CurTime() or not (owner:Alive() and owner:Team() == TEAM_UNDEAD and owner:GetZombieClassTable().Name == "Cold Marrow") then
		self:Remove()
	end
end
