AddCSLuaFile()

SWEP.PrintName = "Drencher"

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 45
SWEP.MeleeDamageVsProps = 62
SWEP.BleedDamageMul = 22 / SWEP.MeleeDamage 
SWEP.SlowDownScale = 1
SWEP.MeleeReach = 78
SWEP.MeleeForceScale = 1.5
--SWEP.NextAura = 0

SWEP.AlertDelay = 3.5

function SWEP:Reload()
	self:SecondaryAttack()
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/combine_gunship/gunship_moan.wav", 100, math.random(30,35))
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 100, math.random(30,35))
end

function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

--function SWEP:Think()
	--if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		--self.IdleAnimation = nil
		--self:SendWeaponAnim(ACT_VM_IDLE)
	--end

	--if self.NextAura <= CurTime() then
		--self.NextAura = CurTime() + 0.4

		--local origin = self:GetOwner():LocalToWorld(self:GetOwner():OBBCenter())
		--for _, ent in pairs(ents.FindInSphere(origin, 60)) do
			--if ent and ent:IsBarricadeProp() and TrueVisible(origin, ent:NearestPoint(origin)) then
				--ent:PoisonDamage(3, self:GetOwner(), self)
			--end
		--end
	--end
--end

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

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/flesh")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end