return function(context, lucide_icons)
    local library = context.library
    local packs = {lucide = lucide_icons}

    function library:register_icon_pack(name, icons)
        assert(type(name) == "string" and name:match("^[%w_-]+$"), "icon pack name must be an identifier")
        assert(type(icons) == "table", "icon pack must be a table")
        packs[string.lower(name)] = icons
        return true
    end

    function library:resolve_icon(value)
        assert(type(value) == "string" and value ~= "", "icon must be a non-empty string")
        if value:match("^rbxassetid://%d+$") or value:match("^https?://") then return value end

        local pack_name, icon_name = value:match("^([%w_-]+):([%w_-]+)$")
        if not pack_name then pack_name, icon_name = "lucide", value end
        local pack = packs[string.lower(pack_name)]
        assert(pack, "Unknown icon pack '" .. pack_name .. "'")
        local asset = pack[icon_name]
        assert(type(asset) == "string" and asset:match("^rbxassetid://%d+$"), "Unknown icon '" .. value .. "'")
        return asset
    end

    library.icon_packs = packs
end
