AddCSLuaFile()

SWEP.PrintName = "Ancient Nightmare"

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 45
SWEP.MeleeDamageVsProps = 65
SWEP.SlowDownScale = 1

function SWEP:Reload()
	self:SecondaryAttack()
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav", 75, 85)
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

local matSheet = Material("Models/Charple/Charple1_sheet")
function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(0, 0, 0)
end
