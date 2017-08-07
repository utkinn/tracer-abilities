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
	self:SetCollided(true)
	self:SetAngles(data.HitNormal:Angle() + Angle(-90, 0, 0))
	
	local hitEnt = data.HitEntity
	if hitEnt:IsWorld() then
		self:GetPhysicsObject():EnableMotion(false)
	else
		self:SetParent(hitEnt)
	end
	
	local effectData = EffectData()
	effectData:SetOrigin(self:GetPos())
	util.Effect("pulseBombLobRing", effectData)
	self:EmitSound("crazylaugh.wav", 75, 150)
	timer.Simple(0.5, function() util.Effect("pulseBombLobRing", effectData) end)
	timer.Simple(1, function()
		for i = 1, 100 do
			util.BlastDamage(self:GetOwner(), self, self:GetPos(), 500, 1000)
			effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			effectData:SetRadius(300)
			effectData:SetScale(30)
			util.Effect("cball_explode", effectData)
			util.Effect("Explosion", effectData)
			self:EmitSound("ambient/explosions/explode_" .. math.random(9) .. ".wav", 140, 75)
		end
	end)
	timer.Simple(1.5, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
end