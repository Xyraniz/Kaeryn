return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:toggle(options)
    options = library:normalize_options("toggle", options)
    local id, flag = library:resolve_identity(options, "toggle", self.name, true)
    local cfg = {
        id = id,
        control_type = "toggle",
        enabled = options.default == true,
        name = options.name or "Toggle",
        info = options.info or nil,
        flag = flag,
        legacy_flags = options.legacy_flags,

        type = options.type and string.lower(options.type) or "toggle";

        default = options.default or false,
        folding = options.folding or false,
        callback = options.callback or function() end,

        items = {};
        separator = options.separator;
    }

    flags[cfg.flag] = cfg.default

    local mobile_switch = library.is_mobile and cfg.type ~= "checkbox"
    local switch_width = mobile_switch and 42 or 40
    local switch_height = 22
    local thumb_size = mobile_switch and 16 or 14
    local thumb_y = (switch_height - 2 - thumb_size) / 2

    local items = cfg.items; do
        items[ "toggle" ] = library:create( "TextButton" , {
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

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "toggle" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
                Parent = items[ "toggle" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            BackgroundTransparency = 1;
            Parent = items[ "toggle" ];
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
            Padding = dim(0, 9);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        if cfg.type == "checkbox" then
            items[ "toggle_button" ] = library:create( "TextButton" , {
                FontFace = fonts.small;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                Text = "";
                LayoutOrder = 2;
                AutoButtonColor = false;
                AnchorPoint = vec2(1, 0);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, 0, 0, 0);
                Size = dim2(0, 16, 0, 16);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = rgb(67, 67, 68)
            }); library:apply_theme(items[ "toggle_button" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle_button" ];
                CornerRadius = dim(0, 4)
            });

            items[ "outline" ] = library:create( "Frame" , {
                Parent = items[ "toggle_button" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(22, 22, 24)
            }); library:apply_theme(items[ "outline" ], "accent", "BackgroundColor3");

            items[ "tick" ] = library:create( "ImageLabel" , {
                ImageTransparency = 1;
                BorderColor3 = rgb(0, 0, 0);
                Image = "rbxassetid://111862698467575";
                BackgroundTransparency = 1;
                Position = dim2(0, -1, 0, 0);
                Parent = items[ "outline" ];
                Size = dim2(1, 2, 1, 2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255);
                ZIndex = 1;
            });

            library:create( "UICorner" , {
                Parent = items[ "outline" ];
                CornerRadius = dim(0, 4)
            });

            library:create( "UIGradient" , {
                Enabled = false;
                Parent = items[ "outline" ];
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))}
            });
        else
            items[ "toggle_button" ] = library:create( "TextButton" , {
                FontFace = fonts.font;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                Text = "";
                LayoutOrder = 2;
                AutoButtonColor = false;
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, switch_width, 0, switch_height);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = themes.preset.accent
            }); library:apply_theme(items[ "toggle_button" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle_button" ];
                CornerRadius = dim(0, 999)
            });

            items[ "inline" ] = library:create( "Frame" , {
                Parent = items[ "toggle_button" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.accent
            }); library:apply_theme(items[ "inline" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "inline" ];
                CornerRadius = dim(0, 999)
            });

            items[ "circle" ] = library:create( "Frame" , {
                Parent = items[ "inline" ];
                Name = "\0";
                Position = dim2(1, -(thumb_size + 3), 0, thumb_y);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, thumb_size, 0, thumb_size);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            library:create( "UICorner" , {
                Parent = items[ "circle" ];
                CornerRadius = dim(0, 999)
            });
        end
    end;

    function cfg.set(bool)
        bool = bool == true
        cfg.enabled = bool
        if cfg.type == "checkbox" then
            library:tween(items[ "tick" ], {Rotation = bool and 0 or 45, ImageTransparency = bool and 0 or 1})
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(67, 67, 68)})
            library:tween(items[ "outline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(22, 22, 24)})
        else
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(62, 62, 66)}, Enum.EasingStyle.Quad)
            library:tween(items[ "inline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(48, 48, 52)}, Enum.EasingStyle.Quad)
            library:tween(items[ "circle" ], {
                BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(205, 205, 212),
                Position = bool and dim2(1, -(thumb_size + 3), 0, thumb_y) or dim2(0, 2, 0, thumb_y),
            }, Enum.EasingStyle.Quad)
        end

        if cfg.folding and cfg.items.elements then
            cfg.items.elements.Visible = bool and cfg._enabled ~= false and cfg._visible ~= false
        end

        flags[cfg.flag] = bool
        library:dispatch_control_callback(cfg, cfg.callback, nil, bool)
    end

    if cfg.folding then
        items.elements = library:create("Frame", {
            Parent = self.items.elements,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = cfg.enabled,
        })
        library:create("UIListLayout", {Parent = items.elements, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    end
    items[ "toggle" ].Activated:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    items[ "toggle_button" ].Activated:Connect(function()
        cfg.set(not cfg.enabled)
    end)

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
        if type(value) ~= "boolean" then return false, nil, "expected a boolean" end
        return true, value
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "toggle")
    library:attach_control(cfg, items.toggle)
    return setmetatable(cfg, library)
end
end
