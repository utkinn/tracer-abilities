local snapshotTick = 0  -- Number of current snapshot

local recallSnapshots = {}  -- Table for storing all snapshots

local function createEffectData(player)
    local effectData = EffectData()
    effectData:SetOrigin(player:GetPos() + Vector(0, 0, 40))
    return effectData
end

local function emitRecallEffect(player)
    local effectData = createEffectData(player)
    util.Effect("recall", effectData)
end

-- function emitReversedRecallEffect(player)
--     createEffectData(player)
--     util.Effect("reversedRecall", effectData)
-- end

local function canRecall(player)
    return player:GetNWBool("canRecall")
            and player:Alive()
            and not player:IsFrozen()
            and player:GetNWBool("readyForRecall")
end

local function enterRecallState(player)
    player:GodEnable()
    player:SetNoTarget(true)
    player:SetRenderMode(RENDERMODE_TRANSALPHA)
    player:SetColor(Color(0, 0, 0, 0))
    -- player:Lock()
    player:EmitSound(OWTA_SOUNDS.recall)
    player:DrawWorldModel(false)
end

local function recall(player)
    player:SetNWBool("readyForRecall", false)

    emitRecallEffect(player)

    local i = snapshotTick - 1
    local oldMaterial = player:GetMaterial()
    local godBeforeRecall = player:HasGodMode()

    enterRecallState(player)

    timer.Create("recallEffect", 1.25 / (3 / TICK_RATE), 3 / TICK_RATE, function()
        i = i - 1

        local snapshot = recallSnapshots[i]
        if snapshot == nil then return end

        local recallData = snapshot[player]
        if recallData == nil then return end

        if player:Health() < recallData.health then
            player:SetHealth(recallData.health)
        end
        if player:Armor() < recallData.armor then
            player:SetArmor(recallData.armor)
        end
        player:SetPos(recallData.position)
        player:SetEyeAngles(recallData.angles)
        player:Extinguish()
    end)

    timer.Simple(1.25, function()
        if not godBeforeRecall then
            player:GodDisable()
        end
        player:SetNoTarget(false)
        player:SetRenderMode(RENDERMODE_NORMAL)
        player:SetColor(Color(255, 255, 255, 255))
        -- player:UnLock()
        player:DrawWorldModel(true)
        emitRecallEffect(player)
        player:SetNWBool("readyForRecall", true)
        player:SetNWBool("canRecall", false)
        -- Such an ugly workaround
        player:SetNWInt("recallRestoreTime", GetConVar("tracer_recall_cooldown"):GetInt() - 1)
        timer.Create("recallRestore_" .. player:UserID(), 1, 0, function()
            if player:GetNWInt("recallRestoreTime") <= 0 then
                player:SetNWBool('canRecall', true)
                timer.Remove("recallRestore_" .. player:UserID())
            end
            player:SetNWInt("recallRestoreTime", player:GetNWInt("recallRestoreTime") - 1)
        end)
    end)
    if player:GetInfoNum("tracer_callouts", 0) == 1 and math.random() < 0.75 then
        timer.Simple(1.5, function()
            player:EmitSound(OWTA_CALLOUTS.recall[math.random(#OWTA_CALLOUTS.recall)])
        end)
    end
    timer.Simple(GetConVar("tracer_recall_cooldown"):GetInt(), function()
        player:SetNWBool("canRecall", true)  -- Regain ability after 12 seconds
        signal("blip", player)
    end)
end

hook.Add("InitPostEntity", "createSnapshotTicker", function()
    timer.Create("incrementTick", TICK_RATE, 0, function()
        snapshotTick = snapshotTick + 1
    end)
end)

hook.Add("InitPostEntity", "createRecallHook", function()
    timer.Create("saveRecallData", TICK_RATE, 0, function()
        recallSnapshots[snapshotTick] = {}
        for _, player in pairs(player.GetAll()) do
            recallSnapshots[snapshotTick][player] = {
                health = player:Health(),
                armor = player:Armor(),
                position = player:GetPos(),
                angles = player:EyeAngles()
                -- primaryAmmo = player:GetAmmoCount(player:GetActiveWeapon)
            }
            -- for i = 350, 500 do    -- Removing expired snapshots
            -- table.remove(recallSnapshots, snapshotTick - i)
            -- -- MsgN("removed recall snapshot at recallSnapshots[", snapshotTick - i, "]")
            -- end
        end
    end)
end)

net.Receive("OWTA_recall", function(length, player)
    if canRecall(player) then recall(player) end
end)
