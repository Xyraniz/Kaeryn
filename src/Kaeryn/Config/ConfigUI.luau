return function(__kaeryn)
    local color = __kaeryn.color
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local ensure_folder = __kaeryn.ensure_folder
    local has_file = __kaeryn.has_file
    local read_file = __kaeryn.read_file
    local write_file = __kaeryn.write_file
    local config_name = __kaeryn.config_name
    local config_path = __kaeryn.config_path
    local flags = __kaeryn.flags
    local notifications = __kaeryn.notifications

function library:init_config(window)
    window:separator({name = "Settings"})
    local main = window:tab({name = "Configs", tabs = {"Main"}})
    local left = main:column({})
    local list_section = left:section({name = "Configs", size = 1, default = true, icon = "rbxassetid://139628202576511"})
    __kaeryn.config_holder = list_section:list({options = {}, flag = "config_name_list"})

    local right = main:column({})
    local section = right:section({name = "Settings", side = "right", size = 1, default = true, icon = "rbxassetid://129380150574313"})
    section:textbox({name = "Config name:", flag = "config_name_text"})

    local function notice(message)
        if not library.unloaded then notifications:create_notification({name = "Configs", info = message}) end
    end
    section:button({name = "Save", callback = function()
        local selected = config_name(flags.config_name_text) or config_name(flags.config_name_list)
        local path = config_path(selected)
        if not path then notice("Enter a configuration name first") return end
        if not ensure_folder(library.directory) or not ensure_folder(library.directory .. "/configs") then
            notice("Cannot create configuration folder") return
        end
        local ok, data = pcall(function() return library:get_config() end)
        if not ok then notice("Cannot encode config: " .. tostring(data)) return end
        local wrote, err = write_file(path, data)
        if not wrote then notice("Save failed: " .. tostring(err)) return end
        library:update_config_list()
        notice("Saved config: " .. selected)
    end})
    section:button({name = "Load", callback = function()
        local selected = config_name(flags.config_name_list) or config_name(flags.config_name_text)
        local path = config_path(selected)
        local content = path and read_file(path)
        if not content then notice("Select an existing configuration") return end
        local ok, err = library:load_config(content)
        notice(ok and ("Loaded config: " .. selected) or ("Load failed: " .. tostring(err)))
    end})
    section:button({name = "Delete", callback = function()
        local selected = config_name(flags.config_name_list) or config_name(flags.config_name_text)
        local path = config_path(selected)
        if not path or not has_file(path) or type(delfile) ~= "function" then
            notice("Select an existing configuration") return
        end
        local ok, err = pcall(delfile, path)
        if not ok then notice("Delete failed: " .. tostring(err)) return end
        library:update_config_list()
        notice("Deleted config: " .. selected)
    end})
    section:colorpicker({name = "Menu Accent", callback = function(accent) library:update_theme("accent", accent) end, color = themes.preset.accent})
    section:keybind({name = "Menu Bind", callback = function(enabled) window.toggle_menu(enabled) end, default = true})
    library:update_config_list()
end
end
