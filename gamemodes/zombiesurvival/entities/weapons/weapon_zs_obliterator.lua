AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Obliterator"
end

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 48
SWEP.MeleeDamageVsProps = 85
SWEP.Primary.Delay = 1.2

SWEP.AlertDelay = 3.5

function SWEP:Reload()
	self:SecondaryAttack()
end

function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/combine_gunship/gunship_moan.wav", 75, math.random(65,75))
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self:EmitSound("npc/metropolice/pain"..math.random(2)..".wav", 95, math.Rand(45, 50), 0.95, CHAN_AUTO)
	--self:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 80, math.random(112, 115), 0.5, CHAN_AUTO)
end


if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(0, 0, 0)
end