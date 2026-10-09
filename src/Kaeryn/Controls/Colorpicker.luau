return function(__kaeryn)
    local uis = __kaeryn.uis
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local color = __kaeryn.color
    local rgb = __kaeryn.rgb
    local hsv = __kaeryn.hsv
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local numseq = __kaeryn.numseq
    local numkey = __kaeryn.numkey
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local safe_callback = __kaeryn.safe_callback
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:colorpicker(options)
    local cfg = {
        name = options.name or "Color",
        flag = library:resolve_flag(options.flag, options.name or "Color", "colorpicker", self.name),

        color = options.color or color(1, 1, 1),
        alpha = options.alpha and 1 - options.alpha or 0,

        open = false,
        callback = options.callback or function() end,
        items = {};

        seperator = options.seperator or options.Seperator or false;
    }

    local dragging_sat = false
    local dragging_hue = false
    local dragging_alpha = false

    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha

    flags[cfg.flag] = {Color = cfg.color, Transparency = cfg.alpha}

    local label;
    if not self.items.right_components then
        label = self:label({name = cfg.name, seperator = cfg.seperator})
    end

    local items = cfg.items; do
        items[ "colorpicker" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = label and label.items.right_components or self.items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim_offset(library.is_mobile and 36 or 16, library.is_mobile and 36 or 16);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(54, 31, 184)
        });

        if library.is_mobile and label then
            label.items.right_components.Size = dim_offset(40, 40)
            label.items.name.Size = dim2(1, -52, 0, 0)
        end

        library:create( "UICorner" , {
            Parent = items[ "colorpicker" ];
            CornerRadius = dim(0, 4)
        });

        items[ "colorpicker_inline" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker" ];
            AnchorPoint = vec2(0.5, 0.5);
            Position = dim2(0.5, 0, 0.5, 0);
            Size = dim_offset(library.is_mobile and 26 or 14, library.is_mobile and 26 or 14);
            Name = "\0";
            BorderMode = Enum.BorderMode.Inset;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(54, 31, 184)
        });

        library:create( "UICorner" , {
            Parent = items[ "colorpicker_inline" ];
            CornerRadius = dim(0, 4)
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
            Parent = items[ "colorpicker_inline" ]
        });

        items[ "colorpicker_holder" ] = library:create( "Frame" , {
            Parent = library[ "other" ];
            Name = "\0";
            Position = dim2(0.20000000298023224, 20, 0.296999990940094, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 166, 0, 197);
            BorderSizePixel = 0;
            Visible = true;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "colorpicker_fade" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            BackgroundTransparency = 0;
            Position = dim2(0, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            ZIndex = 100;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "colorpicker_components" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UICorner" , {
            Parent = items[ "colorpicker_components" ];
            CornerRadius = dim(0, 6)
        });

        items[ "saturation_holder" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 7, 0, 7);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -14, 1, -80);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 39, 39)
        });

        items[ "sat" ] = library:create( "TextButton" , {
            Parent = items[ "saturation_holder" ];
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            Text = "";
            AutoButtonColor = false;
            BorderColor3 = rgb(0, 0, 0);
            ZIndex = 2;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UICorner" , {
            Parent = items[ "sat" ];
            CornerRadius = dim(0, 4)
        });

        library:create( "UIGradient" , {
            Rotation = 270;
            Transparency = numseq{numkey(0, 0), numkey(1, 1)};
            Parent = items[ "sat" ];
            Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
        });

        items[ "val" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "saturation_holder" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIGradient" , {
            Parent = items[ "val" ];
            Transparency = numseq{numkey(0, 0), numkey(1, 1)}
        });

        library:create( "UICorner" , {
            Parent = items[ "val" ];
            CornerRadius = dim(0, 4)
        });

        library:create( "UICorner" , {
            Parent = items[ "saturation_holder" ];
            CornerRadius = dim(0, 4)
        });

        items[ "satvalpicker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 1);
            Parent = items[ "saturation_holder" ];
            Name = "\0";
            Position = dim2(0, 0, 4, 0);
            Size = dim2(0, 16, 0, 16);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });

        library:create( "UICorner" , {
            Parent = items[ "satvalpicker" ];
            CornerRadius = dim(0, 9999)
        });

        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            Parent = items[ "satvalpicker" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        });

        items[ "hue_gradient" ] = library:create( "TextButton" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 10, 1, -71);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -20, 0, 20);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            AutoButtonColor = false;
            Text = "";
        });

        items[ "hue_bar" ] = library:create( "Frame" , {
            Parent = items[ "hue_gradient" ];
            Name = "\0";
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 8);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))};
            Parent = items[ "hue_bar" ]
        });

        library:create( "UICorner" , {
            Parent = items[ "hue_bar" ];
            CornerRadius = dim(0, 6)
        });

        items[ "hue_picker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 0.5);
            Parent = items[ "hue_bar" ];
            Name = "\0";
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(0, 14, 0, 14);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });

        library:create( "UICorner" , {
            Parent = items[ "hue_picker" ];
            CornerRadius = dim(0, 9999)
        });

        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            Parent = items[ "hue_picker" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        });

        items[ "alpha_gradient" ] = library:create( "TextButton" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 10, 1, -49);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -20, 0, 18);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            AutoButtonColor = false;
            Text = "";
        });

        items[ "alpha_bar" ] = library:create( "Frame" , {
            Parent = items[ "alpha_gradient" ];
            Name = "\0";
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 8);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        library:create( "UICorner" , {
            Parent = items[ "alpha_bar" ];
            CornerRadius = dim(0, 6)
        });

        items[ "alpha_picker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 0.5);
            Parent = items[ "alpha_bar" ];
            Name = "\0";
            Position = dim2(1, 0, 0.5, 0);
            Size = dim2(0, 14, 0, 14);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });

        library:create( "UICorner" , {
            Parent = items[ "alpha_picker" ];
            CornerRadius = dim(0, 9999)
        });

        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Parent = items[ "alpha_picker" ]
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(255, 255, 255))};
            Parent = items[ "alpha_bar" ]
        });

        items[ "alpha_indicator" ] = library:create( "ImageLabel" , {
            ScaleType = Enum.ScaleType.Tile;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "alpha_bar" ];
            Image = "rbxassetid://18274452449";
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            TileSize = dim2(0, 6, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0)
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(112, 112, 112)), rgbkey(1, rgb(255, 0, 0))};
            Transparency = numseq{numkey(0, 0.8062499761581421), numkey(1, 0)};
            Parent = items[ "alpha_indicator" ]
        });

        library:create( "UICorner" , {
            Parent = items[ "alpha_indicator" ];
            CornerRadius = dim(0, 6)
        });

        library:create( "UIGradient" , {
            Rotation = 90;
            Parent = items[ "colorpicker_components" ];
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(66, 66, 66))}
        });

        items[ "input" ] = library:create( "TextBox" , {
            FontFace = fonts.font;
            AnchorPoint = vec2(1, 1);
            Text = "";
            Parent = items[ "colorpicker_components" ];
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
            Position = dim2(1, -8, 1, -11);
            Size = dim2(1, -16, 0, 18);
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "input" ];
            CornerRadius = dim(0, 3)
        });

        items[ "UICorenr" ] = library:create( "UICorner" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            CornerRadius = dim(0, 4)
        });
    end;

    local function update_indicators()
        local hue_width = items[ "hue_bar" ].AbsoluteSize.X - items[ "hue_picker" ].AbsoluteSize.X
        local alpha_width = items[ "alpha_bar" ].AbsoluteSize.X - items[ "alpha_picker" ].AbsoluteSize.X
        local saturation_width = items[ "saturation_holder" ].AbsoluteSize.X - items[ "satvalpicker" ].AbsoluteSize.X
        local saturation_height = items[ "saturation_holder" ].AbsoluteSize.Y - items[ "satvalpicker" ].AbsoluteSize.Y
        if hue_width <= 0 or alpha_width <= 0 or saturation_width <= 0 or saturation_height <= 0 then return end

        items[ "hue_picker" ].Position = dim2(0, hue_width * h, 0.5, 0)
        items[ "alpha_picker" ].Position = dim2(0, alpha_width * (1 - a), 0.5, 0)
        items[ "satvalpicker" ].Position = dim2(0, s * saturation_width, 1, 1 - v * saturation_height)
    end

    function cfg.set_visible(bool)
        items[ "colorpicker_fade" ].BackgroundTransparency = 0
        items[ "colorpicker_holder" ].Parent = bool and library[ "items" ] or library[ "other" ]
        if library.is_mobile then
            local holder = items.colorpicker_holder
            holder.Position = library:mobile_popup_position(items.colorpicker, holder.AbsoluteSize.X > 0 and holder.AbsoluteSize.X or 166, holder.AbsoluteSize.Y > 0 and holder.AbsoluteSize.Y or 197, 6)
            library:tween(items.colorpicker_fade, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
        else
            items[ "colorpicker_holder" ].Position = dim_offset(items[ "colorpicker" ].AbsolutePosition.X, items[ "colorpicker" ].AbsolutePosition.Y + items[ "colorpicker" ].AbsoluteSize.Y + 45)
            library:tween(items[ "colorpicker_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
            library:tween(items[ "colorpicker_holder" ], {Position = items[ "colorpicker_holder" ].Position + dim_offset(0, 20)})
        end

        if bool then
            library:close_element(cfg)
            task.defer(function()
                if not library.unloaded and cfg.open then update_indicators() end
            end)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    function cfg.set(color, alpha)
        if type(color) == "boolean" then
            return
        end

        if color then
            h, s, v = color:ToHSV()
        end

        if alpha ~= nil then
            local number = tonumber(alpha)
            if number and number == number then a = clamp(number, 0, 1) end
        end

        local Color = hsv(h, s, v)

        update_indicators()

        items[ "alpha_indicator" ]:FindFirstChildOfClass("UIGradient").Color = rgbseq{rgbkey(0, rgb(112, 112, 112)), rgbkey(1, hsv(h, 1, 1))};

        items[ "colorpicker" ].BackgroundColor3 = Color
        items[ "colorpicker_inline" ].BackgroundColor3 = Color
        items[ "saturation_holder" ].BackgroundColor3 = hsv(h, 1, 1)

        items[ "hue_picker" ].BackgroundColor3 = hsv(h, 1, 1)
        items[ "alpha_picker" ].BackgroundColor3 = hsv(h, 1, 1 - a)
        items[ "satvalpicker" ].BackgroundColor3 = hsv(h, s, v)

        flags[cfg.flag] = {
            Color = Color;
            Transparency = a
        }

        local color = items[ "colorpicker" ].BackgroundColor3
        items[ "input" ].Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
        items[ "input" ].Text ..= library:round(1 - a, 0.01)

        safe_callback(cfg.callback, Color, a)
    end

    function cfg.update_color(input_position)
        local cursor = input_position or uis:GetMouseLocation()

        if dragging_sat then
            local area = items["sat"]
            local size = area.AbsoluteSize
            if size.X <= 0 or size.Y <= 0 then return end
            s = clamp((cursor.X - area.AbsolutePosition.X) / size.X, 0, 1)
            v = 1 - clamp((cursor.Y - area.AbsolutePosition.Y) / size.Y, 0, 1)
        elseif dragging_hue then
            local area = items["hue_gradient"]
            local width = area.AbsoluteSize.X
            if width <= 0 then return end
            h = clamp((cursor.X - area.AbsolutePosition.X) / width, 0, 1)
        elseif dragging_alpha then
            local area = items["alpha_gradient"]
            local width = area.AbsoluteSize.X
            if width <= 0 then return end
            a = 1 - clamp((cursor.X - area.AbsolutePosition.X) / width, 0, 1)
        end

        cfg.set()
    end

    items[ "colorpicker" ].Activated:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    local function start_drag(input, channel)
        local function set_channel(is_dragging)
            dragging_sat = is_dragging and channel == "sat"
            dragging_hue = is_dragging and channel == "hue"
            dragging_alpha = is_dragging and channel == "alpha"
        end
        local started = library:begin_pointer_drag(input, function(position)
            cfg.update_color(position)
        end, function()
            set_channel(false)
        end)
        if not started then return end
        set_channel(true)
        cfg.update_color(input and input.Position or nil)
    end

    if library.is_mobile then
        local function attach_drag(object, channel)
            object.Active = true
            object.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then start_drag(input, channel) end
            end)
        end
        attach_drag(items.alpha_gradient, "alpha")
        attach_drag(items.alpha_picker, "alpha")
        attach_drag(items.hue_gradient, "hue")
        attach_drag(items.hue_picker, "hue")
        attach_drag(items.sat, "sat")
        attach_drag(items.satvalpicker, "sat")
    else
        items["alpha_gradient"].MouseButton1Down:Connect(function() start_drag(nil, "alpha") end)
        items["alpha_picker"].MouseButton1Down:Connect(function() start_drag(nil, "alpha") end)
        items["hue_gradient"].MouseButton1Down:Connect(function() start_drag(nil, "hue") end)
        items["hue_picker"].MouseButton1Down:Connect(function() start_drag(nil, "hue") end)
        items["sat"].MouseButton1Down:Connect(function() start_drag(nil, "sat") end)
        items["satvalpicker"].MouseButton1Down:Connect(function() start_drag(nil, "sat") end)
    end

    items[ "input" ].FocusLost:Connect(function()
        local text = items[ "input" ].Text
        local r, g, b, a = library:convert(text)

        if r and g and b and a then
            cfg.set(rgb(clamp(r, 0, 255), clamp(g, 0, 255), clamp(b, 0, 255)), 1 - clamp(a, 0, 1))
        end
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
    end)

    cfg.set(cfg.color, cfg.alpha)
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "table" or type(value.Color) ~= "string" then
            return false, nil, "expected a color object with a hex Color"
        end
        if not value.Color:match("^#?%x%x%x%x%x%x$") then
            return false, nil, "Color must be a 6-digit hex string"
        end
        local transparency = tonumber(value.Transparency)
        if not transparency or transparency ~= transparency or transparency == math.huge or transparency == -math.huge
            or transparency < 0 or transparency > 1 then
            return false, nil, "Transparency must be between 0 and 1"
        end
        local ok, parsed = pcall(__kaeryn.hex, value.Color)
        if not ok or typeof(parsed) ~= "Color3" then return false, nil, "Color is not valid hex" end
        return true, {Color = value.Color, Transparency = transparency}
    end)

    return setmetatable(cfg, library)
end
end
