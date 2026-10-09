return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local library = __kaeryn.library

function library:settings(options)
    local cfg = {
        open = false;
        items = {};
        sanity = true;
    }

    local items = cfg.items; do
        items[ "outline" ] = library:create( "Frame" , {
            Name = "\0";
            Visible = true;
            Parent = library[ "items" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            ClipsDescendants = true;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "elements" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "inline" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0, 10);
            Size = dim2(1, -20, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            Parent = items[ "elements" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 15);
            Parent = items[ "elements" ]
        });

        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "tick" ] = library:create( "ImageButton" , {
            Image = "rbxassetid://128797200442698";
            Name = "\0";
            AutoButtonColor = false;
            Parent = self.items[ "right_components" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 16, 0, 16);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
    end

    function cfg.set_visible(bool)
        library:tween(items[ "outline" ], {Size = dim_offset(bool and 240 or 0, 0)})
        if library.is_mobile then
            items.outline.Position = library:mobile_popup_position(items.tick, 240, max(230, items.outline.AbsoluteSize.Y), 6)
        else
            items[ "outline" ].Position = dim_offset(items[ "tick" ].AbsolutePosition.X, items[ "tick" ].AbsolutePosition.Y + 90)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    items[ "tick" ].MouseButton1Click:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    return setmetatable(cfg, library)
end
end
