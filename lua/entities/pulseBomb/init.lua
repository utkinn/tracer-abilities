AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Collided")
	self:NetworkVar("Bool", 1, "Stuck")
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

function ENT:SpawnFunction(spawner, trace, class)
	if not trace.Hit then return end

	local SpawnPos = trace.HitPos + trace.HitNormal * 16

	local ent = ents.Create(class)
	ent:SetPos(SpawnPos)
	ent:SetOwner(spawner)
	ent:Spawn()
	
	return ent
end

function ENT:PhysicsCollide(data, collidedPhysObject)
	if not self:GetCollided() then
		self:SetCollided(true)
		self:SetAngles(data.HitNormal:Angle() + Angle(-90, 0, 0))
		
		local hitEnt = data.HitEntity
		if hitEnt:IsWorld() then
			self:GetPhysicsObject():EnableMotion(false)
		else
			self:SetParent(hitEnt)
		end
		
		if hitEnt:IsPlayer() or hitEnt:IsNPC() then
			self:SetStuck(true)
		else
			self:SetStuck(false)
		end
		
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos())
		util.Effect("pulseBombLobRing", effectData)
		timer.Simple(0.5, function() util.Effect("pulseBombLobRing", effectData) end)
		timer.Simple(1, function()
			--self:SetNoDraw(true)
			util.BlastDamage(self:GetOwner(), self, self:GetPos(), 160, 400)
			effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			effectData:SetScale(5)
			util.Effect("cball_explode", effectData)
			util.Effect("Explosion", effectData)
			self:EmitSound("ambient/explosions/explode_" .. math.random(9) .. ".wav", 140, 75)
			self:Remove()
		end)
	end
end