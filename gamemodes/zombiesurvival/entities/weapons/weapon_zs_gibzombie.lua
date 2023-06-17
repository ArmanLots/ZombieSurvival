AddCSLuaFile()

SWEP.PrintName = "Gib Zombie"

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 22
SWEP.MeleeDamageVsProps = 24
SWEP.BleedDamageMul = 10 / SWEP.MeleeDamage
SWEP.MeleeForceScale = 1.25

SWEP.Primary.Delay = 1.6

function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

function SWEP:PlayAlertSound()
	self:PlayAttackSound()
end

function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end

function SWEP:PlayAttackSound()
	self:EmitSound("npc/ichthyosaur/attack_growl"..math.random(3)..".wav", 70, math.Rand(100, 110))
end

function SWEP:ApplyMeleeDamage(ent, trace, damage)
	if SERVER and ent:IsPlayer() then
		local bleed = ent:GiveStatus("bleed")
		if bleed and bleed:IsValid() then
			bleed:AddDamage(damage * self.BleedDamageMul)
			bleed.Damager = self:GetOwner()
		end
	end

	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end

function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
	render.SetColorModulation(1, 0, 0)
end