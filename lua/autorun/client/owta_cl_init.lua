include("tracer_abilities_shared.lua")

net.Receive("OWTA_replicateConVars", function()
    for _, v in pairs(OWTA_conVars) do
        cvars.AddChangeCallback("Tracer Abilities convar changed",
        function(conVar, _, value)
            if LocalPlayer():IsAdmin() then
                net.Start("OWTA_conVarChanged")
                net.WriteUInt(LocalPlayer():UserID(), 7)
                net.WriteString(conVar)
                net.WriteUInt(value, 7)
                net.SendToServer()
            end
        end)
    end

    local values = net.ReadTable()
    local conVarNames = {}
    for k, v in pairs(OWTA_conVars) do
        conVarNames[k] = v:GetName()
    end
    for k, v in pairs(conVarNames) do
        RunConsoleCommand(v, values[k])
    end
end)

hook.Add("Think", "Ability key pressed", function()
    if LocalPlayer():IsTyping() then
        return
    end
    if OWTA_tracerControls.blink ~= nil then
        if input.IsKeyDown(OWTA_tracerControls.blink) then
            if not blinkCastedOnce then
                signal("OWTA_blink")
                blinkCastedOnce = true
            end
        else
            blinkCastedOnce = false
        end
    end
    if OWTA_tracerControls.recall ~= nil then
        if input.IsKeyDown(OWTA_tracerControls.recall) then
            signal("OWTA_recall")
        end
    end
    if OWTA_tracerControls.throwBomb ~= nil then
        if input.IsKeyDown(OWTA_tracerControls.throwBomb) then
            signal("OWTA_throwBomb")
        end
    end
end)
