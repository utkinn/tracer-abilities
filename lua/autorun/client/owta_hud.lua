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
