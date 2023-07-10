CLASS.Name = "Drencher"
CLASS.TranslationName = "class_drencher"
CLASS.Description = "description_drencher"
CLASS.Help = "controls_drencher"

--CLASS.Wave = 7 / 6
--CLASS.Hidden = true
--CLASS.Disabled = true

CLASS.SuperBoss = true

CLASS.Health = 9000
CLASS.DynamicHealth = 0
CLASS.Speed = 130

CLASS.KnockbackScale = 0

CLASS.CanTaunt = true
CLASS.FearPerInstance = 1

CLASS.Points = 120

CLASS.SWEP = "weapon_zs_drencher"

CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")
CLASS.OverrideModel = Model("models/Zombie/Poison.mdl")

CLASS.VoicePitch = 0.6

CLASS.ModelScale = 1.4
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
CLASS.StepSize = 25
CLASS.Mass = DEFAULT_MASS * CLASS.ModelScale

local CurTime = CurTime
local math_random = math.random
local math_ceil = math.ceil
local math_Clamp = math.Clamp
local math_min = math.min
local math_max = math.max
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_IDLE_ZOMBIE = ACT_HL2MP_IDLE_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_WALK_ZOMBIE_01 = ACT_HL2MP_WALK_ZOMBIE_01
local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD
local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY
local ACT_GMOD_GESTURE_RANGE_ZOMBIE = ACT_GMOD_GESTURE_RANGE_ZOMBIE
local ACT_INVALID = ACT_INVALID
local PLAYERANIMEVENT_RELOAD = PLAYERANIMEVENT_RELOAD
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_FOOT
local HITGROUP_HEAD = HITGROUP_HEAD
local HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
local HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
local DMG_ALWAYSGIB = DMG_ALWAYSGIB
local DMG_BURN = DMG_BURN
local DMG_CRUSH = DMG_CRUSH
local bit_band = bit.band

function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

function CLASS:KnockedDown(pl, status, exists)
	pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
end

local StepLeftSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[math_random(#StepLeftSounds)], 70)
	else
		pl:EmitSound(StepRightSounds[math_random(#StepRightSounds)], 70)
	end

	return true
end

function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/combine_soldier/pain"..math_random(3)..".wav", 100, math.Rand(30, 35))
	pl.NextPainSound = CurTime() + 0.5

	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/stalker/go_alert2a.wav", 100, math.Rand(30, 35))

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 625 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 600
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 750
	end

	return 450
end

function CLASS:CalcMainActivity(pl, velocity)
	local revive = pl.Revive
	if revive and revive:IsValid() then
		return ACT_HL2MP_ZOMBIE_SLUMP_RISE, -1
	end

	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetDirection() == DIR_BACK then
			return 1, pl:LookupSequence("zombie_slump_rise_02_fast")
		end

		return ACT_HL2MP_ZOMBIE_SLUMP_RISE, -1
	end

	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsMoaning and wep:IsMoaning() then
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end

		return ACT_HL2MP_IDLE_ZOMBIE, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end

	return ACT_HL2MP_WALK_ZOMBIE_01 - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local revive = pl.Revive
	if revive and revive:IsValid() then
		pl:SetCycle(0.4 + (1 - math_Clamp((revive:GetReviveTime() - CurTime()) / revive:GetReviveAnim(), 0, 1)) * 0.6)
		pl:SetPlaybackRate(0)
		return true
	end

	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetState() == 1 then
			pl:SetCycle(1 - math_max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		else
			pl:SetCycle(math_max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		end
		pl:SetPlaybackRate(0)
		return true
	end

	local len2d = velocity:Length()
	if len2d > 1 then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.IsMoaning and wep:IsMoaning() then
			pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed, 3))
		else
			pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5, 3))
		end
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:DoZombieAttackAnim(data)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

if SERVER then
	function CLASS:ProcessDamage(pl, dmginfo)
		if pl.EradiVived then return end

		local damage = dmginfo:GetDamage()
		if damage >= 0 or damage < pl:Health() then return end

		local attacker, inflictor = dmginfo:GetAttacker(), dmginfo:GetInflictor()
		if attacker == pl or not attacker:IsPlayer() or inflictor.IsMelee or inflictor.NoReviveFromKills then return end

		if pl:WasHitInHead() or pl:GetStatus("shockdebuff") then return end

		local dmgtype = dmginfo:GetDamageType()
		if bit_band(dmgtype, DMG_ALWAYSGIB) ~= 0 or bit_band(dmgtype, DMG_BURN) ~= 0 or bit_band(dmgtype, DMG_CRUSH) ~= 0 then return end

		if CurTime() < (pl.NextZombieRevive or 0) then return end
		pl.NextZombieRevive = CurTime() + 4.25

		dmginfo:SetDamage(0)
		pl:SetHealth(1500)

		local status = pl:GiveStatus("revive_slump")
		if status then
			status:SetReviveTime(CurTime() + 4)
			status:SetReviveAnim(4.15)
			status:SetReviveHeal(1500)

			pl.EradiVived = true
		end

		return true
	end

	function CLASS:OnSpawned(pl)
		--pl:CreateAmbience("devourerambience")
		pl.EradiVived = false
	end
	
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	--if suicide then return end

	local pos = pl:WorldSpaceCenter()

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
	util.Effect("gore_blast", effectdata, true)
		effectdata:SetEntity(pl)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.Effect("gib_player", effectdata, true, true)
	util.ScreenShake(pos, 5, 5, 3, 560)

	pl:GodEnable()
	util.BlastDamageEx(pl:GetActiveWeapon() or pl, pl, pos, 200, 70, DMG_GENERIC, 0.7)
	pl:GodDisable()

	return true
end

end

if not CLIENT then return end 

CLASS.Icon = "zombiesurvival/killicons/poisonzombie"
CLASS.IconColor = Color(255, 0, 0)

local matSkin = Material("models/flesh")
--local matSkin = Material("Models/Barnacle/barnacle_sheet")
function CLASS:PrePlayerDrawOverrideModel(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(1, 0, 0)
end

function CLASS:PostPlayerDrawOverrideModel(pl)
	render.ModelMaterialOverride(nil)
end