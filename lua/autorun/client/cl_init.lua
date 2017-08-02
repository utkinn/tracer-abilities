materials = {
	blink = Material("blink.png", "smooth"),
	recall = Material("recall.png", "smooth")
}

function createFont()
	surface.CreateFont("Overwatch", {
		font = "bignoodletoo",
		size = 50,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	})
	surface.CreateFont("Overwatch 0.5x", {
		font = "bignoodletoo",
		size = 25,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	})
end

createFont()
hook.Add("InitPostEntity", "createFont", createFont)

blinks = 3
canRecall = true

TRANSPARENCY = 100

recallSnapshots = {}

function blink()
	if blinks > 0 and LocalPlayer():Alive() and not LocalPlayer():IsFrozen() then
		timer.Start("restoreBlinks")
		net.Start("blink")
		net.SendToServer()
		blinks = blinks - 1
	end
end

function recall()
	if not IsValid(recallSnapshots[os.time()]) then
		print("recallSnapshots[" .. os.time() .. "] is invalid")
		return
	end
	if canRecall and LocalPlayer():Alive() and not LocalPlayer():IsFrozen() then
		timer.Simple(12, function() canRecall = true end)
		recallRestoreMoment = os.time() + 12
		net.Start("recall")
			net.WriteTable(recallSnapshots[os.time()])
		net.SendToServer()
		canRecall = false
	end
end

concommand.Add("tracer_blink", blink, nil, "Zip horizontally through space in the direction you're moving.", FCVAR_DEMO)
concommand.Add("tracer_recall", recall, nil, "Bound backward in time, returning your health, ammo and position on the map to precisely where they were a few seconds before.", FCVAR_DEMO)

timer.Create("restoreBlinks", 3, 0, function()
	blinks = math.Clamp(blinks + 1, 0, 3)
end)

function drawIcon(icon, shouldBeRed, x, y)
	surface.SetMaterial(icon)
	if shouldBeRed then
		surface.SetDrawColor(255, 0, 0, TRANSPARENCY)
	else
		surface.SetDrawColor(255, 255, 255, TRANSPARENCY)
	end
	surface.DrawTexturedRect(x, y, 50, 50)
end

hook.Add("HUDPaint", "drawBlinkIcon", function()
	drawIcon(materials.blink, blinks == 0, ScrW() * 0.95, ScrH() * 0.75)
	surface.SetFont("Overwatch")
	if blinks == 0 then
		surface.SetTextColor(255, 0, 0, TRANSPARENCY)
	else
		surface.SetTextColor(255, 255, 255, TRANSPARENCY)
	end
	surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.75)
	surface.DrawText(blinks)
end)

hook.Add("HUDPaint", "drawRecallIcon", function()
	drawIcon(materials.recall, not canRecall, ScrW() * 0.95, ScrH() * 0.85)
	if not canRecall then
		surface.SetFont("Overwatch 0.5x")
		surface.SetTextColor(255, 0, 0, TRANSPARENCY)
		surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.86)
		surface.DrawText(recallRestoreMoment - os.time() + 1)
	end
end)