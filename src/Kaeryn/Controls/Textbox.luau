return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:textbox(options)
    options = library:normalize_options("textbox", options)
    local id, flag = library:resolve_identity(options, "textbox", self.name, true)
    local cfg = {
        id = id,
        control_type = "textbox",
        name = options.name or "TextBox",
        legacy_flags = options.legacy_flags,
        placeholder = options.placeholder,
        default = options.default or "",
        flag = flag,
        callback = options.callback or function() end,
        validator = options.validate,
        required = options.required,
        min_length = options.min_length,
        max_length = options.max_length,
        visible = options.visible ~= false,
        items = {};
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "textbox" ] = library:create( "TextButton" , {
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
            Parent = items[ "textbox" ];
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
            Parent = items[ "textbox" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 19);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });

        items[ "input" ] = library:create( "TextBox" , {
            PlaceholderText = cfg.placeholder;
            FontFace = fonts.font;
            Text = "";
            Parent = items[ "right_components" ];
            Name = "\0";
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            PlaceholderColor3 = rgb(255, 255, 255);
            CursorPosition = -1;
            ClearTextOnFocus = false;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            TextColor3 = rgb(72, 72, 72);
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(1, 0, 0, 0);
            Size = dim2(1, -4, 0, 30);
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "input" ];
            CornerRadius = dim(0, 3)
        });

        library:create( "UIPadding" , {
            Parent = items[ "right_components" ];
            PaddingTop = dim(0, 4);
            PaddingRight = dim(0, 4)
        });

        items["error"] = library:create("TextLabel", {
            FontFace = fonts.small;
            TextColor3 = rgb(255, 112, 112);
            Text = "";
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            Visible = false;
            Parent = items["textbox"];
            Name = "ValidationMessage";
            Position = dim2(0, 5, 0, 51);
            Size = dim2(1, -10, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextSize = 12;
        })
    end

    local function validate_text(text)
        local length = utf8.len(text) or #text
        if cfg.required and text == "" then return false, "This field is required" end
        if cfg.min_length and length < cfg.min_length then return false, "Enter at least " .. tostring(cfg.min_length) .. " characters" end
        if cfg.max_length and length > cfg.max_length then return false, "Use " .. tostring(cfg.max_length) .. " characters or fewer" end
        if cfg.validator then
            local ok, valid, message = pcall(cfg.validator, text)
            if not ok then
                warn("[Kaeryn] validator failed for textbox '" .. tostring(cfg.name) .. "': " .. tostring(valid))
                return false, "This value could not be validated"
            end
            if valid ~= true then return false, type(message) == "string" and message or "Enter a valid value" end
        end
        return true
    end

    local function show_error(message)
        items.error.Text = message or ""
        items.error.Visible = message ~= nil and message ~= ""
    end

    function cfg.set(text, explicit_context)
        text = tostring(text or "")
        local valid, reason = validate_text(text)
        if not valid then
            show_error(reason)
            return false, reason
        end
        show_error(nil)
        if flags[cfg.flag] == text and items.input.Text == text then return end
        flags[cfg.flag] = text
        if items.input.Text ~= text then items.input.Text = text end
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, text)
        return true
    end

    items[ "input" ]:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(items[ "input" ].Text, {source = "user", phase = "change"})
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
        local valid = validate_text(items.input.Text)
        if valid then library:commit_control(cfg, {source = "user"}, flags[cfg.flag]) end
    end)

    local default_valid, default_error = validate_text(cfg.default)
    assert(default_valid, "Invalid textbox default: " .. tostring(default_error))
    if cfg.default then
        library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    end

    items.textbox.Visible = cfg.visible
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" then return false, nil, "expected a string" end
        local valid, reason = validate_text(value)
        if not valid then return false, nil, reason end
        return true, value
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "textbox")
    library:attach_control(cfg, items.textbox, self)
    return setmetatable(cfg, library)
end
end
