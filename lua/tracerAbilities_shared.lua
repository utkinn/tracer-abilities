function signal(signalName, player)
	net.Start(signalName)
	if SERVER then
		net.Send(player)
	elseif CLIENT then
		net.SendToServer()
	end
end

conVarFlags = SERVER and {FCVAR_ARCHIVE, FCVAR_REPLICATED} or FCVAR_USERINFO

conVars = 
{
	CreateConVar("tracer_blink_adminonly", 0, flags, "Allow blinking to admins only."),
	CreateConVar("tracer_recall_adminonly", 0, flags, "Allow recalling to admins only."),
	CreateConVar("tracer_blink_stack", 3, flags, "Blink stack size."),
	CreateConVar("tracer_blink_cooldown", 3, flags, "Cooldown of one blink in seconds."),
	CreateConVar("tracer_recall_cooldown", 12, flags, "Cooldown of recall in seconds."),
	CreateConVar("tracer_bomb_adminonly", 0, flags, "Allow using pulse bomb to admins only."),
	CreateConVar("tracer_bomb_charge_multiplier", 1, flags, "Multiplier of the pulse bomb charge speed.")
	CreateConVar("tracer_blink_through_props", 1, flags, "Allow blinking through props and entities.")
}