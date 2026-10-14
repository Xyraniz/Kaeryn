return function(__kaeryn)
    local uis = __kaeryn.uis
    local ws = __kaeryn.ws
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local vec2 = __kaeryn.vec2
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts

    local function lower(text)
        return string.lower(tostring(text or ""))
    end

    function library:search_controls(query)
        query = lower(query):match("^%s*(.-)%s*$")
        if query == "" then return {} end

        local results = {}
        for _, control in pairs(self.controls_by_id) do
            local root = control._ui_root
            if not control._destroyed and control._visible ~= false and control._enabled ~= false and root and root.Parent then
                local section = control._section
                local column = section and section._column
                local page = column and column._page
                local tab = page and page._tab
                local path = table.concat({
                    tab and tab.name or "",
                    page and page.text and page.text.Text or "",
                    section and section.name or "",
                }, " ")
                local haystack = lower(table.concat({control.name or "", control.info or "", control.id or "", control.flag or "", control.control_type or "", path}, " "))
                if string.find(haystack, query, 1, true) then
                    table.insert(results, {control = control, path = path})
                end
            end
        end
        table.sort(results, function(first, second)
            local a = lower(first.control.name or first.control.id)
            local b = lower(second.control.name or second.control.id)
            return a == b and first.control.id < second.control.id or a < b
        end)
        return results
    end

    function library:focus_control(control)
        if type(control) ~= "table" or control._destroyed or not control._ui_root or not control._ui_root.Parent then
            return false, "Control is unavailable"
        end
        local section = control._section
        local column = section and section._column
        local page = column and column._page
        local tab = page and page._tab
        if tab and type(tab.open_tab) == "function" then tab.open_tab() end
        if page and type(page.open_page) == "function" then page.open_page() end

        task.defer(function()
            if library.unloaded or control._destroyed then return end
            local root = control._ui_root
            if not root or not root.Parent then return end
            local scrolling = section and section.items and section.items.scrolling
            if scrolling and scrolling:IsA("ScrollingFrame") then
                local offset = root.AbsolutePosition.Y - scrolling.AbsolutePosition.Y + scrolling.CanvasPosition.Y
                scrolling.CanvasPosition = vec2(0, math.max(0, offset - 18))
            end
            local stroke = library:create("UIStroke", {
                Parent = root,
                Color = themes.preset.accent,
                Thickness = 2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            task.delay(0.9, function()
                if stroke.Parent then stroke:Destroy() end
            end)
        end)
        return true
    end

    function library:init_search(window)
        local items = window.items
        local action_bar = library:create("Frame", {
            Parent = items.multi_holder,
            Name = "HeaderActions",
            AnchorPoint = vec2(0, 0.5),
            Position = dim2(1, 0, 0.5, -2),
            Size = dim2(0, 48, 0, 100),
            BackgroundColor3 = rgb(0, 0, 0),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            ZIndex = 83,
        })
        library:create("UICorner", {Parent = action_bar, CornerRadius = dim(0, 11)})
        library:create("UIStroke", {Parent = action_bar, Color = rgb(37, 37, 41), Thickness = 1})
        library:create("Frame", {
            Parent = action_bar,
            Name = "SquareLeftEdge",
            Position = dim2(0, 0, 0, 0),
            Size = dim2(0, 11, 1, 0),
            BackgroundColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 84,
        })

        local function create_action_button(name, icon_name, y, icon_size)
            local action_button = library:create("TextButton", {
                Parent = action_bar,
                Name = name,
                Position = dim2(0, 4, 0, y),
                Size = dim2(0, 40, 0, 40),
                BackgroundColor3 = themes.preset.surface_hover,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                ZIndex = 85,
            })
            library:create("UICorner", {Parent = action_button, CornerRadius = dim(0, 8)})
            library:apply_theme(action_button, "surface_hover", "BackgroundColor3")
            local icon = library:create("ImageLabel", {
                Parent = action_button,
                Name = "Icon",
                AnchorPoint = vec2(0.5, 0.5),
                Position = dim2(0.5, 0, 0.5, 0),
                Size = dim2(0, icon_size, 0, icon_size),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Image = library:resolve_icon(icon_name),
                ImageColor3 = rgb(255, 255, 255),
                ZIndex = 86,
            })
            library:apply_theme(icon, "text", "ImageColor3")
            library:connection(action_button.MouseEnter, function()
                action_button.BackgroundTransparency = 0
            end)
            library:connection(action_button.MouseLeave, function()
                action_button.BackgroundTransparency = 1
            end)
            return action_button
        end

        local menu_close_button = create_action_button("CloseMenu", "x", 4, 16)
        local button = create_action_button("Search", "search", 56, 18)
        window.search_button = button

        local overlay = library:create("Frame", {
            Parent = library.items,
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = rgb(0, 0, 0),
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 80,
        })
        local panel = library:create("Frame", {
            Parent = overlay,
            AnchorPoint = vec2(0.5, 0.5),
            Position = dim2(0.5, 0, 0.5, 0),
            Size = dim2(0, 500, 0, 410),
            BackgroundColor3 = themes.preset.surface,
            BorderSizePixel = 0,
            ZIndex = 81,
        })
        library:create("UICorner", {Parent = panel, CornerRadius = dim(0, 8)})
        library:create("UIStroke", {Parent = panel, Color = themes.preset.border, Thickness = 1})
        library:apply_theme(panel, "surface", "BackgroundColor3")
        library:apply_theme(panel:FindFirstChildOfClass("UIStroke"), "border", "Color")

        local title = library:create("TextLabel", {
            Parent = panel,
            Position = dim2(0, 16, 0, 13),
            Size = dim2(1, -72, 0, 24),
            BackgroundTransparency = 1,
            FontFace = fonts.font,
            Text = "Search",
            TextColor3 = themes.preset.text,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 82,
        })
        library:apply_theme(title, "text", "TextColor3")
        local close_button = library:create("TextButton", {
            Parent = panel,
            AnchorPoint = vec2(1, 0),
            Position = dim2(1, -12, 0, 11),
            Size = dim2(0, 28, 0, 28),
            BackgroundColor3 = themes.preset.surface_hover,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            FontFace = fonts.small,
            Text = "×",
            TextColor3 = themes.preset.text,
            TextSize = 18,
            ZIndex = 82,
        })
        library:create("UICorner", {Parent = close_button, CornerRadius = dim(0, 5)})
        library:apply_theme(close_button, "surface_hover", "BackgroundColor3")
        library:apply_theme(close_button, "text", "TextColor3")

        local query = library:create("TextBox", {
            Parent = panel,
            Position = dim2(0, 14, 0, 48),
            Size = dim2(1, -28, 0, 36),
            BackgroundColor3 = themes.preset.surface_alt,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            FontFace = fonts.small,
            PlaceholderText = "Search controls...",
            Text = "",
            TextColor3 = themes.preset.text,
            PlaceholderColor3 = themes.preset.muted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 82,
        })
        library:create("UICorner", {Parent = query, CornerRadius = dim(0, 5)})
        library:create("UIPadding", {Parent = query, PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10)})
        library:apply_theme(query, "surface_alt", "BackgroundColor3")
        library:apply_theme(query, "text", "TextColor3")
        library:apply_theme(query, "muted", "PlaceholderColor3")

        local list = library:create("ScrollingFrame", {
            Parent = panel,
            Position = dim2(0, 14, 0, 94),
            Size = dim2(1, -28, 1, -106),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = dim2(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = themes.preset.muted,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 82,
        })
        library:create("UIListLayout", {Parent = list, Padding = dim(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
        local empty = library:create("TextLabel", {
            Parent = list,
            Size = dim2(1, 0, 0, 36),
            BackgroundTransparency = 1,
            FontFace = fonts.small,
            Text = "Type to search controls",
            TextColor3 = themes.preset.muted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 82,
        })
        library:apply_theme(empty, "muted", "TextColor3")

        local result_buttons = {}
        local function clear_results()
            for _, child in ipairs(result_buttons) do child:Destroy() end
            table.clear(result_buttons)
        end
        local function render_results()
            clear_results()
            local text = query.Text
            if text:match("^%s*$") then
                empty.Visible = true
                library:localize(empty, "Type to search controls")
                return
            end
            local results = library:search_controls(text)
            empty.Visible = #results == 0
            if #results == 0 then library:localize(empty, "No controls found") else empty.Text = "" end
            for index = 1, math.min(#results, 40) do
                local result = results[index]
                local control = result.control
                local name = control.name or control.id
                local path = result.path:gsub("%s+", " "):match("^%s*(.-)%s*$")
                local button_row = library:create("TextButton", {
                    Parent = list,
                    Size = dim2(1, 0, 0, 46),
                    BackgroundColor3 = themes.preset.surface_alt,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    FontFace = fonts.small,
                    Text = name .. "   ·   " .. path,
                    TextColor3 = themes.preset.text_soft,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    LayoutOrder = index,
                    ZIndex = 83,
                })
                library:create("UICorner", {Parent = button_row, CornerRadius = dim(0, 5)})
                library:create("UIPadding", {Parent = button_row, PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10)})
                library:apply_theme(button_row, "surface_alt", "BackgroundColor3")
                library:apply_theme(button_row, "text_soft", "TextColor3")
                button_row.Activated:Connect(function()
                    if library:focus_control(control) then
                        overlay.Visible = false
                        query:ReleaseFocus()
                    end
                end)
                table.insert(result_buttons, button_row)
            end
        end

        local function close_search()
            overlay.Visible = false
            if uis:GetFocusedTextBox() == query then query:ReleaseFocus() end
        end
        local function open()
            if library.unloaded then return end
            if library.active_dialog and library.active_dialog.close then library.active_dialog:close(false) end
            library:close_element()
            overlay.Visible = true
            render_results()
            query:CaptureFocus()
        end
        library:connection(button.Activated, open)
        library:connection(menu_close_button.Activated, function()
            library:unload_menu()
        end)
        local function update_header_actions()
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            local main_right = items.main.AbsolutePosition.X + items.main.AbsoluteSize.X
            local protrudes = main_right + 48 <= viewport.X - 8
            local header_top = items.multi_holder.AbsolutePosition.Y
            local header_height = items.multi_holder.AbsoluteSize.Y
            local bar_height = action_bar.AbsoluteSize.Y
            if header_height <= 0 then header_height = items.multi_holder.Size.Y.Offset end
            if bar_height <= 0 then bar_height = action_bar.Size.Y.Offset end
            local y_offset = -2
            local min_y_offset = bar_height * 0.5 - header_top - header_height * 0.5
            local max_y_offset = viewport.Y - header_top - header_height * 0.5 - bar_height * 0.5
            if min_y_offset <= max_y_offset then
                y_offset = math.clamp(y_offset, min_y_offset, max_y_offset)
            end
            action_bar.Position = dim2(1, protrudes and 0 or -48, 0.5, y_offset)
        end
        library:connection(items.main:GetPropertyChangedSignal("AbsolutePosition"), update_header_actions)
        library:connection(items.main:GetPropertyChangedSignal("AbsoluteSize"), update_header_actions)
        library:connection(items.multi_holder:GetPropertyChangedSignal("AbsolutePosition"), update_header_actions)
        library:connection(items.multi_holder:GetPropertyChangedSignal("AbsoluteSize"), update_header_actions)
        update_header_actions()
        library:connection(close_button.Activated, close_search)
        library:connection(query:GetPropertyChangedSignal("Text"), render_results)
        library:connection(uis.InputBegan, function(input, processed)
            if input.KeyCode == Enum.KeyCode.Escape and overlay.Visible then
                close_search()
            elseif not processed and input.KeyCode == Enum.KeyCode.K and (uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)) then
                if overlay.Visible then close_search() else open() end
            end
        end)
        local function resize_panel()
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            panel.Size = dim2(0, math.min(500, math.max(180, viewport.X - 24)), 0, math.min(410, math.max(180, viewport.Y - 24)))
            update_header_actions()
        end
        library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), function()
            if ws.CurrentCamera then
                library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), resize_panel)
                resize_panel()
            end
        end)
        if ws.CurrentCamera then library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), resize_panel) end
        resize_panel()
        library.search_locale_connection = library:register_locale_callback(function()
            if overlay.Visible then render_results() end
        end)
        window.search = {open = open, close = close_search, overlay = overlay}
        library.search_overlay = overlay
    end
end
