return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local insert = __kaeryn.insert
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts
    local safe_callback = __kaeryn.safe_callback

function library:tab(properties)
    properties = properties or {}
    local tab_name = properties.name or properties.Name or "visuals"
    local tab_id = properties.id or tab_name
    assert(type(tab_id) == "string" and tab_id:gsub("%s", "") ~= "", "tab id must be a non-empty string")
    assert(type(tab_name) == "string" and tab_name:gsub("%s", "") ~= "", "tab name must be a non-empty string")
    assert(properties.on_enter == nil or type(properties.on_enter) == "function", "tab on_enter must be a function")
    assert(properties.on_leave == nil or type(properties.on_leave) == "function", "tab on_leave must be a function")
    for _, registered_tab in ipairs(library.tabs or {}) do
        assert(registered_tab.id ~= tab_id, "duplicate tab id '" .. tab_id .. "'")
    end
    local cfg = {
        id = tab_id;
        name = tab_name;
        on_enter = properties.on_enter;
        on_leave = properties.on_leave;
        icon = properties.icon or properties.Icon or "lucide:layout-dashboard";
        custom_icon = properties.icon ~= nil or properties.Icon ~= nil;

        tabs = properties.tabs or properties.Tabs or {"Main", "Misc.", "Settings"};
        pages = {};
        current_multi;

        items = {};
    }
    self.tabs = self.tabs or {}
    insert(self.tabs, cfg)

    function cfg:OnEnter(callback)
        assert(type(callback) == "function", "OnEnter expects a function")
        self.on_enter = callback
        return self
    end

    function cfg:OnLeave(callback)
        assert(type(callback) == "function", "OnLeave expects a function")
        self.on_leave = callback
        return self
    end

    local items = cfg.items; do
        items[ "tab_holder" ] = library:create( "Frame" , {
            Parent = library.cache;
            Name = "\0";
            Visible = false;
            AnchorPoint = vec2(0.5, 0);
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 56);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -216, 1, -101);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "button_holder" ];
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 0, 35);
            BorderSizePixel = 0;
            TextSize = 16;
            BackgroundColor3 = rgb(29, 29, 29)
        });

        items[ "icon" ] = library:create( "ImageLabel" , {
            ImageColor3 = themes.preset.muted;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "button" ];
            AnchorPoint = vec2(0, 0.5);
            Image = cfg.icon;
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 22, 0, 22);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        library:apply_theme(items[ "icon" ], "accent", "ImageColor3")
        library:apply_theme(items[ "icon" ], "muted", "ImageColor3")

        if not cfg.custom_icon then
            items["compact_mark"] = library:create("TextLabel", {
                Parent = items["button"],
                Name = "CompactMark",
                AnchorPoint = vec2(0.5, 0.5),
                Position = dim2(0.5, 0, 0.5, 0),
                Size = dim_offset(28, 28),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = fonts.font,
                Text = string.upper(cfg.name:match("[%w]") or "?"),
                TextColor3 = themes.preset.muted,
                TextSize = 15,
                Visible = false,
            })
            library:apply_theme(items["compact_mark"], "accent", "TextColor3")
            library:apply_theme(items["compact_mark"], "muted", "TextColor3")
        end

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = themes.preset.muted;
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            Size = dim2(0, 0, 1, 0);
            Position = dim2(0, 40, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        library:apply_theme(items[ "name" ], "muted", "TextColor3")

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 7)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "button" ];
            Enabled = false;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        items[ "multi_section_button_holder" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = library.cache;
            BackgroundTransparency = 1;
            Name = "\0";
            Visible = false;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -82, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        if library.is_mobile then
            local holder = items.multi_section_button_holder
            holder.Active = true
            holder.ClipsDescendants = true
            holder.ScrollBarThickness = 0
            holder.ScrollingDirection = Enum.ScrollingDirection.X
            holder.AutomaticCanvasSize = Enum.AutomaticSize.X
            holder.CanvasSize = dim_offset(0, 0)
        end

        library:create( "UIListLayout" , {
            Parent = items[ "multi_section_button_holder" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });

        library:create( "UIPadding" , {
            PaddingTop = dim(0, 8);
            PaddingBottom = dim(0, 7);
            Parent = items[ "multi_section_button_holder" ];
            PaddingRight = dim(0, 7);
            PaddingLeft = dim(0, 7)
        });

        for _, section in ipairs(cfg.tabs) do
            local definition = type(section) == "table" and section or {name = section}
            local section_name = definition.name or definition.Name
            local section_id = definition.id or section_name
            assert(type(section_name) == "string" and section_name:gsub("%s", "") ~= "", "tab page name must be a non-empty string")
            assert(type(section_id) == "string" and section_id:gsub("%s", "") ~= "", "tab page id must be a non-empty string")
            for _, existing_page in ipairs(cfg.pages) do
                assert(existing_page.id ~= section_id, "duplicate page id '" .. section_id .. "' in tab '" .. tab_id .. "'")
            end
            assert(definition.lazy == nil or type(definition.lazy) == "function", "tab page lazy must be a function")
            assert(definition.on_enter == nil or type(definition.on_enter) == "function", "tab page on_enter must be a function")
            assert(definition.on_leave == nil or type(definition.on_leave) == "function", "tab page on_leave must be a function")
            local data = {
                id = section_id,
                name = section_name,
                items = {},
                _tab = cfg,
                _lazy_builder = definition.lazy,
                _built = definition.lazy == nil,
                _on_enter = definition.on_enter,
                _on_leave = definition.on_leave,
                _scopes = {},
            }

            local multi_items = data.items; do
                multi_items[ "button" ] = library:create( "TextButton" , {
                    FontFace = fonts.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    AutoButtonColor = false;
                    Text = "";
                    Parent = items[ "multi_section_button_holder" ];
                    Name = "\0";
                    Size = dim2(0, 0, 0, 39);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.X;
                    TextSize = 16;
                    BackgroundColor3 = rgb(25, 25, 29)
                });

                multi_items[ "name" ] = library:create( "TextLabel" , {
                    FontFace = fonts.font;
                    TextColor3 = themes.preset.muted;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = section_name;
                    Parent = multi_items[ "button" ];
                    Name = "\0";
                    Size = dim2(0, 0, 1, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 16;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                library:apply_theme(multi_items[ "name" ], "muted", "TextColor3")

                library:create( "UIPadding" , {
                    Parent = multi_items[ "name" ];
                    PaddingRight = dim(0, 5);
                    PaddingLeft = dim(0, 5)
                });

                multi_items[ "accent" ] = library:create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    AnchorPoint = vec2(0, 1);
                    Parent = multi_items[ "button" ];
                    BackgroundTransparency = 1;
                    Position = dim2(0, 10, 1, 4);
                    Name = "\0";
                    Size = dim2(1, -20, 0, 6);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                }); library:apply_theme(multi_items[ "accent" ], "accent", "BackgroundColor3");

                library:create( "UICorner" , {
                    Parent = multi_items[ "accent" ];
                    CornerRadius = dim(0, 999)
                });

                library:create( "UIPadding" , {
                    Parent = multi_items[ "button" ];
                    PaddingRight = dim(0, 10);
                    PaddingLeft = dim(0, 10)
                });

                library:create( "UICorner" , {
                    Parent = multi_items[ "button" ];
                    CornerRadius = dim(0, 7)
                });

                multi_items[ "tab" ] = library:create( "Frame" , {
                    Parent = library.cache;
                    BackgroundTransparency = 1;
                    Name = "\0";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -20, 1, -20);
                    BorderSizePixel = 0;
                    Visible = false;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                library:create( "UIListLayout" , {
                    FillDirection = Enum.FillDirection.Vertical;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = multi_items[ "tab" ];
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                });

                library:create( "UIPadding" , {
                    PaddingTop = dim(0, 7);
                    PaddingBottom = dim(0, 7);
                    Parent = multi_items[ "tab" ];
                    PaddingRight = dim(0, 7);
                    PaddingLeft = dim(0, 7)
                });
            end

            data.text = multi_items[ "name" ]
            data.accent = multi_items[ "accent" ]
            data.button = multi_items[ "button" ]
            data.page = multi_items[ "tab" ]
            data.parent = setmetatable(data, library):sub_tab({}).items[ "tab_parent" ]

            function data:OnEnter(callback)
                assert(type(callback) == "function", "OnEnter expects a function")
                self._on_enter = callback
                return self
            end

            function data:OnLeave(callback)
                assert(type(callback) == "function", "OnLeave expects a function")
                self._on_leave = callback
                return self
            end

            function data:CreateScope()
                local scope = library:scope()
                table.insert(self._scopes, scope)
                return scope
            end

            local function leave_page(page)
                if not page or not page._active then return end
                page._active = false
                if page._on_leave then safe_callback(page._on_leave, page) end
                for scope_index = #page._scopes, 1, -1 do
                    page._scopes[scope_index]:Destroy()
                    page._scopes[scope_index] = nil
                end
            end

            function data.open_page()
                if data._active then return true end
                if data._build_error then return false, data._build_error end
                if not data._built and data._lazy_builder then
                    data._built = true
                    local build_ok, build_error = pcall(data._lazy_builder, data)
                    if not build_ok then
                        data._build_error = tostring(build_error)
                        warn("[Kaeryn] lazy builder failed for page '" .. data.id .. "': " .. data._build_error)
                        return false, data._build_error
                    end
                end
                local page = cfg.current_multi;

                if page and page ~= data then leave_page(page) end

                if page and page.text ~= data.text then
                    self.items[ "global_fade" ].BackgroundTransparency = 0
                    library:tween(self.items[ "global_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)

                    local old_size = page.page.Size
                    page.page.Size = dim2(1, -20, 1, -20)
                end

                if page then
                    library:tween(page.text, {TextColor3 = themes.preset.muted})
                    library:tween(page.accent, {BackgroundTransparency = 1})
                    library:tween(page.button, {BackgroundTransparency = 1})

                    page.page.Visible = false
                    page.page.Parent = library[ "cache" ]
                end

                library:tween(data.text, {TextColor3 = rgb(255, 255, 255)})
                library:tween(data.accent, {BackgroundTransparency = 0})
                library:tween(data.button, {BackgroundTransparency = 0})
                library:tween(data.page, {Size = dim2(1, 0, 1, 0)}, Enum.EasingStyle.Quad, 0.4)

                data.page.Visible = true
                data.page.Parent = items["tab_holder"]

                cfg.current_multi = data
                data._active = true
                if data._on_enter then safe_callback(data._on_enter, data) end

                library:close_element()
                return true
            end

            multi_items[ "button" ].Activated:Connect(function()
                data.open_page()
            end)

            cfg.pages[#cfg.pages + 1] = setmetatable(data, library)
        end

    end

    function cfg.open_tab(skip_default_page)
        if self._selected_tab_object == cfg then return true end
        local selected_tab = self.selected_tab
        local previous_tab = self._selected_tab_object
        if previous_tab then
            if previous_tab.on_leave then safe_callback(previous_tab.on_leave, previous_tab) end
            if previous_tab.current_multi then
                local current = previous_tab.current_multi
                if current._active then
                    current._active = false
                    if current._on_leave then safe_callback(current._on_leave, current) end
                    for scope_index = #current._scopes, 1, -1 do
                        current._scopes[scope_index]:Destroy()
                        current._scopes[scope_index] = nil
                    end
                end
            end
        end

        if selected_tab then
            if selected_tab[ 4 ] ~= items[ "tab_holder" ] then
                self.items[ "global_fade" ].BackgroundTransparency = 0

                library:tween(self.items[ "global_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
                local side = library.responsive_sidebar_width or 196
                local header = library.responsive_header_height or 56
                if not library.is_mobile then
                    local _, collapsed_size = library:tab_content_geometry(library.window.items.main.AbsoluteSize.X, side, header, 45)
                    selected_tab[ 4 ].Size = collapsed_size
                end
            end

            library:tween(selected_tab[ 1 ], {BackgroundTransparency = 1})
            library:tween(selected_tab[ 2 ], {ImageColor3 = themes.preset.muted})
            library:tween(selected_tab[ 3 ], {TextColor3 = themes.preset.muted})
            if selected_tab[6] then
                library:tween(selected_tab[6], {TextColor3 = themes.preset.muted})
            end

            selected_tab[ 4 ].Visible = false
            selected_tab[ 4 ].Parent = library[ "cache" ]
            selected_tab[ 5 ].Visible = false
            selected_tab[ 5 ].Parent = library[ "cache" ]
        end

        library:tween(items[ "button" ], {BackgroundTransparency = 0})
        library:tween(items[ "icon" ], {ImageColor3 = themes.preset.accent})
        library:tween(items[ "name" ], {TextColor3 = rgb(255, 255, 255)})
        if items["compact_mark"] then
            library:tween(items["compact_mark"], {TextColor3 = themes.preset.accent})
        end
        if not library.is_mobile then
            local side = library.responsive_sidebar_width or 196
            local header = library.responsive_header_height or 56
            local position, size = library:tab_content_geometry(library.window.items.main.AbsoluteSize.X, side, header, 25)
            library:tween(items[ "tab_holder" ], {Position = position, Size = size}, Enum.EasingStyle.Quad, 0.4)
        end

        items[ "tab_holder" ].Visible = true
        items[ "tab_holder" ].Parent = self.items[ "main" ]
        items[ "multi_section_button_holder" ].Visible = true
        items[ "multi_section_button_holder" ].Parent = self.items[ "multi_holder" ]

        self.selected_tab = {
            items[ "button" ];
            items[ "icon" ];
            items[ "name" ];
            items[ "tab_holder" ];
            items[ "multi_section_button_holder" ];
            items["compact_mark"];
        }
        self._selected_tab_object = cfg

        library:close_element()
        if not skip_default_page and cfg.current_multi and not cfg.current_multi._active then
            cfg.current_multi._active = true
            if cfg.current_multi._on_enter then safe_callback(cfg.current_multi._on_enter, cfg.current_multi) end
        elseif cfg.pages[1] and not skip_default_page then
            local opened, reason = cfg.pages[1].open_page()
            if not opened then return false, reason end
        end
        if cfg.on_enter then safe_callback(cfg.on_enter, cfg) end
        if library.is_mobile then library:queue_mobile_layout() end
        return true
    end

    items[ "button" ].Activated:Connect(function()
        cfg.open_tab()
    end)

    if not self.selected_tab then
        cfg.open_tab()
    end

    if library.is_mobile then
        insert(library.mobile_tabs, cfg)
        library:queue_mobile_layout()
    else
        library:refresh_responsive_layout(self)
    end
    return unpack(cfg.pages)
end

function library:separator(properties)
    properties = properties or {}
    assert(type(properties) == "table", "separator options must be a table")
    if properties.Name ~= nil then
        if not library.deprecated_option_warnings["separator_method:Name"] then
            library.deprecated_option_warnings["separator_method:Name"] = true
            warn("[Kaeryn] option 'Name' for separator is deprecated; use 'name'")
        end
        if properties.name ~= nil then error("Conflicting options 'Name' and 'name' for separator", 2) end
    end
    for key in pairs(properties) do
        if key ~= "name" and key ~= "Name" then error("Unknown option '" .. tostring(key) .. "' for separator", 2) end
    end
    local cfg = {items = {}, name = properties.name or properties.Name or "General"}

    local items = cfg.items do
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = themes.preset.muted;
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = self.items[ "button_holder" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, 40, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        library:apply_theme(items[ "name" ], "muted", "TextColor3")

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
    end;

    return setmetatable(cfg, library)
end

function library:seperator(properties)
    if not library.deprecated_option_warnings["method:seperator"] then
        library.deprecated_option_warnings["method:seperator"] = true
        warn("[Kaeryn] method 'seperator' is deprecated; use 'separator'")
    end
    return self:separator(properties)
end

local function resize_auto_sections(column)
    local count = #column._sections
    if count == 0 then return end

    local size = 1 / count
    for _, section in ipairs(column._sections) do
        section.size = size
        local outline = section.items.outline
        if outline and outline.Parent then
            outline.Size = dim2(library.section_content_width, 0, size, -10)
        end
        for _, mobile_section in ipairs(library.mobile_sections) do
            if mobile_section.outline == outline then
                mobile_section.size = size
                break
            end
        end
    end
end

function library:column(properties)
    local cfg = {items = {}, size = properties.size or 1, _sections = {}}
    cfg._page = self

    local items = cfg.items; do
        items[ "column" ] = library:create( "Frame" , {
            Parent = self[ "parent" ] or self.items["tab_parent"];
            BackgroundTransparency = 1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, cfg.size, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        if library.is_mobile then
            items.column:SetAttribute("KaerynSectionSize", cfg.size)
            insert(library.mobile_columns, items.column)
            library:queue_mobile_layout()
        end
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 10);
            Parent = items[ "column" ]
        });

        library:create( "UIListLayout" , {
            Parent = items[ "column" ];
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            HorizontalFlex = Enum.UIFlexAlignment.None;
            Padding = dim(0, 10);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder
        });
    end

    return setmetatable(cfg, library)
end

function library:sub_tab(properties)
    local cfg = {items = {}, order = properties.order or 0; size = properties.size or 1}

    local items = cfg.items; do
        items[ "tab_parent" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = self.items[ "tab" ];
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(0,0,cfg.size,0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            Visible = true;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        if library.is_mobile then
            local page = items.tab_parent
            page.Active = true
            page.ScrollBarThickness = 3
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.CanvasSize = dim_offset(0, 0)
            insert(library.mobile_pages, page)
        end
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            VerticalFlex = Enum.UIFlexAlignment.Fill;
            Parent = items[ "tab_parent" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
        });
    end

    return setmetatable(cfg, library)
end

function library:section(properties)
    properties = properties or {}
    if properties.size ~= nil or properties.Size ~= nil then
        if not library.deprecated_option_warnings["section:size"] then
            library.deprecated_option_warnings["section:size"] = true
            warn("[Kaeryn] section size is deprecated and ignored; section heights are automatic now")
        end
    end
    local background_transparency = properties.background_transparency
    if background_transparency == nil then background_transparency = 0 end
    assert(type(background_transparency) == "number" and background_transparency == background_transparency
        and background_transparency >= 0 and background_transparency <= 1,
        "section background_transparency must be a number between 0 and 1")
    local layer_transparency = math.sqrt(background_transparency)
    local cfg = {
        name = properties.name or properties.Name or "section";
        side = properties.side or properties.Side or "left";
        default = properties.default or properties.Default or false;
        size = 1;
        icon = properties.icon or properties.Icon or "lucide:settings";
        fading_toggle = properties.fading or properties.Fading or false;
        background_transparency = background_transparency;
        items = {};
    };
    cfg._column = self

    local elements_layout
    local items = cfg.items; do
        items[ "outline" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = self.items[ "column" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, cfg.size, -10);
            BorderSizePixel = 0;
            BackgroundTransparency = layer_transparency;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundTransparency = layer_transparency;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        function cfg:SetBackgroundTransparency(transparency)
            if type(transparency) ~= "number" or transparency ~= transparency or transparency < 0 or transparency > 1 then
                return false, "section background transparency must be a number between 0 and 1"
            end
            self.background_transparency = transparency
            local layer_transparency = math.sqrt(transparency)
            items.outline.BackgroundTransparency = layer_transparency
            items.inline.BackgroundTransparency = layer_transparency
            items.button.BackgroundTransparency = layer_transparency
            items.header_separator.BackgroundTransparency = layer_transparency
            return true
        end

        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "scrolling" ] = library:create( "ScrollingFrame" , {
            ScrollBarImageColor3 = rgb(44, 44, 46);
            Active = true;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            ScrollBarThickness = 2;
            Parent = items[ "inline" ];
            Name = "\0";
            Size = dim2(1, 0, 1, -40);
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 35);
            BackgroundColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            CanvasSize = dim2(0, 0, 0, 0)
        });

        items[ "elements" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "scrolling" ];
            Name = "\0";
            BackgroundTransparency = 1;
            AnchorPoint = vec2(0.5, 0);
            Position = dim2(0.5, 0, 0, 10);
            Size = dim2(library.section_control_width, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        elements_layout = library:create( "UIListLayout" , {
            Parent = items[ "elements" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 15);
            Parent = items[ "elements" ]
        });

        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 0, 35);
            BorderSizePixel = 0;
            TextSize = 16;
            BackgroundTransparency = layer_transparency;
            BackgroundColor3 = rgb(19, 19, 21)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "button" ];
            Enabled = false;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 7)
        });

        items[ "Icon" ] = library:create( "ImageLabel" , {
            ImageColor3 = themes.preset.accent;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "button" ];
            AnchorPoint = vec2(0, 0.5);
            Image = cfg.icon;
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 22, 0, 22);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "Icon" ], "accent", "ImageColor3");

        items[ "section_title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            Size = dim2(0, 0, 1, 0);
            Position = dim2(0, 40, 0, -1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items["header_separator"] = library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "button" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 1);
            BorderSizePixel = 0;
            BackgroundTransparency = layer_transparency;
            BackgroundColor3 = rgb(36, 36, 37)
        });

        if cfg.fading_toggle then
            items[ "toggle" ] = library:create( "TextButton" , {
                FontFace = fonts.small;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                AutoButtonColor = false;
                Text = "";
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "button" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, 36, 0, 18);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = rgb(58, 58, 62)
            });  library:apply_theme(items[ "toggle" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle" ];
                CornerRadius = dim(0, 999)
            });

            items[ "toggle_outline" ] = library:create( "Frame" , {
                Parent = items[ "toggle" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(50, 50, 50)
            });  library:apply_theme(items[ "toggle_outline" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle_outline" ];
                CornerRadius = dim(0, 999)
            });

            library:create( "UIGradient" , {
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
                Parent = items[ "toggle_outline" ]
            });

            items[ "toggle_circle" ] = library:create( "Frame" , {
                Parent = items[ "toggle_outline" ];
                Name = "\0";
                Position = dim2(0, 2, 0, 2);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 12, 0, 12);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(86, 86, 88)
            });

            library:create( "UICorner" , {
                Parent = items[ "toggle_circle" ];
                CornerRadius = dim(0, 999)
            });

            library:create( "UICorner" , {
                Parent = items[ "outline" ];
                CornerRadius = dim(0, 7)
            });

            items[ "fade" ] = library:create( "Frame" , {
                Parent = items[ "outline" ];
                BackgroundTransparency = 0.800000011920929;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, 0, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(0, 0, 0)
            });

            library:create( "UICorner" , {
                Parent = items[ "fade" ];
                CornerRadius = dim(0, 7)
            });
        end
    end;

    if cfg.fading_toggle then
        items[ "toggle" ].MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)
        items[ "button" ].MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)

        function cfg.toggle_section(bool)
            library:tween(items[ "toggle" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
            library:tween(items[ "toggle_outline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(50, 50, 50)}, Enum.EasingStyle.Quad)
            library:tween(items[ "toggle_circle" ], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -14, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
            library:tween(items[ "fade" ], {BackgroundTransparency = bool and 1 or 0.8}, Enum.EasingStyle.Quad)
        end
        cfg.toggle_section(cfg.default)
    end

    if library.is_mobile then
        items.scrolling.ScrollingEnabled = false
        items.scrolling.AutomaticCanvasSize = Enum.AutomaticSize.None
        items.scrolling.ScrollBarThickness = 0
        insert(library.mobile_sections, {outline = items.outline, layout = elements_layout, elements = items.elements, scrolling = items.scrolling, size = cfg.size})
        library:connection(elements_layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            library:queue_mobile_layout()
        end)
        library:queue_mobile_layout()
    end
    insert(self._sections, cfg)
    resize_auto_sections(self)
    return setmetatable(cfg, library)
end
end
