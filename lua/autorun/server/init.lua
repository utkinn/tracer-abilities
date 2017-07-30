AddCSLuaFile( "client/cl_init.lua" )

util.AddNetworkString( "blink" )
util.AddNetworkString( "recall" )

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
	local moveAngles = playersAngles[ player ]
	
	
end

net.Receive( "blink", function( length, player ) blink( player ) end )
net.Receive( "recall", function( length, player ) recall( player ) end )