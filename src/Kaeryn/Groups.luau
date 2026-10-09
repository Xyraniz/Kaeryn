return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local insert = __kaeryn.insert
    local remove = __kaeryn.remove
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

local row_meta = {}

local function prefix_options(row, options)
    if type(options) ~= "table" then return options end
    options = table.clone(options or {})
    local prefix = row._namespace .. "."
    if type(options.id) == "string" then options.id = prefix .. options.id end
    if type(options.flag) == "string" then options.flag = prefix .. options.flag end
    if type(options.legacy_flags) == "table" then
        local old_flags = {}
        for index, old_flag in ipairs(options.legacy_flags) do old_flags[index] = prefix .. old_flag end
        options.legacy_flags = old_flags
    end
    return options
end

function row_meta.__index(row, key)
    local method = library[key]
    if type(method) == "function" and library.option_schemas[key] then
        return function(_, options)
            local control = method(row, prefix_options(row, options))
            insert(row._controls, control)
            return control
        end
    end
    if key == "custom_control" then
        return function(_, control_type, options)
            local control = library.custom_control(row, control_type, prefix_options(row, options))
            insert(row._controls, control)
            return control
        end
    end
    return method
end

function library:group(options)
    options = library:normalize_options("group", options)
    local persistent = options.id ~= nil or options.flag ~= nil or #options.legacy_flags > 0
    local id, flag = library:resolve_identity(options, "group", self.name, persistent)
    local cfg = {
        id = id,
        flag = flag,
        control_type = "group",
        name = options.name,
        min_items = options.min_items,
        max_items = options.max_items,
        callback = options.callback,
        legacy_flags = options.legacy_flags,
        rows = {},
        by_key = {},
        next_key = 0,
        _destroyed = false,
        items = {},
    }
    setmetatable(cfg, library)
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements;
        Name = "RepeaterGroup";
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.heading = library:create("Frame", {
        Parent = items.root;
        Name = "GroupHeading";
        Size = dim2(1, 0, 0, 24);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.title = library:create("TextLabel", {
        Parent = items.heading;
        Name = "Name";
        Text = cfg.name;
        FontFace = fonts.small;
        TextSize = 14;
        TextColor3 = themes.preset.text_soft;
        TextXAlignment = Enum.TextXAlignment.Left;
        Size = dim2(1, -40, 1, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.add = library:create("TextButton", {
        Parent = items.heading;
        Name = "Add";
        AnchorPoint = Vector2.new(1, 0);
        Position = dim2(1, 0, 0, 0);
        Size = dim2(0, 34, 1, 0);
        Text = "+";
        FontFace = fonts.font;
        TextSize = 18;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
    })
    library:create("UICorner", {Parent = items.add; CornerRadius = dim(0, 4)})
    items.rows = library:create("Frame", {
        Parent = items.root;
        Name = "Rows";
        Position = dim2(0, 0, 0, 28);
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    library:create("UIListLayout", {Parent = items.rows; Padding = dim(0, 7); SortOrder = Enum.SortOrder.LayoutOrder})

    local function row_keys()
        local result = {}
        for _, row in ipairs(cfg.rows) do insert(result, row.key) end
        return result
    end

    local function changed(action, key, explicit_context)
        if flag then flags[flag] = row_keys() end
        if cfg._updating then return end
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, action, key, row_keys())
    end

    local function update_controls()
        items.add.Active = not cfg._destroyed and #cfg.rows < cfg.max_items
        items.add.TextTransparency = items.add.Active and 0 or 0.55
        for _, row in ipairs(cfg.rows) do
            row.items.remove.Visible = #cfg.rows > cfg.min_items
        end
    end

    local function make_row(key, title)
        local row = {
            key = key,
            name = id .. "." .. key,
            title = title or key,
            _namespace = id .. "." .. key,
            _controls = {},
            _group = cfg,
            items = {},
        }
        setmetatable(row, row_meta)
        row.items.root = library:create("Frame", {
            Parent = items.rows;
            Name = "GroupRow";
            LayoutOrder = #cfg.rows + 1;
            Size = dim2(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = themes.preset.surface_alt;
            BorderSizePixel = 0;
        })
        library:create("UICorner", {Parent = row.items.root; CornerRadius = dim(0, 5)})
        row.items.header = library:create("Frame", {
            Parent = row.items.root;
            Name = "Header";
            Size = dim2(1, 0, 0, 28);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        })
        row.items.title = library:create("TextLabel", {
            Parent = row.items.header;
            Name = "Title";
            Position = dim2(0, 8, 0, 0);
            Size = dim2(1, -42, 1, 0);
            Text = row.title;
            FontFace = fonts.small;
            TextSize = 13;
            TextColor3 = themes.preset.text_soft;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        })
        row.items.remove = library:create("TextButton", {
            Parent = row.items.header;
            Name = "Remove";
            AnchorPoint = Vector2.new(1, 0);
            Position = dim2(1, -5, 0, 3);
            Size = dim2(0, 22, 0, 22);
            Text = "×";
            FontFace = fonts.small;
            TextSize = 15;
            TextColor3 = themes.preset.muted;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            AutoButtonColor = false;
        })
        row.items.elements = library:create("Frame", {
            Parent = row.items.root;
            Name = "Elements";
            Position = dim2(0, 8, 0, 30);
            Size = dim2(1, -16, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        })
        library:create("UIListLayout", {Parent = row.items.elements; Padding = dim(0, 7); SortOrder = Enum.SortOrder.LayoutOrder})
        row.items.remove.Activated:Connect(function()
            if not cfg._destroyed then cfg:Remove(key, {source = "user", phase = "commit"}) end
        end)
        function row:SetTitle(value)
            if type(value) ~= "string" or value == "" then return false, "row title must be a non-empty string" end
            self.title = value
            self.items.title.Text = value
            return true
        end
        function row:Destroy()
            return cfg:Remove(self.key)
        end
        cfg.by_key[key] = row
        insert(cfg.rows, row)
        return row
    end

    local function erase_row(row)
        for index = #row._controls, 1, -1 do row._controls[index]:Destroy() end
        cfg.by_key[row.key] = nil
        for index, candidate in ipairs(cfg.rows) do
            if candidate == row then remove(cfg.rows, index); break end
        end
        if row.items.root.Parent then row.items.root:Destroy() end
    end

    function cfg:Add(key, title, explicit_context)
        if cfg._destroyed then return false, "group has been destroyed" end
        if #cfg.rows >= cfg.max_items then return false, "group has reached max_items" end
        if key == nil then
            repeat cfg.next_key += 1; key = "item-" .. tostring(cfg.next_key) until not cfg.by_key[key]
            title = title or ("Item " .. tostring(cfg.next_key))
        end
        if type(key) ~= "string" or key:gsub("%s", "") == "" then return false, "row key must be a non-empty string" end
        if title ~= nil and type(title) ~= "string" then return false, "row title must be a string" end
        if cfg.by_key[key] then return false, "row key already exists: " .. key end
        local row = make_row(key, title)
        update_controls()
        changed("add", key, explicit_context or {source = "code", phase = "commit"})
        return row
    end

    function cfg:Remove(key, explicit_context)
        if cfg._destroyed then return false, "group has been destroyed" end
        if #cfg.rows <= cfg.min_items then return false, "group cannot go below min_items" end
        local row = type(key) == "table" and key or cfg.by_key[key]
        if not row then return false, "unknown group row" end
        erase_row(row)
        for index, candidate in ipairs(cfg.rows) do candidate.items.root.LayoutOrder = index end
        update_controls()
        changed("remove", row.key, explicit_context or {source = "code", phase = "commit"})
        return true
    end

    function cfg:Move(key, index)
        if cfg._destroyed then return false, "group has been destroyed" end
        local row = cfg.by_key[key]
        if not row then return false, "unknown group row" end
        if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > #cfg.rows then return false, "row index is out of range" end
        local current
        for position, candidate in ipairs(cfg.rows) do if candidate == row then current = position; break end end
        if current == index then return true end
        remove(cfg.rows, current)
        table.insert(cfg.rows, index, row)
        for position, candidate in ipairs(cfg.rows) do candidate.items.root.LayoutOrder = position end
        changed("move", key, {source = "code", phase = "commit"})
        return true
    end

    function cfg:Get(key)
        if key ~= nil then return cfg.by_key[key] end
        return row_keys()
    end

    function cfg:Set(row_list, explicit_context)
        if cfg._destroyed then return false, "group has been destroyed" end
        if type(row_list) ~= "table" then return false, "group value must be an array of row keys" end
        local count, highest_index, seen = 0, 0, {}
        for index, key in pairs(row_list) do
            if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "group value must be a dense array" end
            if type(key) ~= "string" or key == "" or seen[key] then return false, "group row keys must be unique non-empty strings" end
            seen[key] = true
            count += 1
            highest_index = math.max(highest_index, index)
        end
        if count ~= highest_index or count < cfg.min_items or count > cfg.max_items then return false, "group row count is outside its limits" end
        cfg._updating = true
        for _, row in ipairs(table.clone(cfg.rows)) do if not seen[row.key] then erase_row(row) end end
        for _, row_key in ipairs(row_list) do
            if not cfg.by_key[row_key] then cfg:Add(row_key) end
        end
        local ordered = {}
        for index, row_key in ipairs(row_list) do
            ordered[index] = cfg.by_key[row_key]
            ordered[index].items.root.LayoutOrder = index
        end
        cfg.rows = ordered
        cfg._updating = false
        update_controls()
        changed("set", nil, explicit_context or {source = "code", phase = "commit"})
        return true
    end

    function cfg:Destroy(from_root)
        if cfg._destroyed then return end
        cfg._destroyed = true
        for _, row in ipairs(table.clone(cfg.rows)) do
            for index = #row._controls, 1, -1 do row._controls[index]:Destroy() end
        end
        table.clear(cfg.rows)
        table.clear(cfg.by_key)
        if flag then
            config_flags[flag] = nil
            library.config_validators[flag] = nil
            library.used_flags[flag] = nil
            flags[flag] = nil
            for old_flag, new_flag in pairs(library.flag_migrations) do if new_flag == flag then library.flag_migrations[old_flag] = nil end end
        end
        library.used_ids[id] = nil
        if not from_root and items.root.Parent then items.root:Destroy() end
    end

    items.add.Activated:Connect(function()
        if not cfg._destroyed and #cfg.rows < cfg.max_items then cfg:Add(nil, nil, {source = "user", phase = "commit"}) end
    end)

    while #cfg.rows < cfg.min_items do
        cfg.next_key += 1
        local key = "item-" .. tostring(cfg.next_key)
        make_row(key, "Item " .. tostring(cfg.next_key))
    end
    if flag then flags[flag] = row_keys() end
    if flag then
        library:register_config_flag(flag, function(value) return cfg:Set(value, library.change_context) end, function(value)
            if type(value) ~= "table" then return false, nil, "expected a list of row keys" end
            local count, highest_index, seen = 0, 0, {}
            for index, key in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, nil, "row keys must be a dense array" end
                if type(key) ~= "string" or key == "" or seen[key] then return false, nil, "row keys must be unique non-empty strings" end
                seen[key] = true
                count += 1
                highest_index = math.max(highest_index, index)
            end
            if count ~= highest_index or count < cfg.min_items or count > cfg.max_items then return false, nil, "row count is outside group limits" end
            return true, table.clone(value)
        end, cfg.legacy_flags)
    end
    items.root.Destroying:Connect(function()
        if not cfg._destroyed then cfg:Destroy(true) end
    end)
    update_controls()
    return cfg
end
end
