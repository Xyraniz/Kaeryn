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
        min_size = properties.min_size or properties.MinSize or vec2(420, 320);
        max_size = properties.max_size or properties.MaxSize;
        selected_tab;
        items = {};

        tween;
    }
    assert(typeof(cfg.min_size) == "Vector2" and cfg.min_size.X > 0 and cfg.min_size.Y > 0
        and cfg.min_size.X < math.huge and cfg.min_size.Y < math.huge, "window min_size must be a finite positive Vector2")
    assert(cfg.max_size == nil or typeof(cfg.max_size) == "Vector2", "window max_size must be a Vector2")
    if cfg.max_size then
        assert(cfg.max_size.X > 0 and cfg.max_size.Y > 0 and cfg.max_size.X < math.huge and cfg.max_size.Y < math.huge,
            "window max_size values must be finite and positive")
        assert(cfg.max_size.X >= cfg.min_size.X and cfg.max_size.Y >= cfg.min_size.Y, "window max_size must be greater than or equal to min_size")
    end

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
            library:connection(cfg.mobile_button.Activated, function() cfg:Toggle() end, cfg)
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
            library:resizify(items[ "main" ], cfg)
            local viewport_connection
            local function track_viewport()
                if viewport_connection then viewport_connection:Disconnect() end
                if ws.CurrentCamera then
                    viewport_connection = library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
                        library:refresh_responsive_layout(cfg)
                    end)
                    library:refresh_responsive_layout(cfg)
                end
            end
            library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), track_viewport)
            track_viewport()
        end
    end

    local function fire_lifecycle(event)
        local callback = cfg["_on_" .. event]
        if type(callback) ~= "function" then return end
        local ok, err = pcall(callback, cfg)
        if not ok then warn("[Kaeryn] window " .. event .. " callback failed: " .. tostring(err)) end
    end

    function cfg:OnOpen(callback)
        assert(type(callback) == "function", "OnOpen expects a function")
        self._on_open = callback
        return self
    end

    function cfg:OnClose(callback)
        assert(type(callback) == "function", "OnClose expects a function")
        self._on_close = callback
        return self
    end

    function cfg:OnDestroy(callback)
        assert(type(callback) == "function", "OnDestroy expects a function")
        self._on_destroy = callback
        return self
    end

    function cfg:IsOpen()
        if self._destroyed_window then return false end
        if library.is_mobile then return items.main.Visible end
        return library.items.Enabled
    end

    function cfg:Open()
        if self._destroyed_window then return false, "window has been destroyed" end
        local was_open = self:IsOpen()
        if library.is_mobile then items.main.Visible = true else library.items.Enabled = true end
        if not was_open then fire_lifecycle("open") end
        return true
    end

    function cfg:Close()
        if self._destroyed_window then return false, "window has been destroyed" end
        local was_open = self:IsOpen()
        if library.is_mobile then items.main.Visible = false else library.items.Enabled = false end
        library:close_element()
        if was_open then fire_lifecycle("close") end
        return true
    end

    function cfg:Toggle()
        if self:IsOpen() then self:Close() else self:Open() end
        return self:IsOpen()
    end

    function cfg:_fire_destroy()
        if self._destroyed_window then return false end
        if self:IsOpen() then self:Close() end
        self._destroyed_window = true
        fire_lifecycle("destroy")
        return true
    end

    function cfg:Destroy()
        return library:unload_menu()
    end

    function cfg:SetResizeLimits(minimum, maximum)
        if self._destroyed_window then return false, "window has been destroyed" end
        if typeof(minimum) ~= "Vector2" or minimum.X ~= minimum.X or minimum.Y ~= minimum.Y
            or minimum.X <= 0 or minimum.Y <= 0 or minimum.X == math.huge or minimum.Y == math.huge then
            return false, "min_size must be a positive Vector2"
        end
        if maximum ~= nil and (typeof(maximum) ~= "Vector2" or maximum.X ~= maximum.X or maximum.Y ~= maximum.Y
            or maximum.X <= 0 or maximum.Y <= 0 or maximum.X < minimum.X or maximum.Y < minimum.Y
            or maximum.X == math.huge or maximum.Y == math.huge) then
            return false, "max_size must be a Vector2 greater than or equal to min_size"
        end
        self.min_size, self.max_size = minimum, maximum
        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
        local max_width = math.min(maximum and maximum.X or viewport.X, viewport.X)
        local max_height = math.min(maximum and maximum.Y or viewport.Y, viewport.Y)
        local min_width = math.min(minimum.X, max_width)
        local min_height = math.min(minimum.Y, max_height)
        local width = math.clamp(items.main.AbsoluteSize.X, min_width, max_width)
        local height = math.clamp(items.main.AbsoluteSize.Y, min_height, max_height)
        local left = math.clamp(items.main.AbsolutePosition.X, 0, math.max(0, viewport.X - width))
        local top = math.clamp(items.main.AbsolutePosition.Y, 0, math.max(0, viewport.Y - height))
        items.main.Size = dim_offset(width, height)
        items.main.Position = dim_offset(left, top)
        if library.is_mobile then library:queue_mobile_layout() else library:refresh_responsive_layout(self) end
        return true
    end

    function cfg:SaveLayout()
        if self._destroyed_window then return nil, "window has been destroyed" end
        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
        local position, size = items.main.AbsolutePosition, items.main.AbsoluteSize
        local available_x, available_y = math.max(0, viewport.X - size.X), math.max(0, viewport.Y - size.Y)
        local current_tab = self._selected_tab_object
        local current_page = current_tab and current_tab.current_multi
        return {
            version = 1,
            position = {x = available_x > 0 and position.X / available_x or 0, y = available_y > 0 and position.Y / available_y or 0},
            size = {x = viewport.X > 0 and size.X / viewport.X or 1, y = viewport.Y > 0 and size.Y / viewport.Y or 1},
            tab = current_tab and current_tab.id or nil,
            page = current_page and current_page.id or nil,
        }
    end

    function cfg:LoadLayout(layout)
        if self._destroyed_window then return false, "window has been destroyed" end
        if type(layout) ~= "table" or type(layout.position) ~= "table" or type(layout.size) ~= "table" then
            return false, "layout must contain position and size tables"
        end
        if layout.version ~= nil and layout.version ~= 1 then return false, "unsupported layout version" end
        local function valid_fraction(value)
            return type(value) == "number" and value == value and math.abs(value) < math.huge
        end
        local fractions = {layout.position.x, layout.position.y, layout.size.x, layout.size.y}
        for index = 1, 4 do
            if not valid_fraction(fractions[index]) then return false, "layout fractions must be finite numbers" end
        end
        local target_tab, target_page
        for _, tab in ipairs(library.tabs or {}) do
            if layout.tab ~= nil and tab.id == layout.tab then target_tab = tab; break end
        end
        if layout.tab ~= nil and not target_tab then return false, "layout references unknown tab '" .. tostring(layout.tab) .. "'" end
        if layout.page ~= nil then
            for _, page in ipairs(target_tab and target_tab.pages or {}) do
                if page.id == layout.page then target_page = page; break end
            end
            if not target_page then return false, "layout references unknown page '" .. tostring(layout.page) .. "'" end
        end

        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
        local max_width = math.min(self.max_size and self.max_size.X or viewport.X, viewport.X)
        local max_height = math.min(self.max_size and self.max_size.Y or viewport.Y, viewport.Y)
        local min_width = math.min(self.min_size.X, max_width)
        local min_height = math.min(self.min_size.Y, max_height)
        local width = math.clamp(layout.size.x * viewport.X, min_width, max_width)
        local height = math.clamp(layout.size.y * viewport.Y, min_height, max_height)
        local left = math.clamp(layout.position.x, 0, 1) * math.max(0, viewport.X - width)
        local top = math.clamp(layout.position.y, 0, 1) * math.max(0, viewport.Y - height)
        items.main.Size = dim_offset(width, height)
        items.main.Position = dim_offset(left, top)
        if library.is_mobile then library:queue_mobile_layout() else library:refresh_responsive_layout(self) end
        if target_tab then
            local opened, reason = target_tab.open_tab(target_page ~= nil)
            if not opened then return false, reason end
        end
        if target_page then
            local opened, reason = target_page.open_page()
            if not opened then return false, reason end
        end
        return true
    end

    cfg.toggle_menu = function(bool)
        if bool == nil then return cfg:Toggle() end
        if bool then return cfg:Open() end
        return cfg:Close()
    end

    library:init_search(cfg)
    if library.is_mobile then library:queue_mobile_layout() end

    library.window = cfg
    return setmetatable(cfg, library)
end
end
