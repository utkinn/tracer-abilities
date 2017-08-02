AddCSLuaFile("client/cl_init.lua")

util.AddNetworkString("blink")
util.AddNetworkString("recall")

BLINK_LENGHT = 367

playerMoveAngles = {}

recallSnapshots = {}

-- hook.Add( "InitPostEntity", "setupAngleTables", function()
	-- local players = player.GetHumans()
	-- for k, v in pairs( players ) do
		-- playerMoveAngles[ v ] = nil
	-- end
-- end )

hook.Add("PlayerDisconnected", "removeAngleTableEntry", function(player)
	playerMoveAngles[player] = nil
	recallSnapshots[player] = nil
end)

hook.Add("PlayerConnect", "removeAngleTableEntry", function(player)
	recallSnapshots[player] = {}
end)

hook.Add("Move", "retrieveMovementAngles", function(player, moveData)
	playerMoveAngles[player] = moveData:GetMoveAngles()
end)

function blink(player)
	local target = playerMoveAngles[player]:Forward()
	--local target = player:GetPos() + playerMoveAngles[player]:Forward()
	if target.x == 0 and target.y == 0 then
		target = player:GetAimVector()
	end
	target = target * BLINK_LENGHT
	target = target + player:GetPos()
	target.z = player:GetPos().z	--Restricting vertical movement
	
	local tr = util.TraceEntity({	--Trace and Tracer...
		start = player:GetPos() + Vector(0, 0, 10),
		endpos = target,
		filter = function()	--Trace(r) passes through all entities
			return false
		end
	}, player)
	
	if tr.Hit then
		player:SetPos(tr.HitPos)
	else
		player:SetPos(target)
	end
	player:EmitSound("blink" .. math.random(1, 3) .. ".wav")
	-- while util.IsInWorld( target ) or ents.FindInSphere( target, 1 ) do	--Preventing blinking outside the world or inside another entity
		-- target = target - player:GetAimVector()
	-- end
	-- target = target - player:GetAimVector() * 32	--Guaranteed no-stuck 
end

function recall(player)
	--local recallData = recallSnapshots[player]
	local recallData = net.ReadTable()
	player:SetHealth(recallData.health)
	player:SetArmor(recallData.armor)
	player:SetPos(recallData.position)
	player:SetAngles(recallData.angles)
	player:Extinguish()
end

-- hook.Add("InitPostEntity", "createRecallTimer", function()
	-- timer.Create("saveRecallData", 1, 0, function()
		-- local curTime = os.time()
		-- for _, player in pairs(player.GetAll()) do
			-- recallSnapshots[player][curTime + 3] =
			-- {
				-- health = player:Health(),
				-- armor = player:Armor(),
				-- position = player:GetPos(),
				-- angles = player:GetAngles()
			-- }
			-- for i = 1, 5 do
				-- table.remove(recallSnapshots[player], curTime - i)
			-- end
			-- print("created recallSnapshots[" .. player .. "][" .. curTime .. "]")
		-- end
	-- end)
-- end)

net.Receive("blink", function(length, player) blink(player) end)
net.Receive("recall", function(length, player) recall(player) end)