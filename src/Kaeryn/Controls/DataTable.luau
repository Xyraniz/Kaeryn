return function(context)
    local dim2 = context.dim2
    local dim = context.dim
    local rgb = context.rgb
    local library = context.library
    local themes = context.themes
    local fonts = context.fonts
    local flags = context.flags
    local config_flags = context.config_flags

    local function row_key(id)
        return tostring(id)
    end

    function library:data_table(options)
        options = library:normalize_options("data_table", options)
        local id, flag = library:resolve_identity(options, "data_table", self.name, true)
        local cfg = {
            id = id,
            flag = flag,
            control_type = "data_table",
            name = options.name,
            info = options.info,
            callback = options.callback,
            legacy_flags = options.legacy_flags,
            columns = table.clone(options.columns),
            rows = {},
            rows_by_id = {},
            row_views = {},
            sort_key = nil,
            sort_ascending = true,
            items = {},
        }

        local items = cfg.items
        local heading_height = options.info and 40 or 24
        items.root = library:create("Frame", {
            Parent = self.items.elements,
            Name = "DataTable",
            Size = dim2(1, 0, 0, options.max_height + heading_height),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        items.title = library:create("TextLabel", {
            Parent = items.root,
            Name = "Title",
            Size = dim2(1, 0, 0, 20),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            FontFace = fonts.font,
            Text = options.name,
            TextColor3 = themes.preset.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        library:apply_theme(items.title, "text", "TextColor3")
        if options.info then
            items.description = library:create("TextLabel", {
                Parent = items.root,
                Name = "Description",
                Position = dim2(0, 0, 0, 20),
                Size = dim2(1, 0, 0, 16),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = fonts.small,
                Text = options.info,
                TextColor3 = themes.preset.muted,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            library:apply_theme(items.description, "muted", "TextColor3")
        end
        items.header = library:create("Frame", {
            Parent = items.root,
            Name = "Header",
            Position = dim2(0, 0, 0, heading_height),
            Size = dim2(1, 0, 0, 28),
            BackgroundColor3 = themes.preset.surface_alt,
            BorderSizePixel = 0,
        })
        library:apply_theme(items.header, "surface_alt", "BackgroundColor3")
        library:create("UICorner", {Parent = items.header, CornerRadius = dim(0, 4)})
        library:create("UIListLayout", {
            Parent = items.header,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        items.scrolling = library:create("ScrollingFrame", {
            Parent = items.root,
            Name = "Rows",
            Position = dim2(0, 0, 0, heading_height + 32),
            Size = dim2(1, 0, 1, -(heading_height + 32)),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = dim2(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = rgb(72, 72, 73),
        })
        items.rows = library:create("Frame", {
            Parent = items.scrolling,
            Name = "RowsContent",
            Size = dim2(1, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        library:create("UIListLayout", {
            Parent = items.rows,
            Padding = dim(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        local fixed_widths, flexible_columns = 0, 0
        for _, column in ipairs(cfg.columns) do
            if column.width then fixed_widths += column.width else flexible_columns += 1 end
        end
        local flexible_width = flexible_columns > 0 and (1 - fixed_widths) / flexible_columns or 0
        local function column_width(column)
            return column.width or flexible_width
        end

        local function refresh_selection()
            for key, view in pairs(cfg.row_views) do
                view.stroke.Enabled = cfg.value ~= nil and key == row_key(cfg.value)
            end
        end

        local function set_cell_text(view, row)
            for index, column in ipairs(cfg.columns) do
                view.cells[index].Text = row[column.key] == nil and "" or tostring(row[column.key])
            end
        end

        local function make_row(row)
            local key = row_key(row.id)
            local button = library:create("TextButton", {
                Parent = items.rows,
                Name = "Row_" .. key,
                Size = dim2(1, 0, 0, options.row_height),
                BackgroundColor3 = themes.preset.surface,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                LayoutOrder = #cfg.rows,
            })
            library:apply_theme(button, "surface", "BackgroundColor3")
            local stroke = library:create("UIStroke", {
                Parent = button,
                Color = themes.preset.accent,
                Transparency = 0.35,
                Enabled = false,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            library:apply_theme(stroke, "accent", "Color")
            library:create("UICorner", {Parent = button, CornerRadius = dim(0, 4)})
            library:create("UIListLayout", {
                Parent = button,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            local view = {button = button, stroke = stroke, cells = {}}
            for index, column in ipairs(cfg.columns) do
                local cell = library:create("TextLabel", {
                    Parent = button,
                    Name = column.key,
                    Size = dim2(column_width(column), 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    FontFace = fonts.small,
                    Text = "",
                    TextColor3 = themes.preset.text_soft,
                    TextSize = 13,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = index,
                })
                library:apply_theme(cell, "text_soft", "TextColor3")
                library:create("UIPadding", {
                    Parent = cell,
                    PaddingLeft = dim(0, 8),
                    PaddingRight = dim(0, 6),
                })
                view.cells[index] = cell
            end
            library:connection(button.Activated, function()
                if not cfg._destroyed then cfg.set(row.id, {source = "user", phase = "commit"}) end
            end, cfg)
            set_cell_text(view, row)
            cfg.row_views[key] = view
            return view
        end

        local headers = {}
        for index, column in ipairs(cfg.columns) do
            local header = library:create("TextButton", {
                Parent = items.header,
                Name = column.key,
                Size = dim2(column_width(column), 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                FontFace = fonts.font,
                Text = column.label or column.key,
                TextColor3 = themes.preset.text_soft,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = index,
            })
            headers[column.key] = header
            library:apply_theme(header, "text_soft", "TextColor3")
            library:create("UIPadding", {
                Parent = header,
                PaddingLeft = dim(0, 8),
                PaddingRight = dim(0, 6),
            })
            if options.sortable and column.sortable ~= false then
                library:connection(header.Activated, function()
                    if cfg.sort_key == column.key then
                        cfg:Sort(column.key, not cfg.sort_ascending)
                    else
                        cfg:Sort(column.key, true)
                    end
                end, cfg)
                header:SetAttribute("KaerynSortKey", column.key)
            end
        end

        library:attach_control(cfg, items.root, self)

        local function ordered_rows()
            local result = table.clone(cfg.rows)
            if not cfg.sort_key then return result end
            table.sort(result, function(first, second)
                local left, right = first[cfg.sort_key], second[cfg.sort_key]
                if left == right then return row_key(first.id) < row_key(second.id) end
                if left == nil then return not cfg.sort_ascending end
                if right == nil then return cfg.sort_ascending end
                local less
                if type(left) == "number" and type(right) == "number" then
                    less = left < right
                else
                    less = tostring(left) < tostring(right)
                end
                return cfg.sort_ascending and less or (not cfg.sort_ascending and not less)
            end)
            return result
        end

        local function render_order()
            for index, row in ipairs(ordered_rows()) do
                local view = cfg.row_views[row_key(row.id)]
                if view then view.button.LayoutOrder = index; set_cell_text(view, row) end
            end
        end

        function cfg.set(value, explicit_context)
            if value ~= nil then
                local row = cfg.rows_by_id[row_key(value)]
                if not row then return false, "unknown data_table row id '" .. tostring(value) .. "'" end
                value = row.id
            end
            cfg.value = value
            flags[cfg.flag] = value
            refresh_selection()
            local row = value ~= nil and cfg.rows_by_id[row_key(value)] or nil
            library:dispatch_control_callback(cfg, cfg.callback, explicit_context, value, row)
            return true
        end

        function cfg:SetRows(rows)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            local valid, reason = library:validate_data_table(cfg.columns, rows)
            if not valid then return false, reason end
            local next_rows, next_by_id = {}, {}
            for index, row in ipairs(rows) do
                local copy = table.clone(row)
                local key = row_key(copy.id)
                next_rows[index], next_by_id[key] = copy, copy
            end
            for key, view in pairs(cfg.row_views) do
                if not next_by_id[key] then
                    view.button:Destroy()
                    cfg.row_views[key] = nil
                end
            end
            cfg.rows, cfg.rows_by_id = next_rows, next_by_id
            for _, row in ipairs(cfg.rows) do
                local key = row_key(row.id)
                local view = cfg.row_views[key] or make_row(row)
                view.button.LayoutOrder = #cfg.rows
                set_cell_text(view, row)
            end
            if cfg.value ~= nil and not cfg.rows_by_id[row_key(cfg.value)] then
                cfg.set(nil, {source = "code", phase = "commit"})
            elseif cfg.value ~= nil then
                cfg.value = cfg.rows_by_id[row_key(cfg.value)].id
                flags[cfg.flag] = cfg.value
            else
                refresh_selection()
            end
            render_order()
            return true
        end

        function cfg:UpdateRow(id_value, patch)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            local current = cfg.rows_by_id[row_key(id_value)]
            if not current then return false, "unknown data_table row id '" .. tostring(id_value) .. "'" end
            if type(patch) ~= "table" or patch.id ~= nil and patch.id ~= current.id then return false, "row updates must be a table and cannot change the row id" end
            local replacement = table.clone(current)
            for key, value in pairs(patch) do replacement[key] = value end
            local rows = table.clone(cfg.rows)
            for index, row in ipairs(rows) do
                if row_key(row.id) == row_key(id_value) then rows[index] = replacement; break end
            end
            return cfg:SetRows(rows)
        end

        function cfg:RemoveRow(id_value)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            if not cfg.rows_by_id[row_key(id_value)] then return false, "unknown data_table row id '" .. tostring(id_value) .. "'" end
            local rows = {}
            for _, row in ipairs(cfg.rows) do
                if row_key(row.id) ~= row_key(id_value) then table.insert(rows, row) end
            end
            return cfg:SetRows(rows)
        end

        function cfg:Sort(key, ascending)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            local column_exists = false
            for _, column in ipairs(cfg.columns) do
                if column.key == key and options.sortable and column.sortable ~= false then column_exists = true; break end
            end
            if not column_exists then return false, "unknown or non-sortable data_table column '" .. tostring(key) .. "'" end
            if ascending ~= nil and type(ascending) ~= "boolean" then return false, "ascending must be a boolean" end
            cfg.sort_key = key
            cfg.sort_ascending = ascending == nil or ascending
            for _, column in ipairs(cfg.columns) do
                headers[column.key].Text = (column.label or column.key)
                    .. (cfg.sort_key == column.key and (cfg.sort_ascending and "  ↑" or "  ↓") or "")
            end
            render_order()
            return true
        end

        cfg:SetRows(options.rows)
        library:register_config_flag(flag, function(value)
            cfg.set(value, {source = "config", phase = "commit"})
        end, function(value)
            if value == nil then return true, nil end
            if type(value) ~= "string" and type(value) ~= "number" then return false, nil, "expected a row id" end
            local row = cfg.rows_by_id[row_key(value)]
            if not row then return false, nil, "row id does not exist" end
            return true, row.id
        end, options.legacy_flags)

        if options.default ~= nil then
            library:with_change_context("initialization", "initialize", cfg.set, options.default)
        end
        return cfg
    end
end
