local function createBinder(form, text, onChange, initValue)
    local label = vgui.Create("DLabel")
    label:SetText(text)

    local binder = vgui.Create("DBinder")
    binder:SetSize(200, 50)
    if initValue ~= nil then
        binder:SetValue(initValue)
    end

    function binder:SetSelectedNumber(num)
        self.m_iSelectedNumber = num  -- Preserve original functionality
        onChange(num)
    end

    form:AddItem(label, binder)
    return binder
end

hook.Add(
    "PopulateToolMenu",
    "Populate Tracer Abilities settings",
    function()
        -- Graphic settings for players
        spawnmenu.AddToolMenuOption(
                "Utilities",
                "Tracer Abilities",
                "tracerAbilitiesClient",
                "User Settings",
                nil,
                nil,
                function(form)
                    form:CheckBox("Callouts", "tracer_callouts")
                    form:ControlHelp("Say Tracer's phrases when you use abilities.")

                    form:CheckBox("HUD", "tracer_hud")
                    form:ControlHelp("Enable the abilities HUD.")

                    form:CheckBox("Crosshair HUD", "tracer_hud_crosshair")
                    form:ControlHelp("Enable the additional abilities HUD on crosshair.")

                    form:CheckBox("Notification blips", "tracer_notification_blips")
                    form:ControlHelp("Enable ability restore notification sound.")
                end
        )

        spawnmenu.AddToolMenuOption(
                "Utilities",
                "Tracer Abilities",
                "tracerAbilitiesBindings",
                "Key Bindings",
                nil,
                nil,
                function(form)
                    blinkBinder = createBinder(form, "Blink", function(num)
                        updateKeyBinding("blink", num)
                    end, OWTA_tracerControls.blink)
                    recallBin = createBinder(form, "Recall", function(num)
                        updateKeyBinding("recall", num)
                    end, OWTA_tracerControls.recall)
                    bombBinder = createBinder(form, "Throw Pulse Bomb", function(num)
                        updateKeyBinding("throwBomb", num)
                    end, OWTA_tracerControls.throwBomb)
                end
        )

        -- Graphic settings for admins
        spawnmenu.AddToolMenuOption("Utilities", "Tracer Abilities", "tracerAbilitiesAdmin", "Admin Settings", nil, nil,
        function(form)
            if not LocalPlayer():IsAdmin() then
                form:Help("You must have admin privilegies to change these settings.")
                return
            end

            form:CheckBox("Blink for admins only", "tracer_blink_admin_only")
            form:ControlHelp("Allow blinking to admins only.")

            -- FIXME: Zero values on number wangs
            form:NumSlider("Blink stack size", "tracer_blink_stack", 0, 100)
            form:NumSlider("Blink cooldown", "tracer_blink_cooldown", 0, 100)
            form:ControlHelp("Cooldown time of a single blink.")

            form:CheckBox("Recall for admins only", "tracer_recall_admin_only")
            form:ControlHelp("Allow recalling to admins only.")

            form:NumSlider("Recall cooldown", "tracer_recall_cooldown", 1, 100)
            form:ControlHelp("Cooldown time of recall.")

            form:CheckBox("Pulse Bomb for admins only", "tracer_bomb_admin_only")
            form:ControlHelp("Allow using pulse bombs to admins only.")

            form:NumSlider("Pulse Bomb charge multiplier", "tracer_bomb_charge_multiplier", 0, 100)
            form:ControlHelp("Multiplier of the pulse bomb charge speed.")
        end)
    end
)
