AddCSLuaFile("client/cl_init.lua")

util.AddNetworkString("blink")
util.AddNetworkString("recall")

BLINK_LENGHT = 367	--~7 meters
snapshotTick = 0	--Number of current snapshot

recallSnapshots = {}	--Table for storing all snapshots

TICK_RATE = 0.05	--Smoothness of recall.

CreaterConVar("tracer_blink_adminonly", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow blinking to admins only.")
CreaterConVar("tracer_recall_adminonly", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow recalling to admins only.")
CreaterConVar("tracer_blink_stack", 3, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Blink stack size.")
CreaterConVar("tracer_blink_cooldown", 3, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Cooldown of one blink in seconds.")
CreaterConVar("tracer_recall_cooldown", 12, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Cooldown of recall in seconds.")

function blink(player)
	local playerAngles = player:EyeAngles()
	playerAngles.pitch = 0	--Restricting vertical movement

	local blinkDirection = playerAngles:Forward()

	--Direction blinks
	if player:KeyDown( IN_MOVELEFT ) then blinkDirection = -playerAngles:Right() end
	if player:KeyDown( IN_MOVERIGHT ) then blinkDirection = playerAngles:Right() end
	if player:KeyDown( IN_BACK ) then blinkDirection = -playerAngles:Forward() end

	blinkDirection = player:GetPos() + blinkDirection * BLINK_LENGHT
	
	local tr = util.TraceEntity({	--Trace and Tracer...
		start = player:GetPos() + Vector(0, 0, 10),
		endpos = blinkDirection + Vector(0, 0, 10),
		filter = function()	--Trace(r) passes through all entities
			return false
		end
	}, player)
	
	player:SetPos(tr.Hit and tr.HitPos or blinkDirection)
	player:EmitSound("blink" .. math.random(3) .. ".wav")
	if player:GetInfoNum("tracer_callouts", 0) and math.random() < 0.3 then
		timer.Simple(0.7, function() player:EmitSound("callouts/blink/" .. math.random(2) .. ".wav") end)
	end
end

function recall(player)
	local i = snapshotTick - 1
	
	player:GodEnable()
	player:SetColor(Color(255, 255, 255, 0))
	player:Lock()
	player:EmitSound("recall.mp3")
	
	timer.Create("recallEffect", 1.25 / (3 / TICK_RATE), 3 / TICK_RATE, function()
		i = i - 1
		local recallData = recallSnapshots[i][player]
		
		player:SetHealth(recallData.health)
		player:SetArmor(recallData.armor)
		player:SetPos(recallData.position)
		player:SetAngles(recallData.angles)
		player:Extinguish()
	end)
	timer.Simple(1.25, function()
		player:GodDisable()
		player:SetColor(Color(255, 255, 255, 255))
		player:UnLock()
	end)
	if player:GetInfoNum("tracer_callouts", 0) and math.random() < 0.5 then
		timer.Simple(1.5, function() player:EmitSound("callouts/recall/" .. math.random(4) .. ".wav") end)
	end
end

hook.Add("InitPostEntity", "createSnapshotTicker", function()
	timer.Create("incrementTick", TICK_RATE, 0, function()
		snapshotTick = snapshotTick + 1
	end)
end)

hook.Add("InitPostEntity", "createRecallHook", function()
	timer.Create("saveRecallData", TICK_RATE, 0, function()
		recallSnapshots[snapshotTick] = {}
		for _, player in pairs(player.GetAll()) do
			recallSnapshots[snapshotTick][player] =
			{
				health = player:Health(),
				armor = player:Armor(),
				position = player:GetPos(),
				angles = player:GetAngles()
				--primaryAmmo = player:GetAmmoCount(player:GetActiveWeapon)
			}
			-- for i = 350, 500 do	--Removing expired snapshots
				-- table.remove(recallSnapshots, snapshotTick - i)
				-- --MsgN("removed recall snapshot at recallSnapshots[", snapshotTick - i, "]")
			-- end
		end
	end)
end)

net.Receive("blink", function(length, player) blink(player) end)
net.Receive("recall", function(length, player) recall(player) end)