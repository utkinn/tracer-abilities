AddCSLuaFile( "client/cl_init.lua" )

util.AddNetworkString( "blink" )
util.AddNetworkString( "recall" )

BLINK_LENGHT = 367

playersAngles = {}

-- hook.Add( "InitPostEntity", "setupAngleTables", function()
	-- local players = player.GetHumans()
	-- for k, v in pairs( players ) do
		-- playersAngles[ v ] = nil
	-- end
-- end )

hook.Add( "PlayerDisconnected", "removeAngleTableEntry", function( player )
	playersAngles[ player ] = nil
end )

hook.Add( "Move", "retrieveMovementAngles", function( player, moveData )
	playersAngles[ player ] = moveData:GetMoveAngles()
end )

function blink( player )
	local aim = player:GetAimVector()
	aim = aim * 367
	while util.IsInWorld( aim ) or ents.FindInSphere( aim, 1 ) do	--Preventing blinking outside the world or inside another entity
		aim = aim - player:GetAimVector()
	end
	aim.z = player:GetPos().z	--Restricting vertical movement
	player:SetPos( aim )
end

net.Receive( "blink", function( length, player ) blink( player ) end )
net.Receive( "recall", function( length, player ) recall( player ) end )