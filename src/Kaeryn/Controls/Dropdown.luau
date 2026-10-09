return function(__kaeryn)
    local uis = __kaeryn.uis
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
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:dropdown(options)
    options = library:normalize_options("dropdown", options)
    local id, flag = library:resolve_identity(options, "dropdown", self.name, true)
    local cfg = {
        id = id,
        control_type = "dropdown",
        name = options.name or nil;
        info = options.info or nil;
        flag = flag;
        legacy_flags = options.legacy_flags;
        options = options.items or {""};
        callback = options.callback or function() end;
        multi = options.multi or false;
        scrolling = options.scrolling or false;
        searchable = options.searchable == true or (options.searchable ~= false and #(options.items or {}) >= 8);

        width = options.width or 130;

        open = false;
        multi_items = {};
        ignore = options.ignore or false;
        items = {};
        y_size;
        separator = options.separator;
    }

    cfg.default = options.default ~= nil and options.default or (cfg.multi and (cfg.options[1] and {cfg.options[1]} or {}) or cfg.options[1] or "None")
    if options.default == nil then
        local first = cfg.options[1]
        if type(first) == "table" then first = first.value end
        cfg.default = cfg.multi and (first and {first} or {}) or first or "None"
    end
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

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
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
            Image = "lucide:chevron-down";
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
            Visible = false;
            BackgroundTransparency = 1;
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
            ZIndex = 10;
        });

        items[ "outline" ] = library:create("Frame", {
            Parent = items[ "dropdown_holder" ];
            Size = dim2(1, 0, 1, 0);
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(33, 33, 35);
            ZIndex = 10;
        });
        library:create("UICorner", {Parent = items.outline, CornerRadius = dim(0, 4)})
        if cfg.searchable then
            items.search_input = library:create("TextBox", {
                Parent = items.outline,
                Position = dim2(0, 6, 0, 5),
                Size = dim2(1, -12, 0, 28),
                BackgroundColor3 = rgb(25, 25, 29),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                FontFace = fonts.small,
                PlaceholderText = "Search options...",
                Text = "",
                TextColor3 = rgb(235, 235, 235),
                PlaceholderColor3 = rgb(125, 125, 125),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12,
            })
            library:create("UICorner", {Parent = items.search_input, CornerRadius = dim(0, 4)})
            library:create("UIPadding", {Parent = items.search_input, PaddingLeft = dim(0, 8), PaddingRight = dim(0, 8)})
            library:apply_theme(items.search_input, "surface_alt", "BackgroundColor3")
            library:apply_theme(items.search_input, "text", "TextColor3")
            library:apply_theme(items.search_input, "muted", "PlaceholderColor3")
        end
        items.option_list = library:create("ScrollingFrame", {
            Parent = items.outline,
            Position = dim2(0, 0, 0, cfg.searchable and 38 or 0),
            Size = dim2(1, 0, 1, cfg.searchable and -38 or 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            CanvasSize = dim_offset(0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = rgb(100, 100, 100),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 11,
        })
        items.empty = library:create("TextLabel", {
            Parent = items.option_list,
            Position = dim2(0, 7, 0, 6),
            Size = dim2(1, -14, 0, 28),
            BackgroundTransparency = 1,
            FontFace = fonts.small,
            Text = "No options found",
            TextColor3 = rgb(145, 145, 145),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            ZIndex = 12,
        })
        library:apply_theme(items.empty, "muted", "TextColor3")
    end

    local row_bindings = setmetatable({}, {__mode = "k"})
    local option_rows = {}
    local row_height = 30
    local max_visible_rows = 12
    local search_input = items.search_input

    local function option_record(option)
        if type(option) == "table" then
            return {value = option.value, label = option.label or option.value, group = option.group, disabled = option.disabled == true}
        end
        local value = tostring(option)
        return {value = value, label = value, group = nil, disabled = false}
    end

    local function selection_values()
        if cfg.multi then return table.clone(cfg.multi_items) end
        local selected = flags[cfg.flag]
        return selected ~= nil and {selected} or {}
    end

    local function is_selected(value)
        for _, selected in ipairs(selection_values()) do
            if selected == value then return true end
        end
        return false
    end

    local function build_entries()
        local groups, group_order = {}, {}
        local ungrouped = {}
        for _, option in ipairs(cfg.option_data or {}) do
            local key = option.group or ungrouped
            if not groups[key] then
                groups[key] = {}
                table.insert(group_order, key)
            end
            table.insert(groups[key], option)
        end
        local query = string.lower(search_input and search_input.Text or "")
        local entries = {}
        for _, key in ipairs(group_order) do
            local options = groups[key]
            local matching = {}
            for _, option in ipairs(options) do
                local searchable = string.lower(library:translate(option.label) .. " " .. option.value .. " " .. library:translate(option.group or ""))
                if query == "" or string.find(searchable, query, 1, true) then table.insert(matching, option) end
            end
            if #matching > 0 then
                if key ~= ungrouped then table.insert(entries, {kind = "group", label = key}) end
                for _, option in ipairs(matching) do table.insert(entries, {kind = "option", option = option}) end
            end
        end
        cfg.visible_entries = entries
        local popup_height = math.min(#entries, max_visible_rows) * row_height + 8
        if cfg.searchable then popup_height += 38 end
        cfg.y_size = math.max(cfg.searchable and 78 or row_height + 8, popup_height)
        items.option_list.CanvasSize = dim_offset(0, #entries * row_height + 8)
        items.empty.Visible = #entries == 0
        items.option_list.CanvasPosition = vec2(0, math.min(items.option_list.CanvasPosition.Y, math.max(0, #entries * row_height - items.option_list.AbsoluteSize.Y)))
    end

    local function render_rows()
        local entries = cfg.visible_entries or {}
        local first = math.floor(items.option_list.CanvasPosition.Y / row_height) + 1
        for index, row in ipairs(option_rows) do
            local entry_index = first + index - 1
            local entry = entries[entry_index]
            row_bindings[row] = entry
            row.Visible = entry ~= nil
            if entry then
                row.Position = dim2(0, 4, 0, (entry_index - 1) * row_height + 3)
                if entry.kind == "group" then
                    row.Text = library:translate(entry.label)
                    row.TextColor3 = themes.preset.muted
                    row.FontFace = fonts.font
                    row.TextSize = 12
                    row.BackgroundTransparency = 1
                    pcall(function() row.Interactable = false end)
                else
                    local option = entry.option
                    row.Text = library:translate(option.label)
                    row.FontFace = fonts.small
                    row.TextSize = 14
                    row.BackgroundTransparency = option.disabled and 0.6 or 1
                    pcall(function() row.Interactable = not option.disabled end)
                    row.TextColor3 = option.disabled and themes.preset.muted or is_selected(option.value) and themes.preset.accent or themes.preset.text_soft
                end
            end
        end
    end

    local function find_option(value)
        if type(value) ~= "string" then return nil end
        for _, option in ipairs(cfg.option_data or {}) do
            if option.value == value then return option end
        end
        for _, option in ipairs(cfg.option_data or {}) do
            if option.label == value or library:translate(option.label) == value then return option end
        end
    end

    function cfg.set_visible(bool)
        cfg.open = bool == true
        if cfg.open then
            build_entries()
            render_rows()
        end
        local width = math.max(120, items.dropdown.AbsoluteSize.X)
        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
        width = min(width, max(1, viewport.X - 12))
        local height_limit = min(290, max(1, viewport.Y - 20))
        if library.is_mobile then
            local inset = gui_service:GetGuiInset()
            height_limit = min(height_limit, max(1, viewport.Y - inset.Y - 18))
        end
        local height = cfg.open and min(cfg.y_size or 0, height_limit) or 0
        local search_height = cfg.searchable and math.min(38, height) or 0
        items.outline.Size = dim2(1, 0, 1, 0)
        if search_input then search_input.Visible = cfg.open end
        if not cfg.open and search_input and uis:GetFocusedTextBox() == search_input then search_input:ReleaseFocus() end
        items.option_list.Position = dim2(0, 0, 0, search_height)
        items.option_list.Size = dim2(1, 0, 1, -search_height)
        items.dropdown_holder.Size = dim_offset(width, height)
        items.dropdown_holder.Visible = cfg.open
        if cfg.open then
            if library.is_mobile then
                items.dropdown_holder.Position = library:mobile_popup_position(items.dropdown, width, height, 6)
            else
                local px = clamp(items.dropdown.AbsolutePosition.X, 6, max(6, viewport.X - width - 6))
                local py = items.dropdown.AbsolutePosition.Y + items.dropdown.AbsoluteSize.Y + 6
                if py + height > viewport.Y - 8 then py = max(6, items.dropdown.AbsolutePosition.Y - height - 6) end
                items.dropdown_holder.Position = dim_offset(px, py)
            end
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    function cfg.set(value)
        local requested = cfg.multi and (type(value) == "table" and value or {}) or (value ~= nil and {value} or {})
        if cfg.multi and type(value) ~= "table" and value ~= nil then return false, "Multi dropdown values must be a list" end
        if cfg.multi and type(value) == "table" then
            local count, highest = 0, 0
            for index in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "Multi dropdown values must be a dense list" end
                count += 1
                highest = math.max(highest, index)
            end
            if count ~= highest then return false, "Multi dropdown values must be a dense list" end
        end
        local selected, selected_labels, seen = {}, {}, {}
        for index, raw in ipairs(requested) do
            local option = find_option(raw)
            if not option then return false, "Unknown dropdown option at index " .. tostring(index) end
            if option.disabled then return false, "Dropdown option '" .. option.value .. "' is disabled" end
            if not seen[option.value] then
                seen[option.value] = true
                table.insert(selected, option.value)
                table.insert(selected_labels, library:translate(option.label))
            end
        end
        if not cfg.multi and #selected > 1 then return false, "Single dropdowns accept one value" end
        cfg.multi_items = cfg.multi and selected or {}
        flags[cfg.flag] = cfg.multi and selected or selected[1]
        items.sub_text.Text = table.concat(selected_labels, ", ")
        render_rows()
        library:dispatch_control_callback(cfg, cfg.callback, nil, flags[cfg.flag])
        return true
    end

    function cfg.refresh_options(list)
        local valid, reason = library:validate_option_list("dropdown", list)
        if not valid then return false, reason end
        local previous = flags[cfg.flag]
        cfg.options = table.clone(list)
        cfg.option_data = {}
        for _, option in ipairs(cfg.options) do table.insert(cfg.option_data, option_record(option)) end
        if search_input then search_input.Text = "" end
        build_entries()

        local maximum_entries, seen_groups = #cfg.option_data, {}
        for _, option in ipairs(cfg.option_data) do
            if option.group and not seen_groups[option.group] then
                seen_groups[option.group] = true
                maximum_entries += 1
            end
        end
        local needed_rows = math.min(max_visible_rows, math.max(1, maximum_entries))
        while #option_rows < needed_rows do
            local row = library:create("TextButton", {
                Parent = items.option_list,
                Size = dim2(1, -8, 0, row_height),
                BackgroundColor3 = themes.preset.surface_alt,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                FontFace = fonts.small,
                Text = "",
                TextColor3 = themes.preset.text_soft,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Visible = false,
                ZIndex = 12,
            })
            library:create("UICorner", {Parent = row, CornerRadius = dim(0, 3)})
            library:create("UIPadding", {Parent = row, PaddingLeft = dim(0, 7), PaddingRight = dim(0, 6)})
            library:apply_theme(row, "surface_alt", "BackgroundColor3")
            library:connection(row.Activated, function()
                local entry = row_bindings[row]
                if not entry or entry.kind ~= "option" or entry.option.disabled then return end
                local option = entry.option
                if cfg.multi then
                    local selected = table.clone(cfg.multi_items)
                    local selected_index = table.find(selected, option.value)
                    if selected_index then table.remove(selected, selected_index) else table.insert(selected, option.value) end
                    cfg.set(selected)
                else
                    cfg.set_visible(false)
                    cfg.set(option.value)
                end
            end, cfg)
            table.insert(option_rows, row)
        end
        render_rows()
        if previous ~= nil then
            local preserved = {}
            if cfg.multi and type(previous) == "table" then
                for _, value in ipairs(previous) do
                    local option = find_option(value)
                    if option and not option.disabled then table.insert(preserved, value) end
                end
                cfg.set(preserved)
            elseif find_option(previous) and not find_option(previous).disabled then
                cfg.set(previous)
            else
                cfg.set(nil)
            end
        end
        return true
    end

    library:connection(items.option_list:GetPropertyChangedSignal("CanvasPosition"), render_rows, cfg)
    if search_input then library:connection(search_input:GetPropertyChangedSignal("Text"), function()
        build_entries()
        render_rows()
    end, cfg) end

    library:connection(items[ "dropdown" ].Activated, function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end, cfg)

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

    flags[cfg.flag] = nil
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        local function normalize(item)
            local option = find_option(item)
            if option and not option.disabled then return option.value end
            return nil
        end
        if cfg.multi then
            if type(value) ~= "table" then return false, nil, "expected a list of option values" end
            local count = 0
            for index in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then
                    return false, nil, "expected a dense list of option values"
                end
                count += 1
            end
            if #value ~= count then return false, nil, "expected a dense list of option values" end
            local normalized, seen = {}, {}
            for index, item in ipairs(value) do
                local stable_value = normalize(item)
                if not stable_value then return false, nil, "unknown dropdown option at index " .. tostring(index) end
                if seen[stable_value] then return false, nil, "duplicate dropdown option '" .. stable_value .. "'" end
                seen[stable_value] = true
                table.insert(normalized, stable_value)
            end
            return true, normalized
        end
        local stable_value = normalize(value)
        if not stable_value then return false, nil, "expected one of the dropdown values" end
        return true, stable_value
    end, cfg.legacy_flags)

    library:with_change_context("initialization", "initialize", cfg.refresh_options, cfg.options)
    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)

    library:mobile_format_control(items, "dropdown")
    library:attach_control(cfg, items.dropdown_object, self)
    cfg:AddCleanup(function()
        if items.dropdown_holder.Parent then items.dropdown_holder:Destroy() end
    end)
    cfg._locale_connection = library:register_locale_callback(function()
        local labels = {}
        for _, value in ipairs(selection_values()) do
            local option = find_option(value)
            if option then table.insert(labels, library:translate(option.label)) end
        end
        items.sub_text.Text = table.concat(labels, ", ")
        if cfg.open then build_entries(); render_rows() end
    end)
    cfg:AddCleanup(function() cfg._locale_connection:Disconnect() end)
    return setmetatable(cfg, library)
end
end
