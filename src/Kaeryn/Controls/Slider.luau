return function(__kaeryn)
    local uis = __kaeryn.uis
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:slider(options)
    options = library:normalize_options("slider", options)
    local id, flag = library:resolve_identity(options, "slider", self.name, true)
    local cfg = {
        id = id,
        control_type = "slider",
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = flag,
        legacy_flags = options.legacy_flags,
        callback = options.callback or function() end,
        on_commit = options.on_commit,
        info = options.info or nil;

        min = options.min,
        max = options.max,
        intervals = options.interval,
        default = options.default,
        value = options.default,
        separator = options.separator;

        dragging = false,
        items = {}
    }

    cfg.min = tonumber(cfg.min) or 0
    cfg.max = tonumber(cfg.max) or 100
    if cfg.min > cfg.max then cfg.min, cfg.max = cfg.max, cfg.min end
    cfg.intervals = tonumber(cfg.intervals) or 1
    if cfg.intervals <= 0 then cfg.intervals = 1 end
    cfg.default = tonumber(cfg.default) or cfg.min
    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "slider_object" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
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

        library:create("UIListLayout", {
            Parent = items["slider_object"],
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = dim(0, 3),
        })

        items["header"] = library:create("Frame", {
            Parent = items["slider_object"],
            Name = "\0",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = dim2(1, 0, 0, 22),
            LayoutOrder = 1,
        })

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "header" ];
            Name = "\0";
            Position = dim2(0, 4, 0, 0);
            Size = dim2(1, -88, 1, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Center;
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            TextSize = 15;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items["value"] = library:create("TextLabel", {
            FontFace = fonts.small,
            TextColor3 = themes.preset.accent,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Parent = items["header"],
            Name = "\0",
            AnchorPoint = vec2(1, 0),
            Position = dim2(1, -4, 0, 0),
            Size = dim2(0, 78, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = rgb(255, 255, 255),
        })
        library:apply_theme(items["value"], "accent", "TextColor3")

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
                Parent = items[ "slider_object" ];
                Name = "\0";
                Size = dim2(1, 0, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.Y;
                TextSize = 13;
                LayoutOrder = 2;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end

        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "slider_object" ];
            Name = "\0";
            BackgroundTransparency = 1;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 38);
            BorderSizePixel = 0;
            LayoutOrder = 3;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "slider" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            Parent = items[ "right_components" ];
            Name = "\0";
            Position = dim2(0, 6, 0, 0);
            Size = dim2(1, -12, 1, 0);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items["track"] = library:create("Frame", {
            Parent = items[ "slider" ];
            Name = "\0";
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.surface_hover,
        });
        library:apply_theme(items["track"], "surface_hover", "BackgroundColor3")

        library:create("UICorner", {Parent = items["track"], CornerRadius = dim(0, 999)})

        items[ "fill" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items["track"];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.5, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.accent
        });  library:apply_theme(items[ "fill" ], "accent", "BackgroundColor3");

        library:create("UICorner", {Parent = items["fill"], CornerRadius = dim(0, 999)})

        items[ "circle" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0.5, 0.5);
            Parent = items["track"];
            Name = "\0";
            Position = dim2(0.5, 0, 0.5, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 16, 0, 16);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(244, 244, 244)
        });

        library:create("UICorner", {Parent = items["circle"], CornerRadius = dim(0, 999)})
        library:create("UIStroke", {
            Parent = items["circle"],
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = themes.preset.surface,
            Thickness = 2,
        })
    end

    function cfg.set(value, explicit_context)
        local numeric = tonumber(value)
        if not numeric or numeric ~= numeric or numeric == math.huge or numeric == -math.huge then return end
        local range = cfg.max - cfg.min
        cfg.value = clamp(cfg.min + library:round(numeric - cfg.min, cfg.intervals), cfg.min, cfg.max)
        local fraction = range > 0 and (cfg.value - cfg.min) / range or 0
        items["fill"].Size = dim2(fraction, 0, 1, 0)
        items["circle"].Position = dim2(fraction, 0, 0.5, 0)
        items[ "value" ].Text = tostring(cfg.value) .. cfg.suffix

        flags[cfg.flag] = cfg.value
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, flags[cfg.flag])
    end

    function cfg.set_range(minimum, maximum, interval)
        minimum, maximum = tonumber(minimum), tonumber(maximum)
        interval = interval == nil and cfg.intervals or tonumber(interval)
        if not minimum or not maximum or not interval or minimum ~= minimum or maximum ~= maximum or interval ~= interval or interval <= 0
            or minimum == math.huge or minimum == -math.huge or maximum == math.huge or maximum == -math.huge
            or interval == math.huge or interval == -math.huge then
            return false, "Range requires finite min/max and a positive interval"
        end
        if minimum > maximum then return false, "Range min must be less than or equal to max" end
        cfg.min, cfg.max, cfg.intervals = minimum, maximum, interval
        cfg.default = clamp(cfg.default, minimum, maximum)
        return library:with_change_context("code", "commit", function()
            cfg.set(clamp(cfg.value, minimum, maximum))
            return true
        end)
    end

    if library.is_mobile then
        local function update(position)
            local width = max(1, items.track.AbsoluteSize.X)
            local fraction = clamp((position.X - items.track.AbsolutePosition.X) / width, 0, 1)
            cfg.set(cfg.min + (cfg.max - cfg.min) * fraction, {source = "user", phase = "change"})
        end
        items.slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                and library:begin_pointer_drag(input, update, function()
                if cfg._destroyed then return end
                cfg.dragging = false
                library:tween(items.value, {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2)
                library:commit_control(cfg, {source = "user"}, flags[cfg.flag])
                end, cfg) then
                cfg.dragging = true
                update(input.Position)
                library:tween(items.value, {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
    else
        items[ "slider" ].MouseButton1Down:Connect(function()
            if library:begin_pointer_drag(nil, function(position)
                local size_x = clamp((position.X - items[ "track" ].AbsolutePosition.X) / max(1, items[ "track" ].AbsoluteSize.X), 0, 1)
                cfg.set(((cfg.max - cfg.min) * size_x) + cfg.min, {source = "user", phase = "change"})
            end, function()
                if cfg._destroyed then return end
                cfg.dragging = false
                library:tween(items[ "value" ], {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2)
                library:commit_control(cfg, {source = "user"}, flags[cfg.flag])
            end, cfg) then
                cfg.dragging = true
                local position = uis:GetMouseLocation()
                local size_x = clamp((position.X - items[ "track" ].AbsolutePosition.X) / max(1, items[ "track" ].AbsoluteSize.X), 0, 1)
                cfg.set(((cfg.max - cfg.min) * size_x) + cfg.min, {source = "user", phase = "change"})
                library:tween(items[ "value" ], {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
    end

    if cfg.separator then
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end

    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        local numeric = tonumber(value)
        if not numeric or numeric ~= numeric or numeric == math.huge or numeric == -math.huge then
            return false, nil, "expected a finite number"
        end
        if numeric < cfg.min or numeric > cfg.max then
            return false, nil, "value is outside the slider range"
        end
        return true, numeric
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "slider")
    library:attach_control(cfg, items.slider_object, self)
    return setmetatable(cfg, library)
end
end
