AddCSLuaFile()

DEFINE_BASECLASS("weapon_zs_lacerator")

SWEP.PrintName = "Mutated Lacerator"

SWEP.MeleeDamage = 11

SWEP.SlowMeleeDelay = 0.95
SWEP.SlowMeleeDamage = 24
SWEP.PounceDamage = 32

function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = math.floor(damage * 1.2)
	end

	ent:PoisonDamage(damage, self:GetOwner(), self, trace.HitPos)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(0.2, 0.5, 0)
end
