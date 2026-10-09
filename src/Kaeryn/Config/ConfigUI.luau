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
    local list_section = left:section({name = "Configs", default = true, icon = "lucide:folder-open"})
    __kaeryn.config_holder = list_section:list({options = {}, flag = "config_name_list"})

    local right = main:column({})
    local section = right:section({name = "Settings", side = "right", default = true, icon = "lucide:settings"})
    section:textbox({name = "Config name:", flag = "config_name_text"})
    local config_sections = {list = list_section, settings = section}

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
        local ok, preview = library:preview_config(content)
        if not ok then notice("Load failed: " .. tostring(preview)) return end
        local changed_flags = {}
        for index = 1, math.min(#preview.changes, 5) do
            changed_flags[index] = preview.changes[index].flag
        end
        local message = #preview.changes == 0 and "This config will not change any control values."
            or ("This config will change " .. tostring(#preview.changes) .. " control values.")
        if #preview.migrations > 0 then message ..= "\n" .. tostring(#preview.migrations) .. " old flags will be migrated." end
        if #changed_flags > 0 then message ..= "\n\n" .. table.concat(changed_flags, "\n") end
        if #preview.changes > #changed_flags then message ..= "\n...and " .. tostring(#preview.changes - #changed_flags) .. " more." end
        library:confirm({
            title = "Load configuration?",
            message = message,
            confirm_text = "Load",
            on_confirm = function(accepted)
                if not accepted then return end
                local loaded, migrations = library:load_config(content)
                if not loaded then notice("Load failed: " .. tostring(migrations))
                else notice("Loaded config: " .. selected) end
            end,
        })
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
    return config_sections
end
end
