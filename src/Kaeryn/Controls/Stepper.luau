return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:stepper(options)
    options = library:normalize_options("stepper", options)
    local id, flag = library:resolve_identity(options, "stepper", self.name, true)
    local cfg = {
        id = id,
        control_type = "stepper",
        flag = flag,
        legacy_flags = options.legacy_flags,
        name = options.name,
        min = options.min,
        max = options.max,
        step = options.step,
        suffix = options.suffix,
        separator = options.separator,
        value = options.default,
        default = options.default,
        callback = options.callback,
        on_commit = options.on_commit,
        items = {},
    }
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements;
        Name = "NumericStepper";
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
    items.row = library:create("Frame", {
        Parent = items.root;
        Name = "StepperRow";
        Position = dim2(0, 0, 0, 23);
        Size = dim2(1, 0, 0, 30);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.decrease = library:create("TextButton", {
        Parent = items.row;
        Name = "Decrease";
        Size = dim2(0, 30, 1, 0);
        Text = "−";
        FontFace = fonts.font;
        TextSize = 17;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
    })
    items.input = library:create("TextBox", {
        Parent = items.row;
        Name = "Value";
        Position = dim2(0, 34, 0, 0);
        Size = dim2(1, -68, 1, 0);
        Text = "";
        PlaceholderText = "0";
        ClearTextOnFocus = false;
        TextXAlignment = Enum.TextXAlignment.Center;
        FontFace = fonts.small;
        TextSize = 14;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
    })
    items.increase = library:create("TextButton", {
        Parent = items.row;
        Name = "Increase";
        Position = dim2(1, -30, 0, 0);
        Size = dim2(0, 30, 1, 0);
        Text = "+";
        FontFace = fonts.font;
        TextSize = 17;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
    })
    for _, button in ipairs({items.decrease, items.input, items.increase}) do
        library:create("UICorner", {Parent = button; CornerRadius = dim(0, 4)})
    end
    items.error = library:create("TextLabel", {
        Parent = items.root;
        Name = "ValidationMessage";
        Position = dim2(0, 2, 0, 55);
        Size = dim2(1, -4, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        Text = "";
        TextSize = 12;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextColor3 = rgb(255, 112, 112);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Visible = false;
    })
    items.suffix = library:create("TextLabel", {
        Parent = items.row;
        Name = "Suffix";
        AnchorPoint = Vector2.new(1, 0.5);
        Position = dim2(1, -36, 0.5, 0);
        Size = dim2(0, 0, 1, 0);
        AutomaticSize = Enum.AutomaticSize.X;
        Text = cfg.suffix;
        TextSize = 12;
        TextColor3 = themes.preset.muted;
        FontFace = fonts.small;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Visible = cfg.suffix ~= "";
    })

    local function snap(value)
        return clamp(cfg.min + library:round(value - cfg.min, cfg.step), cfg.min, cfg.max)
    end

    local function render()
        items.input.Text = tostring(cfg.value)
        items.error.Visible = false
        items.error.Text = ""
    end

    function cfg.set(value, explicit_context)
        value = tonumber(value)
        if not value or value ~= value or value == math.huge or value == -math.huge then
            items.error.Text = "Enter a number"
            items.error.Visible = true
            return false, "expected a finite number"
        end
        cfg.value = snap(value)
        flags[cfg.flag] = cfg.value
        render()
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, cfg.value)
        return true
    end

    function cfg.set_range(minimum, maximum, step)
        minimum, maximum, step = tonumber(minimum), tonumber(maximum), step == nil and cfg.step or tonumber(step)
        if not minimum or not maximum or not step or minimum ~= minimum or maximum ~= maximum or step ~= step
            or minimum == math.huge or minimum == -math.huge or maximum == math.huge or maximum == -math.huge
            or step == math.huge or step == -math.huge or maximum < minimum or step <= 0 then
            return false, "invalid stepper range"
        end
        cfg.min, cfg.max, cfg.step = minimum, maximum, step
        local success = cfg.set(clamp(cfg.value, minimum, maximum), {source = "code", phase = "commit"})
        return success
    end

    local function commit_user_value(value)
        local success = cfg.set(value, {source = "user", phase = "change"})
        if success then
            library:commit_control(cfg, {source = "user"}, flags[cfg.flag])
            if cfg.on_commit then library:dispatch_control_callback(cfg, cfg.on_commit, {source = "user", phase = "commit"}, flags[cfg.flag]) end
        end
    end

    items.decrease.Activated:Connect(function()
        if cfg._enabled then commit_user_value(cfg.value - cfg.step) end
    end)
    items.increase.Activated:Connect(function()
        if cfg._enabled then commit_user_value(cfg.value + cfg.step) end
    end)
    items.input.FocusLost:Connect(function()
        if not cfg._enabled then render(); return end
        local value = tonumber(items.input.Text)
        if value then
            commit_user_value(value)
        else
            items.error.Text = "Enter a number"
            items.error.Visible = true
        end
    end)

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

    flags[cfg.flag] = nil
    render()
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
            return false, nil, "expected a finite number"
        end
        return true, clamp(value, cfg.min, cfg.max)
    end, cfg.legacy_flags)
    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    library:attach_control(cfg, items.root, self)
    return setmetatable(cfg, library)
end
end
