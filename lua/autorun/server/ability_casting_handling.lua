hook.Add("AbilityCasted", "Tracer ability execution", function(ply, hero, abilityID)
    if hero.name == "Tracer" then
        if abilityID == 1 then
            blink(ply)
        elseif abilityID == 2 then
            recall(ply)
        end
    end
end)
