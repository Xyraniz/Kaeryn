return function(__kaeryn)
    local insert = __kaeryn.insert
    local remove = __kaeryn.remove
    local dim = __kaeryn.dim
    local library = __kaeryn.library
    local themes = __kaeryn.themes

local function can_map(property, token)
    if property == "BackgroundColor3" then
        return token == "accent" or token == "background" or token == "surface"
            or token == "surface_alt" or token == "surface_hover" or token == "border"
            or token == "success" or token == "warning" or token == "error" or token == "info"
    elseif property == "TextColor3" then
        return token == "accent" or token == "text" or token == "text_soft"
            or token == "muted" or token == "text_muted" or token == "success" or token == "warning" or token == "error" or token == "info"
    elseif property == "BorderColor3" then
        return token == "border"
    elseif property == "ImageColor3" or property == "ScrollBarImageColor3" or property == "Color" then
        return true
    end
    return false
end

local scale_for_property = {
    TextSize = "text_scale",
    CornerRadius = "radius_scale",
    Padding = "density",
    PaddingTop = "density",
    PaddingBottom = "density",
    PaddingLeft = "density",
    PaddingRight = "density",
}

local function scaled_value(value, scale)
    if type(value) == "number" then return value * scale end
    if typeof(value) == "UDim" then return dim(value.Scale * scale, value.Offset * scale) end
    return value
end

function library:track_theme(instance, property, value)
    if not instance or typeof(value) ~= "Color3" then return end
    for token, color_value in pairs(themes.preset) do
        if can_map(property, token) and value == color_value then
            local properties = themes.utility[token]
            properties[property] = properties[property] or {}
            local instances = properties[property]
            for _, tracked in ipairs(instances) do
                if tracked == instance then return end
            end
            insert(instances, instance)
            return
        end
    end
end

function library:apply_theme(instance, theme, property)
    local color_value = themes.preset[theme]
    if typeof(color_value) ~= "Color3" or type(property) ~= "string" then return end
    local properties = themes.utility[theme]
    properties[property] = properties[property] or {}
    local instances = properties[property]
    for _, tracked in ipairs(instances) do
        if tracked == instance then return end
    end
    insert(instances, instance)
end

function library:track_theme_scale(instance, property, value)
    local token = scale_for_property[property]
    if not token or (type(value) ~= "number" and typeof(value) ~= "UDim") then return end
    local records = themes.scale_utility[token]
    for _, record in ipairs(records) do if record.instance == instance and record.property == property then return end end
    insert(records, {instance = instance, property = property, base = value})
    pcall(function() instance[property] = scaled_value(value, themes.scale[token]) end)
end

function library:update_theme(theme, new_color)
    if typeof(new_color) ~= "Color3" or themes.preset[theme] == nil then return false end
    local previous = themes.preset[theme]
    for property_name, instances in pairs(themes.utility[theme]) do
        for index = #instances, 1, -1 do
            local object = instances[index]
            if not object or not object.Parent then
                table.remove(instances, index)
            else
                local ok, current = pcall(function() return object[property_name] end)
                if ok and current == previous then
                    pcall(function() object[property_name] = new_color end)
                end
            end
        end
    end
    themes.preset[theme] = new_color
    return true
end

function library:update_theme_scale(token, scale)
    if themes.scale[token] == nil or type(scale) ~= "number" or scale ~= scale or scale == math.huge or scale == -math.huge then
        return false
    end
    local previous = themes.scale[token]
    for index = #themes.scale_utility[token], 1, -1 do
        local record = themes.scale_utility[token][index]
        if not record.instance or not record.instance.Parent then
            remove(themes.scale_utility[token], index)
        else
            pcall(function() record.instance[record.property] = scaled_value(record.base, scale) end)
        end
    end
    themes.scale[token] = scale
    return previous ~= scale
end

function library:set_theme(palette)
    if type(palette) ~= "table" then return false, "Theme must be a table" end
    for token, color_value in pairs(palette) do
        if themes.preset[token] ~= nil then
            if typeof(color_value) ~= "Color3" then return false, "Theme token '" .. tostring(token) .. "' must be a Color3" end
        elseif themes.scale[token] ~= nil then
            if type(color_value) ~= "number" or color_value ~= color_value or color_value == math.huge or color_value == -math.huge then
                return false, "Theme token '" .. tostring(token) .. "' must be a finite number"
            end
            local limits = {text_scale = {0.75, 1.5}, density = {0.65, 1.5}, radius_scale = {0, 2}, motion_scale = {0, 2}}
            if color_value < limits[token][1] or color_value > limits[token][2] then
                return false, "Theme token '" .. tostring(token) .. "' is outside its supported range"
            end
        else
            return false, "Unknown theme token: " .. tostring(token)
        end
    end
    for token, color_value in pairs(palette) do
        if themes.preset[token] ~= nil then
            library:update_theme(token, color_value)
        elseif token == "motion_scale" then
            themes.scale[token] = color_value
        else
            library:update_theme_scale(token, color_value)
        end
    end
    return true
end
end
