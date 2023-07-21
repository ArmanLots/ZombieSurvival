AddCSLuaFile()

ENT.Base = "prop_gunturret"

ENT.SWEP = "weapon_zs_gunturret_pluse"

ENT.AmmoType = "pluse"
ENT.FireDelay = 0.22
ENT.NumShots = 1
ENT.Damage = 30
ENT.PlayLoopingShootSound = false
ENT.Spread = 2
ENT.SearchDistance = 225
ENT.MaxAmmo = 300

if CLIENT then

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	local ent = ClientsideModel("models/weapons/w_IRifle.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:Spawn()
		self.GunAttachment = ent
	end
end

function ENT:DrawTranslucent()
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:ShootPos() + ang:Forward() * -8)
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	self.BaseClass.DrawTranslucent(self)
end

function ENT:OnRemove()
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end

end

function ENT:PlayShootSound()
	self:EmitSound("Airboat.FireGunHeavy")
end
