AddCSLuaFile()

SWEP.Base = "weapon_zs_executioner"

SWEP.ZombieOnly = true
SWEP.MeleeDamage = 36
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.Primary.Delay = 1.1

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitent:IsPlayer() then
		self.MeleeDamage = 46
	end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end

function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end