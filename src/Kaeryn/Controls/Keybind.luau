return function(__kaeryn)
    local ws = __kaeryn.ws
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:keybind(options)
    local default_was_set = type(options) == "table" and options.default ~= nil
    options = library:normalize_options("keybind", options)
    local toggle_target
    if options.toggle_flag ~= nil then
        assert(options.toggle_flag:gsub("%s", "") ~= "", "keybind toggle_flag must be a non-empty toggle flag")
        for _, control in pairs(library.controls_by_id) do
            if control.flag == options.toggle_flag then
                assert(control.control_type == "toggle", "keybind toggle_flag '" .. options.toggle_flag .. "' must reference a toggle")
                toggle_target = control
                break
            end
        end
        assert(toggle_target, "keybind toggle_flag '" .. options.toggle_flag .. "' must reference a toggle created before the keybind")
    end
    local id, flag = library:resolve_identity(options, "keybind", self.name, true)
    local cfg = {
        id = id,
        control_type = "keybind",
        flag = flag,
        legacy_flags = options.legacy_flags,
        callback = options.callback or function() end,
        name = options.name or nil,
        ignore_key = options.ignore or false,
        context = options.context or "global",
        default_key = options.key or "NONE",
        default_mode = options.mode or "Toggle",
        default_active = options.default == true,
        toggle_target = toggle_target,

        key = options.key or nil,
        mode = options.mode or "Toggle",
        active = options.default or false,

        open = false,
        binding = nil,

        hold_instances = {},
        items = {};
    }

    if toggle_target and not default_was_set and cfg.mode ~= "Always" then
        cfg.active = toggle_target.enabled == true
        cfg.default_active = cfg.active
    end

    flags[cfg.flag] = {
        mode = cfg.mode,
        key = cfg.key,
        active = cfg.active
    }

    local items = cfg.items; do
        items[ "keybind_element" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "keybind_element" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            BackgroundTransparency = 1;
            Parent = items[ "keybind_element" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        items[ "keybind_holder" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = items[ "right_components" ];
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Size = dim_offset(68, 22);
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.None;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "keybind_holder" ];
            CornerRadius = dim(0, 4)
        });

        items[ "key" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = themes.preset.muted;
            BorderColor3 = rgb(0, 0, 0);
            Text = "LSHIFT";
            Parent = items[ "keybind_holder" ];
            Name = "\0";
            Size = dim2(1, -8, 1, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Center;
            TextYAlignment = Enum.TextYAlignment.Center;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.None;
            TextSize = 14;
            TextTruncate = Enum.TextTruncate.AtEnd;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "key" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        library:apply_theme(items[ "key" ], "muted", "TextColor3")

        items["conflict"] = library:create("TextLabel", {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 100, 100);
            Text = "!";
            Visible = false;
            Parent = items["right_components"];
            Name = "KeybindConflict";
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
        })

        items[ "dropdown" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = library.items;
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundColor3 = rgb(0, 0, 0)
        });

        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "dropdown" ];
            Size = dim2(1, 0, 1, 0);
            Name = "\0";
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 6);
            PaddingTop = dim(0, 3);
            PaddingLeft = dim(0, 3);
            Parent = items[ "inline" ]
        });

        library:create( "UIListLayout" , {
            Parent = items[ "inline" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 4)
        });

        local options = {"Hold", "Toggle", "Always"}

        cfg.y_size = 14
        for _, option in options do
            local name = library:create( "TextButton" , {
                FontFace = fonts.font;
                TextColor3 = themes.preset.muted;
                BorderColor3 = rgb(0, 0, 0);
                Text = option;
                Parent = items[ "inline" ];
                Name = "\0";
                Size = dim2(0, 0, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 14;
                BackgroundColor3 = rgb(255, 255, 255)
            }); cfg.hold_instances[option] = name
            library:apply_theme(name, "accent", "TextColor3")
            library:apply_theme(name, "muted", "TextColor3")

            cfg.y_size += 25

            library:create( "UIPadding" , {
                Parent = name;
                PaddingTop = dim(0, 1);
                PaddingRight = dim(0, 5);
                PaddingLeft = dim(0, 5)
            });

            name.MouseButton1Click:Connect(function()
                cfg.set(option)

                cfg.set_visible(false)

                cfg.open = false
            end)
        end
    end

    function cfg.modify_mode_color(path)
        for mode, control in pairs(cfg.hold_instances) do
            control.TextColor3 = mode == path and themes.preset.accent or themes.preset.muted
        end
    end

    function cfg.set_mode(mode)
        if mode ~= "Toggle" and mode ~= "Hold" and mode ~= "Always" then return end
        cfg.mode = mode
        cfg.active = mode == "Always" and true or (mode == "Hold" and false or cfg.active)
        cfg.modify_mode_color(mode)
        cfg.set(cfg.active)
    end

    function cfg.set(input, explicit_context)
        local previous_active = cfg.active
        if type(input) == "boolean" then
            cfg.active = cfg.mode == "Always" or input
        elseif typeof(input) == "EnumItem" then
            cfg.key = input == Enum.KeyCode.Escape and "NONE" or input
        elseif type(input) == "string" then
            if input == "Toggle" or input == "Hold" or input == "Always" then
                cfg.mode = input
                if input == "Always" then cfg.active = true end
                if input == "Hold" then cfg.active = false end
            elseif input == "NONE" then
                cfg.key = "NONE"
            else
                local resolved = library:convert_enum(input)
                if resolved then cfg.key = resolved end
            end
        elseif type(input) == "table" then
            cfg.mode = (input.mode == "Toggle" or input.mode == "Hold" or input.mode == "Always") and input.mode or "Toggle"
            local resolved = type(input.key) == "string" and library:convert_enum(input.key) or input.key
            cfg.key = (input.key == "NONE" and "NONE") or resolved or "NONE"
            if input.active ~= nil then cfg.active = input.active == true end
            if cfg.mode == "Always" then cfg.active = true end
            if cfg.mode == "Hold" then cfg.active = false end
        end
        cfg.modify_mode_color(cfg.mode)
        flags[cfg.flag] = {mode = cfg.mode, key = cfg.key or "NONE", active = cfg.active}
        cfg:refresh_key_label()
        if library.refresh_keybind_conflicts then library:refresh_keybind_conflicts() end
        local should_sync_toggle = type(input) == "boolean"
            or (type(input) == "table" and input.active ~= nil)
            or previous_active ~= cfg.active
        if should_sync_toggle and cfg.toggle_target and not cfg.toggle_target._destroyed
            and cfg.toggle_target.enabled ~= cfg.active then
            cfg.toggle_target.set(cfg.active, explicit_context)
        end
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, cfg.active)
        return true
    end

    function cfg:refresh_key_label()
        items.key.Text = self.binding and "..." or library.get_keybind_label(self.key)
        items.key.TextColor3 = self.binding and themes.preset.accent or themes.preset.muted
    end

    function cfg:GetConflicts()
        return library:get_keybind_conflicts(self)
    end

    function cfg:SetContext(context)
        if type(context) ~= "string" or context:gsub("%s", "") == "" then
            return false, "Keybind context must be a non-empty string"
        end
        self.context = context
        library:refresh_keybind_conflicts()
        return true
    end

    function cfg:Rebind()
        if library.is_mobile then return false, "Key capture is unavailable on touch devices" end
        return library:begin_keybind_capture(self) ~= nil
    end

    function cfg:Reset()
        return self:Set({mode = self.default_mode, key = self.default_key, active = self.default_active})
    end

    function cfg.set_visible(bool)
        cfg.open = bool == true
        local size = bool and cfg.y_size or 0
        library:tween(items[ "dropdown" ], {Size = dim_offset(items[ "keybind_holder" ].AbsoluteSize.X, size)})

        if library.is_mobile then
            local width = max(90, items.keybind_holder.AbsoluteSize.X)
            items.dropdown.Position = library:mobile_popup_position(items.keybind_holder, width, max(100, size), 6)
        else
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            local x = clamp(items.keybind_holder.AbsolutePosition.X, 6, max(6, viewport.X - items.keybind_holder.AbsoluteSize.X - 6))
            local y = items.keybind_holder.AbsolutePosition.Y + items.keybind_holder.AbsoluteSize.Y + 60
            if y + size > viewport.Y - 8 then y = max(6, items.keybind_holder.AbsolutePosition.Y - size - 8) end
            items.dropdown.Position = dim_offset(x, y)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    items[ "keybind_holder" ].Activated:Connect(function()
        if library.is_mobile then
            cfg.open = not cfg.open
            cfg.set_visible(cfg.open)
            return
        end
        cfg:Rebind()
    end)

    items[ "keybind_holder" ].MouseButton2Down:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    library:with_change_context("initialization", "initialize", cfg.set, {mode = cfg.mode, active = cfg.active, key = cfg.key})
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "table" then return false, nil, "expected a keybind object" end
        if value.mode ~= "Toggle" and value.mode ~= "Hold" and value.mode ~= "Always" then
            return false, nil, "mode must be Toggle, Hold, or Always"
        end
        if type(value.key) ~= "string" then return false, nil, "key must be an enum name or NONE" end
        local key = value.key
        if key ~= "NONE" and not library:convert_enum(key) then return false, nil, "key is not a valid enum name" end
        if value.active ~= nil and type(value.active) ~= "boolean" then
            return false, nil, "active must be a boolean"
        end
        return true, {mode = value.mode, key = key, active = value.active == true}
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "keybind")
    library:attach_control(cfg, items.keybind_element, self)
    if toggle_target then
        local sync_connection = toggle_target:OnChanged(function(active)
            if cfg._destroyed then return end
            cfg.active = active == true
            flags[cfg.flag] = {mode = cfg.mode, key = cfg.key or "NONE", active = cfg.active}
        end)
        cfg:AddCleanup(function() sync_connection:Disconnect() end)
    end
    library:register_keybind(cfg)
    cfg:AddCleanup(function() library:unregister_keybind(cfg) end)
    cfg:refresh_key_label()
    return setmetatable(cfg, library)
end
end
