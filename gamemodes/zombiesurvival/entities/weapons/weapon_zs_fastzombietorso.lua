AddCSLuaFile()

SWEP.Base = "weapon_zs_zombietorso"

SWEP.PrintName = "Fast Zombie Torso"

SWEP.ViewModel = Model("models/weapons/v_fza.mdl")

SWEP.MeleeDelay = 0.25
SWEP.MeleeDamage = 20
SWEP.BleedDamageMul = 10 / SWEP.MeleeDamage
SWEP.SwingAnimSpeed = 2.4

function SWEP:PlayHitSound()
	self:EmitSound("NPC_FastZombie.AttackHit", nil, nil, nil, CHAN_AUTO)
end

function SWEP:PlayMissSound()
	self:EmitSound("NPC_FastZombie.AttackMiss", nil, nil, nil, CHAN_AUTO)
end

function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/leap1.wav", nil, nil, nil, CHAN_AUTO)
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

function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("NPC_FastZombie.AlertFar")
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("NPC_FastZombie.Frenzy")
end