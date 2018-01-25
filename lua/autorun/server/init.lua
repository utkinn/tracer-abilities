AddCSLuaFile("tracer_abilities_shared.lua")
include("tracer_abilities_shared.lua")
include('server/network_strings.lua')

hook.Add("PlayerInitialSpawn", "sendConVarValues", function(player)
    local values = {}
    for _, convar in pairs(conVars) do
        table.insert(values, convar:GetInt())
    end

    net.Start("OWTA_replicateConVars")
        net.WriteTable(values)
    net.Send(player)
end)

hook.Add("PlayerSpawn", "resetAbilities", function(player)
    player:SetNWInt("blinks", GetConVar("tracer_blink_stack"):GetInt())
    player:SetNWBool("canRecall", true)
    player:SetNWBool("readyForRecall", false)
    player:SetNWBool("ultimateNotified", false)

    timer.Simple(3.1, function()
        player:SetNWBool("readyForRecall", true)
    end)
end)

net.Receive("OWTA_conVarChanged", function()
    local player = player.GetById(net.ReadUInt(7))
    local conVar = net.ReadString()
    local value = net.ReadUInt(7)
    if player:IsAdmin() and value >= 0 and value < 128 then
        GetConVar(conVar):SetInt(value)
    end
end)
