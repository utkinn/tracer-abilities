include("tracerAbilities_shared.lua")

--HUD materials setup
materials =
{
	blink = Material("blink.png", "smooth"),
	recall = Material("recall.png", "smooth"),
	bomb = Material("bomb.png", "smooth"),
	crosshair =
	{
		blink =
		{
			[true] = Material("blinkCrosshairOn.png"),
			[false] = Material("blinkCrosshairOff.png")
		},
		recall =
		{
			[true] = Material("recallCrosshairOn.png"),
			[false] = Material("recallCrosshairOff.png")
		}
	}
}

--Creating HUD font
function createFonts()
	surface.CreateFont("Overwatch",
	{
		font = "BigNoodleTooOblique",
		size = 50
	})
	surface.CreateFont("Overwatch 0.5x",
	{
		font = "BigNoodleTooOblique",
		size = 25
	})
end

createFonts()
hook.Add("InitPostEntity", "createFont", createFonts)

TRANSPARENCY = 255

if not file.Exists("tracerAbilitiesControls.txt", "DATA") then
	tracerControls =
	{
		blink = nil,
		recall = nil,
		throwBomb = nil
	}
else
	tracerControls = util.JSONToTable(file.Read("tracerAbilitiesControls.txt"))
end
	
--Creating console commands
concommand.Add("tracer_blink", function() signal("blink") end, nil, "Zip horizontally through space in the direction you're moving.", FCVAR_DEMO)
concommand.Add("tracer_recall", function() signal("recall") end, nil, "Bound backward in time, returning your health, ammo and position on the map to precisely where they were a few seconds before.", FCVAR_DEMO)
concommand.Add("tracer_throwbomb", function() signal("throwBomb") end, nil, "Lob a large bomb that adheres to any surface or unfortunate opponent it lands on.", FCVAR_DEMO)
CreateClientConVar("tracer_callouts", 1, true, true, "Should your character say Tracer's phrases when you use abilities?")
CreateClientConVar("tracer_hud", 1, true, false, "Enable the abilities HUD.")
CreateClientConVar("tracer_notification_blips", 1, true, false, "Enable ability restore notification sound.")
CreateClientConVar("tracer_hud_crosshair", 1, true, false, "Enable additional crosshair HUD.")

function drawIcon(icon, shouldBeRed, x, y)
	if GetConVar("tracer_hud"):GetBool() and GetConVar("cl_drawhud"):GetBool() then
		surface.SetMaterial(icon)
		if shouldBeRed then
			surface.SetDrawColor(255, 48, 0, TRANSPARENCY)	--Red
		else
			surface.SetDrawColor(255, 208, 64, TRANSPARENCY)	--Yellow
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
		surface.SetDrawColor(255, 208, 64, TRANSPARENCY / 2)	--Yellow
		surface.DrawTexturedRect(x, y, 25, 25)
	end
end

hook.Add("HUDPaint", "drawIconBackground", function()	--Background rectangle
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
		surface.PlaySound("buttons/blip1.wav")	--Notify user
	end
end)

net.Receive("replicateConVars", function()
	for _, v in pairs(conVars) do
		cvars.AddChangeCallback("tracerAbilitiesConVarChanged", function(conVar, _, value)
			if LocalPlayer():IsAdmin() then
				net.Start("tracerAbilitiesConVarChanged")
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

function binder(form, text, onChange, initValue)
	local label = vgui.Create("DLabel")
	label:SetText(text)

	local binder = vgui.Create("DBinder")
	binder:SetSize(200, 50)
	if initValue ~= nil then binder:SetValue(initValue) end
	
	function binder:SetSelectedNumber(num)
		self.m_iSelectedNumber = num -- Preserve original functionality
		onChange(num)
	end
	
	form:AddItem(label, binder)
	return binder
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

hook.Add("PopulateToolMenu", "populateTracerAbilitiesSettings", function()
	--Graphic settings for players
	spawnmenu.AddToolMenuOption("Utilities", "Tracer Abilities", "tracerAbilitiesClient", "User Settings", nil, nil, function(form)
		form:CheckBox("Callouts", "tracer_callouts")
		form:ControlHelp("Say Tracer's phrases when you use abilities.")
		
		form:CheckBox("HUD", "tracer_hud")
		form:ControlHelp("Enable the abilities HUD.")
		
		form:CheckBox("Crosshair HUD", "tracer_hud_crosshair")
		form:ControlHelp("Enable the additionnal abilities HUD on crosshair.")
		
		form:CheckBox("Notification blips", "tracer_notification_blips")
		form:ControlHelp("Enable ability restore notification sound.")
	end)
	
	spawnmenu.AddToolMenuOption("Utilities", "Tracer Abilities", "tracerAbilitiesBindings", "Key Bindings", nil, nil, function(form)
		blinkBinder = binder(form, "Blink", function(num)
			updateKeyBinding("blink", num)
		end, tracerControls.blink)
		recallBinder = binder(form, "Recall", function(num)
			updateKeyBinding("recall", num)
		end, tracerControls.recall)
		bombBinder = binder(form, "Throw Pulse Bomb", function(num)
			updateKeyBinding("throwBomb", num)
		end, tracerControls.throwBomb)
	end)
	
	--Graphic settings for admins
	spawnmenu.AddToolMenuOption("Utilities", "Tracer Abilities", "tracerAbilitiesAdmin", "Admin Settings", nil, nil, function(form)
		if LocalPlayer():IsAdmin() then
			form:CheckBox("Blink for admins only", "tracer_blink_adminonly")
			form:ControlHelp("Allow blinking to admins only.")
			
			form:NumberWang("Blink stack size", "tracer_blink_stack", 0, 100)
			
			form:NumberWang("Blink cooldown", "tracer_blink_cooldown", 0, 100)
			form:ControlHelp("Cooldown time of a single blink.")
			
			form:CheckBox("Recall for admins only", "tracer_recall_adminonly")
			form:ControlHelp("Allow recalling to admins only.")
			
			form:NumberWang("Recall cooldown", "tracer_recall_cooldown", 1, 100)
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

hook.Add("Think", "abilityKeyPressed", function()
	if LocalPlayer():IsTyping() then return end
	if tracerControls.blink ~= nil then
		if input.IsKeyDown(tracerControls.blink) then
			if not blinkCastedOnce then
				signal("blink")
				blinkCastedOnce = true
			end
		else
			blinkCastedOnce = false
		end
	end
	if tracerControls.recall ~= nil then
		if input.IsKeyDown(tracerControls.recall) then
			signal("recall")
		end
	end
	if tracerControls.throwBomb ~= nil then
		if input.IsKeyDown(tracerControls.throwBomb) then
			signal("throwBomb")
		end
	end
end)