function signal(signalName, player)
    net.Start(signalName)
    if SERVER then
        net.Send(player)
    elseif CLIENT then
        net.SendToServer()
    end
end

local conVarFlags = SERVER and { FCVAR_ARCHIVE, FCVAR_REPLICATED } or FCVAR_USERINFO

OWTA_conVars = {
    CreateConVar("tracer_blink_admin_only", 0, conVarFlags, "Allow blinking to admins only."),
    CreateConVar("tracer_recall_admin_only", 0, conVarFlags, "Allow recalling to admins only."),
    CreateConVar("tracer_blink_stack", 3, conVarFlags, "Blink stack size."),
    CreateConVar("tracer_blink_cooldown", 3, conVarFlags, "Cooldown of one blink in seconds."),
    CreateConVar("tracer_recall_cooldown", 12, conVarFlags, "Cooldown of recall in seconds."),
    CreateConVar("tracer_bomb_admin_only", 0, conVarFlags, "Allow using pulse bomb to admins only."),
    CreateConVar("tracer_bomb_charge_multiplier", 1, conVarFlags, "Multiplier of the pulse bomb charge speed.")
}

TICK_RATE = 0.05  -- Smoothness of recall.
