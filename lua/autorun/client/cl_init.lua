include("tracer_abilities_shared.lua")

net.Receive("OWTA_replicateConVars", function()
    for _, v in pairs(conVars) do
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
    for k, v in pairs(conVars) do
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
    if tracerControls.blink ~= nil then
        if input.IsKeyDown(tracerControls.blink) then
            if not blinkCastedOnce then
                signal("OWTA_blink")
                blinkCastedOnce = true
            end
        else
            blinkCastedOnce = false
        end
    end
    if tracerControls.recall ~= nil then
        if input.IsKeyDown(tracerControls.recall) then
            signal("OWTA_recall")
        end
    end
    if tracerControls.throwBomb ~= nil then
        if input.IsKeyDown(tracerControls.throwBomb) then
            signal("OWTA_throwBomb")
        end
    end
end)
