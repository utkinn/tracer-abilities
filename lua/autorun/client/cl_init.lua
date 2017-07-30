blinks = 3

function blink()
	if blinks > 0 and LocalPlayer():Alive() and not LocalPlayer():IsFrozen() then
		net.Start( "blink" )
		net.SendToServer()
		blinks = blinks - 1
	end
end

concommand.Add( "tracer_blink", blink, nil, "Zip horizontally through space in the direction you're moving.", FCVAR_DEMO )
--bounds backward in time, returning her health, ammo and position on the map to precisely where they were a few seconds before.
concommand.Add( "tracer_recall", recall, nil, "Bound backward in time, returning your health, ammo and position on the map to precisely where they were a few seconds before.", FCVAR_DEMO )