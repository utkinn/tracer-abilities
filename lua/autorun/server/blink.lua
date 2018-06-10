local BLINK_LENGTH = 367    -- ~7 meters

local function restoreBlinks(player)
    if player:GetNWInt("blinks") < GetConVar("tracer_blink_stack"):GetInt() then
        player:SetNWInt("blinks", player:GetNWInt("blinks") + 1)
        signal("blip", player)
    else
        timer.Remove("restoreBlinks_" .. player:UserID())
    end
end

local function emitBlinkEffect(player)
    local effectData = EffectData()
    effectData:SetEntity(player)
    util.Effect("blink", effectData)
end

local function calculateBlinkPosition(player, pitch)
    local playerAngles = player:EyeAngles()
    playerAngles.pitch = pitch

    local blinkDirection = playerAngles:Forward()

    -- Direction blinks
    if player:KeyDown(IN_MOVELEFT) then
        blinkDirection = -playerAngles:Right()
    end
    if player:KeyDown(IN_MOVERIGHT) then
        blinkDirection = playerAngles:Right()
    end
    if player:KeyDown(IN_BACK) then
        blinkDirection = -playerAngles:Forward()
    end

    blinkPosition = player:GetPos() + blinkDirection * BLINK_LENGTH

    local tr = util.TraceEntity({  -- Trace and Tracer...
        start = player:GetPos(),  -- [[+ Vector(0, 0, 10)]],
        endpos = blinkPosition,  -- [[+ Vector(0, 0, 10)]],
        filter = function()
            return false  -- Trace(r) passes through all entities
        end
    }, player)

    return tr, blinkPosition, blinkDirection
end

local function executeBlink(player, position, direction)
    local blinkAnim = {
        player:GetPos() - direction * 5,  -- Rolling back for 1 frame
        player:GetPos() + direction * BLINK_LENGTH * 0.2,
        player:GetPos() + direction * BLINK_LENGTH * 0.4,
        player:GetPos() + direction * BLINK_LENGTH * 0.6,
        player:GetPos() + direction * BLINK_LENGTH * 0.8,
        position
    }

    player:SetPos(blinkAnim[1])

    local delay = 0.02

    for frame = 1, 6 do
        timer.Simple(delay, function()
            player:SetPos(blinkAnim[frame])
        end)
        delay = delay + 0.01
    end
end

local function slopeOrWall(player)
    local currentTestedPitch = -1
    while tr.Hit and currentTestedPitch >= -45 do
        tr, blinkPosition = calculateBlinkPosition(player, currentTestedPitch)
        currentTestedPitch = currentTestedPitch - 1
    end
end

local function canBlink(player)
    local chargeCriteria = player:GetNWInt("blinks") > 0
    local adminCriteria = not (GetConVar("tracer_blink_admin_only"):GetBool() and not player:IsAdmin())
    local physicalCriteria = player:Alive() and not player:IsFrozen()

    return chargeCriteria and adminCriteria and physicalCriteria
end

local function shouldPlayCallout(player)
    return player:GetInfoNum("tracer_callouts", 0) == 1 and math.random() < 0.2
end

local function blink(player)
    emitBlinkEffect(player)

    if not timer.Exists("restoreBlinks_" .. player:UserID()) then
        timer.Create("restoreBlinks_" .. player:UserID(), GetConVar("tracer_blink_cooldown"):GetInt(), 0, function()
            restoreBlinks(player)
        end)  -- Reset a cooldown timer
    end

    local tr, blinkPosition, blinkDirection = calculateBlinkPosition(player, 0)

    if tr.Hit then
        slopeOrWall(player)
        executeBlink(player, tr.Hit and calculateBlinkPosition(player, 0).HitPos or tr.HitPos, blinkDirection)
    else
        executeBlink(player, blinkPosition, blinkDirection)
    end

    player:EmitSound(OWTA_SOUNDS.blink[math.random(#OWTA_SOUNDS.blink)])

    if shouldPlayCallout(player) then
        timer.Simple(0.33, function() player:EmitSound(OWTA_CALLOUTS.blink[math.random(#OWTA_CALLOUTS.blink)]) end)
    end

    player:SetNWInt("blinks", player:GetNWInt("blinks") - 1)
end

net.Receive("OWTA_blink", function(length, player)
    if canBlink(player) then blink(player) end
end)
