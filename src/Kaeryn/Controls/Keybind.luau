return function(__kaeryn)
    local uis = __kaeryn.uis
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
    local keys = __kaeryn.keys
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:keybind(options)
    options = library:normalize_options("keybind", options)
    local id, flag = library:resolve_identity(options, "keybind", self.name, true)
    local cfg = {
        id = id,
        control_type = "keybind",
        flag = flag,
        legacy_flags = options.legacy_flags,
        callback = options.callback or function() end,
        name = options.name or nil,
        ignore_key = options.ignore or false,

        key = options.key or nil,
        mode = options.mode or "Toggle",
        active = options.default or false,

        open = false,
        binding = nil,

        hold_instances = {},
        items = {};
    }

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
            Size = dim2(0, 0, 0, 16);
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "keybind_holder" ];
            CornerRadius = dim(0, 4)
        });

        items[ "key" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Text = "LSHIFT";
            Parent = items[ "keybind_holder" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "key" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

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
                TextColor3 = rgb(72, 72, 73);
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
            control.TextColor3 = mode == path and themes.preset.accent or rgb(72, 72, 72)
        end
    end

    function cfg.set_mode(mode)
        if mode ~= "Toggle" and mode ~= "Hold" and mode ~= "Always" then return end
        cfg.mode = mode
        cfg.active = mode == "Always" and true or (mode == "Hold" and false or cfg.active)
        cfg.modify_mode_color(mode)
        cfg.set(cfg.active)
    end

    function cfg.set(input)
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
        local key_string = keys[cfg.key] or (typeof(cfg.key) == "EnumItem" and cfg.key.Name) or "NONE"
        items.key.Text = tostring(key_string)
        library:dispatch_control_callback(cfg, cfg.callback, nil, cfg.active)
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

    items[ "keybind_holder" ].MouseButton1Down:Connect(function()
        if library.is_mobile then
            cfg.open = not cfg.open
            cfg.set_visible(cfg.open)
            return
        end
        if cfg.binding then cfg.binding:Disconnect() end
        items.key.Text = "..."
        cfg.binding = library:connection(uis.InputBegan, function(keycode)
            if cfg._destroyed or not cfg._enabled then return end
            local next_key = keycode.KeyCode ~= Enum.KeyCode.Unknown and keycode.KeyCode or keycode.UserInputType
            cfg.capture_ignored_input = keycode
            if cfg.binding then cfg.binding:Disconnect(); cfg.binding = nil end
            cfg.set(next_key)
        end, cfg)
    end)

    items[ "keybind_holder" ].MouseButton2Down:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    library:connection(uis.InputBegan, function(input, game_event)
        if not cfg._destroyed and cfg._enabled and not game_event and not cfg.binding and input ~= cfg.capture_ignored_input then
            local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

            if selected_key == cfg.key then
                if cfg.mode == "Toggle" then
                    cfg.active = not cfg.active
                    cfg.set(cfg.active)
                elseif cfg.mode == "Hold" then
                    cfg.set(true)
                end
            end
        end
    end, cfg)

    library:connection(uis.InputEnded, function(input, game_event)
        if cfg._destroyed or not cfg._enabled or game_event or cfg.binding then
            return
        end

        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

        if selected_key == cfg.key then
            if cfg.mode == "Hold" then
                cfg.set(false)
            end
        end
    end, cfg)

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
    return setmetatable(cfg, library)
end
end
