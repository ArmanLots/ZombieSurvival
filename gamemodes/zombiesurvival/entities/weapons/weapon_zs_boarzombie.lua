AddCSLuaFile()

SWEP.PrintName = "Boar Zombie"

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 33
SWEP.SlowDownScale = 0

SWEP.AlertDelay = 3.5

function SWEP:Reload()
	self:SecondaryAttack()
end

function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav", 70, math.random(87, 92))
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/zombie/zombie_alert"..math.random(3)..".wav", 70, math.random(87, 92))
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("models/props_wasteland/tugboat02")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
