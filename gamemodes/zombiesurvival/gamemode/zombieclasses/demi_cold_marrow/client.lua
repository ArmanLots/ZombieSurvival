include("shared.lua")

CLASS.Icon = "zombiesurvival/killicons/skeletal_walker"
CLASS.IconColor = Color(0, 0, 255)

local matSkin = Material("Models/Barnacle/barnacle_sheet")
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0, 0, 1)
	render.ModelMaterialOverride(matSkin)
end

function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end
