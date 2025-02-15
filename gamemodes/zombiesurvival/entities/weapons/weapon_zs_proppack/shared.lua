SWEP.Base = "weapon_zs_basemelee"

SWEP.PrintName = "Prop Pack"
SWEP.Description = "A pack of random high quality useful props, Very useful for keeping the barricade alive."

SWEP.ViewModel = "models/weapons/c_aegiskit.mdl"
SWEP.WorldModel = "models/props_debris/wood_board06a.mdl"
SWEP.UseHands = true

SWEP.AmmoIfHas = true
SWEP.AllowEmpty = true

SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SniperRound"
SWEP.Primary.Delay = 0.5
SWEP.Primary.DefaultClip = 2

SWEP.MaxStock = 10

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.15

SWEP.WalkSpeed = SPEED_NORMAL
SWEP.FullWalkSpeed = SPEED_SLOWEST

SWEP.PropModels = {
	Model("models/props_c17/FurnitureWashingmachine001a.mdl"),
	Model("models/props_junk/bicycle01a.mdl"),
	Model("models/props_lab/reciever_cart.mdl"),
	Model("models/props_vehicles/carparts_door01a.mdl"),
	Model("models/props_c17/FurnitureCouch001a.mdl"),
	Model("models/props_interiors/refrigeratorDoor01a.mdl"),
	Model("models/props_c17/FurnitureFridge001a.mdl"),
	Model("models/props_c17/FurnitureRadiator001a.mdl"),
	Model("models/props_interiors/Radiator01a.mdl"),
	Model("models/props_c17/canister01a.mdl"),
	Model("models/props_c17/canister02a.mdl"),
	Model("models/props_c17/oildrum001.mdl"),
	Model("models/props_interiors/Furniture_shelf01a.mdl"),
	Model("models/props_c17/bench01a.mdl"),
	Model("models/props_combine/breenchair.mdl"),
	Model("models/props_junk/TrashBin01a.mdl"),
	Model("models/props_trainstation/trashcan_indoor001a.mdl"),
	Model("models/props_trainstation/trashcan_indoor001b.mdl"),
	Model("models/props_wasteland/controlroom_filecabinet002a.mdl"),
	Model("models/props_wasteland/prison_heater001a.mdl"),
	Model("models/props_interiors/Furniture_Couch02a.mdl"),
	Model("models/props_interiors/Furniture_Lamp01a.mdl"),
	Model("models/props_vehicles/tire001b_truck.mdl"),
	Model("models/props_wasteland/cafeteria_bench001a.mdl"),
	Model("models/props_wasteland/laundry_cart002.mdl"),
	Model("models/props_c17/gravestone003a.mdl"),
	Model("models/props_c17/FurnitureShelf001a.mdl"),
	Model("models/props_trainstation/BenchOutdoor01a.mdl"),
	Model("models/props_wasteland/prison_bedframe001b.mdl"),
	--Model("models/props_c17/Lockers001a.mdl"),
	Model("models/props_c17/FurnitureTable002a.mdl"),
	--Model("models/props_interiors/sofa_chair02.mdl"),
	--Model("models/props_interiors/chairlobby01.mdl"),
	--Model("models/props_interiors/table_bedside.mdl"),
	--Model("models/props_interiors/trashcan01.mdl"),
	--Model("models/props_street/trashbin01.mdl"),
	--Model("models/props_urban/fridge_door003.mdl"),
	--Model("models/props_interiors/refrigerator03.mdl"),
}

SWEP.HoldType = "physgun"

function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local aimvec = self:GetOwner():GetAimVector()
	local shootpos = self:GetOwner():GetShootPos()
	local tr = util.TraceLine({start = shootpos, endpos = shootpos + aimvec * 32, filter = self:GetOwner()})

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(75, 80))

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.IdleAnimation = CurTime() + math.min(self.Primary.Delay, self:SequenceDuration())

	if SERVER then
		self:GetOwner():RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			local ang = aimvec:Angle()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ent:SetPos(tr.HitPos)
			ent:SetAngles(ang)
			ent:SetModel(self.PropModels[math.random(#self.PropModels)])
			ent:Spawn()
			ent:SetHealth(750)
			ent.NoVolumeCarryCheck = true
			ent.NoDisTime = CurTime() + 15
			ent.NoDisOwner = self:GetOwner()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				--phys:SetMass(math.min(phys:GetMass(), 50))
				phys:SetVelocityInstantaneous(self:GetOwner():GetVelocity())
			end
			ent:SetPhysicsAttacker(self:GetOwner())
			self:TakePrimaryAmmo(1)
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	if math.abs(self:GetOwner():GetVelocity().z) >= 256 then return false end

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if SERVER then
		local count = self:GetPrimaryAmmoCount()
		if count ~= self:GetReplicatedAmmo() then
			self:SetReplicatedAmmo(count)
			self:GetOwner():ResetSpeed()
		end
	end
end
