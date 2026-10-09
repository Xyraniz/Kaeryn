return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:segmented(options)
    options = library:normalize_options("segmented", options)
    local id, flag = library:resolve_identity(options, "segmented", self.name, true)
    local cfg = {
        id = id,
        control_type = "segmented",
        flag = flag,
        name = options.name,
        options = table.clone(options.items),
        default = options.default,
        callback = options.callback,
        separator = options.separator,
        items = {},
    }
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements;
        Name = "SegmentedControl";
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.name = library:create("TextLabel", {
        Parent = items.root;
        Name = "Name";
        Text = cfg.name;
        FontFace = fonts.small;
        TextSize = 15;
        TextColor3 = themes.preset.text_soft;
        TextXAlignment = Enum.TextXAlignment.Left;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.container = library:create("Frame", {
        Parent = items.root;
        Name = "Options";
        Position = dim2(0, 0, 0, 23);
        Size = dim2(1, 0, 0, 30);
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        ClipsDescendants = true;
    })
    library:create("UICorner", {Parent = items.container; CornerRadius = dim(0, 5)})
    items.layout = library:create("UIListLayout", {
        Parent = items.container;
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
    })

    local function option_record(option)
        if type(option) == "table" then
            return {value = option.value, label = option.label or option.value, disabled = option.disabled == true}
        end
        return {value = option, label = option, disabled = false}
    end

    local function find_option(value)
        for _, item in ipairs(cfg.options) do
            local option = option_record(item)
            if option.value == value and not option.disabled then return option end
        end
    end

    local function update_selection()
        local selected = flags[cfg.flag]
        for value, button in pairs(items.buttons or {}) do
            local active = value == selected
            local background = active and themes.preset.accent or themes.preset.surface_alt
            local foreground = active and themes.preset.text or themes.preset.muted
            button.BackgroundColor3 = background
            button.TextColor3 = foreground
            library:track_theme(button, "BackgroundColor3", background)
            library:track_theme(button, "TextColor3", foreground)
        end
    end

    local function render()
        items.buttons = {}
        for _, child in ipairs(items.container:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local count = #cfg.options
        for index, raw_option in ipairs(cfg.options) do
            local option = option_record(raw_option)
            local button = library:create("TextButton", {
                Parent = items.container;
                Name = "Option_" .. tostring(index);
                LayoutOrder = index;
                Size = dim2(1 / count, 0, 1, 0);
                Text = library:translate(option.label);
                FontFace = fonts.small;
                TextSize = 13;
                TextTruncate = Enum.TextTruncate.AtEnd;
                TextColor3 = themes.preset.muted;
                BackgroundColor3 = themes.preset.surface_alt;
                BorderSizePixel = 0;
                AutoButtonColor = false;
                Active = not option.disabled;
                Selectable = not option.disabled;
            })
            items.buttons[option.value] = button
            button.Activated:Connect(function()
                if not option.disabled then cfg.set(option.value, {source = "user", phase = "commit"}) end
            end)
        end
        update_selection()
    end

    function cfg.set(value, explicit_context)
        if not find_option(value) then return false, "Unknown or disabled segmented option" end
        if flags[cfg.flag] == value then return true end
        flags[cfg.flag] = value
        update_selection()
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, value)
        return true
    end

    function cfg.refresh_options(new_options)
        local valid, reason = library:validate_option_list("dropdown", new_options)
        if not valid then return false, reason end
        if #new_options < 2 or #new_options > 5 then return false, "Segmented controls need 2 to 5 options" end
        local enabled = 0
        for _, option in ipairs(new_options) do
            if type(option) == "table" and option.group ~= nil then return false, "Segmented items cannot use groups" end
            if type(option) ~= "table" or not option.disabled then enabled += 1 end
        end
        if enabled < 2 or enabled > 5 then return false, "Segmented controls need between 2 and 5 enabled options" end
        cfg.options = table.clone(new_options)
        local current = flags[cfg.flag]
        local next_value = current
        if not find_option(current) then
            local first
            for _, option in ipairs(cfg.options) do
                local item = option_record(option)
                if not item.disabled then first = item.value; break end
            end
            next_value = first
        end
        render()
        if current ~= nil and current ~= next_value then return cfg.set(next_value) end
        return true
    end

    if cfg.separator then
        library:create("Frame", {
            AnchorPoint = Vector2.new(0, 1);
            Parent = self.items.elements;
            Position = dim2(0, 0, 1, 0);
            Size = dim2(1, 1, 0, 1);
            BackgroundColor3 = rgb(36, 36, 37);
            BorderSizePixel = 0;
        })
    end

    cfg.default = cfg.default or (function()
        for _, option in ipairs(cfg.options) do
            local item = option_record(option)
            if not item.disabled then return item.value end
        end
    end)()
    flags[cfg.flag] = nil
    cfg:refresh_options(cfg.options)
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" or not find_option(value) then return false, nil, "expected an enabled segmented option value" end
        return true, value
    end, options.legacy_flags)
    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    library:attach_control(cfg, items.root, self)
    if library.register_locale_callback then
        cfg._locale_connection = library:register_locale_callback(render)
        cfg:AddCleanup(function() if cfg._locale_connection then cfg._locale_connection:Disconnect() end end)
    end
    return setmetatable(cfg, library)
end
end
