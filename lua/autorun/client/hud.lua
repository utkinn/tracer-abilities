TRANSPARENCY = 255

function drawIcon(icon, shouldBeRed, x, y)
    if GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        surface.SetMaterial(icon)
        if shouldBeRed then
            surface.SetDrawColor(255, 48, 0, TRANSPARENCY)    --Red
        else
            surface.SetDrawColor(255, 208, 64, TRANSPARENCY)    --Yellow
        end
        surface.DrawTexturedRect(x, y, 50, 50)
    end
end

function drawCrosshairIcon(icon, disabledIcon, shouldBeEnabled, x, y)
    if GetConVar("tracer_hud_crosshair"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        if not shouldBeEnabled then
            surface.SetMaterial(disabledIcon)
        else
            surface.SetMaterial(icon)
        end
        surface.SetDrawColor(255, 208, 64, TRANSPARENCY / 2)    --Yellow
        surface.DrawTexturedRect(x, y, 25, 25)
    end
end

hook.Add("HUDPaint", "drawIconBackground", function()
    --Background rectangle
    if GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        surface.SetDrawColor(0, 0, 0, 75)
        surface.DrawRect(ScrW() * 0.91, ScrH() * 0.62, ScrW() * 0.085, ScrH() * 0.28)
    end
end)

hook.Add("HUDPaint", "drawBlinkIcon", function()
    if GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        local blinks = LocalPlayer():GetNWInt("blinks")
        drawIcon(materials.blink, blinks == 0, ScrW() * 0.95, ScrH() * 0.65)
        surface.SetFont("Overwatch")
        if blinks == 0 then
            surface.SetTextColor(255, 48, 0, TRANSPARENCY)
        else
            surface.SetTextColor(255, 208, 64, TRANSPARENCY)
        end
        surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.65)
        surface.DrawText(blinks)
    end
end)

hook.Add("HUDPaint", "drawCrosshairBlinkPiece", function()
    if GetConVar("tracer_hud_crosshair"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        local blinks = LocalPlayer():GetNWInt("blinks")
        drawCrosshairIcon(materials.crosshair.blink[true], materials.crosshair.blink[false], blinks >= 3, ScrW() * 0.48, ScrH() * 0.48)
        drawCrosshairIcon(materials.crosshair.blink[true], materials.crosshair.blink[false], blinks >= 2, ScrW() * 0.48, ScrH() * 0.49)
        drawCrosshairIcon(materials.crosshair.blink[true], materials.crosshair.blink[false], blinks >= 1, ScrW() * 0.48, ScrH() * 0.50)
    end
end)

hook.Add("HUDPaint", "drawCrosshairRecall", function()
    if GetConVar("tracer_hud_crosshair"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        drawCrosshairIcon(materials.crosshair.recall[true], materials.crosshair.recall[false], LocalPlayer():GetNWBool("canRecall"), ScrW() * 0.51, ScrH() * 0.49)
    end
end)

hook.Add("HUDPaint", "drawRecallIcon", function()
    if GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        local canRecall = LocalPlayer():GetNWBool("canRecall")
        drawIcon(materials.recall, not canRecall, ScrW() * 0.95, ScrH() * 0.75)
        if not canRecall then
            surface.SetFont("Overwatch 0.5x")
            surface.SetTextColor(255, 48, 0, TRANSPARENCY)
            surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.76)
            surface.DrawText(LocalPlayer():GetNWInt("recallRestoreTime") - 3)
        end
    end
end)

hook.Add("HUDPaint", "drawBombIcon", function()
    if GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
        drawIcon(materials.bomb, false, ScrW() * 0.95, ScrH() * 0.83)
        surface.SetFont("Overwatch")
        surface.SetTextColor(255, 208, 64, TRANSPARENCY)
        surface.SetTextPos(ScrW() * 0.91, ScrH() * 0.83)
        surface.DrawText(math.Round(LocalPlayer():GetNWInt("bombCharge", 0)) .. "%")
    end
end)

net.Receive("blip", function()
    if GetConVar("tracer_notification_blips"):GetBool() then
        surface.PlaySound("buttons/blip1.wav")    --Notify user
    end
end)