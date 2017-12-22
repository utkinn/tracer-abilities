-------------------- Callouts --------------------

local function playOnBombChargeCallout(player)
    player:EmitSound(callouts.pulseBomb.ready[math.random(#callouts.pulseBomb.ready)])
    player:SetNWBool("ultimateNotified", true)
end

local function shouldPlayCallout(player)
    return player:GetNWInt("bombCharge") == 100
            and not player:GetNWBool("ultimateNotified")
            and player:GetInfoNum("tracer_callouts", 0) == 1
end

local function onBombCharge(player)
    playOnBombChargeCallout(player)
end

local function resetCalloutOnThrow(player)
    player:SetNWInt("bombCharge", 0)
    player:SetNWBool("ultimateNotified", false)
end

local function playBombReadyCallout(player)
    player:EmitSound("callouts/pulsebomb/ready/" .. math.random(2) .. ".wav")
    player:SetNWBool("ultimateNotified", true)
end

local function playBombThrowCallout(player, stuckToEnemy)
    if player:GetInfoNum("tracer_callouts", 0) ~= 1 then return end

    local sound
    if stuckToEnemy then
        sound = callouts.pulseBomb.stuck[math.random(#callouts.pulseBomb.stuck)]
    else
        sound = callouts.pulseBomb.notStuck[math.random(#callouts.pulseBomb.notStuck)]
    end
    player:EmitSound(sound)
end

--------------------------------------------------

local function increaseBombCharge(player, increase)
    if not player:IsAdmin() and GetConVar("tracer_bomb_admin_only"):GetBool() then return end
    player:SetNWInt(
            "bombCharge",
            math.Clamp(
                    player:GetNWInt("bombCharge", 0) + increase * GetConVar("tracer_bomb_charge_multiplier"):GetInt(),
                    0,
                    100
            )
    )
    if shouldPlayCallout(player) then
        onBombCharge(player)
    end
end

local function canThrowBomb(player)
    local chargeCriteria = player:GetNWInt("bombCharge") >= 100 and player:Alive()
    local permissionCriteria = not (GetConVar("tracer_bomb_admin_only"):GetBool() and not player:IsAdmin())

    return chargeCriteria and permissionCriteria
end

local function createBomb(player)
    local bomb = ents.Create("pulseBomb")

    bomb:SetPos(player:GetPos() + Vector(0, 0, 50))
    bomb:SetOwner(player)

    bomb:Spawn()

    return bomb
end

local function kickBomb(bomb)
    local phys = bomb:GetPhysicsObject()
    phys:ApplyForceCenter(player:EyeAngles():Forward() * 3000 + Vector(0, 0, 1500))
end

function throwBomb(player)
    resetCalloutOnThrow(player)

    local bomb = createBomb(player)
    kickBomb(bomb)

    bomb:NetworkVarNotify("Stuck", function(entity, varName, _, value)
        playBombThrowCallout(entity:GetOwner(), value)
    end)
end

-------------------- Hooks --------------------

hook.Add("InitPostEntity", "passiveBombCharge", function()
    timer.Create("passiveBombCharge", 2, 0, function()
        for _, player in pairs(player.GetAll()) do
            increaseBombCharge(player, 1)

            if shouldPlayCallout(player) then
                playBombReadyCallout(player)
            end
        end
    end)
end)

hook.Add("EntityTakeDamage", "increaseBombCharge", function(_, damageInfo)
    local damage = damageInfo:GetDamage()
    local attacker = damageInfo:GetAttacker()

    if attacker:IsPlayer() then
        increaseBombCharge(attacker, damage / 10)
    end
end)

-----------------------------------------------

net.Receive("throwBomb", function(length, player)
    if canThrowBomb(player) then throwBomb(player) end
end)
