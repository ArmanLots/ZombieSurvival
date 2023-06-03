CLASS.Base = "bloated_zombie"

CLASS.Name = "Writher Zombie"
CLASS.TranslationName = "class_writher_zombie"
CLASS.Description = "description_writher_zombie"
CLASS.Help = "controls_writher_zombie"


CLASS.Wave = 6 / GM.NumberOfWaves

CLASS.Health = 560
CLASS.DynamicHealth = 8
CLASS.Speed = 155

CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

CLASS.SWEP = "weapon_zs_writherzombie"

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