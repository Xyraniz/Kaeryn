return function(__kaeryn)
    local ws = __kaeryn.ws
    local gui_service = __kaeryn.gui_service
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local insert = __kaeryn.insert
    local find = __kaeryn.find
    local remove = __kaeryn.remove
    local concat = __kaeryn.concat
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local safe_callback = __kaeryn.safe_callback
    local separator_option = __kaeryn.separator_option
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:dropdown(options)
    local cfg = {
        name = options.name or nil;
        info = options.info or nil;
        flag = library:resolve_flag(options.flag, options.name, "dropdown", self.name);
        options = options.items or {""};
        callback = options.callback or function() end;
        multi = options.multi or false;
        scrolling = options.scrolling or false;

        width = options.width or 130;

        open = false;
        option_instances = {};
        multi_items = {};
        ignore = options.ignore or false;
        items = {};
        y_size;
        seperator = separator_option(options, true);
    }

    cfg.default = options.default ~= nil and options.default or (cfg.multi and (cfg.options[1] and {cfg.options[1]} or {}) or cfg.options[1] or "None")
    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "dropdown_object" ] = library:create( "TextButton" , {
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
            Text = cfg.name or "Dropdown";
            Parent = items[ "dropdown_object" ];
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
                Parent = items[ "dropdown_object" ];
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
            Parent = items[ "dropdown_object" ];
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
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        items[ "dropdown" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim2(0, cfg.width, 0, 16);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "dropdown" ];
            CornerRadius = dim(0, 4)
        });

        items[ "sub_text" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Text = "awdawdawdawdawdawdawdaw";
            Parent = items[ "dropdown" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextTruncate = Enum.TextTruncate.AtEnd;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "sub_text" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "indicator" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "dropdown" ];
            AnchorPoint = vec2(1, 0.5);
            Image = "rbxassetid://101025591575185";
            BackgroundTransparency = 1;
            Position = dim2(1, -5, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 12, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "dropdown_holder" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = library[ "items" ];
            Name = "\0";
            Visible = true;
            BackgroundTransparency = 1;
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
            ZIndex = 10;
        });

        items[ "outline" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = items[ "dropdown_holder" ];
            Size = dim2(1, 0, 1, 0);
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(33, 33, 35);
            ZIndex = 10;
        });

        if library.is_mobile then
            items.outline.AutomaticCanvasSize = Enum.AutomaticSize.Y
            items.outline.CanvasSize = dim_offset(0, 0)
            items.outline.ScrollBarThickness = 3
            items.outline.ScrollingDirection = Enum.ScrollingDirection.Y
            items.outline.Active = true
        end
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 6);
            PaddingTop = dim(0, 3);
            PaddingLeft = dim(0, 3);
            Parent = items[ "outline" ]
        });

        library:create( "UIListLayout" , {
            Parent = items[ "outline" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 4)
        });
    end

    function cfg.render_option(text)
        local button = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = text;
            Parent = items[ "outline" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            ZIndex = 10;
        }); library:apply_theme(button, "accent", "TextColor3");

        library:create( "UIPadding" , {
            Parent = button;
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        return button
    end

    function cfg.set_visible(bool)
        cfg.open = bool == true
        local a = bool and cfg.y_size or 0
        if library.is_mobile then
            a = min(a, max(68, (ws.CurrentCamera.ViewportSize.Y - gui_service:GetGuiInset().Y - 12) * 0.52))
            local width = min(max(120, items.dropdown.AbsoluteSize.X), ws.CurrentCamera.ViewportSize.X - 12)
            items.dropdown_holder.Size = dim_offset(width, a)
            items.dropdown_holder.Position = library:mobile_popup_position(items.dropdown, width, a, 6)
        else
            library:tween(items[ "dropdown_holder" ], {Size = dim_offset(items[ "dropdown" ].AbsoluteSize.X, a)})
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            local px = clamp(items.dropdown.AbsolutePosition.X, 6, max(6, viewport.X - items.dropdown.AbsoluteSize.X - 6))
            local py = items.dropdown.AbsolutePosition.Y + 80
            if py + a > viewport.Y - 8 then py = max(6, items.dropdown.AbsolutePosition.Y - a - 8) end
            items.dropdown_holder.Position = dim_offset(px, py)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    function cfg.set(value)
        local selected = {}
        local isTable = type(value) == "table"

        for _, option in cfg.option_instances do
            if option.Text == value or (isTable and find(value, option.Text)) then
                insert(selected, option.Text)
                cfg.multi_items = selected
                option.TextColor3 = themes.preset.accent
            else
                option.TextColor3 = rgb(72, 72, 73)
            end
        end

        items[ "sub_text" ].Text = isTable and concat(selected, ", ") or selected[1] or ""
        cfg.multi_items = isTable and selected or {}
        flags[cfg.flag] = cfg.multi and selected or selected[1]

        safe_callback(cfg.callback, flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        list = type(list) == "table" and list or {}
        cfg.options = list
        local previous = flags[cfg.flag]
        cfg.y_size = 0

        for _, option in cfg.option_instances do
            option:Destroy()
        end

        cfg.option_instances = {}

        for _, option in list do
            local button = cfg.render_option(option)
            if library.is_mobile then
                button.AutomaticSize = Enum.AutomaticSize.None
                button.Size = dim2(1, -12, 0, 29)
                cfg.y_size += 34
            else
                cfg.y_size += 29 + 6
            end
            insert(cfg.option_instances, button)

            button.Activated:Connect(function()
                if cfg.multi then
                    local selected_index = find(cfg.multi_items, button.Text)

                    if selected_index then
                        remove(cfg.multi_items, selected_index)
                    else
                        insert(cfg.multi_items, button.Text)
                    end

                    cfg.set(cfg.multi_items)
                else
                    cfg.set_visible(false)
                    cfg.open = false

                    cfg.set(button.Text)
                end
            end)
        end
        if previous ~= nil then cfg.set(previous) end
    end

    items[ "dropdown" ].Activated:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
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

    flags[cfg.flag] = nil
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        local function allowed(item)
            if type(item) ~= "string" then return false end
            for _, option in ipairs(cfg.options) do
                if tostring(option) == item then return true end
            end
            return false
        end
        if cfg.multi then
            if type(value) ~= "table" then return false, nil, "expected a list of option names" end
            local count = 0
            for index in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then
                    return false, nil, "expected a dense list of option names"
                end
                count += 1
            end
            if #value ~= count then return false, nil, "expected a dense list of option names" end
            local normalized, seen = {}, {}
            for index, item in ipairs(value) do
                if not allowed(item) then return false, nil, "unknown dropdown option at index " .. tostring(index) end
                if seen[item] then return false, nil, "duplicate dropdown option '" .. item .. "'" end
                seen[item] = true
                table.insert(normalized, item)
            end
            return true, normalized
        end
        if not allowed(value) then return false, nil, "expected one of the dropdown options" end
        return true, value
    end)

    cfg.refresh_options(cfg.options)
    cfg.set(cfg.default)

    library:mobile_format_control(items, "dropdown")
    return setmetatable(cfg, library)
end
end
