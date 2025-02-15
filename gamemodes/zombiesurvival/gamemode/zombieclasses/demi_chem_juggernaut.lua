CLASS.Name = "Chem Juggernaut"
CLASS.TranslationName = "class_chem_juggernaut"
CLASS.Description = "description_chem_juggernaut"
CLASS.Help = "controls_chem_juggernaut"

CLASS.SemiBoss = true

CLASS.KnockbackScale = 0

CLASS.FearPerInstance = 0.4

CLASS.CanTaunt = true

CLASS.Points = 20

CLASS.SWEP = "weapon_zs_chemjuggernaut"

CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")
CLASS.OverrideModel = Model("models/player/zombie_lacerator2.mdl")

CLASS.Health = 975
CLASS.DynamicHealth = 75
CLASS.Speed = 170

CLASS.VoicePitch = 0.65

CLASS.ModelScale = 1
--CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
--CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}
--CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
--CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
--CLASS.StepSize = 25
--CLASS.Mass = DEFAULT_MASS * CLASS.ModelScale

CLASS.BloodColor = BLOOD_COLOR_YELLOW

local math_random = math.random
local math_min = math.min
local math_ceil = math.ceil
local CurTime = CurTime

local DIR_BACK = DIR_BACK
local ACT_INVALID = ACT_INVALID
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE.BaseClass, pl, iType, bWalking) * 1.8
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/ichthyosaur/water_growl5.wav", 72, 40)

	return true
end

function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/combine_soldier/pain"..math_random(3)..".wav", 75, math.Rand(60, 65))
	pl.NextPainSound = CurTime() + 0.5

	return true
end

local StepSounds = {
	"npc/zombie_poison/pz_left_foot1.wav"
}
local ScuffSounds = {
	"npc/zombie_poison/pz_right_foot1.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math_random() < 0.333 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 80, 90)
	else
		pl:EmitSound(StepSounds[math_random(#StepSounds)], 80, 90)
	end

	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	elseif pl:Crouching() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		else
			return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
		end
	else
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5 , 3))
	else
		pl:SetPlaybackRate(1 / self.ModelScale)
	end

	return true
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

---if SERVER then
	--function CLASS:ProcessDamage(pl, dmginfo)
		--local wep = pl:GetActiveWeapon()
		--if wep:IsValid() and wep.GetBattlecry and wep:GetBattlecry() > CurTime() then
			--dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)
		--end
	--end

	--function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		--local fakedeath = pl:FakeDeath(234, self.ModelScale)
		--if fakedeath and fakedeath:IsValid() then
			--fakedeath:SetModel(self.OverrideModel)
		--end

		--return true
	--end
--end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/howler"
CLASS.IconColor = Color(127, 255, 0)

function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.2, 1, 0)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(0.2, 1, 0)
end
