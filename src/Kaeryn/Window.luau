return function(__kaeryn)
    local uis = __kaeryn.uis
    local ws = __kaeryn.ws
    local gui_service = __kaeryn.gui_service
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
    local background_image = properties.background
    if background_image == nil then background_image = properties.background_image end
    if background_image == nil then background_image = properties.Background end
    if background_image == "" then background_image = nil end
    assert(background_image == nil or (type(background_image) == "string"
        and (background_image:match("^rbxassetid://%d+$") or background_image:match("^https?://%S+$"))),
        "window background must be a Roblox image asset or an HTTP(S) image URL")

    local background_transparency = properties.background_transparency
    if background_transparency == nil then background_transparency = properties.background_image_transparency end
    if background_transparency == nil then background_transparency = properties.BackgroundImageTransparency end
    if background_transparency == nil then background_transparency = 0 end
    assert(type(background_transparency) == "number" and background_transparency == background_transparency
        and background_transparency >= 0 and background_transparency <= 1,
        "window background_transparency must be a number between 0 and 1")

    local toggle_button_options = properties.toggle_button
    if toggle_button_options == nil then toggle_button_options = {} end
    assert(type(toggle_button_options) == "table", "window toggle_button must be a table")
    local toggle_button_size = toggle_button_options.size
    if toggle_button_size == nil then toggle_button_size = dim_offset(38, 38) end
    local function valid_size_axis(axis)
        return axis.Scale == axis.Scale and axis.Offset == axis.Offset
            and math.abs(axis.Scale) < math.huge and math.abs(axis.Offset) < math.huge
            and axis.Scale >= 0 and axis.Offset >= 0 and (axis.Scale > 0 or axis.Offset > 0)
    end
    assert(typeof(toggle_button_size) == "UDim2" and valid_size_axis(toggle_button_size.X) and valid_size_axis(toggle_button_size.Y),
        "window toggle_button.size must be a UDim2 with positive width and height")
    local toggle_button_icon = toggle_button_options.icon
    if toggle_button_icon ~= nil then
        assert(type(toggle_button_icon) == "string" and toggle_button_icon ~= "", "window toggle_button.icon must be a non-empty icon string")
        library:resolve_icon(toggle_button_icon)
    end
    local toggle_button_draggable = toggle_button_options.draggable
    if toggle_button_draggable == nil then toggle_button_draggable = false end
    assert(type(toggle_button_draggable) == "boolean", "window toggle_button.draggable must be a boolean")

    local cfg = {
        name = properties.name or properties.Name or "nebula";
        size = properties.size or properties.Size or dim2(0, 700, 0, 565);
        background = background_image;
        background_transparency = background_transparency;
        toggle_button = {
            size = toggle_button_size;
            icon = toggle_button_icon;
            draggable = toggle_button_draggable;
        };
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

        items["background_image"] = library:create("ImageLabel", {
            Parent = items.main;
            Name = "WindowBackground";
            Size = dim2(1, 0, 1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Image = cfg.background;
            ImageTransparency = cfg.background_transparency;
            ScaleType = Enum.ScaleType.Crop;
            Visible = cfg.background ~= nil;
            ZIndex = 1;
        })
        library:create("UICorner", {Parent = items.background_image, CornerRadius = dim(0, 10)})

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
            BackgroundTransparency = 0.1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 196, 1, -25);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.background
        });
        library:apply_theme(items[ "side_frame" ], "background", "BackgroundColor3")

        library:create( "Frame" , {
            AnchorPoint = vec2(1, 0);
            Parent = items[ "side_frame" ];
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 1, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });

        items[ "button_holder" ] = library:create( "ScrollingFrame" , {
            Parent = items[ "side_frame" ];
            Name = "\0";
            Active = true;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            ScrollBarThickness = 2;
            ScrollBarImageColor3 = themes.preset.muted;
            CanvasSize = dim_offset(0, 0);
            ClipsDescendants = true;
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 60);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, -60);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.button_holder = items[ "button_holder" ];
        library:apply_theme(items[ "button_holder" ], "muted", "ScrollBarImageColor3")

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
            Text = string.format('<u>%s</u>', cfg.name);
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
            BackgroundTransparency = 0.1;
            Position = dim2(0, 196, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 0, 56);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.background
        }); cfg.multi_holder = items[ "multi_holder" ];
        library:apply_theme(items[ "multi_holder" ], "background", "BackgroundColor3")

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
            library:connection(cfg.sidebar_toggle.Activated, function()
                library.mobile_sidebar_preference = not library:get_mobile_sidebar_compact()
                library:queue_mobile_layout()
            end)
            cfg.mobile_button = library:create("TextButton", {
                Parent = library.items,
                Name = "MobileMenu",
                Text = toggle_button_icon and "" or "☰",
                FontFace = fonts.font,
                TextSize = 24,
                TextColor3 = rgb(255, 255, 255),
                BackgroundColor3 = rgb(25, 25, 29),
                AnchorPoint = vec2(1, 0),
                BorderSizePixel = 0,
                Size = toggle_button_size,
                Position = dim2(1, -11, 0, 8),
                ZIndex = 50
            })
            library:create("UICorner", {Parent = cfg.mobile_button, CornerRadius = dim(0, 9)})
            if toggle_button_icon then
                library:create("ImageLabel", {
                    Parent = cfg.mobile_button,
                    Name = "MenuIcon",
                    Position = dim2(0, 0, 0, 0),
                    Size = dim2(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Image = toggle_button_icon,
                    ImageColor3 = rgb(255, 255, 255),
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 51,
                })
                library:create("UICorner", {Parent = cfg.mobile_button.MenuIcon, CornerRadius = dim(0, 9)})
            end

            local active_drag
            local drag_origin
            local initial_position
            local moved_during_drag = false
            if toggle_button_draggable then
                library:connection(cfg.mobile_button.InputBegan, function(input)
                    local input_type = input.UserInputType
                    if input_type ~= Enum.UserInputType.MouseButton1 and input_type ~= Enum.UserInputType.Touch then return end
                    active_drag = input
                    drag_origin = input.Position
                    initial_position = cfg.mobile_button.Position
                    moved_during_drag = false
                end, cfg)
                library:connection(uis.InputChanged, function(input)
                    if not active_drag then return end
                    local pointer_position
                    if active_drag.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement then
                        pointer_position = input.Position
                    elseif active_drag.UserInputType == Enum.UserInputType.Touch and input == active_drag then
                        pointer_position = input.Position
                    else
                        return
                    end

                    local delta = pointer_position - drag_origin
                    if delta.X * delta.X + delta.Y * delta.Y > 16 then moved_during_drag = true end
                    cfg.mobile_button.Position = dim2(initial_position.X.Scale, initial_position.X.Offset + delta.X,
                        initial_position.Y.Scale, initial_position.Y.Offset + delta.Y)
                end, cfg)
                library:connection(uis.InputEnded, function(input)
                    if not active_drag then return end
                    local ended = active_drag.UserInputType == Enum.UserInputType.MouseButton1
                        and input.UserInputType == Enum.UserInputType.MouseButton1 or input == active_drag
                    if ended then active_drag = nil end
                end, cfg)
            end
            library:connection(cfg.mobile_button.Activated, function()
                if moved_during_drag then
                    moved_during_drag = false
                    return
                end
                cfg:Toggle()
            end, cfg)
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

    function cfg:SetBackgroundImage(image)
        if self._destroyed_window then return false, "window has been destroyed" end
        if image == "" then image = nil end
        if image ~= nil and (type(image) ~= "string"
            or not (image:match("^rbxassetid://%d+$") or image:match("^https?://%S+$"))) then
            return false, "background must be a Roblox image asset or an HTTP(S) image URL"
        end
        self.background = image
        items.background_image.Image = image or ""
        items.background_image.Visible = image ~= nil
        return true
    end

    function cfg:SetBackgroundImageTransparency(transparency)
        if self._destroyed_window then return false, "window has been destroyed" end
        if type(transparency) ~= "number" or transparency ~= transparency or transparency < 0 or transparency > 1 then
            return false, "background transparency must be a number between 0 and 1"
        end
        self.background_transparency = transparency
        items.background_image.ImageTransparency = transparency
        return true
    end

    function cfg:SetSidebarTransparency(transparency)
        if self._destroyed_window then return false, "window has been destroyed" end
        if type(transparency) ~= "number" or transparency ~= transparency or transparency < 0 or transparency > 1 then
            return false, "sidebar transparency must be a number between 0 and 1"
        end
        self.sidebar_transparency = transparency
        local layer_transparency = math.sqrt(transparency)
        items.side_frame.BackgroundTransparency = 1 - (1 - layer_transparency) ^ 2
        return true
    end

    function cfg:ResetToggleButtonPosition()
        if self._destroyed_window then return false, "window has been destroyed" end
        if not self.mobile_button then return false, "toggle button is only available on mobile" end
        local inset = gui_service:GetGuiInset()
        self.mobile_button.Position = dim2(1, -11, 0, math.max(8, floor(inset.Y + 7)))
        return true
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
