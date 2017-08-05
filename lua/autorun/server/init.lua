AddCSLuaFile("client/cl_init.lua")
AddCSLuaFile("effects/blink.lua")
AddCSLuaFile("effects/recall.lua")

util.AddNetworkString("blink")
util.AddNetworkString("recall")
util.AddNetworkString("blip")

BLINK_LENGHT = 367	--~7 meters
snapshotTick = 0	--Number of current snapshot

recallSnapshots = {}	--Table for storing all snapshots

TICK_RATE = 0.05	--Smoothness of recall.

CreateConVar("tracer_blink_adminonly", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow blinking to admins only.")
CreateConVar("tracer_recall_adminonly", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow recalling to admins only.")
CreateConVar("tracer_blink_stack", 3, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Blink stack size.")
CreateConVar("tracer_blink_cooldown", 2, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Cooldown of one blink in seconds.")
CreateConVar("tracer_recall_cooldown", 11, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Cooldown of recall in seconds.")

hook.Add("PlayerSpawn", "resetAbilities", function(player)
	player:SetNWInt("blinks", GetConVar("tracer_blink_stack"):GetInt())
	player:SetNWBool("canRecall", true)
	player:SetNWBool("readyForRecall", false)
	timer.Simple(3.1, function() player:SetNWBool("readyForRecall", true) end)
end)

-- hook.Add("postPlayerDeath", "resetRecallSnapshots", function()
	
-- end)

function restoreBlinks(player)
	if player:GetNWInt("blinks") < GetConVar("tracer_blink_stack"):GetInt() then
		player:SetNWInt("blinks", player:GetNWInt("blinks") + 1)
		net.Start("blip")
		net.Send(player)
	else
		timer.Remove("player_" .. player:UserID())
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

function emitReversedRecallEffect(player)
	local effectData = EffectData()
	effectData:SetOrigin(player:GetPos() + Vector(0, 0, 40))
	util.Effect("reversedRecall", effectData)
end

function calculateBlinkPosition(player, pitch)
	local playerAngles = player:EyeAngles()
	playerAngles.pitch = pitch
	
	local blinkDirection = playerAngles:Forward()
	
	--Direction blinks
	if player:KeyDown( IN_MOVELEFT ) then blinkDirection = -playerAngles:Right() end
	if player:KeyDown( IN_MOVERIGHT ) then blinkDirection = playerAngles:Right() end
	if player:KeyDown( IN_BACK ) then blinkDirection = -playerAngles:Forward() end
	
	blinkPosition = player:GetPos() + blinkDirection * BLINK_LENGHT
	
	local tr = util.TraceEntity({	--Trace and Tracer...
		start = player:GetPos() --[[+ Vector(0, 0, 10)--]],
		endpos = blinkPosition --[[+ Vector(0, 0, 10)--]],
		filter = function()	--Trace(r) passes through all entities
			return false
		end
	}, player)
	
	return tr, blinkPosition, blinkDirection
end

function executeBlink(player, position, direction)
	local blinkAnim = {}
	blinkAnim.reverse = player:GetPos() - direction * 5	--Rolling back for 1 frame
	blinkAnim[1] = player:GetPos() + direction * BLINK_LENGHT * 0.2
	blinkAnim[2] = player:GetPos() + direction * BLINK_LENGHT * 0.4
	blinkAnim[3] = player:GetPos() + direction * BLINK_LENGHT * 0.6
	blinkAnim[4] = player:GetPos() + direction * BLINK_LENGHT * 0.8
	blinkAnim.full = position
	
	player:SetPos(blinkAnim.reverse)
	timer.Simple(0.02, function() player:SetPos(blinkAnim[1]) end)
	timer.Simple(0.03, function() player:SetPos(blinkAnim[2]) end)
	timer.Simple(0.04, function() player:SetPos(blinkAnim[3]) end)
	timer.Simple(0.05, function() player:SetPos(blinkAnim[4]) end)
	timer.Simple(0.06, function() player:SetPos(blinkAnim.full) end)
end

function slopeOrWall()
	local currentTestedPitch = -1
	while tr.Hit and currentTestedPitch >= -45 do
		tr, blinkPosition = calculateBlinkPosition(player, currentTestedPitch)
		currentTestedPitch = currentTestedPitch - 1
	end
end

function blink(player)
	if GetConVar("tracer_blink_adminonly"):GetBool() then
		if not player:IsAdmin() then return end
	end
	if player:GetNWInt("blinks") > 0 and player:Alive() and not player:IsFrozen() then
		emitBlinkEffect(player)
		
		if not timer.Exists("player_" .. player:UserID()) then
			timer.Create("restoreBlinks_" .. player:UserID(), GetConVar("tracer_blink_cooldown"):GetInt(), 0, function() restoreBlinks(player) end)	--Reset a cooldown timer
		end
		
		tr, blinkPosition, blinkDirection = calculateBlinkPosition(player, 0)
		
		if tr.Hit then
			slopeOrWall()
			executeBlink(player, tr.Hit and calculateBlinkPosition(player, 0).HitPos or tr.HitPos, blinkDirection)
		else
			executeBlink(player, blinkPosition, blinkDirection)
		end
		
		player:EmitSound("blink" .. math.random(3) .. ".wav")
		if player:GetInfoNum("tracer_callouts", 0) and math.random() < 0.2 then
			timer.Simple(0.33, function() player:EmitSound("callouts/blink/" .. math.random(2) .. ".wav") end)
		end
		player:SetNWInt("blinks", player:GetNWInt("blinks") - 1)
	end
end

function recall(player)
	if GetConVar("tracer_recall_adminonly"):GetBool() then
		if not player:IsAdmin() then return end
	end
	if player:GetNWBool("canRecall") and player:Alive() and not player:IsFrozen() and player:GetNWBool("readyForRecall") then
		emitRecallEffect(player)
		
		local i = snapshotTick - 1
		
		local oldMaterial = player:GetMaterial()
		
		player:GodEnable()
		player:SetRenderMode(RENDERMODE_TRANSALPHA)
		player:SetColor(Color(0, 0, 0, 0))
		--player:Lock()
		player:EmitSound("recall.mp3")
		player:DrawWorldModel(false)
		
		timer.Create("recallEffect", 1.25 / (3 / TICK_RATE), 3 / TICK_RATE, function()
			i = i - 1
			local recallData = recallSnapshots[i][player]
			
			player:SetHealth(recallData.health)
			player:SetArmor(recallData.armor)
			player:SetPos(recallData.position)
			player:SetEyeAngles(recallData.angles)
			player:Extinguish()
		end)
		timer.Simple(1.25, function()
			player:GodDisable()
			player:SetRenderMode(RENDERMODE_NORMAL)
			player:SetColor(Color(255, 255, 255, 255))
			--player:UnLock()
			player:DrawWorldModel(true)
			emitRecallEffect(player)
		end)
		if player:GetInfoNum("tracer_callouts", 0) and math.random() < 0.75 then
			timer.Simple(1.5, function() player:EmitSound("callouts/recall/" .. math.random(4) .. ".wav") end)
		end
		
		player:SetNWBool("canRecall", false)
		timer.Simple(GetConVar("tracer_recall_cooldown"):GetInt(), function()
			player:SetNWBool("canRecall", true)	--Regain ability after 12 seconds
			net.Start("blip")
			net.Send(player)
		end)
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

net.Receive("blink", function(length, player) blink(player) end)
net.Receive("recall", function(length, player) recall(player) end)