return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local insert = __kaeryn.insert
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:list(properties)
    properties = library:normalize_options("list", properties)
    local id, flag = library:resolve_identity(properties, "list", self.name, true)
    local cfg = {
        id = id,
        control_type = "list",
        name = properties.name,
        legacy_flags = properties.legacy_flags,
        items = {};
        options = properties.options or {"1", "2", "3"};
        flag = flag;
        callback = properties.callback or function() end;
        data_store = {};
        current_element;
    }

    local items = cfg.items; do
        items[ "list" ] = library:create( "Frame" , {
            Parent = self.items[ "elements" ];
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            Parent = items[ "list" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            Parent = items[ "list" ];
            PaddingRight = dim(0, 4);
            PaddingLeft = dim(0, 4)
        });
    end

    function cfg.set(value)
        local found = false
        for _, button in ipairs(cfg.data_store) do
            local label = button:FindFirstChildOfClass("TextLabel")
            if label then
                local match = label.Text == value
                label.TextColor3 = match and rgb(245, 245, 245) or rgb(72, 72, 73)
                if match then cfg.current_element = label; found = true end
            end
        end
        if not found then cfg.current_element = nil end
        flags[cfg.flag] = found and value or nil
        if found then library:dispatch_control_callback(cfg, cfg.callback, nil, value) end
    end

    function cfg.refresh_options(options_to_refresh)
        local valid, reason = library:validate_option_list("list", options_to_refresh)
        if not valid then return false, reason end
        local previous = flags[cfg.flag]
        for _, button in ipairs(cfg.data_store) do button:Destroy() end
        table.clear(cfg.data_store)
        cfg.current_element = nil
        cfg.options = type(options_to_refresh) == "table" and options_to_refresh or {}
        for _, option_data in ipairs(cfg.options) do
            local button = library:create("TextButton", {
                FontFace = fonts.small, Text = "", AutoButtonColor = false,
                Parent = items.list, Size = dim2(1, 0, 0, 30), BorderSizePixel = 0,
                BackgroundColor3 = rgb(33, 33, 35),
            })
            table.insert(cfg.data_store, button)
            local name = library:create("TextLabel", {
                FontFace = fonts.font, Text = tostring(option_data), Parent = button,
                TextColor3 = rgb(72, 72, 73), BorderSizePixel = 0,
                BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0), TextSize = 14,
            })
            library:create("UICorner", {Parent = button, CornerRadius = dim(0, 3)})
            button.MouseButton1Click:Connect(function() cfg.set(name.Text) end)
            name.MouseEnter:Connect(function()
                if cfg.current_element ~= name then name.TextColor3 = rgb(140, 140, 140) end
            end)
            name.MouseLeave:Connect(function()
                if cfg.current_element ~= name then name.TextColor3 = rgb(72, 72, 73) end
            end)
        end
        if previous then cfg.set(previous) end
        return true
    end

    cfg.refresh_options(cfg.options)
    if properties.default ~= nil then
        library:with_change_context("initialization", "initialize", cfg.set, properties.default)
        assert(flags[cfg.flag] ~= nil, "list default must match one of its options")
    end
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" then return false, nil, "expected a string" end
        for _, option in ipairs(cfg.options) do
            if tostring(option) == value then return true, value end
        end
        return false, nil, "value is not one of the list options"
    end, cfg.legacy_flags)
    library:attach_control(cfg, items.list)
    return setmetatable(cfg, library)
end
end
