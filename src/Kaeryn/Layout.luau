return function(__kaeryn)
    local uis = __kaeryn.uis
    local ws = __kaeryn.ws
    local gui_service = __kaeryn.gui_service
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local camera = __kaeryn.camera
    local max = __kaeryn.max
    local floor = __kaeryn.floor
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local notifications = __kaeryn.notifications

function library:mobile_popup_position(anchor, width, height, gap)
    local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
    local inset = gui_service:GetGuiInset()
    local safe_top = max(8, inset.Y + 6)
    local safe_bottom = max(safe_top + 1, viewport.Y - 8)
    width = clamp(width, 1, max(1, viewport.X - 12))
    height = clamp(height, 0, max(1, safe_bottom - safe_top))
    local left = clamp(anchor.AbsolutePosition.X, 6, max(6, viewport.X - width - 6))
    local below = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + (gap or 6)
    local above = anchor.AbsolutePosition.Y - height - (gap or 6)
    local top = below + height <= safe_bottom and below or above
    return dim_offset(floor(left), floor(clamp(top, safe_top, max(safe_top, safe_bottom - height))))
end

function library:mobile_format_control(items, kind)
    if not library.is_mobile or not items then return end
    local root = items.toggle or items.slider_object or items.dropdown_object or items.label or items.textbox or items.keybind_element
    local name = items.name
    if not root or not name then return end

    if kind == "slider" then
        items.header.Size = dim2(1, -8, 0, 24)
        name.TextSize = 14
        name.TextWrapped = false
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.AutomaticSize = Enum.AutomaticSize.None
        name.TextYAlignment = Enum.TextYAlignment.Center
        name.Size = dim2(1, -88, 1, 0)
        items.value.TextSize = 13
        items.value.Size = dim_offset(76, 24)
        if items.info then
            items.info.TextSize = 12
            items.info.TextWrapped = true
            items.info.TextTruncate = Enum.TextTruncate.None
            items.info.AutomaticSize = Enum.AutomaticSize.Y
            items.info.Size = dim2(1, -8, 0, 0)
        end
        items.right_components.Size = dim2(1, -8, 0, 38)
        items.slider.Position = dim_offset(6, 0)
        items.slider.Size = dim2(1, -12, 1, 0)
        return
    end

    name.TextSize = 14
    name.TextWrapped = true
    name.TextTruncate = Enum.TextTruncate.None
    name.AutomaticSize = Enum.AutomaticSize.Y
    name.TextYAlignment = Enum.TextYAlignment.Top
    local name_offset = -8
    if kind == "toggle" then
        name_offset = -61
    elseif kind == "keybind" then
        name_offset = -82
    elseif kind == "label" then
        name_offset = -41
    end
    name.Size = dim2(1, name_offset, 0, 0)
    if items.info then
        items.info.TextSize = 12
        items.info.TextWrapped = true
        items.info.TextTruncate = Enum.TextTruncate.None
        items.info.AutomaticSize = Enum.AutomaticSize.Y
        items.info.Size = dim2(1, -10, 0, 0)
    end

    if kind == "toggle" or kind == "keybind" or kind == "label" then
        if items.right_components then
            items.right_components.AnchorPoint = vec2(1, 0)
            items.right_components.Position = dim2(1, -4, 0, 4)
            items.right_components.Size = dim_offset(kind == "keybind" and 68 or (kind == "label" and 26 or 48), 25)
        end
        if kind == "keybind" then name.Size = dim2(1, -82, 0, 0) end
        if kind == "label" and not items.right_components then name.Size = dim2(1, -8, 0, 0) end
        if kind == "toggle" and items.toggle_button then
            items.toggle_button.Size = dim_offset(items.tick and 24 or 40, 22)
        end
    elseif kind == "dropdown" then
        items.right_components.AnchorPoint = vec2(0, 0)
        items.right_components.Size = dim2(1, -8, 0, 32)
        items.dropdown.Size = dim2(1, 0, 0, 28)
        items.sub_text.TextSize = 13
        items.sub_text.Size = dim2(1, -24, 1, 0)
    elseif kind == "textbox" then
        items.right_components.Size = dim2(1, -8, 0, 34)
        items.input.Size = dim2(1, -4, 0, 30)
    end

    local last_name_y = -1
    local function update()
        if library.unloaded or not root.Parent then return end
        local label_y = max(18, name.AbsoluteSize.Y)
        if label_y == last_name_y then return end
        last_name_y = label_y
        if items.info then
            if kind == "dropdown" then
                items.info.Position = dim_offset(4, label_y + 38)
            elseif kind == "textbox" then
                items.info.Position = dim_offset(4, label_y + 39)
            else
                items.info.Position = dim_offset(4, label_y + 3)
            end
        end
        if kind == "dropdown" or kind == "textbox" then
            items.right_components.Position = dim_offset(4, label_y + 6)
        end
        library:queue_mobile_layout()
    end
    library:connection(name:GetPropertyChangedSignal("AbsoluteSize"), update)
    update()
end

function library:refresh_mobile_layout()
    if library.unloaded or not library.is_mobile or not library.mobile_window then return end
    local camera = ws.CurrentCamera
    if not camera then return end
    local win = library.mobile_window
    local it = win.items
    if not it.main or not it.main.Parent then return end
    local viewport = camera.ViewportSize
    local landscape = viewport.X > viewport.Y
    local inset = gui_service:GetGuiInset()
    local top = max(inset.Y + 9, min(60, floor(viewport.Y * 0.13)))
    local bottom = 9
    local available_width = max(1, viewport.X - 14)
    local width = landscape and min(790, floor(viewport.X * 0.80), available_width) or min(580, floor(viewport.X * 0.96), available_width)
    width = max(1, width)
    local available_height = max(1, viewport.Y - top - bottom)
    local height = landscape and floor(available_height * 0.96) or floor(available_height * 0.92)
    height = clamp(height, 1, available_height)
    local compact = library.mobile_sidebar_preference
    if compact == nil then compact = false end
    local side = compact and 54 or min(216, max(156, floor(width * 0.28)))
    local header = 42
    local footer = 20
    local previous_viewport = library.mobile_viewport
    local changed = previous_viewport ~= viewport
    local old_position = it.main.Position
    local old_size = it.main.Size
    local left = floor((viewport.X - width) / 2)
    local y = floor(top + max(0, (available_height - height) / 2))
    if previous_viewport and changed then
        local old_center_x = (old_position.X.Offset + old_size.X.Offset / 2) / max(previous_viewport.X, 1)
        local old_center_y = (old_position.Y.Offset + old_size.Y.Offset / 2) / max(previous_viewport.Y, 1)
        left = floor(old_center_x * viewport.X - width / 2)
        y = floor(old_center_y * viewport.Y - height / 2)
    elseif previous_viewport and not changed then
        left, y = old_position.X.Offset, old_position.Y.Offset
    end
    left = clamp(left, 0, max(0, viewport.X - width))
    y = clamp(y, top, max(top, viewport.Y - height - bottom))
    library.mobile_viewport = viewport
    it.main.Size = dim_offset(width, height)
    if changed or it.main.Position ~= dim_offset(left, y) then
        it.main.Position = dim_offset(left, y)
    end
    it.side_frame.Size = dim2(0, side, 1, -footer)
    it.title.Text = compact and win.name:sub(1, 1):upper() or win.name
    it.title.TextSize = compact and 18 or (side < 185 and 13 or 14)
    it.title.TextTruncate = compact and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
    it.title.TextWrapped = not compact
    it.title.TextXAlignment = compact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    it.title.Position = dim_offset(compact and 2 or 11, 0)
    it.title.Size = dim_offset(compact and 24 or side - 44, 44)
    it.button_holder.Position = dim_offset(0, 48)
    it.button_holder.Size = dim2(1, 0, 1, -52)
    if win.sidebar_toggle then
        win.sidebar_toggle.Position = dim2(1, -29, 0, 9)
        win.sidebar_toggle.Text = compact and "+" or "−"
    end
    it.multi_holder.Position = dim_offset(side, 0)
    it.multi_holder.Size = dim2(1, -side, 0, header)
    it.global_fade.Position = dim_offset(side, header)
    it.global_fade.Size = dim2(1, -side, 1, -(header + footer))
    it.info.Size = dim2(1, 0, 0, footer)
    it.game.Visible = false
    it.other_info.Visible = not compact
    it.other_info.TextSize = 11
    for _, child in it.button_holder:GetChildren() do
        if child:IsA("TextLabel") then
            child.Visible = not compact
            child.TextSize = 12
        end
    end
    for _, tab in library.mobile_tabs do
        local t = tab.items
        if t and t.button and t.button.Parent then
            t.name.Visible = not compact
            t.name.TextSize = 13
            t.name.TextWrapped = false
            t.name.TextTruncate = Enum.TextTruncate.AtEnd
            t.name.AutomaticSize = Enum.AutomaticSize.None
            t.name.Size = dim2(1, -48, 1, 0)
            t.name.Position = dim_offset(40, 0)
            t.icon.Visible = not (compact and t.compact_mark)
            t.icon.Position = dim2(0, compact and 15 or 11, 0.5, 0)
            t.icon.Size = dim_offset(compact and 24 or 21, compact and 24 or 21)
            if t.compact_mark then
                t.compact_mark.Visible = compact
                t.compact_mark.Size = dim_offset(28, 28)
            end
            t.button.Size = dim2(1, 0, 0, 39)
            t.tab_holder.Position = dim_offset(side, header)
            t.tab_holder.Size = dim2(1, -side - 6, 1, -(header + footer + 6))
            t.multi_section_button_holder.Size = dim2(1, 0, 1, 0)
        end
    end
    for _, page in library.mobile_pages do
        if page.Parent then
            local layout = page:FindFirstChildOfClass("UIListLayout")
            local padding = page:FindFirstChildOfClass("UIPadding")
            page.Active = true
            page.ScrollingEnabled = true
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.CanvasSize = dim_offset(0, 0)
            page.ScrollBarThickness = 3
            if padding then
                local content_inset = clamp(floor(viewport.X * 0.045), 8, 36)
                padding.PaddingLeft = dim(0, content_inset)
                padding.PaddingRight = dim(0, content_inset)
            end
            if layout then
                layout.FillDirection = Enum.FillDirection.Vertical
                layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
                layout.VerticalFlex = Enum.UIFlexAlignment.None
                layout.Padding = dim(0, 9)
            end
        end
    end
    for _, column in library.mobile_columns do
        if column.Parent then
            column.AutomaticSize = Enum.AutomaticSize.Y
            column.Size = dim2(1, 0, 0, 0)
        end
    end
    for _, sec in library.mobile_sections do
        if sec.outline.Parent then
            local content = max(sec.layout.AbsoluteContentSize.Y + 15, sec.elements.AbsoluteSize.Y)
            local target = max(92, math.ceil(content + 57))
            local new_size = dim2(1, 0, 0, target)
            if sec.outline.Size ~= new_size then sec.outline.Size = new_size end
            sec.scrolling.ScrollingEnabled = false
            sec.scrolling.ScrollBarThickness = 0
            sec.scrolling.AutomaticCanvasSize = Enum.AutomaticSize.None
            sec.scrolling.CanvasSize = dim_offset(0, 0)
            sec.elements.Position = dim_offset(8, 8)
            sec.elements.Size = dim2(1, -16, 0, 0)
            sec.layout.Padding = dim(0, 9)
        end
    end
    if win.mobile_button then
        win.mobile_button.Position = dim2(1, -49, 0, max(8, floor(inset.Y + 7)))
    end
end

function library:queue_mobile_layout()
    if not library.is_mobile or library.unloaded or library.mobile_refresh_pending then return end
    library.mobile_refresh_pending = true
    task.defer(function()
        if not library.unloaded then
            local ok, err = pcall(function() library:refresh_mobile_layout() end)
            if not ok then warn("[Kaeryn] Mobile layout: " .. tostring(err)) end
        end
        library.mobile_refresh_pending = false
    end)
end

function library:mobile_drag(handle, frame)
    local touch
    local origin
    local start
    handle.Active = true
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and not touch then
            touch = input
            origin = input.Position
            start = frame.Position
            library:close_element()
        end
    end)
    library:connection(uis.InputChanged, function(input)
        if input ~= touch then return end
        local view = ws.CurrentCamera.ViewportSize
        local next_x = clamp(start.X.Offset + input.Position.X - origin.X, 0, max(0, view.X - frame.AbsoluteSize.X))
        local next_y = clamp(start.Y.Offset + input.Position.Y - origin.Y, 0, max(0, view.Y - frame.AbsoluteSize.Y))
        frame.Position = dim_offset(next_x, next_y)
    end)
    library:connection(uis.InputEnded, function(input)
        if input == touch then touch = nil end
    end)
end

function library:unload_menu()
    if library.unloaded then return end
    if library.cancel_pointer_drag then library:cancel_pointer_drag() end
    library.unloaded = true
    library.current_open = nil
    for index = #library.connections, 1, -1 do
        local connection = library.connections[index]
        if connection then pcall(function() connection:Disconnect() end) end
        library.connections[index] = nil
    end
    if library.items then library.items:Destroy() end
    if library.other then library.other:Destroy() end
    library.items, library.other, library.mobile_window, library.cache = nil, nil, nil, nil
    table.clear(library.mobile_tabs)
    table.clear(library.mobile_pages)
    table.clear(library.mobile_columns)
    table.clear(library.mobile_sections)
    table.clear(library.notifications.notifs)
    for _, group in pairs(themes.utility) do
        for _, objects in pairs(group) do table.clear(objects) end
    end
end

library.unload = library.unload_menu
end
