return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local safe_callback = __kaeryn.safe_callback
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:textbox(options)
    local cfg = {
        name = options.name or "TextBox",
        placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
        default = options.default or "",
        flag = library:resolve_flag(options.flag, options.name or "TextBox", "textbox", self.name),
        callback = options.callback or function() end,
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
    end

    function cfg.set(text)
        text = tostring(text or "")
        if flags[cfg.flag] == text and items.input.Text == text then return end
        flags[cfg.flag] = text
        if items.input.Text ~= text then items.input.Text = text end
        safe_callback(cfg.callback, text)
    end

    items[ "input" ]:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(items[ "input" ].Text)
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
    end)

    if cfg.default then
        cfg.set(cfg.default)
    end

    items.textbox.Visible = cfg.visible
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" then return false, nil, "expected a string" end
        return true, value
    end)

    library:mobile_format_control(items, "textbox")
    return setmetatable(cfg, library)
end
end
