local CONTROLS_FILE = "tracerAbilitiesControls.txt"

if not file.Exists(CONTROLS_FILE, "DATA") then
    OWTA_tracerControls = {
        blink = nil,
        recall = nil,
        throwBomb = nil
    }
else
    OWTA_tracerControls = util.JSONToTable(file.Read(CONTROLS_FILE))
end

function updateKeyBinding(control, num)
    local fileContents = file.Read(CONTROLS_FILE)
    if fileContents ~= "" and fileContents ~= nil then
        OWTA_tracerControls = util.JSONToTable(fileContents)
    else
        OWTA_tracerControls = {}
    end
    OWTA_tracerControls[control] = num
    file.Write(CONTROLS_FILE, util.TableToJSON(OWTA_tracerControls))
end
