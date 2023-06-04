AddCSLuaFile()

SWEP.PrintName = "The Tickle Monster"

SWEP.Base = "weapon_zs_zombie"

SWEP.ViewModel = Model("models/weapons/v_fza.mdl")
SWEP.WorldModel = ""

if CLIENT then
	SWEP.ViewModelFOV = 115
end

SWEP.MeleeDamage = 22
SWEP.MeleeDamageVsProps = 24
SWEP.MeleeReach = 115
SWEP.MeleeSize = 2

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
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav")
end
