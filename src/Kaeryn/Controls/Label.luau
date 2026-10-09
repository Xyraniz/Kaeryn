return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local fonts = __kaeryn.fonts

function library:label(options)
    options = library:normalize_options("label", options)
    local id = library:resolve_identity(options, "label", self.name, false)
    local cfg = {
        id = id,
        control_type = "label",
        value = options.name or "Toggle",
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        separator = options.separator;
        info = options.info or nil;

        items = {};
    }

    local items = cfg.items; do
        items[ "label" ] = library:create( "TextButton" , {
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
            Parent = items[ "label" ];
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
                Parent = items[ "label" ];
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
            Parent = items[ "label" ];
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

    library:mobile_format_control(items, "label")
    function cfg.set(text)
        cfg.value = tostring(text or "")
        cfg.name = cfg.value
        items.name.Text = cfg.value
        library:dispatch_control_callback(cfg, nil, nil, cfg.value)
    end
    library:attach_control(cfg, items.label)
    return setmetatable(cfg, library)
end
end
