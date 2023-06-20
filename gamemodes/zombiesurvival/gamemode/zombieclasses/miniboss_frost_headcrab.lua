CLASS.Base = "poison_headcrab"

CLASS.Name = "Frost Headcrab"
CLASS.TranslationName = "class_frost_headcrab"
CLASS.Description = "description_frost_headcrab"
CLASS.Help = "controls_frost_headcrab"

CLASS.Health = 210
CLASS.DynamicHealth = 4
CLASS.DamageNeedPerPoint = GM.HeadcrabZombiePointRatio
CLASS.Points = CLASS.Health/GM.HeadcrabZombiePointRatio
CLASS.Speed = 160

--CLASS.Wave = 2 / GM.NumberOfWaves
CLASS.MiniBoss = true
CLASS.Wave = 0
CLASS.Unlocked = true

CLASS.SWEP = "weapon_zs_frostheadcrab"

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/poisonheadcrab"
CLASS.IconColor = Color(0, 0, 205)

local matSkin = Material("Models/Barnacle/barnacle_sheet")
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0, 0, 0.5)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
