AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Marrow Mutant"
end

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 32

SWEP.HowlDelay = 10

SWEP.BattlecryInterval = 0
--SWEP.MeleeDamageShielded = 20

--[[function SWEP:MeleeHit(ent, trace, damage, forcescale)
	local owner = self:GetOwner()
	if owner:GetStatus("redmarrow") then
		damage = self.MeleeDamageShielded
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end]]

function SWEP:Reload()
	self:SecondaryAttack()
end

local function Battlecry(pos)
	if SERVER then
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0,0,1))
		util.Effect("zombie_battlecry", effectdata, true)
	end
end

function SWEP:Think()
	self.BaseClass.Think(self)

	if self:GetBattlecry() > CurTime() then
		if self.BattlecryInterval < CurTime() then
			self.BattlecryInterval = CurTime() + 0.25
			local owner = self:GetOwner()
			local center = owner:GetPos() + Vector(0, 0, 32)
			if SERVER then
				for _, ent in pairs(ents.FindInSphere(center, 120)) do
					if ent:IsValidLivingZombie() and WorldVisible(ent:WorldSpaceCenter(), center)then
						ent:GiveStatus("zombie_battlecry", 1)
					end
				end
				
				for _, ent in pairs(ents.FindInSphere(center, 120)) do
					if ent:IsValidLivingZombie() and not ent:GetStatus("zombie_regen") and WorldVisible(ent:WorldSpaceCenter(), center)then
						local zombieclasstbl = ent:GetZombieClassTable()
						local ehp = zombieclasstbl.Boss and ent:GetMaxHealth() * 0.4 or ent:GetMaxHealth() * 1.25
						if ent:Health() <= ehp then
							local status = ent:GiveStatus("zombie_regen", 1)
							if status and status:IsValid() then
								status:SetHealLeft(75)
							end
						end
					end
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or CurTime() < self:GetNextHowl() then return end

	local owner = self:GetOwner()
	local pos = owner:GetPos()

	owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)

	self:SetBattlecry(CurTime() + 5)

	if SERVER then
		owner:EmitSound("npc/fast_zombie/fz_scream1.wav", 75, math.random(60,70), 0.5)
		--util.ScreenShake(pos, 5, 5, 3, 560)

		local center = owner:WorldSpaceCenter()
		timer.Simple(0, function() Battlecry(center) end)

		for _, ent in pairs(ents.FindInSphere(center, 150)) do
			if ent:IsValidLivingHuman() and WorldVisible(ent:WorldSpaceCenter(), center) then
				ent:GiveStatus("frightened", 10)
			end
		end
	end
	self:SetNextHowl(CurTime() + self.HowlDelay)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/fast_zombie/fz_scream1.wav", 75, math.random(60,70), 0.5)
	self:GetOwner():EmitSound("npc/fast_zombie/fz_scream1.wav", 75, math.random(70,80), 0.5)
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self:GetOwner():EmitSound("npc/combine_soldier/die"..math.random(1,3)..".wav", 75, math.random(70,75), 0.5)
	self:GetOwner():EmitSound("npc/combine_soldier/die"..math.random(1,3)..".wav", 75, math.random(78,90), 0.5)
end

function SWEP:SetBattlecry(time)
	self:SetDTFloat(1, time)
end

function SWEP:GetBattlecry()
	return self:GetDTFloat(1)
end

function SWEP:SetNextHowl(time)
	self:SetDTFloat(2, time)
end

function SWEP:GetNextHowl()
	return self:GetDTFloat(2)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/flesh")
function SWEP:PreDrawViewModel(vm)
    render.SetColorModulation(0.5, 0.5, 0)
	render.ModelMaterialOverride(matSheet)
end
