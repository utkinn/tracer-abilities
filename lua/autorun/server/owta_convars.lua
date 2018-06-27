local FLAGS = { FCVAR_ARCHIVE, FCVAR_REPLICATED }

CreateConVar("tracer_blink_admin_only",       0,  FLAGS, "Allow blinking to admins only.")
CreateConVar("tracer_recall_admin_only",      0,  FLAGS, "Allow recalling to admins only.")
CreateConVar("tracer_blink_stack",            3,  FLAGS, "Blink stack size.")
CreateConVar("tracer_blink_cooldown",         3,  FLAGS, "Cooldown of one blink in seconds.")
CreateConVar("tracer_recall_cooldown",        12, FLAGS, "Cooldown of recall in seconds.")
CreateConVar("tracer_bomb_admin_only",        0,  FLAGS, "Allow using pulse bomb to admins only.")
CreateConVar("tracer_bomb_charge_multiplier", 1,  FLAGS, "Multiplier of the pulse bomb charge speed.")
