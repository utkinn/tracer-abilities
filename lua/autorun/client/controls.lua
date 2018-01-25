local CONTROLS_FILE = "tracerAbilitiesControls.txt"

if not file.Exists(CONTROLS_FILE, "DATA") then
    tracerControls = {
        blink = nil,
        recall = nil,
        throwBomb = nil
    }
else
    tracerControls = util.JSONToTable(file.Read(CONTROLS_FILE))
end

function updateKeyBinding(control, num)
    local fileContents = file.Read(CONTROLS_FILE)
    if fileContents ~= "" and fileContents ~= nil then
        tracerControls = util.JSONToTable(fileContents)
    else
        tracerControls = {}
    end
    tracerControls[control] = num
    file.Write(CONTROLS_FILE, util.TableToJSON(tracerControls))
end
