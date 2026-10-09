return function(__kaeryn)
    local insert = __kaeryn.insert
    local library = __kaeryn.library
    local themes = __kaeryn.themes

local function can_map(property, token)
    if property == "BackgroundColor3" then
        return token == "accent" or token == "background" or token == "surface"
            or token == "surface_alt" or token == "surface_hover" or token == "border"
    elseif property == "TextColor3" then
        return token == "accent" or token == "text" or token == "text_soft"
            or token == "muted" or token == "text_muted"
    elseif property == "BorderColor3" then
        return token == "border"
    elseif property == "ImageColor3" or property == "ScrollBarImageColor3" or property == "Color" then
        return true
    end
    return false
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

function library:set_theme(palette)
    if type(palette) ~= "table" then return false, "Theme must be a table" end
    for token, color_value in pairs(palette) do
        if themes.preset[token] == nil then return false, "Unknown theme token: " .. tostring(token) end
        if typeof(color_value) ~= "Color3" then return false, "Theme token '" .. tostring(token) .. "' must be a Color3" end
    end
    for token, color_value in pairs(palette) do
        library:update_theme(token, color_value)
    end
    return true
end
end
