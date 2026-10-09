return function(__kaeryn)
    local ws = __kaeryn.ws
    local coregui = __kaeryn.coregui
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rect = __kaeryn.rect
    local dim_offset = __kaeryn.dim_offset
    local color = __kaeryn.color
    local rgb = __kaeryn.rgb
    local floor = __kaeryn.floor
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts

function library:window(properties)
    assert(not library.unloaded, "Kaeryn has been unloaded")
    assert(not library.items, "This Kaeryn instance already has a window; load a new instance for another window")
    properties = properties or {}
    local cfg = {
        suffix = properties.suffix or properties.Suffix or "tech";
        name = properties.name or properties.Name or "nebula";
        game_name = properties.gameInfo or properties.game_info or properties.GameInfo or "Kaeryn";
        size = properties.size or properties.Size or dim2(0, 700, 0, 565);
        selected_tab;
        items = {};

        tween;
    }

    library[ "items" ] = library:create( "ScreenGui" , {
        Parent = coregui;
        Name = "\0";
        Enabled = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Global;
        IgnoreGuiInset = true;
    });

    library[ "other" ] = library:create( "ScreenGui" , {
        Parent = coregui;
        Name = "\0";
        Enabled = false;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        IgnoreGuiInset = true;
    });

    library.cache = library:create("Folder", {Name = "TabCache", Parent = library.other})
    local initial_viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
    local items = cfg.items; do
        items[ "main" ] = library:create( "Frame" , {
            Parent = library[ "items" ];
            Size = cfg.size;
            Name = "\0";
            Position = dim_offset(
                floor((initial_viewport.X - (initial_viewport.X * cfg.size.X.Scale + cfg.size.X.Offset)) / 2),
                floor((initial_viewport.Y - (initial_viewport.Y * cfg.size.Y.Scale + cfg.size.Y.Offset)) / 2)
            );
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16)
        });

        library:create( "UICorner" , {
            Parent = items[ "main" ];
            CornerRadius = dim(0, 10)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "main" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        items[ "side_frame" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            BackgroundTransparency = 1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 196, 1, -25);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16)
        });

        library:create( "Frame" , {
            AnchorPoint = vec2(1, 0);
            Parent = items[ "side_frame" ];
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 1, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });

        items[ "button_holder" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = items[ "side_frame" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 60);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, -60);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.button_holder = items[ "button_holder" ];
        if library.is_mobile then
            items.button_holder.Active = true
            items.button_holder.ScrollingDirection = Enum.ScrollingDirection.Y
            items.button_holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
            items.button_holder.ScrollBarThickness = 2
            items.button_holder.CanvasSize = dim_offset(0, 0)
            items.button_holder.ClipsDescendants = true
        end

        library:create( "UIListLayout" , {
            Parent = items[ "button_holder" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            PaddingTop = dim(0, 16);
            PaddingBottom = dim(0, 36);
            Parent = items[ "button_holder" ];
            PaddingRight = dim(0, 11);
            PaddingLeft = dim(0, 10)
        });

        local accent = themes.preset.accent
        items[ "title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "side_frame" ];
            Name = "\0";
            Text = string.format('<u>%s</u><font color = "rgb(255, 255, 255)">%s</font>', cfg.name, cfg.suffix);
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 70);
            TextColor3 = themes.preset.accent;
            BorderSizePixel = 0;
            RichText = true;
            TextSize = 30;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "title" ], "accent", "TextColor3");

        items[ "multi_holder" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 0, 56);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.multi_holder = items[ "multi_holder" ];

        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "multi_holder" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });

        items[ "shadow" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(0, 0, 0);
            ScaleType = Enum.ScaleType.Slice;
            Parent = items[ "main" ];
            BorderColor3 = rgb(0, 0, 0);
            Name = "\0";
            BackgroundColor3 = rgb(255, 255, 255);
            Size = dim2(1, 75, 1, 75);
            AnchorPoint = vec2(0.5, 0.5);
            Image = "rbxassetid://112971167999062";
            BackgroundTransparency = 1;
            Position = dim2(0.5, 0, 0.5, 0);
            SliceScale = 0.75;
            ZIndex = -100;
            BorderSizePixel = 0;
            SliceCenter = rect(vec2(112, 112), vec2(147, 147))
        });

        items[ "global_fade" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 56);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 1, -81);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16);
            ZIndex = 2;
        });

        library:create( "UICorner" , {
            Parent = items[ "shadow" ];
            CornerRadius = dim(0, 5)
        });

        items[ "info" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "main" ];
            Name = "\0";
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 25);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(23, 23, 25)
        });

        library:create( "UICorner" , {
            Parent = items[ "info" ];
            CornerRadius = dim(0, 10)
        });

        items[ "grey_fill" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "info" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(23, 23, 25)
        });

        items[ "game" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            Parent = items[ "info" ];
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.game_name;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 10, 0.5, -1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "other_info" ] = library:create( "TextLabel" , {
            Parent = items[ "info" ];
            RichText = true;
            Name = "\0";
            TextColor3 = themes.preset.accent;
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name .. cfg.suffix;
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, -10, 0.5, -1);
            AnchorPoint = vec2(0, 0.5);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Right;
            AutomaticSize = Enum.AutomaticSize.XY;
            FontFace = fonts.font;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "other_info" ], "accent", "TextColor3");
    end

    do
        if library.is_mobile then
            library.mobile_window = cfg
            library:mobile_drag(items.title, items.main)
            cfg.sidebar_toggle = library:create("TextButton", {
                Parent = items.side_frame,
                Name = "MobileSidebarToggle",
                Text = "+",
                FontFace = fonts.font,
                TextSize = 17,
                TextColor3 = rgb(175, 169, 221),
                BackgroundColor3 = rgb(32, 31, 38),
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Size = dim_offset(24, 27),
                ZIndex = 8,
            })
            library:create("UICorner", {Parent = cfg.sidebar_toggle, CornerRadius = dim(0, 6)})
            library:connection(cfg.sidebar_toggle.MouseButton1Click, function()
                local compact = library.mobile_sidebar_preference
                if compact == nil then
                    local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(450, 800)
                    compact = false
                end
                library.mobile_sidebar_preference = not compact
                library:queue_mobile_layout()
            end)
            cfg.mobile_button = library:create("TextButton", {
                Parent = library.items,
                Name = "MobileMenu",
                Text = "☰",
                FontFace = fonts.font,
                TextSize = 24,
                TextColor3 = rgb(255, 255, 255),
                BackgroundColor3 = rgb(25, 25, 29),
                BorderSizePixel = 0,
                Size = dim_offset(38, 38),
                Position = dim2(1, -49, 0, 8),
                ZIndex = 50
            })
            library:create("UICorner", {Parent = cfg.mobile_button, CornerRadius = dim(0, 9)})
            cfg.mobile_button.MouseButton1Click:Connect(function()
                items.main.Visible = not items.main.Visible
                if not items.main.Visible then library:close_element() end
            end)
            local viewport_connection
            local function track_viewport()
                if viewport_connection then viewport_connection:Disconnect() end
                if ws.CurrentCamera then
                    viewport_connection = library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
                        library:queue_mobile_layout()
                    end)
                end
                library:queue_mobile_layout()
            end
            library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), track_viewport)
            track_viewport()
            library:refresh_mobile_layout()
        else
            library:draggify(items[ "main" ])
            library:resizify(items[ "main" ])
        end
    end

    function cfg.toggle_menu(bool)
        if library.is_mobile then
            items.main.Visible = bool
            library:close_element()
        else
            library[ "items" ].Enabled = bool
        end
    end

    return setmetatable(cfg, library)
end
end
