return function(__kaeryn)
    local uis = __kaeryn.uis
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local vec2 = __kaeryn.vec2
    local rgb = __kaeryn.rgb
    local ws = __kaeryn.ws
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts

    local function invoke(callback, ...)
        if type(callback) ~= "function" then return end
        local ok, err = pcall(callback, ...)
        if not ok then warn("[Kaeryn] dialog callback error: " .. tostring(err)) end
    end

    local function open_dialog(kind, options)
        assert(type(options) == "table", "dialog options must be a table")
        assert(library.items and not library.unloaded, "Create a Kaeryn window before opening a dialog")
        if library.active_dialog then library.active_dialog:close(false) end

        local handle = {closed = false, _connections = {}}
        local overlay = library:create("Frame", {
            Parent = library.items,
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = rgb(0, 0, 0),
            BackgroundTransparency = 0.38,
            BorderSizePixel = 0,
            ZIndex = 100,
        })
        local card = library:create("Frame", {
            Parent = overlay,
            AnchorPoint = vec2(0.5, 0.5),
            Position = dim2(0.5, 0, 0.5, 0),
            Size = dim2(0, 420, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = themes.preset.surface,
            BorderSizePixel = 0,
            ZIndex = 101,
        })
        local function resize_card()
            local viewport = (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or vec2(800, 600)
            card.Size = dim2(0, math.min(420, math.max(180, viewport.X - 24)), 0, 0)
        end
        resize_card()
        do
            library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), function()
                if ws.CurrentCamera then
                    library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), resize_card, handle)
                    resize_card()
                end
            end, handle)
            if ws.CurrentCamera then
                library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), resize_card, handle)
            end
        end
        library:create("UICorner", {Parent = card, CornerRadius = dim(0, 8)})
        library:create("UIStroke", {Parent = card, Color = themes.preset.border, Thickness = 1})
        library:create("UIPadding", {Parent = card, PaddingTop = dim(0, 17), PaddingBottom = dim(0, 14), PaddingLeft = dim(0, 17), PaddingRight = dim(0, 17)})
        library:create("UIListLayout", {Parent = card, Padding = dim(0, 9), SortOrder = Enum.SortOrder.LayoutOrder})
        library:apply_theme(card, "surface", "BackgroundColor3")
        library:apply_theme(card:FindFirstChildOfClass("UIStroke"), "border", "Color")

        local title = library:create("TextLabel", {
            Parent = card,
            Size = dim2(1, 0, 0, 23),
            BackgroundTransparency = 1,
            FontFace = fonts.font,
            Text = options.title or (kind == "confirm" and "Confirm" or kind == "prompt" and "Enter a value..." or "Notice"),
            TextColor3 = themes.preset.text,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            ZIndex = 102,
        })
        library:apply_theme(title, "text", "TextColor3")
        local message = library:create("TextLabel", {
            Parent = card,
            Size = dim2(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            FontFace = fonts.small,
            Text = options.message or options.description or "",
            TextColor3 = themes.preset.text_soft,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 2,
            ZIndex = 102,
        })
        library:apply_theme(message, "text_soft", "TextColor3")

        local input
        if kind == "prompt" then
            input = library:create("TextBox", {
                Parent = card,
                Size = dim2(1, 0, 0, 36),
                BackgroundColor3 = themes.preset.surface_alt,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                FontFace = fonts.small,
                PlaceholderText = options.placeholder or "Enter a value...",
                Text = options.default or "",
                TextColor3 = themes.preset.text,
                PlaceholderColor3 = themes.preset.muted,
                TextSize = 14,
                LayoutOrder = 3,
                ZIndex = 102,
            })
            library:create("UICorner", {Parent = input, CornerRadius = dim(0, 5)})
            library:create("UIPadding", {Parent = input, PaddingLeft = dim(0, 9), PaddingRight = dim(0, 9)})
            library:apply_theme(input, "surface_alt", "BackgroundColor3")
            library:apply_theme(input, "text", "TextColor3")
            library:apply_theme(input, "muted", "PlaceholderColor3")
        end

        local actions = library:create("Frame", {
            Parent = card,
            Size = dim2(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = 4,
            ZIndex = 102,
        })
        local action_layout = library:create("UIListLayout", {
            Parent = actions,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = dim(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        local function resize_actions()
            local narrow = card.AbsoluteSize.X < 340
            actions.Size = dim2(1, 0, 0, narrow and 70 or 34)
            action_layout.FillDirection = narrow and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
            action_layout.Padding = dim(0, narrow and 4 or 8)
            for _, child in ipairs(actions:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = narrow and dim2(1, 0, 0, 32) or dim2(0, 92, 0, 32)
                end
            end
        end
        library:connection(card:GetPropertyChangedSignal("AbsoluteSize"), resize_actions, handle)

        local function finish(confirmed)
            if handle.closed then return false end
            handle.closed = true
            if library.active_dialog == handle then library.active_dialog = nil end
            for _, connection in ipairs(handle._connections) do connection:Disconnect() end
            overlay:Destroy()
            local value = kind == "prompt" and (confirmed and input.Text or nil) or (kind == "alert" and true or confirmed)
            if confirmed then
                invoke(options.on_confirm or options.callback, value)
            elseif kind ~= "alert" then
                invoke(options.on_cancel, value)
            end
            return true
        end
        handle.close = finish
        local function connect(signal, callback)
            library:connection(signal, callback, handle)
        end
        local function make_button(text, primary, callback)
            local button = library:create("TextButton", {
                Parent = actions,
                Size = dim2(0, 92, 0, 32),
                BackgroundColor3 = primary and themes.preset.accent or themes.preset.surface_hover,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                FontFace = fonts.small,
                Text = text,
                TextColor3 = themes.preset.text,
                TextSize = 13,
                ZIndex = 103,
            })
            library:create("UICorner", {Parent = button, CornerRadius = dim(0, 5)})
            if primary then library:apply_theme(button, "accent", "BackgroundColor3") else library:apply_theme(button, "surface_hover", "BackgroundColor3") end
            library:apply_theme(button, "text", "TextColor3")
            connect(button.Activated, callback)
            return button
        end

        if kind ~= "alert" then make_button(options.cancel_text or "Cancel", false, function() finish(false) end) end
        make_button(options.confirm_text or (kind == "alert" and "OK" or "Confirm"), true, function() finish(true) end)
        resize_actions()
        connect(uis.InputBegan, function(input_event, processed)
            if processed or handle.closed then return end
            if input_event.KeyCode == Enum.KeyCode.Escape then
                finish(false)
            elseif input_event.KeyCode == Enum.KeyCode.Return and input then
                finish(true)
            end
        end)
        if input then connect(input.FocusLost, function(enter_pressed) if enter_pressed then finish(true) end end) end

        library:close_element()
        library.active_dialog = handle
        handle.overlay = overlay
        if input then input:CaptureFocus() end
        return handle
    end

    function library:alert(options)
        return open_dialog("alert", options)
    end

    function library:confirm(options)
        return open_dialog("confirm", options)
    end

    function library:prompt(options)
        return open_dialog("prompt", options)
    end
end
