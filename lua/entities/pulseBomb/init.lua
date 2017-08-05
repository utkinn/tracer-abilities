AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Collided")
end

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:SetModelScale(0.3)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
	
	self:SetCollided(false)
end

function ENT:PhysicsCollide(data, collidedPhysObject)
	if not self:GetCollided() then
		self:SetCollided(true)
		self:SetAngles(data.HitNormal:Angle() + Angle(-90, 0, 0))
		local hitEnt = data.HitEntity
		net.Start("bombStickedToEnemy")
		if hitEnt:IsWorld() --[[or hitEnt:IsNPC() or hitEnt:IsPlayer()--]] then
			self:GetPhysicsObject():EnableMotion(false)
			net.WriteBool(false)
		else
			self:SetParent(hitEnt)
			net.WriteBool(true)
		end
		net.Send(self:GetOwner())
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos())
		util.Effect("pulseBombLobRing", effectData)
		timer.Simple(0.5, function() util.Effect("pulseBombLobRing", effectData) end)
		timer.Simple(1, function()
			self:SetNoDraw(true)
			util.BlastDamage(self:GetOwner(), self, self:GetPos(), 160, 400)
			effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			effectData:SetScale(5)
			util.Effect("cball_explode", effectData)
			util.Effect("Explosion", effectData)
			self:EmitSound("ambient/explosions/explode_" .. math.random(9) .. ".wav", 140, 75)
		end)
	end
end