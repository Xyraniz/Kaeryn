return function(__kaeryn)
    local uis = __kaeryn.uis
    local ws = __kaeryn.ws
    local tween_service = __kaeryn.tween_service
    local dim2 = __kaeryn.dim2
    local rgb = __kaeryn.rgb
    local camera = __kaeryn.camera
    local mouse = __kaeryn.mouse
    local max = __kaeryn.max
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local insert = __kaeryn.insert
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local used_flags = library.used_flags

function library:tween(obj, properties, easing_style, time)
    if library.unloaded or not obj then return nil end
    for property, value in pairs(properties) do
        if typeof(value) == "Color3" and library.track_theme then
            library:track_theme(obj, property, value)
        end
    end
    local tween = tween_service:Create(obj, TweenInfo.new(time or 0.25, easing_style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), properties)
    tween:Play()
    return tween
end

function library:resizify(frame)
    local Frame = Instance.new("TextButton")
    Frame.Position = dim2(1, -10, 1, -10)
    Frame.BorderColor3 = rgb(0, 0, 0)
    Frame.Size = dim2(0, 10, 0, 10)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = rgb(255, 255, 255)
    Frame.Parent = frame
    Frame.BackgroundTransparency = 1
    Frame.Text = ""

    local resizing = false
    local start_size
    local start
    local og_size = frame.Size

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)

    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport = (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or camera.ViewportSize
            local viewport_x = viewport.X
            local viewport_y = viewport.Y

            local current_size = dim2(
                start_size.X.Scale,
                math.clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    min(og_size.X.Offset, viewport_x),
                    viewport_x
                ),
                start_size.Y.Scale,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    min(og_size.Y.Offset, viewport_y),
                    viewport_y
                )
            )

            library:tween(frame, {Size = current_size}, Enum.EasingStyle.Linear, 0.05)
        end
    end)
end

function library:next_flag()
    repeat
        library.flag_counter += 1
    until flags["flagnumber" .. library.flag_counter] == nil and used_flags["flagnumber" .. library.flag_counter] == nil
    return "flagnumber" .. library.flag_counter
end

function library:resolve_flag(flag, name, kind, owner_name)
    local resolved = flag
    if resolved == nil then
        if type(name) ~= "string" or name:gsub("%s", "") == "" then
            error("unnamed " .. tostring(kind) .. " needs options.name or options.flag for a stable config key", 2)
        else
            local function slug(value)
                local normalized = string.lower(value):gsub("[^%w]+", "."):gsub("^%.+", ""):gsub("%.+$", "")
                return normalized
            end
            local parts = {slug(tostring(kind or "control"))}
            if type(owner_name) == "string" and owner_name:gsub("%s", "") ~= "" then
                table.insert(parts, slug(owner_name))
            end
            table.insert(parts, slug(name))
            resolved = table.concat(parts, ".")
        end
    end
    if type(resolved) ~= "string" or resolved:gsub("%s", "") == "" then
        error("Kaeryn flags must be non-empty strings", 2)
    end
    if used_flags[resolved] then
        local message = "duplicate flag '" .. resolved .. "'; pass a unique options.flag (for example 'aim.enabled')"
        warn("[Kaeryn] " .. message)
        error(message, 2)
    end
    used_flags[resolved] = true
    return resolved
end

function library:register_config_flag(flag, setter, validator)
    assert(type(flag) == "string" and used_flags[flag], "Kaeryn config flag was not reserved")
    assert(type(setter) == "function", "Kaeryn config setter must be a function")
    assert(type(validator) == "function", "Kaeryn config validator must be a function")
    assert(config_flags[flag] == nil, "Kaeryn config setter already exists for flag '" .. flag .. "'")
    config_flags[flag] = setter
    library.config_validators[flag] = validator
end

function library:mouse_in_frame(uiobject)
    local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
    local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

    return (y_cond and x_cond)
end

function library:draggify(frame)
    local dragging = false
    local start_size = frame.Position
    local start

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            start_size = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport = (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or camera.ViewportSize
            local viewport_x = viewport.X
            local viewport_y = viewport.Y

            local current_position = dim2(
                0,
                clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    0,
                    max(0, viewport_x - frame.AbsoluteSize.X)
                ),
                0,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    0,
                    max(0, viewport_y - frame.AbsoluteSize.Y)
                )
            )

            library:tween(frame, {Position = current_position}, Enum.EasingStyle.Linear, 0.05)
            library:close_element()
        end
    end)
end

function library:convert(str)
    if type(str) ~= "string" then return end
    local values = {}

    for value in string.gmatch(str, "[^,]+") do
        local number = tonumber(value)
        if not number or number ~= number or number == math.huge or number == -math.huge then return end
        insert(values, number)
    end

    if #values == 4 then
        return unpack(values)
    else
        return
    end
end

function library:convert_enum(enum)
    if typeof(enum) == "EnumItem" then return enum end
    if type(enum) ~= "string" then return nil end
    local category, item = enum:match("^Enum%.([%w_]+)%.([%w_]+)$")
    if not category or not item then return nil end
    local ok, result = pcall(function() return Enum[category][item] end)
    return ok and result or nil
end
end
