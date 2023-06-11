local surface_PlaySound = surface.PlaySound

local DamageFloaters = CreateClientConVar("zs_damagefloaters", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_damagefloaters", function(cvar, oldvalue, newvalue)
	DamageFloaters = newvalue ~= "0"
end)

local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team

local function AltSelItemUpd()
	local activeweapon = MySelf:GetActiveWeapon()
	if not activeweapon or not activeweapon:IsValid() then return end

	local actwclass = activeweapon:GetClass()
	local weapon = weapons.Get(actwclass)
	GAMEMODE.HumanMenuPanel.SelectedItemLabel:SetText(weapon and weapon.PrintName or Format("#%s", actwclass))
end

net.Receive("zs_legdamage", function(length)
	MySelf.LegDamage = net.ReadFloat()
end)

net.Receive("zs_armdamage", function(length)
	MySelf.ArmDamage = net.ReadFloat()
end)

net.Receive("zs_nextboss", function(length)
	GAMEMODE.NextBossZombie = net.ReadEntity()
	GAMEMODE.NextBossZombieClass = GAMEMODE.ZombieClasses[net.ReadUInt(8)].Name
end)

net.Receive("zs_nextsuperboss", function(length)
	GAMEMODE.NextSuperBossZombie = net.ReadEntity()
	GAMEMODE.NextSuperBossZombieClass = GAMEMODE.ZombieClasses[net.ReadUInt(8)].Name
end)

net.Receive("zs_zvols", function(length)
	local volunteers = {}
	local count = net.ReadUInt(8)
	for i=1, count do
		volunteers[i] = net.ReadEntity()
	end

	GAMEMODE.ZombieVolunteers = volunteers
end)

net.Receive("zs_dmg", function(length)
	local damage = net.ReadFloat()
	local pos = net.ReadVector()

	if DamageFloaters then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetMagnitude(damage)
			effectdata:SetScale(0)
		util.Effect("damagenumber", effectdata)
	end
end)

net.Receive("zs_dmg_prop", function(length)
	local damage = net.ReadFloat()
	local pos = net.ReadVector()

	if DamageFloaters then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetMagnitude(damage)
			effectdata:SetScale(-1)
		util.Effect("damagenumber", effectdata)
	end
end)

net.Receive("zs_dmg_type", function(length)
	local damage = net.ReadFloat()
	local dmgtype = net.ReadUInt(8)
	local pos = net.ReadVector()

	if DamageFloaters then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetMagnitude(damage)
			effectdata:SetScale(dmgtype)
		util.Effect("damagenumber", effectdata)
	end
end)


net.Receive("zs_lifestats", function(length)
	local barricadedamage = net.ReadUInt(16)
	local humandamage = net.ReadUInt(16)
	local brainseaten = net.ReadUInt(8)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsBarricadeDamage = barricadedamage
	GAMEMODE.LifeStatsHumanDamage = humandamage
	GAMEMODE.LifeStatsBrainsEaten = brainseaten
end)

net.Receive("zs_lifestatsbd", function(length)
	local barricadedamage = net.ReadUInt(16)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsBarricadeDamage = barricadedamage
end)

net.Receive("zs_lifestatshd", function(length)
	local humandamage = net.ReadUInt(16)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsHumanDamage = humandamage
end)

net.Receive("zs_lifestatsbe", function(length)
	local brainseaten = net.ReadUInt(8)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsBrainsEaten = brainseaten
end)

net.Receive("zs_honmention", function(length)
	local pl = net.ReadEntity()
	local mentionid = net.ReadUInt(8)
	local etc = net.ReadInt(32)

	if pl:IsValid() then
		gamemode.Call("AddHonorableMention", pl, mentionid, etc)
	end
end)

net.Receive("zs_wavestart", function(length)
	local wave = net.ReadInt(16)
	local time = net.ReadFloat()

	gamemode.Call("SetWave", wave)
	gamemode.Call("SetWaveEnd", time)

	if GAMEMODE.ZombieEscape then
		GAMEMODE:CenterNotify(COLOR_RED, {font = "ZSHUDFont"}, translate.Get("escape_from_the_zombies"))
	elseif not GAMEMODE:IsEndlessMode() and wave == GAMEMODE:GetNumberOfWaves() then
		GAMEMODE:CenterNotify({killicon = "default"}, {font = "ZSHUDFont"}, " ", COLOR_RED, translate.Get("final_wave"), {killicon = "default"})
		GAMEMODE:CenterNotify(translate.Get("final_wave_sub"))
	else
		GAMEMODE:CenterNotify({killicon = "default"}, {font = "ZSHUDFont"}, " ", COLOR_RED, translate.Format("wave_x_has_begun", wave), {killicon = "default"})

		if wave == 1 and GAMEMODE:GetUseSigils() then
			GAMEMODE:CenterNotify(translate.Format("x_sigils_appeared", GAMEMODE.MaxSigils))
		end
	end

	surface_PlaySound("ambient/creatures/town_zombie_call1.wav")
end)

net.Receive("zs_classunlock", function(length)
	GAMEMODE:CenterNotify(COLOR_GREEN, translate.Format("x_unlocked", net.ReadString()))
end)

net.Receive("zs_waveend", function(length)
	local wave = net.ReadInt(16)
	local time = net.ReadFloat()

	gamemode.Call("SetWaveStart", time)

	if wave > 0 then
		GAMEMODE:CenterNotify(COLOR_RED, {font = "ZSHUDFont"}, translate.Format("wave_x_is_over", wave))
		GAMEMODE:CenterNotify(translate.Get("wave_x_is_over_sub"))

		if MySelf:IsValid() and P_Team(MySelf) == TEAM_HUMAN then
			if not GAMEMODE.NoNotifyUnusedSP and MySelf:GetZSSPRemaining() > 0 then
				GAMEMODE:CenterNotify(translate.Format("unspent_skill_points_press_x", input.LookupBinding("gm_showspare1") or "F3"))
			end

			if GAMEMODE.EndWavePointsBonus > 0 and not MySelf:IsSkillActive(SKILL_POINT_OLD) then
				local pointsbonus = GAMEMODE.EndWavePointsBonus + (GAMEMODE:GetWave() - 1) * GAMEMODE.EndWavePointsBonusPerWave + (MySelf.EndWavePointsExtra or 0)

				if not MySelf.Scourer then
					GAMEMODE:CenterNotify(COLOR_CYAN, translate.Format("points_for_surviving", pointsbonus))
				else
					GAMEMODE:CenterNotify(COLOR_ORANGE, translate.Format("scrap_for_surviving", pointsbonus))
				end
			end
		end

		surface_PlaySound("ambient/atmosphere/cave_hit"..math.random(6)..".wav")
	end
end)

net.Receive("zs_gamestate", function(length)
	local wave = net.ReadInt(16)
	local wavestart = net.ReadFloat()
	local waveend = net.ReadFloat()

	gamemode.Call("SetWave", wave)
	gamemode.Call("SetWaveStart", wavestart)
	gamemode.Call("SetWaveEnd", waveend)
end)

net.Receive("zs_miniboss_spawned", function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}
	local kid = {killicon = "default"}

	if ent == MySelf and ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_YELLOW, translate.Format("you_are_x", translate.Get(classtbl.TranslationName)), ki)
	end
end)

net.Receive("zs_semiboss_spawned", function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}
	local kid = {killicon = "default"}

	if ent == MySelf and ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_YELLOW, translate.Format("you_are_x", translate.Get(classtbl.TranslationName)), ki)
	elseif ent:IsValid() and P_Team(MySelf) == TEAM_UNDEAD or P_Team(MySelf) == TEAM_HUMAN then
		GAMEMODE:CenterNotify(ki, " ", COLOR_ORANGE, translate.Format("x_has_risen_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	else
		GAMEMODE:CenterNotify(kid, " ", COLOR_ORANGE, translate.Get("semi_x_has_risen"), kid)
	end
end)

net.Receive("zs_boss_spawned", function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}
	local kid = {killicon = "default"}

	if ent == MySelf and ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_RORANGE, translate.Format("you_are_x", translate.Get(classtbl.TranslationName)), ki)
	elseif ent:IsValid() and P_Team(MySelf) == TEAM_UNDEAD or P_Team(MySelf) == TEAM_HUMAN then
		GAMEMODE:CenterNotify(ki, " ", COLOR_RED, translate.Format("x_has_risen_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	else
		GAMEMODE:CenterNotify(kid, " ", COLOR_RED, translate.Get("x_has_risen"), kid)
	end

	if MySelf:IsValid() then
		MySelf:EmitSound(string.format("npc/zombie_poison/pz_alert%d.wav", math.random(1, 2)), 0, math.random(95, 105))
	end

	GAMEMODE.NextBossZombie = nil
	GAMEMODE.NextBossZombieClass = nil
end)

net.Receive("zs_boss_slain", function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}

	if ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_YELLOW, translate.Format("x_has_been_slain_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	end

	if MySelf:IsValid() then
		MySelf:EmitSound("ambient/atmosphere/cave_hit4.wav", 0, 150)
	end
end)


net.Receive("zs_superboss_spawned", function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}
	local kid = {killicon = "default"}

	if ent == MySelf and ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_RED, translate.Format("you_are_x", translate.Get(classtbl.TranslationName)), ki)
	elseif ent:IsValid() and P_Team(MySelf) == TEAM_UNDEAD or P_Team(MySelf) == TEAM_HUMAN then
		GAMEMODE:CenterNotify(ki, " ", COLOR_SOFTRED, translate.Format("x_has_risen_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	else
		GAMEMODE:CenterNotify(kid, " ", COLOR_SOFTRED, translate.Get("super_x_has_risen"), kid)
	end

	if MySelf:IsValid() then
		MySelf:EmitSound(string.format("npc/zombie_poison/pz_alert%d.wav", math.random(1, 2)), 0, math.random(75, 85))
	end

	GAMEMODE.NextSuperBossZombie = nil
	GAMEMODE.NextSuperBossZombieClass = nil
end)

net.Receive("zs_superboss_slain", function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}

	if ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_RORANGE, translate.Format("x_has_been_slain_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	end

	if MySelf:IsValid() then
		MySelf:EmitSound("ambient/atmosphere/cave_hit4.wav", 0, 115)
	end
end)

net.Receive("zs_classunlockstate", function(length)
	local clstr = net.ReadInt(8)
	local class = GAMEMODE.ZombieClasses[clstr]
	local unlocked = net.ReadBool()

	class.Locked = not unlocked
	class.Unlocked = unlocked
end)

net.Receive("zs_centernotify", function(length)
	local tab = net.ReadTable()

	GAMEMODE:CenterNotify(unpack(tab))
end)

net.Receive("zs_topnotify", function(length)
	local tab = net.ReadTable()

	GAMEMODE:TopNotify(unpack(tab))
end)

net.Receive("zs_survivor", function(length)
	local ent = net.ReadEntity()

	if ent:IsValidPlayer() then
		GAMEMODE:TopNotify(ent, " ", translate.Get("has_survived"))

		if ent == MySelf then
			util.WhiteOut(3)
		end
	end
end)

net.Receive("zs_lasthuman", function(length)
	local pl = net.ReadEntity()

	gamemode.Call("LastHuman", pl)
end)

net.Receive("zs_gamemodecall", function(length)
	gamemode.Call(net.ReadString())
end)

net.Receive("zs_lasthumanpos", function(length)
	GAMEMODE.LastHumanPosition = net.ReadVector()
end)

net.Receive("zs_endround", function(length)
	local winner = net.ReadUInt(8)
	local nextmap = net.ReadString()

	gamemode.Call("EndRound", winner, nextmap)
end)

net.Receive("zs_healother", function(length)
	if net.ReadBool() then
		gamemode.Call("HealedOtherPlayer", net.ReadEntity(), net.ReadFloat())
	else
		GAMEMODE:CenterNotify({killicon = "weapon_zs_medicalkit"}, " ", COLOR_GREEN, translate.Format("healed_x_for_y", net.ReadEntity():Name(), net.ReadFloat()))
	end
end)

net.Receive("zs_repairobject", function(length)
	gamemode.Call("RepairedObject", net.ReadEntity(), net.ReadFloat())
end)

net.Receive("zs_commission", function(length)
	gamemode.Call("ReceivedCommission", net.ReadEntity(), net.ReadEntity(), net.ReadFloat())
end)

net.Receive("zs_sigilcorrupted", function(length)
	local corrupted = net.ReadUInt(8)
	local ent = net.ReadEntity()

	LastSigilCorrupted = CurTime()

	if MySelf:IsValid() then
		local maxsigils = GAMEMODE:NumSigils()
		local winddown = CreateSound(MySelf, "ambient/levels/labs/teleport_winddown1.wav")
		winddown:PlayEx(1, 120)

		timer.Simple(1.25, function()
			MySelf:EmitSound("ambient/levels/labs/machine_stop1.wav", 75, 80)
			MySelf:EmitSound("ambient/atmosphere/hole_hit5.wav", 75, 70)
		end)

		timer.Simple(1.5, function()
			winddown:Stop()
			MySelf:EmitSound("zombiesurvival/eyeflash.ogg", 75, 100)
		end)

		local letter = "?"
		for i, sigil in pairs(ents.FindByClass("prop_obj_sigil")) do
			if ent == sigil then
				letter = string.char(64 + i)
				break
			end
		end

		if corrupted == maxsigils then
			GAMEMODE:CenterNotify({killicon = "default"}, {font = "ZSHUDFontSmall"}, COLOR_RED, translate.Get("sigil_corrupted_last"), {killicon = "default"})
		else
			GAMEMODE:CenterNotify(COLOR_RED, {font = "ZSHUDFontSmall"}, translate.Format("sigil_corrupted", letter))
			GAMEMODE:CenterNotify(COLOR_RED, translate.Format("sigil_corrupted_x_remain", maxsigils - corrupted))
		end
	end
end)

net.Receive("zs_sigiluncorrupted", function(length)
	local corrupted = net.ReadUInt(8)
	local ent = net.ReadEntity()

	LastSigilUncorrupted = CurTime()

	if MySelf:IsValid() then
		MySelf:EmitSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 75, 180)

		timer.Simple(1.25, function()
			MySelf:EmitSound("ambient/machines/teleport1.wav", 75, 60, 0.3)
		end)

		local letter = "?"
		for i, sigil in pairs(ents.FindByClass("prop_obj_sigil")) do
			if ent == sigil then
				letter = string.char(64 + i)
				break
			end
		end

		GAMEMODE:CenterNotify(COLOR_GREEN, {font = "ZSHUDFontSmall"}, translate.Format("sigil_uncorrupted", letter))
	end
end)

net.Receive("zs_ammopickup", function(length)
	local amount = net.ReadUInt(16)
	local ammotype = net.ReadString()
	local ico = GAMEMODE.AmmoIcons[ammotype] or "weapon_zs_resupplybox"

	ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

	GAMEMODE:CenterNotify({killicon = ico}, " ", COLOR_GREEN, translate.Format("obtained_x_y_ammo", amount, ammotype))
end)

net.Receive("zs_ammogive", function(length)
	local amount = net.ReadUInt(16)
	local ammotype = net.ReadString()
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end
	local ico = GAMEMODE.AmmoIcons[ammotype] or "weapon_zs_resupplybox"

	ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

	GAMEMODE:CenterNotify({killicon = ico}, " ", COLOR_GREEN, translate.Format("gave_x_y_ammo_to_z", amount, ammotype, ent:Name()))
end)

net.Receive("zs_ammogiven", function(length)
	local amount = net.ReadUInt(16)
	local ammotype = net.ReadString()
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end
	local ico = GAMEMODE.AmmoIcons[ammotype] or "weapon_zs_resupplybox"

	ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

	GAMEMODE:CenterNotify({killicon = ico}, " ", COLOR_GREEN, translate.Format("obtained_x_y_ammo_from_z", amount, ammotype, ent:Name()))
end)

net.Receive("zs_deployablelost", function(length)
	local deploy = net.ReadString()
	local class = net.ReadString()

	GAMEMODE:CenterNotify({killicon = class}, " ", COLOR_RED, translate.Format("deployable_lost", deploy))
end)

net.Receive("zs_deployableclaim", function(length)
	local deploy = net.ReadString()
	local class = net.ReadString()

	GAMEMODE:CenterNotify({killicon = class}, " ", COLOR_LBLUE, translate.Format("deployable_claimed", deploy))
end)

net.Receive("zs_deployableout", function(length)
	local deploy = net.ReadString()
	local class = net.ReadString()

	GAMEMODE:CenterNotify({killicon = class}, " ", COLOR_RED, translate.Format("ran_out_of_ammo", deploy))
end)

net.Receive("zs_trinketrecharged", function(length)
	local trinket = net.ReadString()
	MySelf:EmitSound("buttons/button3.wav", 75, 50)

	GAMEMODE:CenterNotify({killicon = "weapon_zs_trinket"}, " ", COLOR_RORANGE, translate.Format("trinket_recharged", trinket))
end)

net.Receive("zs_trinketconsumed", function(length)
	local trinket = net.ReadString()
	MySelf:EmitSound("buttons/button3.wav", 75, 50)

	GAMEMODE:CenterNotify({killicon = "weapon_zs_trinket"}, " ", COLOR_RORANGE, translate.Format("trinket_consumed", trinket))
end)

net.Receive("zs_invitem", function(length)
	local invitemt = net.ReadString()
	local inviname = GAMEMODE.ZSInventoryItemData[invitemt].PrintName
	local category = GAMEMODE:GetInventoryItemType(invitemt)

	surface.PlaySound("items/ammo_pickup.wav")
	GAMEMODE:CenterNotify({killicon = category == INVCAT_TRINKETS and "weapon_zs_trinket" or "weapon_zs_craftables"}, " ", COLOR_RORANGE, translate.Format("obtained_a_inv", inviname))
end)

net.Receive("zs_invgiven", function(length)
	local invitemt = net.ReadString()
	local inviname = GAMEMODE.ZSInventoryItemData[invitemt].PrintName
	local category = GAMEMODE:GetInventoryItemType(invitemt)
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = category == INVCAT_TRINKETS and "weapon_zs_trinket" or "weapon_zs_craftables"}, " ", COLOR_RORANGE, translate.Format("obtained_inv_item_from_z", inviname, ent:Name()))
end)

net.Receive("zs_healby", function(length)
	local amount = net.ReadFloat()
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicalkit"}, " ", COLOR_GREEN, translate.Format("healed_x_by_y", ent:Name(), amount))
end)

net.Receive("zs_buffby", function(length)
	local ent = net.ReadEntity()
	local buff = net.ReadString()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicgun"}, " ", COLOR_GREEN, translate.Format("buffed_x_with_y", ent:Name(), buff))
end)

net.Receive("zs_buffwith", function(length)
	local ent = net.ReadEntity()
	local buff = net.ReadString()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicgun"}, " ", COLOR_GREEN, translate.Format("buffed_x_with_a_y", ent:Name(), buff))
end)

net.Receive("zs_nailremoved", function(length)
	local ent = net.ReadEntity()
	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_hammer"}, " ", COLOR_RED, translate.Format("removed_your_nail", ent:Name()))
end)

net.Receive("zs_currentround", function(length)
	GAMEMODE.CurrentRound = net.ReadUInt(6)
end)

net.Receive("zs_updatealtselwep", function(length)
	if MySelf:Alive() and P_Team(MySelf) == TEAM_HUMAN and GAMEMODE.HumanMenuPanel and GAMEMODE.HumanMenuPanel:IsValid() and not GAMEMODE.InventoryMenu.SelInv then
		timer.Simple(0.25, AltSelItemUpd)
	end
end)

net.Receive("zs_nestbuilt", function(length)
	if GAMEMODE.ZSpawnMenu and GAMEMODE.ZSpawnMenu:IsValid() then
		GAMEMODE.ZSpawnMenu:RefreshContents()
	end
end)

net.Receive("zs_achievementsprogress", function()
	GAMEMODE.AchievementsProgress = util.JSONToTable(net.ReadString())

	-- Clamp progress
	for id, progress in pairs(GAMEMODE.AchievementsProgress) do
		if isnumber(progress) then
			GAMEMODE.AchievementsProgress[id] = math.Clamp(progress, 0, GAMEMODE.Achievements[id].Goal)
		end
	end
end)

net.Receive("zs_achievementgained", function()
	local ply = net.ReadEntity()
	local id = net.ReadString()
	chat.AddText(COLOR_WHITE, "[", Color(125, 255, 125), "ZS", COLOR_WHITE, "] ", ply, COLOR_WHITE, " has earned ", Color(125, 255, 125), GAMEMODE.Achievements[id].Name, COLOR_WHITE, ".")
end)

net.Receive("zs_mutations_table", function(len)
	local mutationstable = net.ReadTable()
	if mutationstable then
		GAMEMODE.UsedMutations = mutationstable
	end
end)
