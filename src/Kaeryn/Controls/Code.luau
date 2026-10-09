return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local highlighter = require("./Highlighter")

local theme_tokens = {keyword = true, builtin = true, literal = true, number = true, string = true,
    comment = true, operator = true, call = true, property = true, text = true}

function library:code(options)
    options = library:normalize_options("code", options)
    local id = library:resolve_identity(options, "code", self.name, false)
    local code_theme = table.clone(options.code_theme or {})
    for token, color in pairs(code_theme) do
        assert(theme_tokens[token], "Unknown code_theme token '" .. tostring(token) .. "'")
        assert(typeof(color) == "Color3", "code_theme." .. token .. " must be a Color3")
    end

    local cfg = {
        id = id,
        control_type = "code",
        name = options.name,
        code = options.code,
        value = options.code,
        code_size = options.code_size,
        height = options.height,
        code_theme = code_theme,
        can_copy = options.can_copy,
        on_copy = options.on_copy,
        items = {},
    }
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundColor3 = themes.preset.surface_alt,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = dim2(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    library:apply_theme(items.root, "surface_alt", "BackgroundColor3")
    library:create("UICorner", {Parent = items.root, CornerRadius = dim(0, 6)})
    local outline = library:create("UIStroke", {
        Parent = items.root,
        Color = themes.preset.border,
        Thickness = 1,
        Transparency = 0.2,
    })
    library:apply_theme(outline, "border", "Color")
    library:create("UIListLayout", {Parent = items.root, Padding = dim(0, 0), SortOrder = Enum.SortOrder.LayoutOrder})

    items.header = library:create("Frame", {
        Parent = items.root,
        BackgroundColor3 = themes.preset.surface,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, 32),
        LayoutOrder = 1,
    })
    library:apply_theme(items.header, "surface", "BackgroundColor3")

    items.title = library:create("TextLabel", {
        Parent = items.header,
        BackgroundTransparency = 1,
        FontFace = __kaeryn.fonts.small,
        Text = cfg.name,
        TextColor3 = themes.preset.text_soft,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = dim2(1, cfg.can_copy and -48 or -16, 1, 0),
        Position = dim2(0, 10, 0, 0),
    })
    library:apply_theme(items.title, "text_soft", "TextColor3")

    if cfg.can_copy then
        items.copy = library:create("ImageButton", {
            Parent = items.header,
            AnchorPoint = vec2(1, 0.5),
            Position = dim2(1, -7, 0.5, 0),
            Size = dim2(0, 24, 0, 24),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Image = "lucide:copy",
            ImageColor3 = themes.preset.muted,
            ImageTransparency = 0.1,
        })
        library:apply_theme(items.copy, "muted", "ImageColor3")
    end

    items.body = library:create("ScrollingFrame", {
        Parent = items.root,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, cfg.height or 0),
        AutomaticSize = cfg.height == nil and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
        CanvasSize = dim2(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.XY,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = themes.preset.muted,
        LayoutOrder = 2,
    })

    library:create("UIPadding", {
        Parent = items.body,
        PaddingTop = dim(0, 9),
        PaddingBottom = dim(0, 9),
        PaddingLeft = dim(0, 10),
        PaddingRight = dim(0, 10),
    })

    items.text = library:create("TextLabel", {
        Parent = items.body,
        BackgroundTransparency = 1,
        FontFace = Font.fromEnum(Enum.Font.Code),
        RichText = true,
        Text = "",
        TextColor3 = themes.preset.text_soft,
        TextSize = cfg.code_size,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = dim2(0, 0, 0, 0),
    })
    library:apply_theme(items.text, "text_soft", "TextColor3")

    local function render_code()
        items.text.Text = highlighter(cfg.code, cfg.code_theme)
    end

    function cfg.set(source)
        if type(source) ~= "string" then return false, "code must be a string" end
        cfg.code = source
        cfg.value = source
        render_code()
        return true
    end

    if items.copy then
        items.copy.Activated:Connect(function()
            local copied = false
            if type(setclipboard) == "function" then copied = pcall(setclipboard, cfg.code) end
            if not copied and type(toclipboard) == "function" then copied = pcall(toclipboard, cfg.code) end
            if type(cfg.on_copy) == "function" then
                local metadata = {source = "user", phase = "commit", id = cfg.id, name = cfg.name, type = cfg.control_type}
                local callback_ok, callback_result = pcall(cfg.on_copy, cfg.code, copied, metadata)
                if not callback_ok then
                    warn("[Kaeryn] callback failed during user/commit for '" .. tostring(cfg.name)
                        .. "' (id " .. cfg.id .. "): " .. tostring(callback_result))
                else
                    copied = copied or callback_result == true
                end
            end
            items.copy.Image = library:resolve_icon(copied and "lucide:check" or "lucide:clipboard-x")
            items.copy.ImageColor3 = copied and themes.preset.success or themes.preset.warning
            task.delay(1, function()
                if cfg._destroyed or not items.copy.Parent then return end
                items.copy.Image = library:resolve_icon("lucide:copy")
                items.copy.ImageColor3 = themes.preset.muted
            end)
        end)
    end

    render_code()
    library:attach_control(cfg, items.root, self)
    function cfg:SetCode(source)
        return self:Set(source)
    end
    return setmetatable(cfg, library)
end
end
