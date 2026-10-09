return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local safe_callback = __kaeryn.safe_callback
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:toggle(options)
    local cfg = {
        enabled = options.default == true,
        name = options.name or "Toggle",
        info = options.info or nil,
        flag = library:resolve_flag(options.flag, options.name or "Toggle", "toggle", self.name),

        type = options.type and string.lower(options.type) or "toggle";

        default = options.default or false,
        folding = options.folding or false,
        callback = options.callback or function() end,

        items = {};
        seperator = options.seperator or options.Seperator or false;
    }

    flags[cfg.flag] = cfg.default

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

        if cfg.info then
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info;
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
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, 36, 0, 18);
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

            library:create( "UIGradient" , {
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
                Parent = items[ "inline" ]
            });

            items[ "circle" ] = library:create( "Frame" , {
                Parent = items[ "inline" ];
                Name = "\0";
                Position = dim2(1, -14, 0, 2);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 12, 0, 12);
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
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
            library:tween(items[ "inline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(50, 50, 50)}, Enum.EasingStyle.Quad)
            library:tween(items[ "circle" ], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -14, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
        end

        safe_callback(cfg.callback, bool)

        if cfg.folding and cfg.items.elements then
            cfg.items.elements.Visible = bool
        end

        flags[cfg.flag] = bool
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
    items[ "toggle" ].MouseButton1Click:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    items[ "toggle_button" ].MouseButton1Click:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    if cfg.seperator then
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

    cfg.set(cfg.default)

    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "boolean" then return false, nil, "expected a boolean" end
        return true, value
    end)

    library:mobile_format_control(items, "toggle")
    return setmetatable(cfg, library)
end
end
