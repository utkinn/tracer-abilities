AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function spawnFearThing(bombPosition)
    local bullseye = ents.Create('npc_bullseye')
    bullseye:Input('SetRelationship', nil, nil, 'D_FR')
    bullseye:SetPos(bombPosition)
    bullseye:Spawn()
end

function ENT:SetupDataTables()
    bomb:NetworkVar("Bool", 0, "Collided")
    bomb:NetworkVar("Bool", 1, "Stuck")
end

function ENT:Initialize()
    bomb:SetModel("models/props_combine/combine_mine01.mdl")
    bomb:SetModelScale(0.3)

    bomb:PhysicsInit(SOLID_VPHYSICS)
    bomb:SetMoveType(MOVETYPE_VPHYSICS)
    bomb:SetSolid(SOLID_VPHYSICS)
    bomb:PhysWake()

    bomb:SetCollided(false)
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

function explode(bomb)
    util.BlastDamage(bomb:GetOwner(), bomb, bomb:GetPos(), 160, 400)
    effectData = EffectData()
    effectData:SetOrigin(bomb:GetPos())
    effectData:SetScale(5)
    util.Effect("cball_explode", effectData)
    util.Effect("Explosion", effectData)
    bomb:EmitSound("ambient/explosions/explode_" .. math.random(9) .. ".wav", 140, 75)
    bomb:Remove()
end

function createEffect(bomb)
    local effectData = EffectData()
    effectData:SetOrigin(bomb:GetPos())
    util.Effect("pulseBombLobRing", effectData)
    timer.Simple(0.5, function() util.Effect("pulseBombLobRing", effectData) end)
    timer.Simple(1, function()
        --bomb:SetNoDraw(true)
        explode(bomb)
    end)
end

function ENT:PhysicsCollide(data, collidedPhysObject)
    if not bomb:GetCollided() then
        bomb:SetCollided(true)
        bomb:SetAngles(data.HitNormal:Angle() + Angle(-90, 0, 0))

        spawnFearThing(bomb:GetPos())

        local hitEnt = data.HitEntity
        if hitEnt:IsWorld() then
            bomb:GetPhysicsObject():EnableMotion(false)
        else
            bomb:SetParent(hitEnt)
        end

        if hitEnt:IsPlayer() or hitEnt:IsNPC() then
            bomb:SetStuck(true)
        else
            bomb:SetStuck(false)
        end

        createEffect(bomb)
    end
end
