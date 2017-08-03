AddCSLuaFile("client/cl_init.lua")

util.AddNetworkString("blink")
util.AddNetworkString("recall")

BLINK_LENGHT = 367
snapshotTick = 0

recallSnapshots = {}

TICK_RATE = 0.05

function blink(player)
	local playerAngles = player:EyeAngles()
	playerAngles.pitch = 0	--Restricting vertical movement

	local blinkDirection = playerAngles:Forward()

	if player:KeyDown( IN_MOVELEFT ) then blinkDirection = -playerAngles:Right() end
	if player:KeyDown( IN_MOVERIGHT ) then blinkDirection = playerAngles:Right() end
	if player:KeyDown( IN_BACK ) then blinkDirection = -playerAngles:Forward() end

	blinkDirection = player:GetPos() + blinkDirection * BLINK_LENGHT
	--target.z = player:GetPos().z	--Restricting vertical movement
	
	local tr = util.TraceEntity({	--Trace and Tracer...
		start = player:GetPos() + Vector(0, 0, 10),
		endpos = blinkDirection + Vector(0, 0, 10),
		filter = function()	--Trace(r) passes through all entities
			return false
		end
	}, player)
	
	-- if tr.Hit then
		-- player:SetPos(tr.HitPos)
	-- else
		-- player:SetPos(blinkDirection)
	-- end
	player:SetPos(tr.Hit and tr.HitPos or blinkDirection)
	player:EmitSound("blink" .. math.random(1, 3) .. ".wav")
	-- while util.IsInWorld( target ) or ents.FindInSphere( target, 1 ) do	--Preventing blinking outside the world or inside another entity
		-- target = target - player:GetAimVector()
	-- end
	-- target = target - player:GetAimVector() * 32	--Guaranteed no-stuck 
end

function recall(player)
	-- MsgN( "----------------------------------------------------")
	-- for k, v in SortedPairs(recallSnapshots) do
		-- MsgN( "recallSnapshots[", k, "]:")
		-- for k2, v2 in pairs(v) do
			-- MsgN( "\trecallSnapshots[", k, "][", k2, "]:")
			-- for k3, v3 in pairs(v2) do
				-- MsgN( "\t\trecallSnapshots[", k, "][", k2, "][", k3, "] = ", v3)
			-- end
		-- end
	-- end
	-- MsgN( "----------------------------------------------------")
	
	--local currentTime = math.Round(os.clock(), 1)
	--local targetTime = currentTime - 3
	--MsgN("recallData = recallSnapshots[", targetTime, "][", player, "]")
	local i = snapshotTick - 1
	player:GodEnable()
	player:SetColor(Color(255, 255, 255, 0))
	player:Lock()
	player:EmitSound("recall.mp3")
	timer.Create("recallEffect", 1.25 / (3 / TICK_RATE), 3 / TICK_RATE, function()
		i = i - 1
		--MsgN("trying to load recall snapshot, recallData = recallSnapshots[", i, "][", player, "]")
		--if not IsValid(recallSnapshots[i]) then MsgN("failed to load a recall snapshot") return end
		local recallData = recallSnapshots[i]
		--MsgN("recallSnapshots[", i, "] = ", recallSnapshots[i])
		local personalData = recallData[player]
		--MsgN("recallData[", player, "] = ", recallData[player])
		--local recallData = net.ReadTable()
		player:SetHealth(personalData.health)
		player:SetArmor(personalData.armor)
		player:SetPos(personalData.position)
		player:SetAngles(personalData.angles)
		player:Extinguish()
	end)
	timer.Simple(1.25, function()
		player:GodDisable()
		player:SetColor(Color(255, 255, 255, 255))
		player:UnLock()
	end)
end

hook.Add("InitPostEntity", "createSnapshotTicker", function()
	timer.Create("incrementTick", TICK_RATE, 0, function()
		snapshotTick = snapshotTick + 1
	end)
end)

hook.Add("InitPostEntity", "createRecallHook", function()
	timer.Create("saveRecallData", TICK_RATE, 0, function()
		--local curTime = math.Round(os.clock(), 1)
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
			--MsgN("created recall snapshot in recallSnapshots[", snapshotTick, "][", player, "]")
		end
	end)
end)

net.Receive("blink", function(length, player) blink(player) end)
net.Receive("recall", function(length, player) recall(player) end)