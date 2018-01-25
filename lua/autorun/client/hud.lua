local TRANSPARENCY = 255
local ICON_SIZE = 50
local CROSSHAIR_ICON_SIZE = 25

local RED = Color(255, 48, 0, TRANSPARENCY)
local YELLOW = Color(255, 208, 64, TRANSPARENCY)

local function shouldDrawHUD()
    return GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool()
end

local function shouldDrawCrosshairHUD()
    return GetConVar("tracer_hud_crosshair"):GetBool() and GetConVar("cl_drawhud"):GetBool()
end

local function drawIcon(icon, shouldBeRed, x, y)
    if not shouldDrawHUD() then return end

    surface.SetMaterial(icon)
    if shouldBeRed then
        surface.SetDrawColor(RED)
    else
        surface.SetDrawColor(YELLOW)
    end
    surface.DrawTexturedRect(x, y, ICON_SIZE, ICON_SIZE)
end

local function drawCrosshairIcon(icon, disabledIcon, shouldBeEnabled, x, y)
    if not shouldDrawCrosshairHUD() then return end

    local YELLOW_TRANSPARENT = Color(255, 208, 64, TRANSPARENCY / 2)

    local materialOfIconToDraw
    if shouldBeEnabled then
        materialOfIconToDraw = icon
    else
        materialOfIconToDraw = disabledIcon
    end

    surface.SetMaterial(materialOfIconToDraw)
    surface.SetDrawColor(YELLOW_TRANSPARENT)
    surface.DrawTexturedRect(x, y, CROSSHAIR_ICON_SIZE, CROSSHAIR_ICON_SIZE)
end

local function drawCrosshairBlinkPiece(screenYPercent, blinksRequiredToBeFilled)
    local blinks = LocalPlayer():GetNWInt("blinks")
    local blinkMaterials = OWTA_MATERIALS.crosshair.blink
    local X = ScrW() * 0.48

    drawCrosshairIcon(
            blinkMaterials[true], blinkMaterials[false], blinks >= blinksRequiredToBeFilled, X, ScrH() * screenYPercent
    )
end

local function shouldPlayBlip()
    return GetConVar("tracer_notification_blips"):GetBool()
end

local function playBlip()
    surface.PlaySound("buttons/blip1.wav")
end

hook.Add("HUDPaint", "Draw icon background plate", function()
    if not shouldDrawHUD() then return end

    local BLACK_TRANSPARENT = Color(0, 0, 0, 75)

    local X = ScrW() * 0.91
    local Y = ScrH() * 0.62
    local WIDTH = ScrW() * 0.085
    local HEIGTH = ScrH() * 0.28

    surface.SetDrawColor(BLACK_TRANSPARENT)
    surface.DrawRect(X, Y, WIDTH, HEIGTH)
end)

hook.Add("HUDPaint", "Draw Blink icon", function()
    if not shouldDrawHUD() then return end

    local blinks = LocalPlayer():GetNWInt("blinks")
    local ICON_X = ScrW() * 0.95
    local ICON_Y = ScrH() * 0.65
    local TEXT_X = ScrW() * 0.93
    local TEXT_Y = ScrH() * 0.65

    local colorToUse
    if blinks == 0 then
        colorToUse = RED
    else
        colorToUse = YELLOW
    end

    drawIcon(OWTA_MATERIALS.blink, blinks == 0, ICON_X, ICON_Y)

    surface.SetFont("Overwatch")
    surface.SetTextColor(colorToUse)
    surface.SetTextPos(TEXT_X, TEXT_Y)
    surface.DrawText(blinks)
end)

hook.Add("HUDPaint", "Draw crosshair Blink piece", function()
    if not shouldDrawCrosshairHUD() then return end

    local blinks = LocalPlayer():GetNWInt("blinks")

    drawCrosshairBlinkPiece(0.48, 3)
    drawCrosshairBlinkPiece(0.49, 2)
    drawCrosshairBlinkPiece(0.5, 1)
end)

hook.Add("HUDPaint", "drawCrosshairRecall", function()
    if not shouldDrawCrosshairHUD() then return end

    local recallMaterials = OWTA_MATERIALS.crosshair.recall
    local canRecall = LocalPlayer():GetNWBool("canRecall")

    drawCrosshairIcon(recallMaterials[true], recallMaterials[false], canRecall, ScrW() * 0.51, ScrH() * 0.49)
end)

hook.Add("HUDPaint", "drawRecallIcon", function()
    if not shouldDrawHUD() then return end

    local canRecall = LocalPlayer():GetNWBool("canRecall")

    drawIcon(OWTA_MATERIALS.recall, not canRecall, ScrW() * 0.95, ScrH() * 0.75)

    if not canRecall then
        surface.SetFont("Overwatch 0.5x")
        surface.SetTextColor(255, 48, 0, TRANSPARENCY)
        surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.76)
        surface.DrawText(LocalPlayer():GetNWInt("recallRestoreTime") - 3)
    end
end)

hook.Add("HUDPaint", "drawBombIcon", function()
    if not shouldDrawHUD() then return end

    drawIcon(OWTA_MATERIALS.bomb, false, ScrW() * 0.95, ScrH() * 0.83)
    surface.SetFont("Overwatch")
    surface.SetTextColor(255, 208, 64, TRANSPARENCY)
    surface.SetTextPos(ScrW() * 0.91, ScrH() * 0.83)
    surface.DrawText(math.Round(LocalPlayer():GetNWInt("bombCharge", 0)) .. "%")
end)

net.Receive("blip", function()
    if shouldPlayBlip() then
        playBlip()
    end
end)
