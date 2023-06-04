CLASS.Base = "elder_ghoul"

CLASS.Name = "Prime Ghoul"
CLASS.TranslationName = "class_primeghoul"
CLASS.Description = "description_primeghoul"
CLASS.Help = "controls_noxiousghoul"

CLASS.Health = 820
CLASS.DynamicHealth = 20
CLASS.Speed = 180

CLASS.SemiBoss = true
CLASS.Unlocked = true

CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio
CLASS.NoPlayerColor = true

CLASS.SWEP = "weapon_zs_primeghoul"

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/ghoul"
CLASS.IconColor = Color(178, 34, 34)

local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

local colGlow = Color(255, 0, 0)
local matSkin = Material("Models/humans/corpse/corpse1.vtf")
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(1, 0, 0)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 10, 0.5, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 3, 3, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 10, 0.5, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 3, 3, colGlow)
	end
end
