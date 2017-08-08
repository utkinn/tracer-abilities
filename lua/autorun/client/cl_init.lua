--HUD materials setup
materials =
{
	blink = Material("blink.png", "smooth"),
	recall = Material("recall.png", "smooth"),
	bomb = Material("bomb.png", "smooth")
}

--Creating HUD font
function createFonts()
	surface.CreateFont("Overwatch",
	{
		font = "BigNoodleTooOblique",
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
	surface.CreateFont("Overwatch 0.5x",
	{
		font = "BigNoodleTooOblique",
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
	
function blink()
	net.Start("blink")
	net.SendToServer()
end

function recall()
	net.Start("recall")	--Send a recall request to server
	net.SendToServer()
end

function throwBomb()
	net.Start("throwBomb")
	net.SendToServer()
end

--Creating console commands
concommand.Add("tracer_blink", blink, nil, "Zip horizontally through space in the direction you're moving.", FCVAR_DEMO)
concommand.Add("tracer_recall", recall, nil, "Bound backward in time, returning your health, ammo and position on the map to precisely where they were a few seconds before.", FCVAR_DEMO)
concommand.Add("tracer_throwbomb", throwBomb, nil, "Lob a large bomb that adheres to any surface or unfortunate opponent it lands on.", FCVAR_DEMO)
CreateClientConVar("tracer_callouts", 1, true, true, "Should your character say Tracer's phrases when you use abilities?")
CreateClientConVar("tracer_hud", 1, true, false, "Enable the abilities HUD.")
CreateClientConVar("tracer_notification_blips", 1, true, false, "Enable ability restore notification sound.")

function drawIcon(icon, shouldBeRed, x, y)
	if GetConVar("tracer_hud"):GetBool() then
		surface.SetMaterial(icon)
		if shouldBeRed then
			surface.SetDrawColor(255, 48, 0, TRANSPARENCY)	--Red
		else
			surface.SetDrawColor(255, 208, 64, TRANSPARENCY)	--Yellow
		end
		surface.DrawTexturedRect(x, y, 50, 50)
	end
end

hook.Add("HUDPaint", "drawIconBackground", function()	--Background rectangle
	if GetConVar("tracer_hud"):GetBool() then
		surface.SetDrawColor(0, 0, 0, 75)
		surface.DrawRect(ScrW() * 0.91, ScrH() * 0.62, ScrW() * 0.085, ScrH() * 0.28)
	end
end)

hook.Add("HUDPaint", "drawBlinkIcon", function()
	if GetConVar("tracer_hud"):GetBool() then
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

hook.Add("HUDPaint", "drawRecallIcon", function()
	if GetConVar("tracer_hud"):GetBool() then
		local canRecall = LocalPlayer():GetNWBool("canRecall")
		drawIcon(materials.recall, not canRecall, ScrW() * 0.95, ScrH() * 0.75)
		if not canRecall then
			surface.SetFont("Overwatch 0.5x")
			surface.SetTextColor(255, 48, 0, TRANSPARENCY)
			surface.SetTextPos(ScrW() * 0.93, ScrH() * 0.76)
			surface.DrawText(LocalPlayer():GetNWInt("recallRestoreTime"))
		end
	end
end)

hook.Add("HUDPaint", "drawBombIcon", function()
	if GetConVar("tracer_hud"):GetBool() then
		drawIcon(materials.bomb, false, ScrW() * 0.95, ScrH() * 0.83)
		surface.SetFont("Overwatch")
		surface.SetTextColor(255, 208, 64, TRANSPARENCY)
		surface.SetTextPos(ScrW() * 0.91, ScrH() * 0.83)
		surface.DrawText(math.Round(LocalPlayer():GetNWInt("bombCharge", 0)) .. "%")
	end
end)

net.Receive("blip", function()
	if GetConVar("tracer_notification_blips"):GetBool() then
		surface.PlaySound("buttons/blip1.wav")	--Notify user
	end
end)

hook.Add("PopulateToolMenu", "populateTracerAbilitiesSettings", function()
	--Graphic settings for players
	spawnmenu.AddToolMenuOption("Utilities", "User", "tracerAbilitiesClient", "Tracer Abilities Settings", nil, nil, function(form)
		form:CheckBox("Callouts", "tracer_callouts")
		form:ControlHelp("Say Tracer's phrases when you use abilities.")
		
		form:CheckBox("HUD", "tracer_hud")
		form:ControlHelp("Enable the abilities HUD.")
		
		form:CheckBox("Notification blips", "tracer_notification_blips")
		form:ControlHelp("Enable ability restore notification sound.")
	end)
	
	--Graphic settings for admins
	spawnmenu.AddToolMenuOption("Utilities", "Admin", "tracerAbilitiesAdmin", "Tracer Abilities Settings", nil, nil, function(form)
		if LocalPlayer():IsAdmin() then
			form:CheckBox("Blink for admins only", "tracer_blink_adminonly")
			form:ControlHelp("Allow blinking to admins only.")
			
			form:CheckBox("Recall for admins only", "tracer_recall_adminonly")
			form:ControlHelp("Allow recalling to admins only.")
			
			form:NumberWang("Blink stack size", "tracer_blink_stack", 0, 100)
			
			form:NumberWang("Blink cooldown", "tracer_blink_cooldown", 0, 100)
			form:ControlHelp("Cooldown time of a single blink.")
			
			form:NumberWang("Recall cooldown", "tracer_recall_cooldown", 0, 100)
			form:ControlHelp("Cooldown time of recall.")
			
			form:CheckBox("Pulse Bomb for admins only", "tracer_bomb_adminonly")
			form:ControlHelp("Allow using pulse bombs to admins only.")
			
			form:NumSlider("Pulse Bomb charge multiplier", "tracer_bomb_charge_multiplier", 0, 100)
			form:ControlHelp("Multiplier of the pulse bomb charge speed.")
		else
			form:Help("You must have admin privilegies to change these settings.")
		end
	end)
end)