--HUD materials setup
materials = {
	blink = Material("blink.png", "smooth"),
	recall = Material("recall.png", "smooth")
}

--Creating HUD font
function createFonts()
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

createFonts()
hook.Add("InitPostEntity", "createFont", createFonts)

TRANSPARENCY = 255

recallRestoreMoment = 0

function blink()
	net.Start("blink")
	net.SendToServer()
end

function recall()
	recallRestoreMoment = os.time() + 13	--Used in HUD to show cooldown time
	net.Start("recall")	--Send a recall request to server
	net.SendToServer()
end

--Creating console commands
concommand.Add("tracer_blink", blink, nil, "Zip horizontally through space in the direction you're moving.", FCVAR_DEMO)
concommand.Add("tracer_recall", recall, nil, "Bound backward in time, returning your health, ammo and position on the map to precisely where they were a few seconds before.", FCVAR_DEMO)
CreateClientConVar("tracer_callouts", 1, true, true, "Should your character say Tracer's phrases when you use abilities?") 

function drawIcon(icon, shouldBeRed, x, y)
	surface.SetMaterial(icon)
	if shouldBeRed then
		surface.SetDrawColor(255, 48, 0, TRANSPARENCY)	--Red
	else
		surface.SetDrawColor(255, 160, 0, TRANSPARENCY)	--Yellow
	end
	surface.DrawTexturedRect(x, y, 50, 50)
end

hook.Add("HUDPaint", "drawIconBackground", function()	--Background rectangle
	surface.SetDrawColor(0, 0, 0, 75)
	surface.DrawRect(ScrW() * 0.92, ScrH() * 0.72, ScrW() * 0.075, ScrH() * 0.2)
end)

hook.Add("HUDPaint", "drawBlinkIcon", function()
	local blinks = LocalPlayer():GetNWInt("blinks")
	drawIcon(materials.blink, blinks == 0, ScrW() * 0.95, ScrH() * 0.75)
	surface.SetFont("Overwatch")
	if blinks == 0 then
		surface.SetTextColor(255, 48, 0, TRANSPARENCY)
	else
		surface.SetTextColor(255, 160, 0, TRANSPARENCY)
	end
	surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.75)
	surface.DrawText(blinks)
end)

hook.Add("HUDPaint", "drawRecallIcon", function()
	local canRecall = LocalPlayer():GetNWBool("canRecall")
	drawIcon(materials.recall, not canRecall, ScrW() * 0.95, ScrH() * 0.85)
	if not canRecall then
		surface.SetFont("Overwatch 0.5x")
		surface.SetTextColor(255, 48, 0, TRANSPARENCY)
		surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.86)
		surface.DrawText(recallRestoreMoment - os.time() + 1)
	end
end)

net.Receive("blip", function()
	surface.PlaySound("buttons/blip1.wav")	--Notify user
end)