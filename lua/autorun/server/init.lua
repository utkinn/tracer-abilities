AddCSLuaFile( "client/cl_init.lua" )

util.AddNetworkString( "blink" )
util.AddNetworkString( "recall" )

BLINK_LENGHT = 367

playerMoveAngles = {}

-- hook.Add( "InitPostEntity", "setupAngleTables", function()
	-- local players = player.GetHumans()
	-- for k, v in pairs( players ) do
		-- playerMoveAngles[ v ] = nil
	-- end
-- end )

hook.Add( "PlayerDisconnected", "removeAngleTableEntry", function( player )
	playerMoveAngles[ player ] = nil
end )

hook.Add( "Move", "retrieveMovementAngles", function( player, moveData )
	playerMoveAngles[ player ] = moveData:GetMoveAngles()
end )

function blink( player )
	local target = playerMoveAngles[ player ]:Forward()
	if target.x == 0 and target.y == 0 then
		target = player:GetAimVector()
	end
	target = target * 367
	target.z = player:GetPos().z	--Restricting vertical movement
	
	local tr = util.TraceEntity({	--Trace and Tracer...
		start = player:GetPos(),
		endpos = target,
		filter = function()	--Trace(r) passes through all entities
			return false
		end
	}, player )
	
	if tr.Hit then
		player:SetPos( tr.HitPos )
	else
		player:SetPos( target )
	end
	-- while util.IsInWorld( target ) or ents.FindInSphere( target, 1 ) do	--Preventing blinking outside the world or inside another entity
		-- target = target - player:GetAimVector()
	-- end
	-- target = target - player:GetAimVector() * 32	--Guaranteed no-stuck 
	-- 
	
	
end

net.Receive( "blink", function( length, player ) blink( player ) end )
net.Receive( "recall", function( length, player ) recall( player ) end )