if not file.Exists("tracerAbilitiesControls.txt", "DATA") then
    tracerControls = {
        blink = nil,
        recall = nil,
        throwBomb = nil
    }
else
    tracerControls = util.JSONToTable(file.Read("tracerAbilitiesControls.txt"))
end

function updateKeyBinding(control, num)
    local fileContents = file.Read("tracerAbilitiesControls.txt")
    if fileContents ~= "" and fileContents ~= nil then
        tracerControls = util.JSONToTable(fileContents)
    else
        tracerControls = {}
    end
    tracerControls[control] = num
    file.Write("tracerAbilitiesControls.txt", util.TableToJSON(tracerControls))
end
