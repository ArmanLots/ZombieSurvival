INC_SERVER()

ENT.HealthLock = 0
ENT.AttackMessageCooldown = 20

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderFX(kRenderFxDistort)

	self:SetModel("models/props_wasteland/medbridge_post01.mdl")
	self:PhysicsInitBox(Vector(-16.285, -16.285, -0.29) * self.ModelScale, Vector(16.285, 16.285, 104.29) * self.ModelScale)
	self:SetUseType(SIMPLE_USE)

	self:CollisionRulesChanged()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self:SetSigilHealthBase(self.MaxHealth)
	self:SetSigilHealthRegen(self.HealthRegen)
	self:SetSigilLastDamaged(0)

	local ent = ents.Create("prop_prop_blocker")
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:SetOwner(self)
		--ent:SetParent(self) -- Prevents collisions
		self:DeleteOnRemove(ent)
	end
end

function ENT:Use(pl)
	if pl.NextSigilTPTry and pl.NextSigilTPTry >= CurTime() then return end

	if pl:Team() == TEAM_HUMAN and pl:Alive() and not self:GetSigilCorrupted() then
		local tpexist = pl:GetStatus("sigilteleport")
		if tpexist and tpexist:IsValid() then return end

		if GAMEMODE:NumUncorruptedSigils() >= 2 then
			local status = pl:GiveStatus("sigilteleport")
			if status:IsValid() then
				status:SetFromSigil(self)
				status:SetEndTime(CurTime() + 2 * (pl.SigilTeleportTimeMul or 1))

				pl.NextSigilTPTry = CurTime() + 1
			end
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if self:GetSigilHealth() <= 0 or dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() and dmginfo:GetDamage() > 2 and CurTime() >= self.HealthLock then
		if self:CanBeDamagedByTeam(attacker:Team()) then
			local damagemul = math.Clamp(tonumber(8 + #player.GetAll() / #player.GetAll() * 1.4), 0.8, 3)
			if attacker:Team() == TEAM_HUMAN then
				local dmgtype = dmginfo:GetDamageType()
				if bit.band(dmgtype, DMG_SLASH) ~= 0 or bit.band(dmgtype, DMG_CLUB) ~= 0 then
					dmginfo:SetDamage(dmginfo:GetDamage() * 1.6 * (attacker:IsSkillActive(SKILL_UNCORRUPTOR) and 0.85 or 1) * damagemul)
				elseif attacker:IsSkillActive(SKILL_UNCORRUPTOR) then
					dmginfo:SetDamage(dmginfo:GetDamage() * 1.28 * 0.85 * damagemul)
				else
					dmginfo:SetDamage(0)
					return
				end
			elseif attacker:Team() == TEAM_UNDEAD then
				dmginfo:SetDamage(dmginfo:GetDamage() * damagemul)
			end

			local oldhealth = self:GetSigilHealth()
			self:SetSigilLastDamaged(CurTime())
			self:SetSigilHealthBase(oldhealth - dmginfo:GetDamage())

			if (self.LastAttackTime or 0) + self.AttackMessageCooldown < CurTime() and not self:GetSigilCorrupted() then
				local letter = "?"
				for i, sigil in pairs(ents.FindByClass("prop_obj_sigil")) do
					if self == sigil then
						letter = string.char(64 + i)
						break
					end
				end
				self.LastAttackTime = CurTime()

				for _,pl in pairs(team.GetPlayers(TEAM_HUMAN)) do
					pl:CenterNotify(COLOR_WHITE, Format("Sigil %s is under attack!", letter))
				end
			end 

			if self:GetSigilHealth() <= 0 then
				if self:GetSigilCorrupted() then
					gamemode.Call("PreOnSigilUncorrupted", self, dmginfo)
					self:SetSigilCorrupted(false)
					self:SetSigilHealthBase(self.MaxHealth * 0.5)
					self:SetSigilLastDamaged(0)
					gamemode.Call("OnSigilUncorrupted", self, dmginfo)
					attacker:GiveAchievementProgress("sigil_uncorruptor", 1)
				else
					gamemode.Call("PreOnSigilCorrupted", self, dmginfo)
					self:SetSigilCorrupted(true)
					self:SetSigilHealthBase(self.MaxHealth)
					self:SetSigilLastDamaged(0)
					gamemode.Call("OnSigilCorrupted", self, dmginfo)
				end
			end
		elseif attacker:Team() == TEAM_UNDEAD then
			self.HealthLock = CurTime() + 1
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
