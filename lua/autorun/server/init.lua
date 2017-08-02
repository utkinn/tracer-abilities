AddCSLuaFile("client/cl_init.lua")

util.AddNetworkString("blink")
util.AddNetworkString("recall")

BLINK_LENGHT = 367

recallSnapshots = {}

-- hook.Add( "InitPostEntity", "setupAngleTables", function()
	-- local players = player.GetHumans()
	-- for k, v in pairs( players ) do
		-- playerMoveAngles[ v ] = nil
	-- end
-- end )

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
	MsgN( "----------------------------------------------------")
	for k, v in SortedPairs(recallSnapshots) do
		MsgN( "recallSnapshots[", k, "]:")
		for k2, v2 in pairs(v) do
			MsgN( "\trecallSnapshots[", k, "][", k2, "]:")
			for k3, v3 in pairs(v2) do
				MsgN( "\t\trecallSnapshots[", k, "][", k2, "][", k3, "] = ", v3)
			end
		end
	end
	MsgN( "----------------------------------------------------")
	
	local currentTime = math.Round(os.clock(), 1)
	--local targetTime = currentTime - 3
	--MsgN("recallData = recallSnapshots[", targetTime, "][", player, "]")
	local i = currentTime - 0.2
	timer.Create( "recallEffect", 0.0417, 28, function()
		i = i - 0.1
		MsgN("trying to load recall snapshot, recallData = recallSnapshots[", i, "][", player, "]")
		--if not IsValid(recallSnapshots[i]) then MsgN("failed to load a recall snapshot") return end
		local recallData = recallSnapshots[i]
		MsgN("recallSnapshots[", i, "] = ", recallSnapshots[i])
		local personalData = recallData[player]
		MsgN("recallData[", player, "] = ", recallData[player])
		--local recallData = net.ReadTable()
		player:SetHealth(personalData.health)
		player:SetArmor(personalData.armor)
		player:SetPos(personalData.position)
		player:SetAngles(personalData.angles)
		player:Extinguish()
	end)
end

hook.Add("InitPostEntity", "createRecallTimer", function()
	timer.Create("saveRecallData", 0.1, 0, function()
		local curTime = math.Round(os.clock(), 1)
		recallSnapshots[curTime] = {}
		for _, player in pairs(player.GetAll()) do
			recallSnapshots[curTime][player] =
			{
				health = player:Health(),
				armor = player:Armor(),
				position = player:GetPos(),
				angles = player:GetAngles()
				--primaryAmmo = player:GetAmmoCount(player:GetActiveWeapon)
			}
			for i = 3, 5, 0.1 do	--Removing expired snapshots
				table.remove(recallSnapshots, curTime - i)
				MsgN("removed recall snapshot at recallSnapshots[", curTime - i, "]")
			end
			MsgN("created recall snapshot in recallSnapshots[", curTime, "][", player, "]")
		end
	end)
end)

net.Receive("blink", function(length, player) blink(player) end)
net.Receive("recall", function(length, player) recall(player) end)