CLASS.Base = "bloated_zombie"

CLASS.Name = "Gib Zombie"
CLASS.TranslationName = "class_gib_zombie"
CLASS.Description = "description_gib_zombie"
CLASS.Help = "controls_gib_zombie"


CLASS.MiniBoss = true

CLASS.Health = 675
CLASS.DynamicHealth = 25
CLASS.Speed = 135

CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

CLASS.SWEP = "weapon_zs_gibzombie"

CLASS.Model = Model("models/player/fatty/fatty.mdl")

local math_random = math.random
local string_format = string.format

function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("npc/zombie_poison/pz_idle%d.wav", math_random(2, 3)), 65, 70)
	pl.NextPainSound = CurTime() + 0.5

	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/ichthyosaur/water_growl5.wav", 72, 40)

	return true
end