AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:SetModelScale(0.4)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
end

function ENT:PhysicsCollide(data, collidedPhysObject)
	self:SetAngles(data.HitNormal:Angle() + Angle(-90, 0, 0))
	--constraint.Weld(collidedPhysObject.HitEntity, self, 0, 0, 0, true, true)
	if IsValid(collidedPhysObject.HitEntity) then
		self:SetParent(data.HitEntity)
	end
	self:PhysicsDestroy()
	timer.Simple(1, function()
		util.BlastDamage(self:GetOwner(), self, self:GetPos(), 160, 400)
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos())
		effectData:SetScale(5)
		util.Effect("cball_explode", effectData)
		util.Effect("Explosion", effectData)
		self:EmitSound("ambient/explosions/explode_" .. math.random(9) .. ".wav", 140, 75)
		self:Remove()
	end)
end