AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = "Pluse Turret"
SWEP.Description = "A high powered turret that can fire pluse slowing shots. Every 20 shots fires a energy ball which can bounce of multiple zombies.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 30

SWEP.GhostStatus = "ghost_gunturret_pluse"
SWEP.DeployClass = "prop_gunturret_pluse"

SWEP.TurretAmmoType = "pluse"
SWEP.TurretAmmoStartAmount = 30
SWEP.TurretSpread = 2

SWEP.Tier = 5

SWEP.Primary.Ammo = "turret_pluse"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)