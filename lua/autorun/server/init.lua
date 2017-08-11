AddCSLuaFile("tracerAbilities_shared.lua")

include("tracerAbilities_shared.lua")

util.AddNetworkString("blink")
util.AddNetworkString("recall")
util.AddNetworkString("throwBomb")
util.AddNetworkString("blip")
util.AddNetworkString("tracerAbilitiesConVarChanged")
util.AddNetworkString("replicateConVars")

BLINK_LENGHT = 367	--~7 meters

snapshotTick = 0	--Number of current snapshot

recallSnapshots = {}	--Table for storing all snapshots for recalls

--Sound tables
sounds =
{
	blink =
	{
		[1] = Sound("blink/1.wav"),
		[2] = Sound("blink/2.wav"),
		[3] = Sound("blink/3.wav"),
	},
	recall = Sound("recall.mp3")
}
callouts =
{
	blink =
	{
		[1] = Sound("callouts/blink/1.wav"),
		[2] = Sound("callouts/blink/2.wav")
	},
	recall = 
	{
		[1] = Sound("callouts/recall/1.wav"),
		[2] = Sound("callouts/recall/2.wav"),
		[3] = Sound("callouts/recall/3.wav"),
		[4] = Sound("callouts/recall/4.wav")
	}, 
	pulseBomb =
	{
		stuck =
		{
			[1] = Sound("callouts/pulsebomb/stuck/1.wav"),
			[2] = Sound("callouts/pulsebomb/stuck/2.wav"),
			[3] = Sound("callouts/pulsebomb/stuck/3.wav"),
			[4] = Sound("callouts/pulsebomb/stuck/4.wav")
		},
		notStuck =
		{
			[1] = Sound("callouts/pulsebomb/notstuck/1.wav"),
			[2] = Sound("callouts/pulsebomb/notstuck/2.wav"),
			[3] = Sound("callouts/pulsebomb/notstuck/3.wav"),
			[4] = Sound("callouts/pulsebomb/notstuck/4.wav")
		},
		ready =
		{
			[1] = Sound("callouts/pulsebomb/ready/1.wav"),
			[2] = Sound("callouts/pulsebomb/ready/2.wav")
		}
	}
}

TICK_RATE = 0.05	--Smoothness of recall.

hook.Add("PlayerInitialSpawn", "sendConVarValues", function(player)	--Manual console variable replication.
	--Collecting values of each console variable
	local values = {}
	for _, cvar in pairs(conVars) do
		table.insert(values, cvar:GetInt())
	end
	
	--Sending values to client
	net.Start("replicateConVars")
		net.WriteTable(values)
	net.Send(player)
end)

--Resetting abilities after death
hook.Add("PlayerSpawn", "resetAbilities", function(player)
	player:SetNWInt("blinks", GetConVar("tracer_blink_stack"):GetInt())
	player:SetNWBool("canRecall", true)
	player:SetNWBool("readyForRecall", false)
	player:SetNWBool("ultimateNotified", false)
	timer.Simple(3.1, function() player:SetNWBool("readyForRecall", true) end)
end)

--Increase the player's Pulse Bomb charge when he deals damage
function increaseBombCharge(player, increase)
	if not player:IsAdmin() and GetConVar("tracer_bomb_adminonly"):GetBool() then return end	--If bomb is available for admins only, regular players don't need to have a charge
	player:SetNWInt("bombCharge", math.Clamp(player:GetNWInt("bombCharge", 0) + increase * GetConVar("tracer_bomb_charge_multiplier"):GetInt(), 0, 100))
	if player:GetNWInt("bombCharge") == 100 and not player:GetNWBool("ultimateNotified") and player:GetInfoNum("tracer_callouts", 0) then	--Saying "Pulse Bomb ready!"
		player:EmitSound(callouts.pulseBomb.ready[math.random(#callouts.pulseBomb.ready)])
		player:SetNWBool("ultimateNotified", true)
	end
end

hook.Add("EntityTakeDamage", "increaseBombCharge", function(_, dmgInfo)
	local dmg = dmgInfo:GetDamage()
	local attacker = dmgInfo:GetAttacker()
	
	if attacker:IsPlayer() then
		increaseBombCharge(attacker, dmg / 10)
	end
end)

function restoreBlinks(player)
	if player:GetNWInt("blinks") < GetConVar("tracer_blink_stack"):GetInt() then
		player:SetNWInt("blinks", player:GetNWInt("blinks") + 1)
		signal("blip", player)
	else
		timer.Remove("restoreBlinks_" .. player:UserID())
	end
end

function emitBlinkEffect(player)
	local effectData = EffectData()
	effectData:SetEntity(player)
	util.Effect("blink", effectData)
end

function emitRecallEffect(player)
	local effectData = EffectData()
	effectData:SetOrigin(player:GetPos() + Vector(0, 0, 40))
	util.Effect("recall", effectData)
end

function blink(player)
	if GetConVar("tracer_blink_adminonly"):GetBool() then
		if not player:IsAdmin() then return end
	end
	if player:GetNWInt("blinks") > 0 and player:Alive() and not player:IsFrozen() then
		emitBlinkEffect(player)
		
		if not timer.Exists("restoreBlinks_" .. player:UserID()) then
			timer.Create("restoreBlinks_" .. player:UserID(), GetConVar("tracer_blink_cooldown"):GetInt(), 0, function() restoreBlinks(player) end)	--Reset a cooldown timer
		end
		
		local startPos, endPos = calculateBlinkPosition(player)
		
		executeBlink(player, startPos, endPos)
		
		player:EmitSound(sounds.blink[math.random(#sounds.blink)])
		if player:GetInfoNum("tracer_callouts", 0) and math.random() < 0.2 then
			timer.Simple(0.33, function() player:EmitSound(callouts.blink[math.random(#callouts.blink)]) end)
		end
		
		player:SetNWInt("blinks", player:GetNWInt("blinks") - 1)
	end
end

function calculateBlinkPosition(player)
	local playerEyeAngles = player:EyeAngles()
	playerEyeAngles.pitch = 0
	
	--If player isn't moving, we're blinking forward
	local blinkDirection = playerEyeAngles:Forward()
	--Direction blinks
	if player:KeyDown(IN_MOVELEFT) then blinkDirection = -playerEyeAngles:Right() end
	if player:KeyDown(IN_MOVERIGHT) then blinkDirection = playerEyeAngles:Right() end
	if player:KeyDown(IN_BACK) then blinkDirection = -playerEyeAngles:Forward() end
	
	blinkPosition = player:GetPos() + blinkDirection * BLINK_LENGHT
	
	local blinkPositions = {}
	
	for testedLength = 1, BLINK_LENGHT do
		local testedPos = player:GetPos() + blinkDirection * testedLength
		
		traceResult = util.TraceEntity(
		{
			start = testedPos,
			endpos = testedPos,
			filter = function(entity)
				if GetConVar("tracer_blink_through_props"):GetBool() then
					return false
				else
					return entity:GetClass() == "prop_dynamic"
				end
			end
		}, player)
		
		if traceResult.Hit then
			tryUpResult = blinkCalc_tryUpOrDown(testedPos, player, true)
			if not tryUpResult then break else
				testedPos.z = player:GetPos().z + tryDownResult
				blinkPositions[testedLength] = testedPos
			end
		else
			tryDownResult = blinkCalc_tryUpOrDown(testedPos, player, false)
			testedPos.z = player:GetPos().z + tryDownResult
			blinkPositions[testedLength] = testedPos
		end
	end
	return blinkPositions[1], blinkPositions[#blinkPositions]
end

function blinkCalc_tryUpOrDown(position, player, up)
	local testedZOffset = up and 1 or -1
	repeat
		traceResult = util.TraceEntity(
		{
			start = position + Vector(0, 0, position.z + testedZOffset),
			endpos = position + Vector(0, 0, position.z + testedZOffset),
			filter = function(entity)
				if GetConVar("tracer_blink_through_props"):GetBool() then
					return false
				else
					return entity:GetClass() == "prop_dynamic"
				end
			end
		}, player)
	until traceResult.Hit and (up and testedZOffset < 18 or testedZOffset > -18)
	return traceResult.Hit and 0 or testedZOffset
end

function executeBlink(player, firstPosition, endPosition)
	local blinkBeginTime = CurTime()
	local timeSinceBlink = CurTime() - blinkBeginTime
	
	while timeSinceBlink <= 0.5 do
		timeSinceBlink = CurTime() - blinkBeginTime
		player:SetPos(LerpVector((timeSinceBlink) / 0.5, firstPosition, endPosition))
	end
end

function recall(player)
	if GetConVar("tracer_recall_adminonly"):GetBool() then
		if not player:IsAdmin() then return end
	end
	if player:GetNWBool("canRecall") and player:Alive() and not player:IsFrozen() and player:GetNWBool("readyForRecall") then
		player:SetNWBool("readyForRecall", false)
		
		emitRecallEffect(player)
		
		local i = snapshotTick - 1
		
		local oldMaterial = player:GetMaterial()
		
		local godBeforeRecall = player:HasGodMode()
		
		player:GodEnable()
		player:SetNoTarget(true)
		player:SetRenderMode(RENDERMODE_TRANSALPHA)
		player:SetColor(Color(0, 0, 0, 0))
		--player:Lock()
		player:EmitSound(sounds.recall)
		player:DrawWorldModel(false)
		
		timer.Create("recallEffect", 1.25 / (3 / TICK_RATE), 3 / TICK_RATE, function()
			i = i - 1
			local recallData = recallSnapshots[i][player]
			
			if recallData == nil then return end
			if player:Health() < recallData.health then
				player:SetHealth(recallData.health)
			end
			if player:Armor() < recallData.armor then
				player:SetArmor(recallData.armor)
			end
			player:SetPos(recallData.position)
			player:SetEyeAngles(recallData.angles)
			player:Extinguish()
		end)
		timer.Simple(1.25, function()
			if not godBeforeRecall then
				player:GodDisable()
			end
			player:SetNoTarget(false)
			player:SetRenderMode(RENDERMODE_NORMAL)
			player:SetColor(Color(255, 255, 255, 255))
			--player:UnLock()
			player:DrawWorldModel(true)
			emitRecallEffect(player)
			player:SetNWBool("readyForRecall", true)
			player:SetNWBool("canRecall", false)
			
			--Such an ugly workaround
			player:SetNWInt("recallRestoreTime", GetConVar("tracer_recall_cooldown"):GetInt() + 2)
			timer.Create("recallRestore_" .. player:UserID(), 1, 0, function()
				if player:GetNWInt("recallRestoreTime") < 0 then timer.Remove("recallRestore_" .. player:UserID()) end
				player:SetNWInt("recallRestoreTime", player:GetNWInt("recallRestoreTime") - 1)
			end)
		end)
		
		if player:GetInfoNum("tracer_callouts", 0) and math.random() < 0.75 then
			timer.Simple(1.5, function() player:EmitSound(callouts.recall[math.random(#callouts.recall)]) end)
		end
		
		timer.Simple(GetConVar("tracer_recall_cooldown"):GetInt(), function()
			player:SetNWBool("canRecall", true)	--Regain ability after 12 seconds
			signal("blip", player)
		end)
	end
end

function throwBomb(player)
	if GetConVar("tracer_bomb_adminonly"):GetBool() then
		if not player:IsAdmin() then return end
	end
	if player:GetNWInt("bombCharge") >= 100 and player:Alive() then
		player:SetNWInt("bombCharge", 0)
		player:SetNWBool("ultimateNotified", false)
	
		local bomb = ents.Create("pulseBomb")
		
		bomb:SetPos(player:GetPos() + Vector(0, 0, 50))
		bomb:SetOwner(player)
		
		bomb:Spawn()
		local phys = bomb:GetPhysicsObject()
		phys:ApplyForceCenter(player:EyeAngles():Forward() * 3000 + Vector(0, 0, 1500))
		
		bomb:NetworkVarNotify("Stuck", function(entity, varName, _, value)
			playBombCallout(entity:GetOwner(), value)
		end)
	end
end

function playBombCallout(player, stuckToEnemy)
	if not player:GetInfoNum("tracer_callouts", 0) then return end
	if stuckToEnemy then
		player:EmitSound(callouts.pulseBomb.stuck[math.random(#callouts.pulseBomb.stuck)])
	else
		player:EmitSound(callouts.pulseBomb.notStuck[math.random(#callouts.pulseBomb.notStuck)])
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
				angles = player:EyeAngles()
				--primaryAmmo = player:GetAmmoCount(player:GetActiveWeapon)
			}
			-- for i = 350, 500 do	--Removing expired snapshots
				-- table.remove(recallSnapshots, snapshotTick - i)
				-- --MsgN("removed recall snapshot at recallSnapshots[", snapshotTick - i, "]")
			-- end
		end
	end)
end)

hook.Add("InitPostEntity", "staticBombCharge", function()
	timer.Create("staticBombCharge", 2, 0, function()
		for _, player in pairs(player.GetAll()) do
			player:SetNWInt("bombCharge", math.Clamp(player:GetNWInt("bombCharge", 0) + GetConVar("tracer_bomb_charge_multiplier"):GetInt(), 0, 100))
			if player:GetNWInt("bombCharge") == 100 and not player:GetNWBool("ultimateNotified") and player:GetInfoNum("tracer_callouts", 0) then
				player:EmitSound("callouts/pulsebomb/ready/" .. math.random(2) .. ".wav")
				player:SetNWBool("ultimateNotified", true)
			end
		end
	end)
end)

net.Receive("blink", function(length, player) blink(player) end)
net.Receive("recall", function(length, player) recall(player) end)
net.Receive("throwBomb", function(length, player) throwBomb(player) end)

net.Receive("tracerAbilitiesConVarChanged", function()
	local player = player.GetById(net.ReadUInt(7))
	local conVar = net.ReadString()
	local value = net.ReadUInt(7)
	if player:IsAdmin() and value >= 0 and value < 128 then
		GetConVar(conVar):SetInt(value)
	end
end)