local __kaeryn_modules = {
    ["src/Kaeryn/Bootstrap.luau"] = function(__kaeryn_require)
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()

local max = math.max
local floor = math.floor
local min = math.min
local abs = math.abs
local noise = math.noise
local rad = math.rad
local random = math.random
local pow = math.pow
local sin = math.sin
local pi = math.pi
local tan = math.tan
local atan2 = math.atan2
local clamp = math.clamp

local insert = table.insert
local find = table.find
local remove = table.remove
local concat = table.concat

local library = {
    directory = "kaeryn",
    folders = {
        "/fonts",
        "/configs",
    },
    flags = {},
    config_flags = {},
    config_validators = {},
    used_flags = {},
    connections = {},
    notifications = {notifs = {}},
    current_open;
    unloaded = false;
    flag_counter = 0;
}

local themes = {
    preset = {
        accent = rgb(155, 150, 219),
        background = rgb(14, 14, 16),
        surface = rgb(22, 22, 24),
        surface_alt = rgb(25, 25, 29),
        surface_hover = rgb(33, 33, 35),
        border = rgb(23, 23, 29),
        text = rgb(255, 255, 255),
        text_soft = rgb(245, 245, 245),
        muted = rgb(130, 130, 130),
        text_muted = rgb(72, 72, 73),
        success = rgb(91, 190, 129),
        warning = rgb(232, 174, 78),
        error = rgb(227, 91, 91),
        info = rgb(113, 165, 235),
    },

    utility = {
        accent = {}, background = {}, surface = {}, surface_alt = {},
        surface_hover = {}, border = {}, text = {}, text_soft = {},
        muted = {}, text_muted = {}, success = {}, warning = {}, error = {}, info = {},
    },
    scale = {text_scale = 1, density = 1, radius_scale = 1, motion_scale = 1},
    scale_utility = {text_scale = {}, density = {}, radius_scale = {}, motion_scale = {}},
}

local keys = {
    [Enum.KeyCode.LeftShift] = "LS",
    [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC",
    [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS",
    [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent",
    [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1",
    [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3",
    [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5",
    [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7",
    [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9",
    [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~",
    [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]",
    [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(",
    [Enum.KeyCode.Semicolon] = ";",
    [Enum.KeyCode.Quote] = "'",
    [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/",
    [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}

library.__index = library

function library:round(number, interval)
    if type(number) ~= "number" then return 0 end
    if type(interval) ~= "number" or interval <= 0 then interval = 1 end
    local multiplier = 1 / interval
    return floor(number * multiplier + 0.5) / multiplier
end

library.is_mobile = uis.TouchEnabled and (not uis.MouseEnabled or not uis.KeyboardEnabled)
library.mobile_tabs = {}
library.mobile_columns = {}
library.mobile_pages = {}
library.mobile_sections = {}

local function ensure_folder(path)
    if type(isfolder) == "function" then
        local ok, result = pcall(isfolder, path)
        if ok and result then return true end
    end
    if type(makefolder) ~= "function" then return false end
    local ok = pcall(makefolder, path)
    if not ok and type(isfolder) == "function" then
        local exists, result = pcall(isfolder, path)
        return exists and result
    end
    return ok
end

local function has_file(path)
    if type(isfile) ~= "function" then return false end
    local ok, exists = pcall(isfile, path)
    return ok and exists
end

local function read_file(path)
    if not has_file(path) or type(readfile) ~= "function" then return nil end
    local ok, content = pcall(readfile, path)
    return ok and type(content) == "string" and content or nil
end

local function write_file(path, content)
    if type(writefile) ~= "function" then return false, "writefile unavailable" end
    local ok, err = pcall(writefile, path, content)
    if not ok then return false, tostring(err) end
    if err == false then return false, "writefile returned false" end
    return true
end

local function safe_callback(callback, ...)
    if type(callback) ~= "function" then return end
    local ok, result = pcall(callback, ...)
    if not ok then warn("[Kaeryn] callback error: " .. tostring(result)) end
    return ok, result
end

local function config_name(value)
    if type(value) ~= "string" then return nil end
    local name = value:match("^%s*(.-)%s*$")
    if not name or name == "" then return nil end
    name = name:gsub("%.cfg$", "")
    name = name:gsub("[^%w%._%-]", "_"):sub(1, 64)
    if name == "" or name == "." or name == ".." then return nil end
    return name
end

local function separator_option(options, default)
    if options.separator ~= nil then return options.separator end
    if options.seperator ~= nil then return options.seperator end
    if options.Seperator ~= nil then return options.Seperator end
    return default
end

local function config_path(value)
    local name = config_name(value)
    return name and (library.directory .. "/configs/" .. name .. ".cfg") or nil
end

library.filesystem_available = ensure_folder(library.directory)
for _, path in ipairs(library.folders) do
    library.filesystem_available = ensure_folder(library.directory .. path) and library.filesystem_available
end

local flags = library.flags
local config_flags = library.config_flags
local notifications = library.notifications

local fonts = {
    small = Font.fromEnum(Enum.Font.Gotham),
    font = Font.fromEnum(Enum.Font.GothamBold)
}

do
    local function register_font(name, weight, file_name, url)
        if not library.filesystem_available or type(getcustomasset) ~= "function" then return nil end
        local ttf = library.directory .. "/fonts/" .. file_name
        local manifest = library.directory .. "/fonts/" .. name .. ".font"
        if not has_file(ttf) then
            local ok, content = pcall(function() return game:HttpGet(url) end)
            if not ok or type(content) ~= "string" or #content < 100 then return nil end
            local wrote = write_file(ttf, content)
            if not wrote then return nil end
        end
        local ok, asset = pcall(getcustomasset, ttf)
        if not ok or type(asset) ~= "string" then return nil end
        local data = {name = name, faces = {{name = "Normal", weight = weight, style = "Normal", assetId = asset}}}
        local encoded_ok, encoded = pcall(function() return http_service:JSONEncode(data) end)
        if not encoded_ok then return nil end
        local existing = read_file(manifest)
        if existing ~= encoded then
            if not write_file(manifest, encoded) then return nil end
        end
        local custom_ok, font_asset = pcall(getcustomasset, manifest)
        return custom_ok and font_asset or nil
    end

    local medium = register_font("Medium", 500, "Medium.ttf", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-Medium.ttf")
    local semibold = register_font("SemiBold", 600, "SemiBold.ttf", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-SemiBold.ttf")
    if medium then
        local ok, face = pcall(Font.new, medium, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        if ok then fonts.small = face end
    end
    if semibold then
        local ok, face = pcall(Font.new, semibold, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        if ok then fonts.font = face end
    end
end
return {
    uis = uis,
    players = players,
    ws = ws,
    rs = rs,
    http_service = http_service,
    gui_service = gui_service,
    lighting = lighting,
    run = run,
    stats = stats,
    coregui = coregui,
    debris = debris,
    tween_service = tween_service,
    sound_service = sound_service,
    vec2 = vec2,
    vec3 = vec3,
    dim2 = dim2,
    dim = dim,
    rect = rect,
    cfr = cfr,
    empty_cfr = empty_cfr,
    point_object_space = point_object_space,
    angle = angle,
    dim_offset = dim_offset,
    color = color,
    rgb = rgb,
    hex = hex,
    hsv = hsv,
    rgbseq = rgbseq,
    rgbkey = rgbkey,
    numseq = numseq,
    numkey = numkey,
    camera = camera,
    lp = lp,
    mouse = mouse,
    max = max,
    floor = floor,
    min = min,
    abs = abs,
    noise = noise,
    rad = rad,
    random = random,
    pow = pow,
    sin = sin,
    pi = pi,
    tan = tan,
    atan2 = atan2,
    clamp = clamp,
    insert = insert,
    find = find,
    remove = remove,
    concat = concat,
    library = library,
    themes = themes,
    keys = keys,
    ensure_folder = ensure_folder,
    has_file = has_file,
    read_file = read_file,
    write_file = write_file,
    safe_callback = safe_callback,
    config_name = config_name,
    separator_option = separator_option,
    config_path = config_path,
    flags = flags,
    config_flags = config_flags,
    config_validators = library.config_validators,
    notifications = notifications,
    fonts = fonts,
}

    end,
    ["src/Kaeryn/Config/ConfigManager.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local http_service = __kaeryn.http_service
    local hex = __kaeryn.hex
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local config_validators = __kaeryn.config_validators

local function copy_value(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, item in pairs(value) do copy[key] = copy_value(item) end
    return copy
end

function library:update_config_list()
    local config_holder = __kaeryn.config_holder
    if not config_holder or type(listfiles) ~= "function" or not library.filesystem_available then return end
    local ok, files = pcall(listfiles, library.directory .. "/configs")
    if not ok or type(files) ~= "table" then return end
    local result, seen = {}, {}
    for _, file in ipairs(files) do
        if type(file) == "string" then
            local basename = file:gsub("\\", "/"):match("([^/]+)$")
            local name = basename and basename:match("^(.*)%.cfg$")
            if name and not seen[name] then
                seen[name] = true
                table.insert(result, name)
            end
        end
    end
    table.sort(result)
    config_holder.refresh_options(result)
end

function library:get_config()
    local data = {}
    for key, value in pairs(flags) do
        if key ~= "config_name_list" and key ~= "config_name_text" then
            if type(value) == "table" and value.key ~= nil then
                data[key] = {active = value.active == true, mode = value.mode, key = tostring(value.key)}
            elseif type(value) == "table" and typeof(value.Color) == "Color3" then
                data[key] = {Transparency = value.Transparency or 0, Color = value.Color:ToHex()}
            else
                data[key] = value
            end
        end
    end
    return http_service:JSONEncode(data)
end

local function values_equal(first, second)
    if type(first) ~= type(second) then return false end
    if type(first) ~= "table" then return first == second end
    for key, value in pairs(first) do
        if not values_equal(value, second[key]) then return false end
    end
    for key in pairs(second) do
        if first[key] == nil then return false end
    end
    return true
end

local function prepare_config(self, config_json)
    local ok, data = pcall(function() return http_service:JSONDecode(config_json) end)
    if not ok or type(data) ~= "table" then return false, "Invalid configuration JSON" end

    local keys, errors = {}, {}
    for key in pairs(data) do
        if type(key) ~= "string" then
            table.insert(errors, "configuration keys must be strings")
        else
            table.insert(keys, key)
        end
    end
    table.sort(keys)

    local migrated, migration_sources, applied_keys = {}, {}, {}
    for _, source_key in ipairs(keys) do
        local target_key = source_key
        local visited = {}
        while self.flag_migrations[target_key] do
            if visited[target_key] then
                table.insert(errors, source_key .. ": cyclic flag migration")
                break
            end
            visited[target_key] = true
            target_key = self.flag_migrations[target_key]
        end
        if migration_sources[target_key] then
            table.insert(errors, "both '" .. migration_sources[target_key] .. "' and '" .. source_key .. "' resolve to '" .. target_key .. "'")
        else
            migration_sources[target_key] = source_key
            migrated[target_key] = data[source_key]
            if source_key ~= target_key then table.insert(applied_keys, {from = source_key, to = target_key}) end
        end
    end
    if #errors > 0 then return false, table.concat(errors, "; ") end
    data = migrated
    table.sort(applied_keys, function(first, second) return first.from < second.from end)

    local validation_keys = {}
    for key in pairs(data) do table.insert(validation_keys, key) end
    table.sort(validation_keys)
    local staged = {}
    for _, key in ipairs(validation_keys) do
        local setter = config_flags[key]
        if not setter then
            table.insert(errors, key .. ": unknown config flag")
        else
            local validator = config_validators[key]
            if type(validator) ~= "function" then
                table.insert(errors, key .. ": no validator is registered")
            else
                local call_ok, valid, normalized, reason = pcall(validator, data[key])
                if not call_ok then
                    table.insert(errors, key .. ": validator failed: " .. tostring(valid))
                elseif valid == true then
                    table.insert(staged, {key = key, value = normalized})
                else
                    table.insert(errors, key .. ": " .. tostring(reason or normalized or "invalid value"))
                end
            end
        end
    end
    if #errors > 0 then return false, table.concat(errors, "; ") end

    local changes = {}
    for _, entry in ipairs(staged) do
        local before = copy_value(flags[entry.key])
        if not values_equal(before, entry.value) then
            table.insert(changes, {flag = entry.key, before = before, after = copy_value(entry.value)})
        end
    end
    table.sort(changes, function(first, second) return first.flag < second.flag end)
    return true, {staged = staged, migrations = applied_keys, changes = changes}
end

function library:preview_config(config_json)
    local ok, prepared = prepare_config(self, config_json)
    if not ok then return false, prepared end
    return true, {changes = prepared.changes, migrations = prepared.migrations}
end

function library:load_config(config_json)
    local ok, prepared = prepare_config(self, config_json)
    if not ok then return false, prepared end

    local applied = {}
    for _, entry in ipairs(prepared.staged) do
        local key, value = entry.key, entry.value
        local snapshot = copy_value(flags[key])
        table.insert(applied, {key = key, value = snapshot})
        local succeeded, err = pcall(function()
            library:with_change_context("config", "commit", function()
                if type(value) == "table" and type(value.Color) == "string" then
                    config_flags[key](hex(value.Color), value.Transparency)
                else
                    config_flags[key](value)
                end
            end)
        end)
        if not succeeded then
            local rollback_errors = {}
            for index = #applied, 1, -1 do
                local prior = applied[index]
                local restored, restore_err = pcall(function()
                    library:with_change_context("config", "rollback", config_flags[prior.key], prior.value)
                end)
                if not restored then table.insert(rollback_errors, prior.key .. ": " .. tostring(restore_err)) end
            end
            local message = key .. ": setter failed: " .. tostring(err)
            if #rollback_errors > 0 then
                message ..= "; rollback failed: " .. table.concat(rollback_errors, ", ")
            end
            return false, message
        end
    end
    return true, prepared.migrations
end
end

    end,
    ["src/Kaeryn/Config/ConfigUI.luau"] = function(__kaeryn_require)
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
    local list_section = left:section({name = "Configs", size = 1, default = true, icon = "lucide:folder-open"})
    __kaeryn.config_holder = list_section:list({options = {}, flag = "config_name_list"})

    local right = main:column({})
    local section = right:section({name = "Settings", side = "right", size = 1, default = true, icon = "lucide:settings"})
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
end
end

    end,
    ["src/Kaeryn/Controls/Button.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts

function library:button(options)
    options = library:normalize_options("button", options)
    local id = library:resolve_identity(options, "button", self.name, false)
    local cfg = {
        id = id,
        control_type = "button",
        name = options.name or "TextBox",
        callback = options.callback or function() end,
        items = {};
    }

    local items = cfg.items; do
        items[ "button_element" ] = library:create( "Frame" , {
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = items[ "button_element" ];
            Name = "\0";
            Position = dim2(1, -4, 0, 0);
            Size = dim2(1, -8, 0, 30);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 3)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "name" ], "accent", "TextColor3");
    end

    items[ "button" ].MouseButton1Click:Connect(function()
        library:dispatch_control_callback(cfg, cfg.callback, nil)

        items[ "name" ].TextColor3 = themes.preset.accent
        library:tween(items[ "name" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    library:attach_control(cfg, items.button_element, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Colorpicker.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local uis = __kaeryn.uis
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local color = __kaeryn.color
    local rgb = __kaeryn.rgb
    local hsv = __kaeryn.hsv
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local numseq = __kaeryn.numseq
    local numkey = __kaeryn.numkey
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:colorpicker(options)
    options = library:normalize_options("colorpicker", options)
    local id, flag = library:resolve_identity(options, "colorpicker", self.name, true)
    local cfg = {
        id = id,
        control_type = "colorpicker",
        name = options.name or "Color",
        flag = flag,
        legacy_flags = options.legacy_flags,

        color = options.color or color(1, 1, 1),
        alpha = options.alpha and 1 - options.alpha or 0,

        open = false,
        callback = options.callback or function() end,
        on_commit = options.on_commit,
        info = options.info,
        items = {};

        separator = options.separator;
    }

    local dragging_sat = false
    local dragging_hue = false
    local dragging_alpha = false

    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha

    flags[cfg.flag] = {Color = cfg.color, Transparency = cfg.alpha}

    local label;
    if not self.items.right_components then
        label = self:label({name = cfg.name, info = cfg.info, separator = cfg.separator})
    end

    local items = cfg.items; do
        items[ "colorpicker" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = label and label.items.right_components or self.items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim_offset(library.is_mobile and 36 or 16, library.is_mobile and 36 or 16);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(54, 31, 184)
        });

        if library.is_mobile and label then
            label.items.right_components.Size = dim_offset(40, 40)
            label.items.name.Size = dim2(1, -52, 0, 0)
        end

        library:create( "UICorner" , {
            Parent = items[ "colorpicker" ];
            CornerRadius = dim(0, 4)
        });

        items[ "colorpicker_inline" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker" ];
            AnchorPoint = vec2(0.5, 0.5);
            Position = dim2(0.5, 0, 0.5, 0);
            Size = dim_offset(library.is_mobile and 26 or 14, library.is_mobile and 26 or 14);
            Name = "\0";
            BorderMode = Enum.BorderMode.Inset;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(54, 31, 184)
        });

        library:create( "UICorner" , {
            Parent = items[ "colorpicker_inline" ];
            CornerRadius = dim(0, 4)
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
            Parent = items[ "colorpicker_inline" ]
        });

        items[ "colorpicker_holder" ] = library:create( "Frame" , {
            Parent = library[ "other" ];
            Name = "\0";
            Position = dim2(0.20000000298023224, 20, 0.296999990940094, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 166, 0, 197);
            BorderSizePixel = 0;
            Visible = true;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "colorpicker_fade" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            BackgroundTransparency = 0;
            Position = dim2(0, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            ZIndex = 100;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "colorpicker_components" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UICorner" , {
            Parent = items[ "colorpicker_components" ];
            CornerRadius = dim(0, 6)
        });

        items[ "saturation_holder" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 7, 0, 7);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -14, 1, -80);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 39, 39)
        });

        items[ "sat" ] = library:create( "TextButton" , {
            Parent = items[ "saturation_holder" ];
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            Text = "";
            AutoButtonColor = false;
            BorderColor3 = rgb(0, 0, 0);
            ZIndex = 2;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UICorner" , {
            Parent = items[ "sat" ];
            CornerRadius = dim(0, 4)
        });

        library:create( "UIGradient" , {
            Rotation = 270;
            Transparency = numseq{numkey(0, 0), numkey(1, 1)};
            Parent = items[ "sat" ];
            Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
        });

        items[ "val" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "saturation_holder" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIGradient" , {
            Parent = items[ "val" ];
            Transparency = numseq{numkey(0, 0), numkey(1, 1)}
        });

        library:create( "UICorner" , {
            Parent = items[ "val" ];
            CornerRadius = dim(0, 4)
        });

        library:create( "UICorner" , {
            Parent = items[ "saturation_holder" ];
            CornerRadius = dim(0, 4)
        });

        items[ "satvalpicker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 1);
            Parent = items[ "saturation_holder" ];
            Name = "\0";
            Position = dim2(0, 0, 4, 0);
            Size = dim2(0, 16, 0, 16);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });

        library:create( "UICorner" , {
            Parent = items[ "satvalpicker" ];
            CornerRadius = dim(0, 9999)
        });

        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            Parent = items[ "satvalpicker" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        });

        items[ "hue_gradient" ] = library:create( "TextButton" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 10, 1, -71);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -20, 0, 20);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            AutoButtonColor = false;
            Text = "";
        });

        items[ "hue_bar" ] = library:create( "Frame" , {
            Parent = items[ "hue_gradient" ];
            Name = "\0";
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 8);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))};
            Parent = items[ "hue_bar" ]
        });

        library:create( "UICorner" , {
            Parent = items[ "hue_bar" ];
            CornerRadius = dim(0, 6)
        });

        items[ "hue_picker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 0.5);
            Parent = items[ "hue_bar" ];
            Name = "\0";
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(0, 14, 0, 14);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });

        library:create( "UICorner" , {
            Parent = items[ "hue_picker" ];
            CornerRadius = dim(0, 9999)
        });

        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            Parent = items[ "hue_picker" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        });

        items[ "alpha_gradient" ] = library:create( "TextButton" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 10, 1, -49);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -20, 0, 18);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            AutoButtonColor = false;
            Text = "";
        });

        items[ "alpha_bar" ] = library:create( "Frame" , {
            Parent = items[ "alpha_gradient" ];
            Name = "\0";
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 8);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        library:create( "UICorner" , {
            Parent = items[ "alpha_bar" ];
            CornerRadius = dim(0, 6)
        });

        items[ "alpha_picker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 0.5);
            Parent = items[ "alpha_bar" ];
            Name = "\0";
            Position = dim2(1, 0, 0.5, 0);
            Size = dim2(0, 14, 0, 14);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });

        library:create( "UICorner" , {
            Parent = items[ "alpha_picker" ];
            CornerRadius = dim(0, 9999)
        });

        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Parent = items[ "alpha_picker" ]
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(255, 255, 255))};
            Parent = items[ "alpha_bar" ]
        });

        items[ "alpha_indicator" ] = library:create( "ImageLabel" , {
            ScaleType = Enum.ScaleType.Tile;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "alpha_bar" ];
            Image = "rbxassetid://18274452449";
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            TileSize = dim2(0, 6, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0)
        });

        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(112, 112, 112)), rgbkey(1, rgb(255, 0, 0))};
            Transparency = numseq{numkey(0, 0.8062499761581421), numkey(1, 0)};
            Parent = items[ "alpha_indicator" ]
        });

        library:create( "UICorner" , {
            Parent = items[ "alpha_indicator" ];
            CornerRadius = dim(0, 6)
        });

        library:create( "UIGradient" , {
            Rotation = 90;
            Parent = items[ "colorpicker_components" ];
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(66, 66, 66))}
        });

        items[ "input" ] = library:create( "TextBox" , {
            FontFace = fonts.font;
            AnchorPoint = vec2(1, 1);
            Text = "";
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            PlaceholderColor3 = rgb(255, 255, 255);
            CursorPosition = -1;
            ClearTextOnFocus = false;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            TextColor3 = rgb(72, 72, 72);
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(1, -8, 1, -11);
            Size = dim2(1, -16, 0, 18);
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "input" ];
            CornerRadius = dim(0, 3)
        });

        items[ "UICorenr" ] = library:create( "UICorner" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            CornerRadius = dim(0, 4)
        });
    end;

    local function update_indicators()
        local hue_width = items[ "hue_bar" ].AbsoluteSize.X - items[ "hue_picker" ].AbsoluteSize.X
        local alpha_width = items[ "alpha_bar" ].AbsoluteSize.X - items[ "alpha_picker" ].AbsoluteSize.X
        local saturation_width = items[ "saturation_holder" ].AbsoluteSize.X - items[ "satvalpicker" ].AbsoluteSize.X
        local saturation_height = items[ "saturation_holder" ].AbsoluteSize.Y - items[ "satvalpicker" ].AbsoluteSize.Y
        if hue_width <= 0 or alpha_width <= 0 or saturation_width <= 0 or saturation_height <= 0 then return end

        items[ "hue_picker" ].Position = dim2(0, hue_width * h, 0.5, 0)
        items[ "alpha_picker" ].Position = dim2(0, alpha_width * (1 - a), 0.5, 0)
        items[ "satvalpicker" ].Position = dim2(0, s * saturation_width, 1, 1 - v * saturation_height)
    end

    function cfg.set_visible(bool)
        items[ "colorpicker_fade" ].BackgroundTransparency = 0
        items[ "colorpicker_holder" ].Parent = bool and library[ "items" ] or library[ "other" ]
        if library.is_mobile then
            local holder = items.colorpicker_holder
            holder.Position = library:mobile_popup_position(items.colorpicker, holder.AbsoluteSize.X > 0 and holder.AbsoluteSize.X or 166, holder.AbsoluteSize.Y > 0 and holder.AbsoluteSize.Y or 197, 6)
            library:tween(items.colorpicker_fade, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
        else
            items[ "colorpicker_holder" ].Position = dim_offset(items[ "colorpicker" ].AbsolutePosition.X, items[ "colorpicker" ].AbsolutePosition.Y + items[ "colorpicker" ].AbsoluteSize.Y + 45)
            library:tween(items[ "colorpicker_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
            library:tween(items[ "colorpicker_holder" ], {Position = items[ "colorpicker_holder" ].Position + dim_offset(0, 20)})
        end

        if bool then
            library:close_element(cfg)
            task.defer(function()
                if not library.unloaded and cfg.open then update_indicators() end
            end)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    function cfg.set(color, alpha, explicit_context)
        if type(color) == "boolean" then
            return
        end

        if color then
            h, s, v = color:ToHSV()
        end

        if alpha ~= nil then
            local number = tonumber(alpha)
            if number and number == number then a = clamp(number, 0, 1) end
        end

        local Color = hsv(h, s, v)

        update_indicators()

        items[ "alpha_indicator" ]:FindFirstChildOfClass("UIGradient").Color = rgbseq{rgbkey(0, rgb(112, 112, 112)), rgbkey(1, hsv(h, 1, 1))};

        items[ "colorpicker" ].BackgroundColor3 = Color
        items[ "colorpicker_inline" ].BackgroundColor3 = Color
        items[ "saturation_holder" ].BackgroundColor3 = hsv(h, 1, 1)

        items[ "hue_picker" ].BackgroundColor3 = hsv(h, 1, 1)
        items[ "alpha_picker" ].BackgroundColor3 = hsv(h, 1, 1 - a)
        items[ "satvalpicker" ].BackgroundColor3 = hsv(h, s, v)

        flags[cfg.flag] = {
            Color = Color;
            Transparency = a
        }

        local color = items[ "colorpicker" ].BackgroundColor3
        items[ "input" ].Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
        items[ "input" ].Text ..= library:round(1 - a, 0.01)

        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, Color, a)
    end

    function cfg.update_color(input_position, explicit_context)
        local cursor = input_position or uis:GetMouseLocation()

        if dragging_sat then
            local area = items["sat"]
            local size = area.AbsoluteSize
            if size.X <= 0 or size.Y <= 0 then return end
            s = clamp((cursor.X - area.AbsolutePosition.X) / size.X, 0, 1)
            v = 1 - clamp((cursor.Y - area.AbsolutePosition.Y) / size.Y, 0, 1)
        elseif dragging_hue then
            local area = items["hue_gradient"]
            local width = area.AbsoluteSize.X
            if width <= 0 then return end
            h = clamp((cursor.X - area.AbsolutePosition.X) / width, 0, 1)
        elseif dragging_alpha then
            local area = items["alpha_gradient"]
            local width = area.AbsoluteSize.X
            if width <= 0 then return end
            a = 1 - clamp((cursor.X - area.AbsolutePosition.X) / width, 0, 1)
        end

        cfg.set(nil, nil, explicit_context)
    end

    items[ "colorpicker" ].Activated:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    local function start_drag(input, channel)
        local function set_channel(is_dragging)
            dragging_sat = is_dragging and channel == "sat"
            dragging_hue = is_dragging and channel == "hue"
            dragging_alpha = is_dragging and channel == "alpha"
        end
        local started = library:begin_pointer_drag(input, function(position)
            cfg.update_color(position, {source = "user", phase = "change"})
        end, function()
            if cfg._destroyed then return end
            set_channel(false)
            local value = flags[cfg.flag]
            library:commit_control(cfg, {source = "user"}, value.Color, value.Transparency)
        end, cfg)
        if not started then return end
        set_channel(true)
        cfg.update_color(input and input.Position or nil, {source = "user", phase = "change"})
    end

    if library.is_mobile then
        local function attach_drag(object, channel)
            object.Active = true
            object.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then start_drag(input, channel) end
            end)
        end
        attach_drag(items.alpha_gradient, "alpha")
        attach_drag(items.alpha_picker, "alpha")
        attach_drag(items.hue_gradient, "hue")
        attach_drag(items.hue_picker, "hue")
        attach_drag(items.sat, "sat")
        attach_drag(items.satvalpicker, "sat")
    else
        items["alpha_gradient"].MouseButton1Down:Connect(function() start_drag(nil, "alpha") end)
        items["alpha_picker"].MouseButton1Down:Connect(function() start_drag(nil, "alpha") end)
        items["hue_gradient"].MouseButton1Down:Connect(function() start_drag(nil, "hue") end)
        items["hue_picker"].MouseButton1Down:Connect(function() start_drag(nil, "hue") end)
        items["sat"].MouseButton1Down:Connect(function() start_drag(nil, "sat") end)
        items["satvalpicker"].MouseButton1Down:Connect(function() start_drag(nil, "sat") end)
    end

    items[ "input" ].FocusLost:Connect(function()
        local text = items[ "input" ].Text
        local r, g, b, a = library:convert(text)

        if r and g and b and a then
            cfg.set(rgb(clamp(r, 0, 255), clamp(g, 0, 255), clamp(b, 0, 255)), 1 - clamp(a, 0, 1), {source = "user", phase = "commit"})
        end
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
    end)

    library:with_change_context("initialization", "initialize", cfg.set, cfg.color, cfg.alpha)
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "table" or type(value.Color) ~= "string" then
            return false, nil, "expected a color object with a hex Color"
        end
        if not value.Color:match("^#?%x%x%x%x%x%x$") then
            return false, nil, "Color must be a 6-digit hex string"
        end
        local transparency = tonumber(value.Transparency)
        if not transparency or transparency ~= transparency or transparency == math.huge or transparency == -math.huge
            or transparency < 0 or transparency > 1 then
            return false, nil, "Transparency must be between 0 and 1"
        end
        local ok, parsed = pcall(__kaeryn.hex, value.Color)
        if not ok or typeof(parsed) ~= "Color3" then return false, nil, "Color is not valid hex" end
        return true, {Color = value.Color, Transparency = transparency}
    end, cfg.legacy_flags)

    cfg._description_label = label and label.items.info or nil
    if label then cfg._cleanup = {function() label:Destroy() end} end
    library:attach_control(cfg, label and label.items.label or items.colorpicker, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/DataTable.luau"] = function(__kaeryn_require)
return function(context)
    local dim2 = context.dim2
    local dim = context.dim
    local rgb = context.rgb
    local library = context.library
    local themes = context.themes
    local fonts = context.fonts
    local flags = context.flags
    local config_flags = context.config_flags

    local function row_key(id)
        return tostring(id)
    end

    function library:data_table(options)
        options = library:normalize_options("data_table", options)
        local id, flag = library:resolve_identity(options, "data_table", self.name, true)
        local cfg = {
            id = id,
            flag = flag,
            control_type = "data_table",
            name = options.name,
            info = options.info,
            callback = options.callback,
            legacy_flags = options.legacy_flags,
            columns = table.clone(options.columns),
            rows = {},
            rows_by_id = {},
            row_views = {},
            sort_key = nil,
            sort_ascending = true,
            items = {},
        }

        local items = cfg.items
        local heading_height = options.info and 40 or 24
        items.root = library:create("Frame", {
            Parent = self.items.elements,
            Name = "DataTable",
            Size = dim2(1, 0, 0, options.max_height + heading_height),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        items.title = library:create("TextLabel", {
            Parent = items.root,
            Name = "Title",
            Size = dim2(1, 0, 0, 20),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            FontFace = fonts.font,
            Text = options.name,
            TextColor3 = themes.preset.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        library:apply_theme(items.title, "text", "TextColor3")
        if options.info then
            items.description = library:create("TextLabel", {
                Parent = items.root,
                Name = "Description",
                Position = dim2(0, 0, 0, 20),
                Size = dim2(1, 0, 0, 16),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = fonts.small,
                Text = options.info,
                TextColor3 = themes.preset.muted,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            library:apply_theme(items.description, "muted", "TextColor3")
        end
        items.header = library:create("Frame", {
            Parent = items.root,
            Name = "Header",
            Position = dim2(0, 0, 0, heading_height),
            Size = dim2(1, 0, 0, 28),
            BackgroundColor3 = themes.preset.surface_alt,
            BorderSizePixel = 0,
        })
        library:apply_theme(items.header, "surface_alt", "BackgroundColor3")
        library:create("UICorner", {Parent = items.header, CornerRadius = dim(0, 4)})
        library:create("UIListLayout", {
            Parent = items.header,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        items.scrolling = library:create("ScrollingFrame", {
            Parent = items.root,
            Name = "Rows",
            Position = dim2(0, 0, 0, heading_height + 32),
            Size = dim2(1, 0, 1, -(heading_height + 32)),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = dim2(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = rgb(72, 72, 73),
        })
        items.rows = library:create("Frame", {
            Parent = items.scrolling,
            Name = "RowsContent",
            Size = dim2(1, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        library:create("UIListLayout", {
            Parent = items.rows,
            Padding = dim(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        local fixed_widths, flexible_columns = 0, 0
        for _, column in ipairs(cfg.columns) do
            if column.width then fixed_widths += column.width else flexible_columns += 1 end
        end
        local flexible_width = flexible_columns > 0 and (1 - fixed_widths) / flexible_columns or 0
        local function column_width(column)
            return column.width or flexible_width
        end

        local function refresh_selection()
            for key, view in pairs(cfg.row_views) do
                view.stroke.Enabled = cfg.value ~= nil and key == row_key(cfg.value)
            end
        end

        local function set_cell_text(view, row)
            for index, column in ipairs(cfg.columns) do
                view.cells[index].Text = row[column.key] == nil and "" or tostring(row[column.key])
            end
        end

        local function make_row(row)
            local key = row_key(row.id)
            local button = library:create("TextButton", {
                Parent = items.rows,
                Name = "Row_" .. key,
                Size = dim2(1, 0, 0, options.row_height),
                BackgroundColor3 = themes.preset.surface,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                LayoutOrder = #cfg.rows,
            })
            library:apply_theme(button, "surface", "BackgroundColor3")
            local stroke = library:create("UIStroke", {
                Parent = button,
                Color = themes.preset.accent,
                Transparency = 0.35,
                Enabled = false,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            library:apply_theme(stroke, "accent", "Color")
            library:create("UICorner", {Parent = button, CornerRadius = dim(0, 4)})
            library:create("UIListLayout", {
                Parent = button,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            local view = {button = button, stroke = stroke, cells = {}}
            for index, column in ipairs(cfg.columns) do
                local cell = library:create("TextLabel", {
                    Parent = button,
                    Name = column.key,
                    Size = dim2(column_width(column), 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    FontFace = fonts.small,
                    Text = "",
                    TextColor3 = themes.preset.text_soft,
                    TextSize = 13,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = index,
                })
                library:apply_theme(cell, "text_soft", "TextColor3")
                library:create("UIPadding", {
                    Parent = cell,
                    PaddingLeft = dim(0, 8),
                    PaddingRight = dim(0, 6),
                })
                view.cells[index] = cell
            end
            library:connection(button.Activated, function()
                if not cfg._destroyed then cfg.set(row.id, {source = "user", phase = "commit"}) end
            end, cfg)
            set_cell_text(view, row)
            cfg.row_views[key] = view
            return view
        end

        local headers = {}
        for index, column in ipairs(cfg.columns) do
            local header = library:create("TextButton", {
                Parent = items.header,
                Name = column.key,
                Size = dim2(column_width(column), 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                FontFace = fonts.font,
                Text = column.label or column.key,
                TextColor3 = themes.preset.text_soft,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = index,
            })
            headers[column.key] = header
            library:apply_theme(header, "text_soft", "TextColor3")
            library:create("UIPadding", {
                Parent = header,
                PaddingLeft = dim(0, 8),
                PaddingRight = dim(0, 6),
            })
            if options.sortable and column.sortable ~= false then
                library:connection(header.Activated, function()
                    if cfg.sort_key == column.key then
                        cfg:Sort(column.key, not cfg.sort_ascending)
                    else
                        cfg:Sort(column.key, true)
                    end
                end, cfg)
                header:SetAttribute("KaerynSortKey", column.key)
            end
        end

        library:attach_control(cfg, items.root, self)

        local function ordered_rows()
            local result = table.clone(cfg.rows)
            if not cfg.sort_key then return result end
            table.sort(result, function(first, second)
                local left, right = first[cfg.sort_key], second[cfg.sort_key]
                if left == right then return row_key(first.id) < row_key(second.id) end
                if left == nil then return not cfg.sort_ascending end
                if right == nil then return cfg.sort_ascending end
                local less
                if type(left) == "number" and type(right) == "number" then
                    less = left < right
                else
                    less = tostring(left) < tostring(right)
                end
                return cfg.sort_ascending and less or (not cfg.sort_ascending and not less)
            end)
            return result
        end

        local function render_order()
            for index, row in ipairs(ordered_rows()) do
                local view = cfg.row_views[row_key(row.id)]
                if view then view.button.LayoutOrder = index; set_cell_text(view, row) end
            end
        end

        function cfg.set(value, explicit_context)
            if value ~= nil then
                local row = cfg.rows_by_id[row_key(value)]
                if not row then return false, "unknown data_table row id '" .. tostring(value) .. "'" end
                value = row.id
            end
            cfg.value = value
            flags[cfg.flag] = value
            refresh_selection()
            local row = value ~= nil and cfg.rows_by_id[row_key(value)] or nil
            library:dispatch_control_callback(cfg, cfg.callback, explicit_context, value, row)
            return true
        end

        function cfg:SetRows(rows)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            local valid, reason = library:validate_data_table(cfg.columns, rows)
            if not valid then return false, reason end
            local next_rows, next_by_id = {}, {}
            for index, row in ipairs(rows) do
                local copy = table.clone(row)
                local key = row_key(copy.id)
                next_rows[index], next_by_id[key] = copy, copy
            end
            for key, view in pairs(cfg.row_views) do
                if not next_by_id[key] then
                    view.button:Destroy()
                    cfg.row_views[key] = nil
                end
            end
            cfg.rows, cfg.rows_by_id = next_rows, next_by_id
            for _, row in ipairs(cfg.rows) do
                local key = row_key(row.id)
                local view = cfg.row_views[key] or make_row(row)
                view.button.LayoutOrder = #cfg.rows
                set_cell_text(view, row)
            end
            if cfg.value ~= nil and not cfg.rows_by_id[row_key(cfg.value)] then
                cfg.set(nil, {source = "code", phase = "commit"})
            elseif cfg.value ~= nil then
                cfg.value = cfg.rows_by_id[row_key(cfg.value)].id
                flags[cfg.flag] = cfg.value
            else
                refresh_selection()
            end
            render_order()
            return true
        end

        function cfg:UpdateRow(id_value, patch)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            local current = cfg.rows_by_id[row_key(id_value)]
            if not current then return false, "unknown data_table row id '" .. tostring(id_value) .. "'" end
            if type(patch) ~= "table" or patch.id ~= nil and patch.id ~= current.id then return false, "row updates must be a table and cannot change the row id" end
            local replacement = table.clone(current)
            for key, value in pairs(patch) do replacement[key] = value end
            local rows = table.clone(cfg.rows)
            for index, row in ipairs(rows) do
                if row_key(row.id) == row_key(id_value) then rows[index] = replacement; break end
            end
            return cfg:SetRows(rows)
        end

        function cfg:RemoveRow(id_value)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            if not cfg.rows_by_id[row_key(id_value)] then return false, "unknown data_table row id '" .. tostring(id_value) .. "'" end
            local rows = {}
            for _, row in ipairs(cfg.rows) do
                if row_key(row.id) ~= row_key(id_value) then table.insert(rows, row) end
            end
            return cfg:SetRows(rows)
        end

        function cfg:Sort(key, ascending)
            if cfg._destroyed then return false, "data_table has been destroyed" end
            local column_exists = false
            for _, column in ipairs(cfg.columns) do
                if column.key == key and options.sortable and column.sortable ~= false then column_exists = true; break end
            end
            if not column_exists then return false, "unknown or non-sortable data_table column '" .. tostring(key) .. "'" end
            if ascending ~= nil and type(ascending) ~= "boolean" then return false, "ascending must be a boolean" end
            cfg.sort_key = key
            cfg.sort_ascending = ascending == nil or ascending
            for _, column in ipairs(cfg.columns) do
                headers[column.key].Text = (column.label or column.key)
                    .. (cfg.sort_key == column.key and (cfg.sort_ascending and "  ↑" or "  ↓") or "")
            end
            render_order()
            return true
        end

        cfg:SetRows(options.rows)
        library:register_config_flag(flag, function(value)
            cfg.set(value, {source = "config", phase = "commit"})
        end, function(value)
            if value == nil then return true, nil end
            if type(value) ~= "string" and type(value) ~= "number" then return false, nil, "expected a row id" end
            local row = cfg.rows_by_id[row_key(value)]
            if not row then return false, nil, "row id does not exist" end
            return true, row.id
        end, options.legacy_flags)

        if options.default ~= nil then
            library:with_change_context("initialization", "initialize", cfg.set, options.default)
        end
        return cfg
    end
end

    end,
    ["src/Kaeryn/Controls/Dropdown.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local uis = __kaeryn.uis
    local ws = __kaeryn.ws
    local gui_service = __kaeryn.gui_service
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:dropdown(options)
    options = library:normalize_options("dropdown", options)
    local id, flag = library:resolve_identity(options, "dropdown", self.name, true)
    local cfg = {
        id = id,
        control_type = "dropdown",
        name = options.name or nil;
        info = options.info or nil;
        flag = flag;
        legacy_flags = options.legacy_flags;
        options = options.items or {""};
        callback = options.callback or function() end;
        multi = options.multi or false;
        scrolling = options.scrolling or false;
        searchable = options.searchable == true or (options.searchable ~= false and #(options.items or {}) >= 8);

        width = options.width or 130;

        open = false;
        multi_items = {};
        ignore = options.ignore or false;
        items = {};
        y_size;
        separator = options.separator;
    }

    cfg.default = options.default ~= nil and options.default or (cfg.multi and (cfg.options[1] and {cfg.options[1]} or {}) or cfg.options[1] or "None")
    if options.default == nil then
        local first = cfg.options[1]
        if type(first) == "table" then first = first.value end
        cfg.default = cfg.multi and (first and {first} or {}) or first or "None"
    end
    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "dropdown_object" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name or "Dropdown";
            Parent = items[ "dropdown_object" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
                Parent = items[ "dropdown_object" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            BackgroundTransparency = 1;
            Parent = items[ "dropdown_object" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        items[ "dropdown" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim2(0, cfg.width, 0, 16);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "dropdown" ];
            CornerRadius = dim(0, 4)
        });

        items[ "sub_text" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Text = "awdawdawdawdawdawdawdaw";
            Parent = items[ "dropdown" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextTruncate = Enum.TextTruncate.AtEnd;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "sub_text" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "indicator" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "dropdown" ];
            AnchorPoint = vec2(1, 0.5);
            Image = "lucide:chevron-down";
            BackgroundTransparency = 1;
            Position = dim2(1, -5, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 12, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "dropdown_holder" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = library[ "items" ];
            Name = "\0";
            Visible = false;
            BackgroundTransparency = 1;
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
            ZIndex = 10;
        });

        items[ "outline" ] = library:create("Frame", {
            Parent = items[ "dropdown_holder" ];
            Size = dim2(1, 0, 1, 0);
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(33, 33, 35);
            ZIndex = 10;
        });
        library:create("UICorner", {Parent = items.outline, CornerRadius = dim(0, 4)})
        if cfg.searchable then
            items.search_input = library:create("TextBox", {
                Parent = items.outline,
                Position = dim2(0, 6, 0, 5),
                Size = dim2(1, -12, 0, 28),
                BackgroundColor3 = rgb(25, 25, 29),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                FontFace = fonts.small,
                PlaceholderText = "Search options...",
                Text = "",
                TextColor3 = rgb(235, 235, 235),
                PlaceholderColor3 = rgb(125, 125, 125),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12,
            })
            library:create("UICorner", {Parent = items.search_input, CornerRadius = dim(0, 4)})
            library:create("UIPadding", {Parent = items.search_input, PaddingLeft = dim(0, 8), PaddingRight = dim(0, 8)})
            library:apply_theme(items.search_input, "surface_alt", "BackgroundColor3")
            library:apply_theme(items.search_input, "text", "TextColor3")
            library:apply_theme(items.search_input, "muted", "PlaceholderColor3")
        end
        items.option_list = library:create("ScrollingFrame", {
            Parent = items.outline,
            Position = dim2(0, 0, 0, cfg.searchable and 38 or 0),
            Size = dim2(1, 0, 1, cfg.searchable and -38 or 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            CanvasSize = dim_offset(0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = rgb(100, 100, 100),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 11,
        })
        items.empty = library:create("TextLabel", {
            Parent = items.option_list,
            Position = dim2(0, 7, 0, 6),
            Size = dim2(1, -14, 0, 28),
            BackgroundTransparency = 1,
            FontFace = fonts.small,
            Text = "No options found",
            TextColor3 = rgb(145, 145, 145),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            ZIndex = 12,
        })
        library:apply_theme(items.empty, "muted", "TextColor3")
    end

    local row_bindings = setmetatable({}, {__mode = "k"})
    local option_rows = {}
    local row_height = 30
    local max_visible_rows = 12
    local search_input = items.search_input

    local function option_record(option)
        if type(option) == "table" then
            return {value = option.value, label = option.label or option.value, group = option.group, disabled = option.disabled == true}
        end
        local value = tostring(option)
        return {value = value, label = value, group = nil, disabled = false}
    end

    local function selection_values()
        if cfg.multi then return table.clone(cfg.multi_items) end
        local selected = flags[cfg.flag]
        return selected ~= nil and {selected} or {}
    end

    local function is_selected(value)
        for _, selected in ipairs(selection_values()) do
            if selected == value then return true end
        end
        return false
    end

    local function build_entries()
        local groups, group_order = {}, {}
        local ungrouped = {}
        for _, option in ipairs(cfg.option_data or {}) do
            local key = option.group or ungrouped
            if not groups[key] then
                groups[key] = {}
                table.insert(group_order, key)
            end
            table.insert(groups[key], option)
        end
        local query = string.lower(search_input and search_input.Text or "")
        local entries = {}
        for _, key in ipairs(group_order) do
            local options = groups[key]
            local matching = {}
            for _, option in ipairs(options) do
                local searchable = string.lower(library:translate(option.label) .. " " .. option.value .. " " .. library:translate(option.group or ""))
                if query == "" or string.find(searchable, query, 1, true) then table.insert(matching, option) end
            end
            if #matching > 0 then
                if key ~= ungrouped then table.insert(entries, {kind = "group", label = key}) end
                for _, option in ipairs(matching) do table.insert(entries, {kind = "option", option = option}) end
            end
        end
        cfg.visible_entries = entries
        local popup_height = math.min(#entries, max_visible_rows) * row_height + 8
        if cfg.searchable then popup_height += 38 end
        cfg.y_size = math.max(cfg.searchable and 78 or row_height + 8, popup_height)
        items.option_list.CanvasSize = dim_offset(0, #entries * row_height + 8)
        items.empty.Visible = #entries == 0
        items.option_list.CanvasPosition = vec2(0, math.min(items.option_list.CanvasPosition.Y, math.max(0, #entries * row_height - items.option_list.AbsoluteSize.Y)))
    end

    local function render_rows()
        local entries = cfg.visible_entries or {}
        local first = math.floor(items.option_list.CanvasPosition.Y / row_height) + 1
        for index, row in ipairs(option_rows) do
            local entry_index = first + index - 1
            local entry = entries[entry_index]
            row_bindings[row] = entry
            row.Visible = entry ~= nil
            if entry then
                row.Position = dim2(0, 4, 0, (entry_index - 1) * row_height + 3)
                if entry.kind == "group" then
                    row.Text = library:translate(entry.label)
                    row.TextColor3 = themes.preset.muted
                    row.FontFace = fonts.font
                    row.TextSize = 12
                    row.BackgroundTransparency = 1
                    pcall(function() row.Interactable = false end)
                else
                    local option = entry.option
                    row.Text = library:translate(option.label)
                    row.FontFace = fonts.small
                    row.TextSize = 14
                    row.BackgroundTransparency = option.disabled and 0.6 or 1
                    pcall(function() row.Interactable = not option.disabled end)
                    row.TextColor3 = option.disabled and themes.preset.muted or is_selected(option.value) and themes.preset.accent or themes.preset.text_soft
                end
            end
        end
    end

    local function find_option(value)
        if type(value) ~= "string" then return nil end
        for _, option in ipairs(cfg.option_data or {}) do
            if option.value == value then return option end
        end
        for _, option in ipairs(cfg.option_data or {}) do
            if option.label == value or library:translate(option.label) == value then return option end
        end
    end

    function cfg.set_visible(bool)
        cfg.open = bool == true
        if cfg.open then
            build_entries()
            render_rows()
        end
        local width = math.max(120, items.dropdown.AbsoluteSize.X)
        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
        width = min(width, max(1, viewport.X - 12))
        local height_limit = min(290, max(1, viewport.Y - 20))
        if library.is_mobile then
            local inset = gui_service:GetGuiInset()
            height_limit = min(height_limit, max(1, viewport.Y - inset.Y - 18))
        end
        local height = cfg.open and min(cfg.y_size or 0, height_limit) or 0
        local search_height = cfg.searchable and math.min(38, height) or 0
        items.outline.Size = dim2(1, 0, 1, 0)
        if search_input then search_input.Visible = cfg.open end
        if not cfg.open and search_input and uis:GetFocusedTextBox() == search_input then search_input:ReleaseFocus() end
        items.option_list.Position = dim2(0, 0, 0, search_height)
        items.option_list.Size = dim2(1, 0, 1, -search_height)
        items.dropdown_holder.Size = dim_offset(width, height)
        items.dropdown_holder.Visible = cfg.open
        if cfg.open then
            if library.is_mobile then
                items.dropdown_holder.Position = library:mobile_popup_position(items.dropdown, width, height, 6)
            else
                local px = clamp(items.dropdown.AbsolutePosition.X, 6, max(6, viewport.X - width - 6))
                local py = items.dropdown.AbsolutePosition.Y + items.dropdown.AbsoluteSize.Y + 6
                if py + height > viewport.Y - 8 then py = max(6, items.dropdown.AbsolutePosition.Y - height - 6) end
                items.dropdown_holder.Position = dim_offset(px, py)
            end
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    function cfg.set(value)
        local requested = cfg.multi and (type(value) == "table" and value or {}) or (value ~= nil and {value} or {})
        if cfg.multi and type(value) ~= "table" and value ~= nil then return false, "Multi dropdown values must be a list" end
        if cfg.multi and type(value) == "table" then
            local count, highest = 0, 0
            for index in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "Multi dropdown values must be a dense list" end
                count += 1
                highest = math.max(highest, index)
            end
            if count ~= highest then return false, "Multi dropdown values must be a dense list" end
        end
        local selected, selected_labels, seen = {}, {}, {}
        for index, raw in ipairs(requested) do
            local option = find_option(raw)
            if not option then return false, "Unknown dropdown option at index " .. tostring(index) end
            if option.disabled then return false, "Dropdown option '" .. option.value .. "' is disabled" end
            if not seen[option.value] then
                seen[option.value] = true
                table.insert(selected, option.value)
                table.insert(selected_labels, library:translate(option.label))
            end
        end
        if not cfg.multi and #selected > 1 then return false, "Single dropdowns accept one value" end
        cfg.multi_items = cfg.multi and selected or {}
        flags[cfg.flag] = cfg.multi and selected or selected[1]
        items.sub_text.Text = table.concat(selected_labels, ", ")
        render_rows()
        library:dispatch_control_callback(cfg, cfg.callback, nil, flags[cfg.flag])
        return true
    end

    function cfg.refresh_options(list)
        local valid, reason = library:validate_option_list("dropdown", list)
        if not valid then return false, reason end
        local previous = flags[cfg.flag]
        cfg.options = table.clone(list)
        cfg.option_data = {}
        for _, option in ipairs(cfg.options) do table.insert(cfg.option_data, option_record(option)) end
        if search_input then search_input.Text = "" end
        build_entries()

        local maximum_entries, seen_groups = #cfg.option_data, {}
        for _, option in ipairs(cfg.option_data) do
            if option.group and not seen_groups[option.group] then
                seen_groups[option.group] = true
                maximum_entries += 1
            end
        end
        local needed_rows = math.min(max_visible_rows, math.max(1, maximum_entries))
        while #option_rows < needed_rows do
            local row = library:create("TextButton", {
                Parent = items.option_list,
                Size = dim2(1, -8, 0, row_height),
                BackgroundColor3 = themes.preset.surface_alt,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                FontFace = fonts.small,
                Text = "",
                TextColor3 = themes.preset.text_soft,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Visible = false,
                ZIndex = 12,
            })
            library:create("UICorner", {Parent = row, CornerRadius = dim(0, 3)})
            library:create("UIPadding", {Parent = row, PaddingLeft = dim(0, 7), PaddingRight = dim(0, 6)})
            library:apply_theme(row, "surface_alt", "BackgroundColor3")
            library:connection(row.Activated, function()
                local entry = row_bindings[row]
                if not entry or entry.kind ~= "option" or entry.option.disabled then return end
                local option = entry.option
                if cfg.multi then
                    local selected = table.clone(cfg.multi_items)
                    local selected_index = table.find(selected, option.value)
                    if selected_index then table.remove(selected, selected_index) else table.insert(selected, option.value) end
                    cfg.set(selected)
                else
                    cfg.set_visible(false)
                    cfg.set(option.value)
                end
            end, cfg)
            table.insert(option_rows, row)
        end
        render_rows()
        if previous ~= nil then
            local preserved = {}
            if cfg.multi and type(previous) == "table" then
                for _, value in ipairs(previous) do
                    local option = find_option(value)
                    if option and not option.disabled then table.insert(preserved, value) end
                end
                cfg.set(preserved)
            elseif find_option(previous) and not find_option(previous).disabled then
                cfg.set(previous)
            else
                cfg.set(nil)
            end
        end
        return true
    end

    library:connection(items.option_list:GetPropertyChangedSignal("CanvasPosition"), render_rows, cfg)
    if search_input then library:connection(search_input:GetPropertyChangedSignal("Text"), function()
        build_entries()
        render_rows()
    end, cfg) end

    library:connection(items[ "dropdown" ].Activated, function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end, cfg)

    if cfg.separator then
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end

    flags[cfg.flag] = nil
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        local function normalize(item)
            local option = find_option(item)
            if option and not option.disabled then return option.value end
            return nil
        end
        if cfg.multi then
            if type(value) ~= "table" then return false, nil, "expected a list of option values" end
            local count = 0
            for index in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then
                    return false, nil, "expected a dense list of option values"
                end
                count += 1
            end
            if #value ~= count then return false, nil, "expected a dense list of option values" end
            local normalized, seen = {}, {}
            for index, item in ipairs(value) do
                local stable_value = normalize(item)
                if not stable_value then return false, nil, "unknown dropdown option at index " .. tostring(index) end
                if seen[stable_value] then return false, nil, "duplicate dropdown option '" .. stable_value .. "'" end
                seen[stable_value] = true
                table.insert(normalized, stable_value)
            end
            return true, normalized
        end
        local stable_value = normalize(value)
        if not stable_value then return false, nil, "expected one of the dropdown values" end
        return true, stable_value
    end, cfg.legacy_flags)

    library:with_change_context("initialization", "initialize", cfg.refresh_options, cfg.options)
    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)

    library:mobile_format_control(items, "dropdown")
    library:attach_control(cfg, items.dropdown_object, self)
    cfg:AddCleanup(function()
        if items.dropdown_holder.Parent then items.dropdown_holder:Destroy() end
    end)
    cfg._locale_connection = library:register_locale_callback(function()
        local labels = {}
        for _, value in ipairs(selection_values()) do
            local option = find_option(value)
            if option then table.insert(labels, library:translate(option.label)) end
        end
        items.sub_text.Text = table.concat(labels, ", ")
        if cfg.open then build_entries(); render_rows() end
    end)
    cfg:AddCleanup(function() cfg._locale_connection:Disconnect() end)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Keybind.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local ws = __kaeryn.ws
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:keybind(options)
    options = library:normalize_options("keybind", options)
    local id, flag = library:resolve_identity(options, "keybind", self.name, true)
    local cfg = {
        id = id,
        control_type = "keybind",
        flag = flag,
        legacy_flags = options.legacy_flags,
        callback = options.callback or function() end,
        name = options.name or nil,
        ignore_key = options.ignore or false,
        context = options.context or "global",
        default_key = options.key or "NONE",
        default_mode = options.mode or "Toggle",
        default_active = options.default == true,

        key = options.key or nil,
        mode = options.mode or "Toggle",
        active = options.default or false,

        open = false,
        binding = nil,

        hold_instances = {},
        items = {};
    }

    flags[cfg.flag] = {
        mode = cfg.mode,
        key = cfg.key,
        active = cfg.active
    }

    local items = cfg.items; do
        items[ "keybind_element" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "keybind_element" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            BackgroundTransparency = 1;
            Parent = items[ "keybind_element" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        items[ "keybind_holder" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = items[ "right_components" ];
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Size = dim2(0, 0, 0, 16);
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "keybind_holder" ];
            CornerRadius = dim(0, 4)
        });

        items[ "key" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Text = "LSHIFT";
            Parent = items[ "keybind_holder" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "key" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items["conflict"] = library:create("TextLabel", {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 100, 100);
            Text = "!";
            Visible = false;
            Parent = items["right_components"];
            Name = "KeybindConflict";
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
        })

        items[ "dropdown" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = library.items;
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundColor3 = rgb(0, 0, 0)
        });

        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "dropdown" ];
            Size = dim2(1, 0, 1, 0);
            Name = "\0";
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 6);
            PaddingTop = dim(0, 3);
            PaddingLeft = dim(0, 3);
            Parent = items[ "inline" ]
        });

        library:create( "UIListLayout" , {
            Parent = items[ "inline" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 4)
        });

        local options = {"Hold", "Toggle", "Always"}

        cfg.y_size = 14
        for _, option in options do
            local name = library:create( "TextButton" , {
                FontFace = fonts.font;
                TextColor3 = rgb(72, 72, 73);
                BorderColor3 = rgb(0, 0, 0);
                Text = option;
                Parent = items[ "inline" ];
                Name = "\0";
                Size = dim2(0, 0, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 14;
                BackgroundColor3 = rgb(255, 255, 255)
            }); cfg.hold_instances[option] = name
            library:apply_theme(name, "accent", "TextColor3")

            cfg.y_size += 25

            library:create( "UIPadding" , {
                Parent = name;
                PaddingTop = dim(0, 1);
                PaddingRight = dim(0, 5);
                PaddingLeft = dim(0, 5)
            });

            name.MouseButton1Click:Connect(function()
                cfg.set(option)

                cfg.set_visible(false)

                cfg.open = false
            end)
        end
    end

    function cfg.modify_mode_color(path)
        for mode, control in pairs(cfg.hold_instances) do
            control.TextColor3 = mode == path and themes.preset.accent or rgb(72, 72, 72)
        end
    end

    function cfg.set_mode(mode)
        if mode ~= "Toggle" and mode ~= "Hold" and mode ~= "Always" then return end
        cfg.mode = mode
        cfg.active = mode == "Always" and true or (mode == "Hold" and false or cfg.active)
        cfg.modify_mode_color(mode)
        cfg.set(cfg.active)
    end

    function cfg.set(input, explicit_context)
        if type(input) == "boolean" then
            cfg.active = cfg.mode == "Always" or input
        elseif typeof(input) == "EnumItem" then
            cfg.key = input == Enum.KeyCode.Escape and "NONE" or input
        elseif type(input) == "string" then
            if input == "Toggle" or input == "Hold" or input == "Always" then
                cfg.mode = input
                if input == "Always" then cfg.active = true end
                if input == "Hold" then cfg.active = false end
            elseif input == "NONE" then
                cfg.key = "NONE"
            else
                local resolved = library:convert_enum(input)
                if resolved then cfg.key = resolved end
            end
        elseif type(input) == "table" then
            cfg.mode = (input.mode == "Toggle" or input.mode == "Hold" or input.mode == "Always") and input.mode or "Toggle"
            local resolved = type(input.key) == "string" and library:convert_enum(input.key) or input.key
            cfg.key = (input.key == "NONE" and "NONE") or resolved or "NONE"
            if input.active ~= nil then cfg.active = input.active == true end
            if cfg.mode == "Always" then cfg.active = true end
            if cfg.mode == "Hold" then cfg.active = false end
        end
        cfg.modify_mode_color(cfg.mode)
        flags[cfg.flag] = {mode = cfg.mode, key = cfg.key or "NONE", active = cfg.active}
        cfg:refresh_key_label()
        if library.refresh_keybind_conflicts then library:refresh_keybind_conflicts() end
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, cfg.active)
        return true
    end

    function cfg:refresh_key_label()
        items.key.Text = self.binding and "..." or library.get_keybind_label(self.key)
    end

    function cfg:GetConflicts()
        return library:get_keybind_conflicts(self)
    end

    function cfg:SetContext(context)
        if type(context) ~= "string" or context:gsub("%s", "") == "" then
            return false, "Keybind context must be a non-empty string"
        end
        self.context = context
        library:refresh_keybind_conflicts()
        return true
    end

    function cfg:Rebind()
        if library.is_mobile then return false, "Key capture is unavailable on touch devices" end
        return library:begin_keybind_capture(self) ~= nil
    end

    function cfg:Reset()
        return self:Set({mode = self.default_mode, key = self.default_key, active = self.default_active})
    end

    function cfg.set_visible(bool)
        cfg.open = bool == true
        local size = bool and cfg.y_size or 0
        library:tween(items[ "dropdown" ], {Size = dim_offset(items[ "keybind_holder" ].AbsoluteSize.X, size)})

        if library.is_mobile then
            local width = max(90, items.keybind_holder.AbsoluteSize.X)
            items.dropdown.Position = library:mobile_popup_position(items.keybind_holder, width, max(100, size), 6)
        else
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            local x = clamp(items.keybind_holder.AbsolutePosition.X, 6, max(6, viewport.X - items.keybind_holder.AbsoluteSize.X - 6))
            local y = items.keybind_holder.AbsolutePosition.Y + items.keybind_holder.AbsoluteSize.Y + 60
            if y + size > viewport.Y - 8 then y = max(6, items.keybind_holder.AbsolutePosition.Y - size - 8) end
            items.dropdown.Position = dim_offset(x, y)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    items[ "keybind_holder" ].MouseButton1Down:Connect(function()
        if library.is_mobile then
            cfg.open = not cfg.open
            cfg.set_visible(cfg.open)
            return
        end
        cfg:Rebind()
    end)

    items[ "keybind_holder" ].MouseButton2Down:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    library:with_change_context("initialization", "initialize", cfg.set, {mode = cfg.mode, active = cfg.active, key = cfg.key})
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "table" then return false, nil, "expected a keybind object" end
        if value.mode ~= "Toggle" and value.mode ~= "Hold" and value.mode ~= "Always" then
            return false, nil, "mode must be Toggle, Hold, or Always"
        end
        if type(value.key) ~= "string" then return false, nil, "key must be an enum name or NONE" end
        local key = value.key
        if key ~= "NONE" and not library:convert_enum(key) then return false, nil, "key is not a valid enum name" end
        if value.active ~= nil and type(value.active) ~= "boolean" then
            return false, nil, "active must be a boolean"
        end
        return true, {mode = value.mode, key = key, active = value.active == true}
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "keybind")
    library:attach_control(cfg, items.keybind_element, self)
    library:register_keybind(cfg)
    cfg:AddCleanup(function() library:unregister_keybind(cfg) end)
    cfg:refresh_key_label()
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Label.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local fonts = __kaeryn.fonts

function library:label(options)
    options = library:normalize_options("label", options)
    local id = library:resolve_identity(options, "label", self.name, false)
    local cfg = {
        id = id,
        control_type = "label",
        value = options.name or "Toggle",
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        separator = options.separator;
        info = options.info or nil;

        items = {};
    }

    local items = cfg.items; do
        items[ "label" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "label" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
                Parent = items[ "label" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            BackgroundTransparency = 1;
            Parent = items[ "label" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 9);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
    end

    if cfg.separator then
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end

    library:mobile_format_control(items, "label")
    function cfg.set(text)
        cfg.value = tostring(text or "")
        cfg.name = cfg.value
        items.name.Text = cfg.value
        library:dispatch_control_callback(cfg, nil, nil, cfg.value)
    end
    library:attach_control(cfg, items.label, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/List.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local insert = __kaeryn.insert
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:list(properties)
    properties = library:normalize_options("list", properties)
    local id, flag = library:resolve_identity(properties, "list", self.name, true)
    local cfg = {
        id = id,
        control_type = "list",
        name = properties.name,
        legacy_flags = properties.legacy_flags,
        items = {};
        options = properties.options or {"1", "2", "3"};
        flag = flag;
        callback = properties.callback or function() end;
        data_store = {};
        current_element;
    }

    local items = cfg.items; do
        items[ "list" ] = library:create( "Frame" , {
            Parent = self.items[ "elements" ];
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            Parent = items[ "list" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            Parent = items[ "list" ];
            PaddingRight = dim(0, 4);
            PaddingLeft = dim(0, 4)
        });
    end

    function cfg.set(value)
        local found = false
        for _, button in ipairs(cfg.data_store) do
            local label = button:FindFirstChildOfClass("TextLabel")
            if label then
                local match = label.Text == value
                label.TextColor3 = match and rgb(245, 245, 245) or rgb(72, 72, 73)
                if match then cfg.current_element = label; found = true end
            end
        end
        if not found then cfg.current_element = nil end
        flags[cfg.flag] = found and value or nil
        if found then library:dispatch_control_callback(cfg, cfg.callback, nil, value) end
    end

    function cfg.refresh_options(options_to_refresh)
        local valid, reason = library:validate_option_list("list", options_to_refresh)
        if not valid then return false, reason end
        local previous = flags[cfg.flag]
        for _, button in ipairs(cfg.data_store) do button:Destroy() end
        table.clear(cfg.data_store)
        cfg.current_element = nil
        cfg.options = type(options_to_refresh) == "table" and options_to_refresh or {}
        for _, option_data in ipairs(cfg.options) do
            local button = library:create("TextButton", {
                FontFace = fonts.small, Text = "", AutoButtonColor = false,
                Parent = items.list, Size = dim2(1, 0, 0, 30), BorderSizePixel = 0,
                BackgroundColor3 = rgb(33, 33, 35),
            })
            table.insert(cfg.data_store, button)
            local name = library:create("TextLabel", {
                FontFace = fonts.font, Text = tostring(option_data), Parent = button,
                TextColor3 = rgb(72, 72, 73), BorderSizePixel = 0,
                BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0), TextSize = 14,
            })
            library:create("UICorner", {Parent = button, CornerRadius = dim(0, 3)})
            button.MouseButton1Click:Connect(function() cfg.set(name.Text) end)
            name.MouseEnter:Connect(function()
                if cfg.current_element ~= name then name.TextColor3 = rgb(140, 140, 140) end
            end)
            name.MouseLeave:Connect(function()
                if cfg.current_element ~= name then name.TextColor3 = rgb(72, 72, 73) end
            end)
        end
        if previous then cfg.set(previous) end
        return true
    end

    cfg.refresh_options(cfg.options)
    if properties.default ~= nil then
        library:with_change_context("initialization", "initialize", cfg.set, properties.default)
        assert(flags[cfg.flag] ~= nil, "list default must match one of its options")
    end
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" then return false, nil, "expected a string" end
        for _, option in ipairs(cfg.options) do
            if tostring(option) == value then return true, value end
        end
        return false, nil, "value is not one of the list options"
    end, cfg.legacy_flags)
    library:attach_control(cfg, items.list, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Segmented.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:segmented(options)
    options = library:normalize_options("segmented", options)
    local id, flag = library:resolve_identity(options, "segmented", self.name, true)
    local cfg = {
        id = id,
        control_type = "segmented",
        flag = flag,
        name = options.name,
        options = table.clone(options.items),
        default = options.default,
        callback = options.callback,
        separator = options.separator,
        items = {},
    }
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements;
        Name = "SegmentedControl";
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.name = library:create("TextLabel", {
        Parent = items.root;
        Name = "Name";
        Text = cfg.name;
        FontFace = fonts.small;
        TextSize = 15;
        TextColor3 = themes.preset.text_soft;
        TextXAlignment = Enum.TextXAlignment.Left;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.container = library:create("Frame", {
        Parent = items.root;
        Name = "Options";
        Position = dim2(0, 0, 0, 23);
        Size = dim2(1, 0, 0, 30);
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        ClipsDescendants = true;
    })
    library:create("UICorner", {Parent = items.container; CornerRadius = dim(0, 5)})
    items.layout = library:create("UIListLayout", {
        Parent = items.container;
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
    })

    local function option_record(option)
        if type(option) == "table" then
            return {value = option.value, label = option.label or option.value, disabled = option.disabled == true}
        end
        return {value = option, label = option, disabled = false}
    end

    local function find_option(value)
        for _, item in ipairs(cfg.options) do
            local option = option_record(item)
            if option.value == value and not option.disabled then return option end
        end
    end

    local function update_selection()
        local selected = flags[cfg.flag]
        for value, button in pairs(items.buttons or {}) do
            local active = value == selected
            local background = active and themes.preset.accent or themes.preset.surface_alt
            local foreground = active and themes.preset.text or themes.preset.muted
            button.BackgroundColor3 = background
            button.TextColor3 = foreground
            library:track_theme(button, "BackgroundColor3", background)
            library:track_theme(button, "TextColor3", foreground)
        end
    end

    local function render()
        items.buttons = {}
        for _, child in ipairs(items.container:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local count = #cfg.options
        for index, raw_option in ipairs(cfg.options) do
            local option = option_record(raw_option)
            local button = library:create("TextButton", {
                Parent = items.container;
                Name = "Option_" .. tostring(index);
                LayoutOrder = index;
                Size = dim2(1 / count, 0, 1, 0);
                Text = library:translate(option.label);
                FontFace = fonts.small;
                TextSize = 13;
                TextTruncate = Enum.TextTruncate.AtEnd;
                TextColor3 = themes.preset.muted;
                BackgroundColor3 = themes.preset.surface_alt;
                BorderSizePixel = 0;
                AutoButtonColor = false;
                Active = not option.disabled;
                Selectable = not option.disabled;
            })
            items.buttons[option.value] = button
            button.Activated:Connect(function()
                if not option.disabled then cfg.set(option.value, {source = "user", phase = "commit"}) end
            end)
        end
        update_selection()
    end

    function cfg.set(value, explicit_context)
        if not find_option(value) then return false, "Unknown or disabled segmented option" end
        if flags[cfg.flag] == value then return true end
        flags[cfg.flag] = value
        update_selection()
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, value)
        return true
    end

    function cfg.refresh_options(new_options)
        local valid, reason = library:validate_option_list("dropdown", new_options)
        if not valid then return false, reason end
        if #new_options < 2 or #new_options > 5 then return false, "Segmented controls need 2 to 5 options" end
        local enabled = 0
        for _, option in ipairs(new_options) do
            if type(option) == "table" and option.group ~= nil then return false, "Segmented items cannot use groups" end
            if type(option) ~= "table" or not option.disabled then enabled += 1 end
        end
        if enabled < 2 or enabled > 5 then return false, "Segmented controls need between 2 and 5 enabled options" end
        cfg.options = table.clone(new_options)
        local current = flags[cfg.flag]
        local next_value = current
        if not find_option(current) then
            local first
            for _, option in ipairs(cfg.options) do
                local item = option_record(option)
                if not item.disabled then first = item.value; break end
            end
            next_value = first
        end
        render()
        if current ~= nil and current ~= next_value then return cfg.set(next_value) end
        return true
    end

    if cfg.separator then
        library:create("Frame", {
            AnchorPoint = Vector2.new(0, 1);
            Parent = self.items.elements;
            Position = dim2(0, 0, 1, 0);
            Size = dim2(1, 1, 0, 1);
            BackgroundColor3 = rgb(36, 36, 37);
            BorderSizePixel = 0;
        })
    end

    cfg.default = cfg.default or (function()
        for _, option in ipairs(cfg.options) do
            local item = option_record(option)
            if not item.disabled then return item.value end
        end
    end)()
    flags[cfg.flag] = nil
    cfg:refresh_options(cfg.options)
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" or not find_option(value) then return false, nil, "expected an enabled segmented option value" end
        return true, value
    end, options.legacy_flags)
    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    library:attach_control(cfg, items.root, self)
    if library.register_locale_callback then
        cfg._locale_connection = library:register_locale_callback(render)
        cfg:AddCleanup(function() if cfg._locale_connection then cfg._locale_connection:Disconnect() end end)
    end
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Settings.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local library = __kaeryn.library

function library:settings(options)
    local cfg = {
        open = false;
        items = {};
        sanity = true;
    }

    local items = cfg.items; do
        items[ "outline" ] = library:create( "Frame" , {
            Name = "\0";
            Visible = true;
            Parent = library[ "items" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            ClipsDescendants = true;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "elements" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "inline" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0, 10);
            Size = dim2(1, -20, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            Parent = items[ "elements" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 15);
            Parent = items[ "elements" ]
        });

        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "tick" ] = library:create( "ImageButton" , {
            Image = "lucide:settings";
            Name = "\0";
            AutoButtonColor = false;
            Parent = self.items[ "right_components" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 16, 0, 16);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
    end

    function cfg.set_visible(bool)
        library:tween(items[ "outline" ], {Size = dim_offset(bool and 240 or 0, 0)})
        if library.is_mobile then
            items.outline.Position = library:mobile_popup_position(items.tick, 240, max(230, items.outline.AbsoluteSize.Y), 6)
        else
            items[ "outline" ].Position = dim_offset(items[ "tick" ].AbsolutePosition.X, items[ "tick" ].AbsolutePosition.Y + 90)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    items[ "tick" ].MouseButton1Click:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Slider.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local uis = __kaeryn.uis
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:slider(options)
    options = library:normalize_options("slider", options)
    local id, flag = library:resolve_identity(options, "slider", self.name, true)
    local cfg = {
        id = id,
        control_type = "slider",
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = flag,
        legacy_flags = options.legacy_flags,
        callback = options.callback or function() end,
        on_commit = options.on_commit,
        info = options.info or nil;

        min = options.min,
        max = options.max,
        intervals = options.interval,
        default = options.default,
        value = options.default,
        separator = options.separator;

        dragging = false,
        items = {}
    }

    cfg.min = tonumber(cfg.min) or 0
    cfg.max = tonumber(cfg.max) or 100
    if cfg.min > cfg.max then cfg.min, cfg.max = cfg.max, cfg.min end
    cfg.intervals = tonumber(cfg.intervals) or 1
    if cfg.intervals <= 0 then cfg.intervals = 1 end
    cfg.default = tonumber(cfg.default) or cfg.min
    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "slider_object" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create("UIListLayout", {
            Parent = items["slider_object"],
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = dim(0, 3),
        })

        items["header"] = library:create("Frame", {
            Parent = items["slider_object"],
            Name = "\0",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = dim2(1, 0, 0, 22),
            LayoutOrder = 1,
        })

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "header" ];
            Name = "\0";
            Position = dim2(0, 4, 0, 0);
            Size = dim2(1, -88, 1, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Center;
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            TextSize = 15;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items["value"] = library:create("TextLabel", {
            FontFace = fonts.small,
            TextColor3 = themes.preset.accent,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Parent = items["header"],
            Name = "\0",
            AnchorPoint = vec2(1, 0),
            Position = dim2(1, -4, 0, 0),
            Size = dim2(0, 78, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = rgb(255, 255, 255),
        })
        library:apply_theme(items["value"], "accent", "TextColor3")

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
                Parent = items[ "slider_object" ];
                Name = "\0";
                Size = dim2(1, 0, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.Y;
                TextSize = 13;
                LayoutOrder = 2;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end

        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "slider_object" ];
            Name = "\0";
            BackgroundTransparency = 1;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 38);
            BorderSizePixel = 0;
            LayoutOrder = 3;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "slider" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            Parent = items[ "right_components" ];
            Name = "\0";
            Position = dim2(0, 6, 0, 0);
            Size = dim2(1, -12, 1, 0);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundTransparency = 1;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items["track"] = library:create("Frame", {
            Parent = items[ "slider" ];
            Name = "\0";
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(1, 0, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.surface_hover,
        });
        library:apply_theme(items["track"], "surface_hover", "BackgroundColor3")

        library:create("UICorner", {Parent = items["track"], CornerRadius = dim(0, 999)})

        items[ "fill" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items["track"];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.5, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.accent
        });  library:apply_theme(items[ "fill" ], "accent", "BackgroundColor3");

        library:create("UICorner", {Parent = items["fill"], CornerRadius = dim(0, 999)})

        items[ "circle" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0.5, 0.5);
            Parent = items["track"];
            Name = "\0";
            Position = dim2(0.5, 0, 0.5, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 16, 0, 16);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(244, 244, 244)
        });

        library:create("UICorner", {Parent = items["circle"], CornerRadius = dim(0, 999)})
        library:create("UIStroke", {
            Parent = items["circle"],
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = themes.preset.surface,
            Thickness = 2,
        })
    end

    function cfg.set(value, explicit_context)
        local numeric = tonumber(value)
        if not numeric or numeric ~= numeric or numeric == math.huge or numeric == -math.huge then return end
        local range = cfg.max - cfg.min
        cfg.value = clamp(cfg.min + library:round(numeric - cfg.min, cfg.intervals), cfg.min, cfg.max)
        local fraction = range > 0 and (cfg.value - cfg.min) / range or 0
        items["fill"].Size = dim2(fraction, 0, 1, 0)
        items["circle"].Position = dim2(fraction, 0, 0.5, 0)
        items[ "value" ].Text = tostring(cfg.value) .. cfg.suffix

        flags[cfg.flag] = cfg.value
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, flags[cfg.flag])
    end

    function cfg.set_range(minimum, maximum, interval)
        minimum, maximum = tonumber(minimum), tonumber(maximum)
        interval = interval == nil and cfg.intervals or tonumber(interval)
        if not minimum or not maximum or not interval or minimum ~= minimum or maximum ~= maximum or interval ~= interval or interval <= 0
            or minimum == math.huge or minimum == -math.huge or maximum == math.huge or maximum == -math.huge
            or interval == math.huge or interval == -math.huge then
            return false, "Range requires finite min/max and a positive interval"
        end
        if minimum > maximum then return false, "Range min must be less than or equal to max" end
        cfg.min, cfg.max, cfg.intervals = minimum, maximum, interval
        cfg.default = clamp(cfg.default, minimum, maximum)
        return library:with_change_context("code", "commit", function()
            cfg.set(clamp(cfg.value, minimum, maximum))
            return true
        end)
    end

    if library.is_mobile then
        local function update(position)
            local width = max(1, items.track.AbsoluteSize.X)
            local fraction = clamp((position.X - items.track.AbsolutePosition.X) / width, 0, 1)
            cfg.set(cfg.min + (cfg.max - cfg.min) * fraction, {source = "user", phase = "change"})
        end
        items.slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                and library:begin_pointer_drag(input, update, function()
                if cfg._destroyed then return end
                cfg.dragging = false
                library:tween(items.value, {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2)
                library:commit_control(cfg, {source = "user"}, flags[cfg.flag])
                end, cfg) then
                cfg.dragging = true
                update(input.Position)
                library:tween(items.value, {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
    else
        items[ "slider" ].MouseButton1Down:Connect(function()
            if library:begin_pointer_drag(nil, function(position)
                local size_x = clamp((position.X - items[ "track" ].AbsolutePosition.X) / max(1, items[ "track" ].AbsoluteSize.X), 0, 1)
                cfg.set(((cfg.max - cfg.min) * size_x) + cfg.min, {source = "user", phase = "change"})
            end, function()
                if cfg._destroyed then return end
                cfg.dragging = false
                library:tween(items[ "value" ], {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2)
                library:commit_control(cfg, {source = "user"}, flags[cfg.flag])
            end, cfg) then
                cfg.dragging = true
                local position = uis:GetMouseLocation()
                local size_x = clamp((position.X - items[ "track" ].AbsolutePosition.X) / max(1, items[ "track" ].AbsoluteSize.X), 0, 1)
                cfg.set(((cfg.max - cfg.min) * size_x) + cfg.min, {source = "user", phase = "change"})
                library:tween(items[ "value" ], {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
    end

    if cfg.separator then
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end

    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        local numeric = tonumber(value)
        if not numeric or numeric ~= numeric or numeric == math.huge or numeric == -math.huge then
            return false, nil, "expected a finite number"
        end
        if numeric < cfg.min or numeric > cfg.max then
            return false, nil, "value is outside the slider range"
        end
        return true, numeric
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "slider")
    library:attach_control(cfg, items.slider_object, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Stepper.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local clamp = __kaeryn.clamp
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local fonts = __kaeryn.fonts

function library:stepper(options)
    options = library:normalize_options("stepper", options)
    local id, flag = library:resolve_identity(options, "stepper", self.name, true)
    local cfg = {
        id = id,
        control_type = "stepper",
        flag = flag,
        legacy_flags = options.legacy_flags,
        name = options.name,
        min = options.min,
        max = options.max,
        step = options.step,
        suffix = options.suffix,
        separator = options.separator,
        value = options.default,
        default = options.default,
        callback = options.callback,
        on_commit = options.on_commit,
        items = {},
    }
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements;
        Name = "NumericStepper";
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.name = library:create("TextLabel", {
        Parent = items.root;
        Name = "Name";
        Text = cfg.name;
        FontFace = fonts.small;
        TextSize = 15;
        TextColor3 = themes.preset.text_soft;
        TextXAlignment = Enum.TextXAlignment.Left;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.row = library:create("Frame", {
        Parent = items.root;
        Name = "StepperRow";
        Position = dim2(0, 0, 0, 23);
        Size = dim2(1, 0, 0, 30);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.decrease = library:create("TextButton", {
        Parent = items.row;
        Name = "Decrease";
        Size = dim2(0, 30, 1, 0);
        Text = "−";
        FontFace = fonts.font;
        TextSize = 17;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
    })
    items.input = library:create("TextBox", {
        Parent = items.row;
        Name = "Value";
        Position = dim2(0, 34, 0, 0);
        Size = dim2(1, -68, 1, 0);
        Text = "";
        PlaceholderText = "0";
        ClearTextOnFocus = false;
        TextXAlignment = Enum.TextXAlignment.Center;
        FontFace = fonts.small;
        TextSize = 14;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
    })
    items.increase = library:create("TextButton", {
        Parent = items.row;
        Name = "Increase";
        Position = dim2(1, -30, 0, 0);
        Size = dim2(0, 30, 1, 0);
        Text = "+";
        FontFace = fonts.font;
        TextSize = 17;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
    })
    for _, button in ipairs({items.decrease, items.input, items.increase}) do
        library:create("UICorner", {Parent = button; CornerRadius = dim(0, 4)})
    end
    items.error = library:create("TextLabel", {
        Parent = items.root;
        Name = "ValidationMessage";
        Position = dim2(0, 2, 0, 55);
        Size = dim2(1, -4, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        Text = "";
        TextSize = 12;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextColor3 = rgb(255, 112, 112);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Visible = false;
    })
    items.suffix = library:create("TextLabel", {
        Parent = items.row;
        Name = "Suffix";
        AnchorPoint = Vector2.new(1, 0.5);
        Position = dim2(1, -36, 0.5, 0);
        Size = dim2(0, 0, 1, 0);
        AutomaticSize = Enum.AutomaticSize.X;
        Text = cfg.suffix;
        TextSize = 12;
        TextColor3 = themes.preset.muted;
        FontFace = fonts.small;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Visible = cfg.suffix ~= "";
    })

    local function snap(value)
        return clamp(cfg.min + library:round(value - cfg.min, cfg.step), cfg.min, cfg.max)
    end

    local function render()
        items.input.Text = tostring(cfg.value)
        items.error.Visible = false
        items.error.Text = ""
    end

    function cfg.set(value, explicit_context)
        value = tonumber(value)
        if not value or value ~= value or value == math.huge or value == -math.huge then
            items.error.Text = "Enter a number"
            items.error.Visible = true
            return false, "expected a finite number"
        end
        cfg.value = snap(value)
        flags[cfg.flag] = cfg.value
        render()
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, cfg.value)
        return true
    end

    function cfg.set_range(minimum, maximum, step)
        minimum, maximum, step = tonumber(minimum), tonumber(maximum), step == nil and cfg.step or tonumber(step)
        if not minimum or not maximum or not step or minimum ~= minimum or maximum ~= maximum or step ~= step
            or minimum == math.huge or minimum == -math.huge or maximum == math.huge or maximum == -math.huge
            or step == math.huge or step == -math.huge or maximum < minimum or step <= 0 then
            return false, "invalid stepper range"
        end
        cfg.min, cfg.max, cfg.step = minimum, maximum, step
        local success = cfg.set(clamp(cfg.value, minimum, maximum), {source = "code", phase = "commit"})
        return success
    end

    local function commit_user_value(value)
        local success = cfg.set(value, {source = "user", phase = "change"})
        if success then
            library:commit_control(cfg, {source = "user"}, flags[cfg.flag])
            if cfg.on_commit then library:dispatch_control_callback(cfg, cfg.on_commit, {source = "user", phase = "commit"}, flags[cfg.flag]) end
        end
    end

    items.decrease.Activated:Connect(function()
        if cfg._enabled then commit_user_value(cfg.value - cfg.step) end
    end)
    items.increase.Activated:Connect(function()
        if cfg._enabled then commit_user_value(cfg.value + cfg.step) end
    end)
    items.input.FocusLost:Connect(function()
        if not cfg._enabled then render(); return end
        local value = tonumber(items.input.Text)
        if value then
            commit_user_value(value)
        else
            items.error.Text = "Enter a number"
            items.error.Visible = true
        end
    end)

    if cfg.separator then
        library:create("Frame", {
            AnchorPoint = Vector2.new(0, 1);
            Parent = self.items.elements;
            Position = dim2(0, 0, 1, 0);
            Size = dim2(1, 1, 0, 1);
            BackgroundColor3 = rgb(36, 36, 37);
            BorderSizePixel = 0;
        })
    end

    flags[cfg.flag] = nil
    render()
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
            return false, nil, "expected a finite number"
        end
        return true, clamp(value, cfg.min, cfg.max)
    end, cfg.legacy_flags)
    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    library:attach_control(cfg, items.root, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Textbox.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:textbox(options)
    options = library:normalize_options("textbox", options)
    local id, flag = library:resolve_identity(options, "textbox", self.name, true)
    local cfg = {
        id = id,
        control_type = "textbox",
        name = options.name or "TextBox",
        legacy_flags = options.legacy_flags,
        placeholder = options.placeholder,
        default = options.default or "",
        flag = flag,
        callback = options.callback or function() end,
        validator = options.validate,
        required = options.required,
        min_length = options.min_length,
        max_length = options.max_length,
        visible = options.visible ~= false,
        items = {};
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "textbox" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "textbox" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "textbox" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 19);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });

        items[ "input" ] = library:create( "TextBox" , {
            PlaceholderText = cfg.placeholder;
            FontFace = fonts.font;
            Text = "";
            Parent = items[ "right_components" ];
            Name = "\0";
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            PlaceholderColor3 = rgb(255, 255, 255);
            CursorPosition = -1;
            ClearTextOnFocus = false;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            TextColor3 = rgb(72, 72, 72);
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(1, 0, 0, 0);
            Size = dim2(1, -4, 0, 30);
            BackgroundColor3 = rgb(33, 33, 35)
        });

        library:create( "UICorner" , {
            Parent = items[ "input" ];
            CornerRadius = dim(0, 3)
        });

        library:create( "UIPadding" , {
            Parent = items[ "right_components" ];
            PaddingTop = dim(0, 4);
            PaddingRight = dim(0, 4)
        });

        items["error"] = library:create("TextLabel", {
            FontFace = fonts.small;
            TextColor3 = rgb(255, 112, 112);
            Text = "";
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            Visible = false;
            Parent = items["textbox"];
            Name = "ValidationMessage";
            Position = dim2(0, 5, 0, 51);
            Size = dim2(1, -10, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            TextSize = 12;
        })
    end

    local function validate_text(text)
        local length = utf8.len(text) or #text
        if cfg.required and text == "" then return false, "This field is required" end
        if cfg.min_length and length < cfg.min_length then return false, "Enter at least " .. tostring(cfg.min_length) .. " characters" end
        if cfg.max_length and length > cfg.max_length then return false, "Use " .. tostring(cfg.max_length) .. " characters or fewer" end
        if cfg.validator then
            local ok, valid, message = pcall(cfg.validator, text)
            if not ok then
                warn("[Kaeryn] validator failed for textbox '" .. tostring(cfg.name) .. "': " .. tostring(valid))
                return false, "This value could not be validated"
            end
            if valid ~= true then return false, type(message) == "string" and message or "Enter a valid value" end
        end
        return true
    end

    local function show_error(message)
        items.error.Text = message or ""
        items.error.Visible = message ~= nil and message ~= ""
    end

    function cfg.set(text, explicit_context)
        text = tostring(text or "")
        local valid, reason = validate_text(text)
        if not valid then
            show_error(reason)
            return false, reason
        end
        show_error(nil)
        if flags[cfg.flag] == text and items.input.Text == text then return end
        flags[cfg.flag] = text
        if items.input.Text ~= text then items.input.Text = text end
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, text)
        return true
    end

    items[ "input" ]:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(items[ "input" ].Text, {source = "user", phase = "change"})
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
        local valid = validate_text(items.input.Text)
        if valid then library:commit_control(cfg, {source = "user"}, flags[cfg.flag]) end
    end)

    local default_valid, default_error = validate_text(cfg.default)
    assert(default_valid, "Invalid textbox default: " .. tostring(default_error))
    if cfg.default then
        library:with_change_context("initialization", "initialize", cfg.set, cfg.default)
    end

    items.textbox.Visible = cfg.visible
    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "string" then return false, nil, "expected a string" end
        local valid, reason = validate_text(value)
        if not valid then return false, nil, reason end
        return true, value
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "textbox")
    library:attach_control(cfg, items.textbox, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Controls/Toggle.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

function library:toggle(options)
    options = library:normalize_options("toggle", options)
    local id, flag = library:resolve_identity(options, "toggle", self.name, true)
    local cfg = {
        id = id,
        control_type = "toggle",
        enabled = options.default == true,
        name = options.name or "Toggle",
        info = options.info or nil,
        flag = flag,
        legacy_flags = options.legacy_flags,

        type = options.type and string.lower(options.type) or "toggle";

        default = options.default or false,
        folding = options.folding or false,
        callback = options.callback or function() end,

        items = {};
        separator = options.separator;
    }

    flags[cfg.flag] = cfg.default

    local mobile_switch = library.is_mobile and cfg.type ~= "checkbox"
    local switch_width = mobile_switch and 42 or 40
    local switch_height = 22
    local thumb_size = mobile_switch and 16 or 14
    local thumb_y = (switch_height - 2 - thumb_size) / 2

    local items = cfg.items; do
        items[ "toggle" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "toggle" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        do
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info or "";
                Visible = cfg.info ~= nil and cfg.info ~= "";
                Parent = items[ "toggle" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        items[ "right_components" ] = library:create( "Frame" , {
            BackgroundTransparency = 1;
            Parent = items[ "toggle" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 9);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        if cfg.type == "checkbox" then
            items[ "toggle_button" ] = library:create( "TextButton" , {
                FontFace = fonts.small;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                Text = "";
                LayoutOrder = 2;
                AutoButtonColor = false;
                AnchorPoint = vec2(1, 0);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, 0, 0, 0);
                Size = dim2(0, 16, 0, 16);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = rgb(67, 67, 68)
            }); library:apply_theme(items[ "toggle_button" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle_button" ];
                CornerRadius = dim(0, 4)
            });

            items[ "outline" ] = library:create( "Frame" , {
                Parent = items[ "toggle_button" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(22, 22, 24)
            }); library:apply_theme(items[ "outline" ], "accent", "BackgroundColor3");

            items[ "tick" ] = library:create( "ImageLabel" , {
                ImageTransparency = 1;
                BorderColor3 = rgb(0, 0, 0);
                Image = "lucide:check";
                BackgroundTransparency = 1;
                Position = dim2(0, -1, 0, 0);
                Parent = items[ "outline" ];
                Size = dim2(1, 2, 1, 2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255);
                ZIndex = 1;
            });

            library:create( "UICorner" , {
                Parent = items[ "outline" ];
                CornerRadius = dim(0, 4)
            });

            library:create( "UIGradient" , {
                Enabled = false;
                Parent = items[ "outline" ];
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))}
            });
        else
            items[ "toggle_button" ] = library:create( "TextButton" , {
                FontFace = fonts.font;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                Text = "";
                LayoutOrder = 2;
                AutoButtonColor = false;
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, switch_width, 0, switch_height);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = themes.preset.accent
            }); library:apply_theme(items[ "toggle_button" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle_button" ];
                CornerRadius = dim(0, 999)
            });

            items[ "inline" ] = library:create( "Frame" , {
                Parent = items[ "toggle_button" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.accent
            }); library:apply_theme(items[ "inline" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "inline" ];
                CornerRadius = dim(0, 999)
            });

            items[ "circle" ] = library:create( "Frame" , {
                Parent = items[ "inline" ];
                Name = "\0";
                Position = dim2(1, -(thumb_size + 3), 0, thumb_y);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, thumb_size, 0, thumb_size);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            library:create( "UICorner" , {
                Parent = items[ "circle" ];
                CornerRadius = dim(0, 999)
            });
        end
    end;

    function cfg.set(bool)
        bool = bool == true
        cfg.enabled = bool
        if cfg.type == "checkbox" then
            library:tween(items[ "tick" ], {Rotation = bool and 0 or 45, ImageTransparency = bool and 0 or 1})
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(67, 67, 68)})
            library:tween(items[ "outline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(22, 22, 24)})
        else
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(62, 62, 66)}, Enum.EasingStyle.Quad)
            library:tween(items[ "inline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(48, 48, 52)}, Enum.EasingStyle.Quad)
            library:tween(items[ "circle" ], {
                BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(205, 205, 212),
                Position = bool and dim2(1, -(thumb_size + 3), 0, thumb_y) or dim2(0, 2, 0, thumb_y),
            }, Enum.EasingStyle.Quad)
        end

        if cfg.folding and cfg.items.elements then
            cfg.items.elements.Visible = bool and cfg._enabled ~= false and cfg._visible ~= false
        end

        flags[cfg.flag] = bool
        library:dispatch_control_callback(cfg, cfg.callback, nil, bool)
    end

    if cfg.folding then
        items.elements = library:create("Frame", {
            Parent = self.items.elements,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = cfg.enabled,
        })
        library:create("UIListLayout", {Parent = items.elements, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    end
    items[ "toggle" ].Activated:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    items[ "toggle_button" ].Activated:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    if cfg.separator then
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end

    library:with_change_context("initialization", "initialize", cfg.set, cfg.default)

    library:register_config_flag(cfg.flag, cfg.set, function(value)
        if type(value) ~= "boolean" then return false, nil, "expected a boolean" end
        return true, value
    end, cfg.legacy_flags)

    library:mobile_format_control(items, "toggle")
    library:attach_control(cfg, items.toggle, self)
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Core.luau"] = function(__kaeryn_require)
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
    local fonts = __kaeryn.fonts
    local themes = __kaeryn.themes
    local library = __kaeryn.library
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local used_flags = library.used_flags

library.used_ids = library.used_ids or {}
library.flag_migrations = library.flag_migrations or {}
library.controls_by_id = library.controls_by_id or {}
library.custom_control_types = library.custom_control_types or {}
library.deprecated_option_warnings = library.deprecated_option_warnings or {}

local function descriptor(types, default, extra)
    local result = {type = types, default = default}
    if extra then
        for key, value in pairs(extra) do result[key] = value end
    end
    return result
end

local common_fields = {
    id = descriptor("string"),
    flag = descriptor("string"),
    legacy_flags = descriptor("table", {}),
}

local function fields(base, values, include_config_fields)
    local result = {id = common_fields.id}
    if include_config_fields ~= false then
        result.flag = common_fields.flag
        result.legacy_flags = common_fields.legacy_flags
    end
    for key, value in pairs(base or {}) do result[key] = value end
    for key, value in pairs(values or {}) do result[key] = value end
    return result
end

local common_aliases = {Name = "name", Seperator = "separator", seperator = "separator"}
library.option_schemas = {
    toggle = {
        fields = fields({name = descriptor("string", "Toggle"), info = descriptor("string"), default = descriptor("boolean", false),
            type = descriptor("string", "toggle", {values = {"toggle", "checkbox"}}), folding = descriptor("boolean", false),
            callback = descriptor("function", function() end), separator = descriptor("boolean", false)}),
        aliases = common_aliases,
    },
    slider = {
        fields = fields({name = descriptor("string"), info = descriptor("string"), default = descriptor("number", 10),
            min = descriptor("number", 0), max = descriptor("number", 100), interval = descriptor("number", 1, {min = 0}),
            suffix = descriptor("string", ""), callback = descriptor("function", function() end), separator = descriptor("boolean", true),
            on_commit = descriptor("function")}),
        aliases = {Name = "name", Seperator = "separator", seperator = "separator", minimum = "min", maximum = "max",
            decimal = "interval", step = "interval", onCommit = "on_commit"},
    },
    dropdown = {
        fields = fields({name = descriptor("string"), info = descriptor("string"), items = descriptor("table", {""}),
            default = descriptor({"string", "table"}), callback = descriptor("function", function() end), multi = descriptor("boolean", false),
            scrolling = descriptor("boolean", false), searchable = descriptor("boolean"), width = descriptor("number", 130, {min = 1}), ignore = descriptor("boolean", false),
            separator = descriptor("boolean", true)}),
        aliases = common_aliases,
    },
    label = {
        fields = fields({name = descriptor("string", "Toggle"), info = descriptor("string"), enabled = descriptor("boolean"),
            separator = descriptor("boolean", false)}, nil, false),
        aliases = common_aliases,
    },
    colorpicker = {
        fields = fields({name = descriptor("string", "Color"), info = descriptor("string"), color = descriptor("Color3"), alpha = descriptor("number", nil, {min = 0, max = 1}),
            callback = descriptor("function", function() end), on_commit = descriptor("function"), separator = descriptor("boolean", false)}),
        aliases = common_aliases,
    },
    textbox = {
        fields = fields({name = descriptor("string", "TextBox"), placeholder = descriptor("string", "type here..."), default = descriptor("string", ""),
            callback = descriptor("function", function() end), visible = descriptor("boolean", true), required = descriptor("boolean", false),
            min_length = descriptor("number", nil, {min = 0}), max_length = descriptor("number", nil, {min = 0}), validate = descriptor("function")}),
        aliases = {Name = "name", placeholdertext = "placeholder", holder = "placeholder", holdertext = "placeholder"},
    },
    keybind = {
        fields = fields({name = descriptor("string"), key = descriptor({"string", "EnumItem"}), mode = descriptor("string", "Toggle", {values = {"Toggle", "Hold", "Always"}}),
            default = descriptor("boolean", false), ignore = descriptor("boolean", false), context = descriptor("string", "global"), callback = descriptor("function", function() end)}),
        aliases = {Name = "name"},
    },
    segmented = {
        fields = fields({name = descriptor("string", "Mode"), items = descriptor("table", {}), default = descriptor("string"),
            callback = descriptor("function", function() end), separator = descriptor("boolean", false)}),
        aliases = common_aliases,
    },
    stepper = {
        fields = fields({name = descriptor("string", "Value"), default = descriptor("number", 0),
            min = descriptor("number", 0), max = descriptor("number", 100), step = descriptor("number", 1, {min = 0}), suffix = descriptor("string", ""),
            callback = descriptor("function", function() end), on_commit = descriptor("function"), separator = descriptor("boolean", true)}),
        aliases = {Name = "name", Seperator = "separator", seperator = "separator"},
    },
    group = {
        fields = fields({name = descriptor("string", "Items"), min_items = descriptor("number", 0, {min = 0}), max_items = descriptor("number", 25, {min = 1}),
            callback = descriptor("function", function() end)}),
        aliases = {Name = "name"},
    },
    button = {
        fields = fields({name = descriptor("string", "TextBox"), callback = descriptor("function", function() end)}, nil, false),
        aliases = {Name = "name"},
    },
    list = {
        fields = fields({name = descriptor("string"), info = descriptor("string"), options = descriptor("table", {"1", "2", "3"}), default = descriptor("string"),
            callback = descriptor("function", function() end)}),
        aliases = common_aliases,
    },
    data_table = {
        fields = fields({name = descriptor("string", "Table"), info = descriptor("string"), columns = descriptor("table", {}),
            rows = descriptor("table", {}), default = descriptor({"string", "number"}), max_height = descriptor("number", 260, {min = 72}),
            row_height = descriptor("number", 30, {min = 20, max = 80}), sortable = descriptor("boolean", true),
            callback = descriptor("function", function() end), separator = descriptor("boolean", false)}),
        aliases = common_aliases,
    },
}

local function type_matches(value, expected)
    local expected_types = type(expected) == "table" and expected or {expected}
    for _, kind in ipairs(expected_types) do
        if kind == "EnumItem" and typeof(value) == "EnumItem" then return true end
        if kind == "Color3" and typeof(value) == "Color3" then return true end
        if kind == "function" and type(value) == "function" then return true end
        if kind ~= "EnumItem" and kind ~= "Color3" and type(value) == kind then return true end
    end
    return false
end

local function copy_default(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = item end
    return result
end

function library:normalize_options(control_type, options, schema)
    options = options or {}
    assert(type(options) == "table", control_type .. " options must be a table")
    schema = schema or self.option_schemas[control_type]
    assert(type(schema) == "table" and type(schema.fields) == "table", "No option schema registered for '" .. tostring(control_type) .. "'")

    local normalized = {}
    local aliases = schema.aliases or {}
    for key, value in pairs(options) do
        local canonical = aliases[key] or key
        if aliases[key] then
            local warning_key = control_type .. ":" .. tostring(key)
            if not self.deprecated_option_warnings[warning_key] then
                self.deprecated_option_warnings[warning_key] = true
                warn("[Kaeryn] option '" .. tostring(key) .. "' for " .. control_type .. " is deprecated; use '" .. canonical .. "'")
            end
        end
        if normalized[canonical] ~= nil then
            error("Conflicting options '" .. tostring(key) .. "' and '" .. canonical .. "' for " .. control_type, 2)
        end
        normalized[canonical] = value
    end

    for key in pairs(normalized) do
        if not schema.fields[key] then
            error("Unknown option '" .. tostring(key) .. "' for " .. control_type, 2)
        end
    end

    if control_type == "toggle" and type(normalized.type) == "string" then normalized.type = string.lower(normalized.type) end

    for key, rule in pairs(schema.fields) do
        if type(rule) == "string" then rule = {type = rule} end
        if normalized[key] == nil and rule.default ~= nil then normalized[key] = copy_default(rule.default) end
        local value = normalized[key]
        if value ~= nil and not type_matches(value, rule.type) then
            error("Invalid option '" .. key .. "' for " .. control_type .. ": expected " .. tostring(type(rule.type) == "table" and table.concat(rule.type, " or ") or rule.type), 2)
        end
        if type(value) == "number" then
            if value ~= value or value == math.huge or value == -math.huge then error("Option '" .. key .. "' for " .. control_type .. " must be finite", 2) end
            if rule.min and value < rule.min then error("Option '" .. key .. "' for " .. control_type .. " must be at least " .. tostring(rule.min), 2) end
            if rule.max and value > rule.max then error("Option '" .. key .. "' for " .. control_type .. " must be at most " .. tostring(rule.max), 2) end
        end
        if value ~= nil and rule.values and not table.find(rule.values, value) then
            error("Invalid option '" .. key .. "' for " .. control_type .. ": expected " .. table.concat(rule.values, ", "), 2)
        end
    end
    if normalized.legacy_flags ~= nil then
        local count, highest_index, seen = 0, 0, {}
        for index, old_flag in pairs(normalized.legacy_flags) do
            if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then error("Option 'legacy_flags' for " .. control_type .. " must be a dense array", 2) end
            if type(old_flag) ~= "string" or old_flag:gsub("%s", "") == "" then
                error("Option 'legacy_flags[" .. tostring(index) .. "]' for " .. control_type .. " must be a non-empty string", 2)
            end
            if seen[old_flag] then error("Option 'legacy_flags' for " .. control_type .. " contains duplicate flag '" .. old_flag .. "'", 2) end
            seen[old_flag] = true
            count += 1
            highest_index = math.max(highest_index, index)
        end
        if count ~= highest_index then error("Option 'legacy_flags' for " .. control_type .. " must be a dense array", 2) end
    end
    if control_type == "slider" then
        if normalized.max < normalized.min then error("Option 'max' for slider must be greater than or equal to 'min'", 2) end
        if normalized.interval <= 0 then error("Option 'interval' for slider must be greater than zero", 2) end
    end
    if control_type == "stepper" then
        if normalized.max < normalized.min then error("Option 'max' for stepper must be greater than or equal to 'min'", 2) end
        if normalized.step <= 0 then error("Option 'step' for stepper must be greater than zero", 2) end
        if normalized.default < normalized.min or normalized.default > normalized.max then error("Option 'default' for stepper must be inside its range", 2) end
    elseif control_type == "textbox" then
        if normalized.min_length and normalized.max_length and normalized.min_length > normalized.max_length then
            error("Option 'min_length' for textbox must be less than or equal to 'max_length'", 2)
        end
        for _, key in ipairs({"min_length", "max_length"}) do
            local value = normalized[key]
            if value and value % 1 ~= 0 then error("Option '" .. key .. "' for textbox must be an integer", 2) end
        end
    elseif control_type == "group" and normalized.max_items < normalized.min_items then
        error("Option 'max_items' for group must be greater than or equal to 'min_items'", 2)
    elseif control_type == "segmented" then
        local valid, reason = self:validate_option_list("dropdown", normalized.items)
        if not valid then error("Option 'items' for segmented: " .. reason, 2) end
        if #normalized.items < 2 or #normalized.items > 5 then error("Option 'items' for segmented must contain between 2 and 5 options", 2) end
        local enabled = 0
        for _, item in ipairs(normalized.items) do
            if type(item) == "table" and item.group ~= nil then error("Segmented items cannot use groups", 2) end
            if type(item) ~= "table" or not item.disabled then enabled += 1 end
        end
        if enabled < 2 or enabled > 5 then error("Option 'items' for segmented must have between 2 and 5 enabled options", 2) end
        if normalized.default ~= nil then
            local found = false
            for _, item in ipairs(normalized.items) do
                local value = type(item) == "table" and item.value or item
                local disabled = type(item) == "table" and item.disabled
                if value == normalized.default and not disabled then found = true; break end
            end
            if not found then error("Option 'default' for segmented must match an enabled option", 2) end
        end
    elseif control_type == "data_table" then
        local valid, reason = self:validate_data_table(normalized.columns, normalized.rows)
        if not valid then error("Invalid data_table options: " .. reason, 2) end
        if normalized.default ~= nil then
            local found = false
            for _, row in ipairs(normalized.rows) do
                if tostring(row.id) == tostring(normalized.default) then found = true; break end
            end
            if not found then error("Option 'default' for data_table must match a row id", 2) end
        end
    end
    if control_type == "dropdown" or control_type == "list" then
        local option_key = control_type == "dropdown" and "items" or "options"
        local valid, reason = self:validate_option_list(control_type, normalized[option_key])
        if not valid then error("Option '" .. option_key .. "' for " .. control_type .. ": " .. reason, 2) end
        if control_type == "list" and normalized.default ~= nil then
            local found = false
            for _, item in ipairs(normalized.options) do
                if tostring(item) == normalized.default then found = true; break end
            end
            if not found then error("Option 'default' for list must match one of its options", 2) end
        elseif control_type == "dropdown" and normalized.default ~= nil then
            local defaults = normalized.multi and normalized.default or {normalized.default}
            if type(defaults) ~= "table" then error("Option 'default' for dropdown must be a list when multi is true", 2) end
            local defaults_valid, defaults_reason = self:validate_option_list("dropdown", defaults)
            if not defaults_valid then error("Option 'default' for dropdown: " .. defaults_reason, 2) end
            for _, selected in ipairs(defaults) do
                if type(selected) ~= "string" then error("Option 'default' for dropdown must contain strings", 2) end
                local found = #normalized.items == 0
                for _, option in ipairs(normalized.items) do
                    if type(option) == "string" then
                        found = option == selected
                    elseif type(option) == "table" then
                        found = not option.disabled and (option.value == selected or option.label == selected or self:translate(option.label) == selected)
                    end
                    if found then break end
                end
                if not found then
                    error("Option 'default' for dropdown contains unknown option '" .. selected .. "'", 2)
                end
            end
        end
    end
    return normalized
end

function library:validate_option_list(control_type, options)
    if type(options) ~= "table" then return false, "must be a table" end
    local count, highest_index, seen = 0, 0, {}
    for index, option in pairs(options) do
        if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "must be a dense array" end
        if control_type == "dropdown" then
            if type(option) == "table" then
                for key in pairs(option) do
                    if key ~= "value" and key ~= "label" and key ~= "group" and key ~= "disabled" then
                        return false, "dropdown item has unknown field '" .. tostring(key) .. "'"
                    end
                end
                if type(option.value) ~= "string" then return false, "dropdown item value must be a string" end
                if option.label ~= nil and type(option.label) ~= "string" then return false, "dropdown item label must be a string" end
                if option.group ~= nil and type(option.group) ~= "string" then return false, "dropdown item group must be a string" end
                if option.disabled ~= nil and type(option.disabled) ~= "boolean" then return false, "dropdown item disabled must be a boolean" end
            elseif type(option) ~= "string" then
                return false, "items must contain strings or option tables"
            end
        end
        if control_type == "list" and type(option) ~= "string" and type(option) ~= "number" and type(option) ~= "boolean" then
            return false, "options must contain strings, numbers, or booleans"
        end
        local key = type(option) == "table" and option.value or tostring(option)
        if seen[key] then return false, "contains duplicate option '" .. key .. "'" end
        seen[key] = true
        count += 1
        highest_index = math.max(highest_index, index)
    end
    if count ~= highest_index then return false, "must be a dense array" end
    return true
end

function library:validate_data_table(columns, rows)
    if type(columns) ~= "table" or #columns == 0 then return false, "columns must be a non-empty array" end
    if type(rows) ~= "table" then return false, "rows must be an array" end

    local column_keys, column_count, fixed_widths, flexible_columns = {}, 0, 0, 0
    for index, column in pairs(columns) do
        if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "columns must be a dense array" end
        if type(column) ~= "table" then return false, "column " .. tostring(index) .. " must be a table" end
        for key in pairs(column) do
            if key ~= "key" and key ~= "label" and key ~= "width" and key ~= "sortable" then
                return false, "column " .. tostring(index) .. " has unknown field '" .. tostring(key) .. "'"
            end
        end
        if type(column.key) ~= "string" or column.key:gsub("%s", "") == "" then return false, "column " .. tostring(index) .. " needs a non-empty key" end
        if column_keys[column.key] then return false, "duplicate column key '" .. column.key .. "'" end
        if column.label ~= nil and type(column.label) ~= "string" then return false, "column '" .. column.key .. "' label must be a string" end
        if column.width ~= nil and (type(column.width) ~= "number" or column.width ~= column.width or column.width <= 0 or column.width > 1) then
            return false, "column '" .. column.key .. "' width must be between 0 and 1"
        end
        if column.width then fixed_widths += column.width else flexible_columns += 1 end
        if column.sortable ~= nil and type(column.sortable) ~= "boolean" then return false, "column '" .. column.key .. "' sortable must be a boolean" end
        column_keys[column.key] = true
        column_count += 1
    end
    if column_count ~= #columns then return false, "columns must be a dense array" end
    if fixed_widths > 1 or (flexible_columns > 0 and fixed_widths >= 1) then return false, "column widths leave no room for the remaining columns" end

    local row_ids, row_count = {}, 0
    for index, row in pairs(rows) do
        if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "rows must be a dense array" end
        if type(row) ~= "table" then return false, "row " .. tostring(index) .. " must be a table" end
        if (type(row.id) ~= "string" and type(row.id) ~= "number") or tostring(row.id):gsub("%s", "") == "" then
            return false, "row " .. tostring(index) .. " needs a non-empty string or numeric id"
        end
        if type(row.id) == "number" and (row.id ~= row.id or row.id == math.huge or row.id == -math.huge) then
            return false, "row " .. tostring(index) .. " id must be finite"
        end
        local id = tostring(row.id)
        if row_ids[id] then return false, "duplicate row id '" .. id .. "'" end
        row_ids[id] = true
        for key, value in pairs(row) do
            if key ~= "id" and not column_keys[key] then return false, "row '" .. id .. "' has unknown column '" .. tostring(key) .. "'" end
            if key ~= "id" and value ~= nil and type(value) ~= "string" and type(value) ~= "number" and type(value) ~= "boolean" then
                return false, "row '" .. id .. "' cell '" .. tostring(key) .. "' must be a string, number, or boolean"
            end
            if key ~= "id" and type(value) == "number" and (value ~= value or value == math.huge or value == -math.huge) then
                return false, "row '" .. id .. "' cell '" .. tostring(key) .. "' must be finite"
            end
        end
        row_count += 1
    end
    if row_count ~= #rows then return false, "rows must be a dense array" end
    return true
end

function library:tween(obj, properties, easing_style, time)
    if library.unloaded or not obj then return nil end
    for property, value in pairs(properties) do
        if typeof(value) == "Color3" and library.track_theme then
            library:track_theme(obj, property, value)
        end
    end
    local duration = (time or 0.25) * (themes.scale.motion_scale or 1)
    local tween = tween_service:Create(obj, TweenInfo.new(duration, easing_style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), properties)
    tween:Play()
    return tween
end

function library:resizify(frame, window_config)
    window_config = window_config or {min_size = frame.AbsoluteSize}
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
    local start_absolute
    local start

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
            start_absolute = frame.AbsoluteSize
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
            local minimum = window_config.min_size
            local maximum = window_config.max_size
            local min_width = min(minimum.X, viewport_x)
            local min_height = min(minimum.Y, viewport_y)
            local max_width = min(maximum and maximum.X or viewport_x, viewport_x)
            local max_height = min(maximum and maximum.Y or viewport_y, viewport_y)
            if max_width < min_width then min_width = max_width end
            if max_height < min_height then min_height = max_height end
            local width = clamp(start_absolute.X + input.Position.X - start.X, min_width, max_width)
            local height = clamp(start_absolute.Y + input.Position.Y - start.Y, min_height, max_height)

            local current_size = dim2(
                start_size.X.Scale,
                start_size.X.Offset + width - start_absolute.X,
                start_size.Y.Scale,
                start_size.Y.Offset + height - start_absolute.Y
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

local function slug(value)
    local normalized = string.lower(value):gsub("[^%w]+", "."):gsub("^%.+", ""):gsub("%.+$", "")
    return normalized
end

function library:legacy_flag(name, kind, owner_name)
    if type(name) ~= "string" or name:gsub("%s", "") == "" then return nil end
    local parts = {slug(tostring(kind or "control"))}
    if type(owner_name) == "string" and owner_name:gsub("%s", "") ~= "" then table.insert(parts, slug(owner_name)) end
    table.insert(parts, slug(name))
    return table.concat(parts, ".")
end

function library:resolve_flag(flag, name, kind, owner_name)
    local resolved = flag or self:legacy_flag(name, kind, owner_name)
    if type(resolved) ~= "string" or resolved:gsub("%s", "") == "" then
        error("Unnamed " .. tostring(kind) .. " needs options.id or options.flag for a stable config key", 2)
    end
    if used_flags[resolved] then
        local message = "duplicate flag '" .. resolved .. "'; pass a unique options.id or options.flag"
        warn("[Kaeryn] " .. message)
        error(message, 2)
    end
    used_flags[resolved] = true
    return resolved
end

function library:register_flag_migration(old_flag, new_flag)
    assert(type(old_flag) == "string" and old_flag:gsub("%s", "") ~= "", "old flag must be a non-empty string")
    assert(type(new_flag) == "string" and new_flag:gsub("%s", "") ~= "", "new flag must be a non-empty string")
    assert(old_flag ~= new_flag, "old and new flags must be different")
    assert(not used_flags[old_flag], "cannot migrate active flag '" .. old_flag .. "'")
    local existing = self.flag_migrations[old_flag]
    assert(existing == nil or existing == new_flag, "flag migration already targets '" .. tostring(existing) .. "'")
    local cursor, visited = new_flag, {[old_flag] = true}
    while self.flag_migrations[cursor] do
        assert(not visited[cursor], "flag migrations cannot contain a cycle")
        visited[cursor] = true
        cursor = self.flag_migrations[cursor]
    end
    assert(cursor ~= old_flag, "flag migrations cannot contain a cycle")
    self.flag_migrations[old_flag] = new_flag
    return true
end

function library:resolve_identity(options, kind, owner_name, persistent)
    options = options or {}
    local old_flag = self:legacy_flag(options.name, kind, owner_name)
    local flag
    if persistent then
        flag = options.flag or options.id or old_flag
        if not flag then error("Unnamed " .. kind .. " needs options.id or options.flag for a stable config key", 2) end
    end
    local id = options.id or flag or old_flag
    if not id then
        self.generated_control_id = (self.generated_control_id or 0) + 1
        id = kind .. "." .. tostring(self.generated_control_id)
    end
    if type(id) ~= "string" or id:gsub("%s", "") == "" then error("Control id must be a non-empty string", 2) end
    if self.used_ids[id] then
        if options.id ~= nil or options.flag ~= nil then error("Duplicate control id '" .. id .. "'", 2) end
        repeat
            self.generated_control_id = (self.generated_control_id or 0) + 1
            id = kind .. "." .. tostring(self.generated_control_id)
        until not self.used_ids[id]
    end
    if persistent then
        local previous_migrations = table.clone(self.flag_migrations)
        flag = self:resolve_flag(flag, options.name, kind, owner_name)
        local migrated, migration_error = pcall(function()
            if (options.id or options.flag) and old_flag and old_flag ~= flag then
                self:register_flag_migration(old_flag, flag)
            end
            for _, legacy_flag in ipairs(options.legacy_flags or {}) do
                if legacy_flag ~= flag then self:register_flag_migration(legacy_flag, flag) end
            end
        end)
        if not migrated then
            used_flags[flag] = nil
            table.clear(self.flag_migrations)
            for old_flag, new_flag in pairs(previous_migrations) do self.flag_migrations[old_flag] = new_flag end
            error(migration_error, 2)
        end
    end
    self.used_ids[id] = true
    return id, flag, old_flag
end

function library:register_config_flag(flag, setter, validator, legacy_flags)
    assert(type(flag) == "string" and used_flags[flag], "Kaeryn config flag was not reserved")
    assert(type(setter) == "function", "Kaeryn config setter must be a function")
    assert(type(validator) == "function", "Kaeryn config validator must be a function")
    assert(config_flags[flag] == nil, "Kaeryn config setter already exists for flag '" .. flag .. "'")
    if legacy_flags ~= nil then
        assert(type(legacy_flags) == "table", "legacy_flags must be an array of strings")
        local count, highest_index = 0, 0
        for index, old_flag in pairs(legacy_flags) do
            assert(type(index) == "number" and index >= 1 and index % 1 == 0, "legacy_flags must be an array of strings")
            assert(type(old_flag) == "string" and old_flag:gsub("%s", "") ~= "", "legacy_flags[" .. tostring(index) .. "] must be a non-empty string")
            count += 1
            highest_index = math.max(highest_index, index)
        end
        assert(count == highest_index, "legacy_flags must be a dense array of strings")

        local migrations = table.clone(self.flag_migrations)
        for _, old_flag in ipairs(legacy_flags) do
            if old_flag ~= flag then
                assert(not used_flags[old_flag], "cannot migrate active flag '" .. old_flag .. "'")
                assert(migrations[old_flag] == nil or migrations[old_flag] == flag, "flag migration already targets '" .. tostring(migrations[old_flag]) .. "'")
                local cursor, visited = flag, {[old_flag] = true}
                while migrations[cursor] do
                    assert(not visited[cursor], "flag migrations cannot contain a cycle")
                    visited[cursor] = true
                    cursor = migrations[cursor]
                end
                assert(cursor ~= old_flag, "flag migrations cannot contain a cycle")
                migrations[old_flag] = flag
            end
        end
        for _, old_flag in ipairs(legacy_flags) do
            if old_flag ~= flag then self:register_flag_migration(old_flag, flag) end
        end
    end
    config_flags[flag] = setter
    library.config_validators[flag] = validator
end

function library:with_change_context(source, phase, callback, ...)
    assert(type(callback) == "function", "change-context callback must be a function")
    local previous = self.change_context
    self.change_context = {source = source, phase = phase}
    local results = table.pack(pcall(callback, ...))
    self.change_context = previous
    if not results[1] then error(results[2], 2) end
    return table.unpack(results, 2, results.n)
end

local function callback_context(control, explicit)
    local current = library.change_context or {}
    local metadata = {
        source = (explicit and explicit.source) or current.source or "user",
        phase = (explicit and explicit.phase) or current.phase or "commit",
        id = control.id,
        flag = control.flag,
        name = control.name,
        type = control.control_type,
    }
    return metadata
end

local function log_callback_error(control, action, message, source)
    local identity = tostring(control.name or control.id or control.control_type or "custom control")
    warn("[Kaeryn] callback failed during " .. action .. " for '" .. identity .. "'"
        .. (control.id and " (id " .. control.id .. ")" or "")
        .. (control.flag and " (flag " .. control.flag .. ")" or "") .. ": " .. tostring(message))
    library.last_callback_error = {id = control.id, flag = control.flag, name = control.name, action = action,
        source = source or (library.change_context and library.change_context.source) or "user", error = tostring(message)}
end

function library:dispatch_control_callback(control, callback, explicit_context, ...)
    local metadata = callback_context(control, explicit_context)
    local args = table.pack(...)
    args.n += 1
    args[args.n] = metadata
    local callback_ok, callback_result = true, nil
    if type(callback) == "function" then
        callback_ok, callback_result = pcall(callback, table.unpack(args, 1, args.n))
        if not callback_ok then log_callback_error(control, metadata.source .. "/" .. metadata.phase, callback_result, metadata.source) end
    end
    control.last_change = metadata

    local listeners = control._changed_listeners or {}
    for _, listener in ipairs(listeners) do
        local listener_ok, listener_err = pcall(listener, table.unpack(args, 1, args.n))
        if not listener_ok then log_callback_error(control, metadata.source .. "/OnChanged", listener_err, metadata.source) end
    end
    if metadata.phase == "commit" then self:commit_control(control, metadata, table.unpack(args, 1, args.n - 1)) end
    return callback_ok, callback_result, metadata
end

function library:commit_control(control, metadata, ...)
    metadata = callback_context(control, metadata)
    metadata.phase = "commit"
    local args = table.pack(...)
    args.n += 1
    args[args.n] = metadata
    if type(control.on_commit) == "function" then
        local committed, commit_err = pcall(control.on_commit, table.unpack(args, 1, args.n))
        if not committed then log_callback_error(control, metadata.source .. "/OnCommit", commit_err, metadata.source) end
    end
    for _, listener in ipairs(control._committed_listeners or {}) do
        local listener_ok, listener_err = pcall(listener, table.unpack(args, 1, args.n))
        if not listener_ok then log_callback_error(control, metadata.source .. "/OnCommitted", listener_err, metadata.source) end
    end
end

local function connect_listener(control, list_name, callback)
    assert(type(callback) == "function", "listener must be a function")
    local listeners = control[list_name]
    table.insert(listeners, callback)
    local connection = {Connected = true}
    function connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        for index = #listeners, 1, -1 do
            if listeners[index] == callback then table.remove(listeners, index) end
        end
    end
    return connection
end

function library:attach_control(control, root, section)
    assert(type(control) == "table", "control handle must be a table")
    assert(type(control.id) == "string" and self.used_ids[control.id], "control handle needs a reserved id")
    control._ui_root = root
    control._section = section
    control._changed_listeners = control._changed_listeners or {}
    control._committed_listeners = control._committed_listeners or {}
    control._cleanup = control._cleanup or {}
    control._enabled = true
    control._visible = true
    control._attached = true
    self.controls_by_id[control.id] = control

    function control:OnChanged(callback)
        return connect_listener(self, "_changed_listeners", callback)
    end
    function control:OnCommitted(callback)
        return connect_listener(self, "_committed_listeners", callback)
    end
    function control:AddCleanup(callback)
        assert(type(callback) == "function", "cleanup must be a function")
        table.insert(self._cleanup, callback)
    end
    function control:Get()
        if self.flag then return library.flags[self.flag] end
        return self.value
    end
    function control:Set(...)
        if self._destroyed then return false, "This control has been destroyed" end
        if type(self.set) ~= "function" then return false, "This control does not have a value setter" end
        local values = table.pack(...)
        return library:with_change_context("code", "commit", function()
            local results = table.pack(self.set(table.unpack(values, 1, values.n)))
            if results.n == 0 or results[1] == nil then return true end
            return table.unpack(results, 1, results.n)
        end)
    end
    function control:SetVisible(visible)
        if self._destroyed or not self._ui_root or self._ui_root.Parent == nil then return false end
        local is_visible = visible == true
        if not is_visible then
            if library.cancel_pointer_drag then library:cancel_pointer_drag(self) end
            if type(self.set_visible) == "function" then pcall(self.set_visible, false) end
        end
        self._visible = is_visible
        self._ui_root.Visible = is_visible
        if self.control_type == "toggle" and self.items.elements then
            self.items.elements.Visible = is_visible and self._enabled and self.enabled == true
        end
        return true
    end
    function control:SetEnabled(enabled)
        if self._destroyed or not self._ui_root or self._ui_root.Parent == nil then return false end
        self._enabled = enabled == true
        if not self._enabled then
            if library.cancel_pointer_drag then library:cancel_pointer_drag(self) end
            if type(self.set_visible) == "function" then pcall(self.set_visible, false) end
            if self.control_type == "keybind" and self.binding then
                self.binding:Disconnect()
                self.binding = nil
                if self.refresh_key_label then self:refresh_key_label() end
            end
            if self.control_type == "keybind" and self.mode == "Hold" and self.active and self.set then
                self.set(false, {source = "code", phase = "change"})
            end
        end
        local ok = pcall(function() self._ui_root.Interactable = self._enabled end)
        if not ok then pcall(function() self._ui_root.Active = self._enabled end) end
        if self.control_type == "toggle" and self.items.elements then
            self.items.elements.Visible = self._visible and self._enabled and self.enabled == true
        end
        return true
    end
    function control:SetDescription(description)
        if self._destroyed then return false, "This control has been destroyed" end
        assert(type(description) == "string", "description must be a string")
        self.info = description
        local info = self._description_label or (self.items and self.items.info)
        if not info and self._ui_root and self._ui_root.Parent then
            local root = self._ui_root
            local layout = root:FindFirstChildOfClass("UIListLayout")
            local properties = {
                FontFace = fonts.small,
                TextColor3 = rgb(130, 130, 130),
                Text = description,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextSize = 13,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = dim2(1, -10, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = root,
            }
            if layout then
                properties.LayoutOrder = 10000
            else
                properties.Position = dim2(0, 5, 0, root.AbsoluteSize.Y + 4)
            end
            info = library:create("TextLabel", properties)
            self._description_label = info
        end
        if not info then return false, "This control has no visible UI root" end
        info.Text = description
        info.Visible = description ~= ""
        return true
    end
    function control:SetOptions(options)
        if self._destroyed then return false, "This control has been destroyed" end
        if type(self.refresh_options) ~= "function" then return false, "This control does not support options" end
        if type(options) ~= "table" then return false, "Options must be a table" end
        if self.control_type == "dropdown" or self.control_type == "list" or self.control_type == "segmented" then
            local valid, reason = library:validate_option_list(self.control_type == "segmented" and "dropdown" or self.control_type, options)
            if not valid then return false, reason end
        end
        return library:with_change_context("code", "commit", function() return self.refresh_options(options) end)
    end
    function control:SetRange(minimum, maximum, interval)
        if self._destroyed then return false, "This control has been destroyed" end
        if type(self.set_range) ~= "function" then return false, "This control does not support numeric ranges" end
        return self.set_range(minimum, maximum, interval)
    end
    function control:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        if library.cancel_pointer_drag then library:cancel_pointer_drag(self) end
        if type(self.set_visible) == "function" then pcall(self.set_visible, false) end
        for index = #self._cleanup, 1, -1 do pcall(self._cleanup[index]) end
        for index = #(self._connections or {}), 1, -1 do pcall(function() self._connections[index]:Disconnect() end) end
        table.clear(self._changed_listeners)
        table.clear(self._committed_listeners)
        if self._ui_root and self._ui_root.Parent then self._ui_root:Destroy() end
        if library.controls_by_id[self.id] == self then
            library.controls_by_id[self.id] = nil
            library.used_ids[self.id] = nil
            if self.flag then
                config_flags[self.flag] = nil
                library.config_validators[self.flag] = nil
                used_flags[self.flag] = nil
                library.flags[self.flag] = nil
                for old_flag, new_flag in pairs(library.flag_migrations) do
                    if new_flag == self.flag then library.flag_migrations[old_flag] = nil end
                end
            end
        end
    end
    return control
end

function library:register_control(control_type, factory, schema)
    assert(type(control_type) == "string" and control_type:match("^[%a][%w_]*$"), "custom control name must be an identifier")
    assert(type(factory) == "function", "custom control factory must be a function")
    local key = string.lower(control_type)
    assert(type(self[key]) ~= "function" and self.custom_control_types[key] == nil, "control type '" .. key .. "' is already registered")
    if schema ~= nil then assert(type(schema) == "table" and type(schema.fields) == "table", "custom control schema must define fields") end
    local custom_schema = {fields = fields({name = descriptor("string"), info = descriptor("string")}), aliases = {}}
    for alias, canonical in pairs(common_aliases) do custom_schema.aliases[alias] = canonical end
    for field, rule in pairs((schema and schema.fields) or {}) do custom_schema.fields[field] = rule end
    for alias, canonical in pairs((schema and schema.aliases) or {}) do custom_schema.aliases[alias] = canonical end
    self.custom_control_types[key] = {factory = factory, schema = custom_schema}
    return true
end

function library:custom_control(control_type, options)
    local section = self
    local key = string.lower(tostring(control_type or ""))
    local definition = self.custom_control_types[key]
    if not definition then error("Unknown custom control type '" .. key .. "'", 2) end
    local normalized = self:normalize_options(key, options, definition.schema)
    local prior_migrations = table.clone(self.flag_migrations)
    local id, flag = self:resolve_identity(normalized, key, self.name, normalized.flag ~= nil)
    normalized.id, normalized.flag = id, flag
    local ok, control = pcall(function()
        local result = definition.factory(section, normalized, library)
        assert(type(result) == "table", "custom control factory must return a control handle")
        assert(not result.id or result.id == id, "Custom control factories cannot replace their registered id")
        assert(not result.flag or result.flag == flag, "Custom control flags must be declared in options")
        result.id = id
        result.flag = result.flag or flag
        result.name = result.name or normalized.name
        result.control_type = key
        result.legacy_flags = result.legacy_flags or normalized.legacy_flags
        if not result._ui_root then result._ui_root = result.items and result.items.root end
        if not result._attached then library:attach_control(result, result._ui_root, section) end
        return result
    end)
    if not ok then
        self.used_ids[id] = nil
        if flag then
            self.used_flags[flag] = nil
            config_flags[flag] = nil
            self.config_validators[flag] = nil
            self.flags[flag] = nil
        end
        for old_flag, target_flag in pairs(self.flag_migrations) do
            if prior_migrations[old_flag] == nil and target_flag == flag then self.flag_migrations[old_flag] = nil end
        end
        error(control, 2)
    end
    return control
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

    end,
    ["src/Kaeryn/Dialogs.luau"] = function(__kaeryn_require)
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

    end,
    ["src/Kaeryn/Groups.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rgb = __kaeryn.rgb
    local insert = __kaeryn.insert
    local remove = __kaeryn.remove
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local flags = __kaeryn.flags
    local config_flags = __kaeryn.config_flags
    local fonts = __kaeryn.fonts

local row_meta = {}

local function prefix_options(row, options)
    if type(options) ~= "table" then return options end
    options = table.clone(options or {})
    local prefix = row._namespace .. "."
    if type(options.id) == "string" then options.id = prefix .. options.id end
    if type(options.flag) == "string" then options.flag = prefix .. options.flag end
    if type(options.legacy_flags) == "table" then
        local old_flags = {}
        for index, old_flag in ipairs(options.legacy_flags) do old_flags[index] = prefix .. old_flag end
        options.legacy_flags = old_flags
    end
    return options
end

function row_meta.__index(row, key)
    local method = library[key]
    if type(method) == "function" and library.option_schemas[key] then
        return function(_, options)
            local control = method(row, prefix_options(row, options))
            insert(row._controls, control)
            return control
        end
    end
    if key == "custom_control" then
        return function(_, control_type, options)
            local control = library.custom_control(row, control_type, prefix_options(row, options))
            insert(row._controls, control)
            return control
        end
    end
    return method
end

function library:group(options)
    options = library:normalize_options("group", options)
    local persistent = options.id ~= nil or options.flag ~= nil or #options.legacy_flags > 0
    local id, flag = library:resolve_identity(options, "group", self.name, persistent)
    local cfg = {
        id = id,
        flag = flag,
        control_type = "group",
        name = options.name,
        min_items = options.min_items,
        max_items = options.max_items,
        callback = options.callback,
        legacy_flags = options.legacy_flags,
        rows = {},
        by_key = {},
        next_key = 0,
        _destroyed = false,
        items = {},
    }
    setmetatable(cfg, library)
    local items = cfg.items

    items.root = library:create("Frame", {
        Parent = self.items.elements;
        Name = "RepeaterGroup";
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.heading = library:create("Frame", {
        Parent = items.root;
        Name = "GroupHeading";
        Size = dim2(1, 0, 0, 24);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.title = library:create("TextLabel", {
        Parent = items.heading;
        Name = "Name";
        Text = cfg.name;
        FontFace = fonts.small;
        TextSize = 14;
        TextColor3 = themes.preset.text_soft;
        TextXAlignment = Enum.TextXAlignment.Left;
        Size = dim2(1, -40, 1, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.add = library:create("TextButton", {
        Parent = items.heading;
        Name = "Add";
        AnchorPoint = Vector2.new(1, 0);
        Position = dim2(1, 0, 0, 0);
        Size = dim2(0, 34, 1, 0);
        Text = "+";
        FontFace = fonts.font;
        TextSize = 18;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
    })
    library:create("UICorner", {Parent = items.add; CornerRadius = dim(0, 4)})
    items.rows = library:create("Frame", {
        Parent = items.root;
        Name = "Rows";
        Position = dim2(0, 0, 0, 28);
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    library:create("UIListLayout", {Parent = items.rows; Padding = dim(0, 7); SortOrder = Enum.SortOrder.LayoutOrder})

    local function row_keys()
        local result = {}
        for _, row in ipairs(cfg.rows) do insert(result, row.key) end
        return result
    end

    local function changed(action, key, explicit_context)
        if flag then flags[flag] = row_keys() end
        if cfg._updating then return end
        library:dispatch_control_callback(cfg, cfg.callback, explicit_context, action, key, row_keys())
    end

    local function update_controls()
        items.add.Active = not cfg._destroyed and #cfg.rows < cfg.max_items
        items.add.TextTransparency = items.add.Active and 0 or 0.55
        for _, row in ipairs(cfg.rows) do
            row.items.remove.Visible = #cfg.rows > cfg.min_items
        end
    end

    local function make_row(key, title)
        local row = {
            key = key,
            name = id .. "." .. key,
            title = title or key,
            _namespace = id .. "." .. key,
            _controls = {},
            _group = cfg,
            items = {},
        }
        setmetatable(row, row_meta)
        row.items.root = library:create("Frame", {
            Parent = items.rows;
            Name = "GroupRow";
            LayoutOrder = #cfg.rows + 1;
            Size = dim2(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = themes.preset.surface_alt;
            BorderSizePixel = 0;
        })
        library:create("UICorner", {Parent = row.items.root; CornerRadius = dim(0, 5)})
        row.items.header = library:create("Frame", {
            Parent = row.items.root;
            Name = "Header";
            Size = dim2(1, 0, 0, 28);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        })
        row.items.title = library:create("TextLabel", {
            Parent = row.items.header;
            Name = "Title";
            Position = dim2(0, 8, 0, 0);
            Size = dim2(1, -42, 1, 0);
            Text = row.title;
            FontFace = fonts.small;
            TextSize = 13;
            TextColor3 = themes.preset.text_soft;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        })
        row.items.remove = library:create("TextButton", {
            Parent = row.items.header;
            Name = "Remove";
            AnchorPoint = Vector2.new(1, 0);
            Position = dim2(1, -5, 0, 3);
            Size = dim2(0, 22, 0, 22);
            Text = "×";
            FontFace = fonts.small;
            TextSize = 15;
            TextColor3 = themes.preset.muted;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            AutoButtonColor = false;
        })
        row.items.elements = library:create("Frame", {
            Parent = row.items.root;
            Name = "Elements";
            Position = dim2(0, 8, 0, 30);
            Size = dim2(1, -16, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        })
        library:create("UIListLayout", {Parent = row.items.elements; Padding = dim(0, 7); SortOrder = Enum.SortOrder.LayoutOrder})
        row.items.remove.Activated:Connect(function()
            if not cfg._destroyed then cfg:Remove(key, {source = "user", phase = "commit"}) end
        end)
        function row:SetTitle(value)
            if type(value) ~= "string" or value == "" then return false, "row title must be a non-empty string" end
            self.title = value
            self.items.title.Text = value
            return true
        end
        function row:Destroy()
            return cfg:Remove(self.key)
        end
        cfg.by_key[key] = row
        insert(cfg.rows, row)
        return row
    end

    local function erase_row(row)
        for index = #row._controls, 1, -1 do row._controls[index]:Destroy() end
        cfg.by_key[row.key] = nil
        for index, candidate in ipairs(cfg.rows) do
            if candidate == row then remove(cfg.rows, index); break end
        end
        if row.items.root.Parent then row.items.root:Destroy() end
    end

    function cfg:Add(key, title, explicit_context)
        if cfg._destroyed then return false, "group has been destroyed" end
        if #cfg.rows >= cfg.max_items then return false, "group has reached max_items" end
        if key == nil then
            repeat cfg.next_key += 1; key = "item-" .. tostring(cfg.next_key) until not cfg.by_key[key]
            title = title or ("Item " .. tostring(cfg.next_key))
        end
        if type(key) ~= "string" or key:gsub("%s", "") == "" then return false, "row key must be a non-empty string" end
        if title ~= nil and type(title) ~= "string" then return false, "row title must be a string" end
        if cfg.by_key[key] then return false, "row key already exists: " .. key end
        local row = make_row(key, title)
        update_controls()
        changed("add", key, explicit_context or {source = "code", phase = "commit"})
        return row
    end

    function cfg:Remove(key, explicit_context)
        if cfg._destroyed then return false, "group has been destroyed" end
        if #cfg.rows <= cfg.min_items then return false, "group cannot go below min_items" end
        local row = type(key) == "table" and key or cfg.by_key[key]
        if not row then return false, "unknown group row" end
        erase_row(row)
        for index, candidate in ipairs(cfg.rows) do candidate.items.root.LayoutOrder = index end
        update_controls()
        changed("remove", row.key, explicit_context or {source = "code", phase = "commit"})
        return true
    end

    function cfg:Move(key, index)
        if cfg._destroyed then return false, "group has been destroyed" end
        local row = cfg.by_key[key]
        if not row then return false, "unknown group row" end
        if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > #cfg.rows then return false, "row index is out of range" end
        local current
        for position, candidate in ipairs(cfg.rows) do if candidate == row then current = position; break end end
        if current == index then return true end
        remove(cfg.rows, current)
        table.insert(cfg.rows, index, row)
        for position, candidate in ipairs(cfg.rows) do candidate.items.root.LayoutOrder = position end
        changed("move", key, {source = "code", phase = "commit"})
        return true
    end

    function cfg:Get(key)
        if key ~= nil then return cfg.by_key[key] end
        return row_keys()
    end

    function cfg:Set(row_list, explicit_context)
        if cfg._destroyed then return false, "group has been destroyed" end
        if type(row_list) ~= "table" then return false, "group value must be an array of row keys" end
        local count, highest_index, seen = 0, 0, {}
        for index, key in pairs(row_list) do
            if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, "group value must be a dense array" end
            if type(key) ~= "string" or key == "" or seen[key] then return false, "group row keys must be unique non-empty strings" end
            seen[key] = true
            count += 1
            highest_index = math.max(highest_index, index)
        end
        if count ~= highest_index or count < cfg.min_items or count > cfg.max_items then return false, "group row count is outside its limits" end
        cfg._updating = true
        for _, row in ipairs(table.clone(cfg.rows)) do if not seen[row.key] then erase_row(row) end end
        for _, row_key in ipairs(row_list) do
            if not cfg.by_key[row_key] then cfg:Add(row_key) end
        end
        local ordered = {}
        for index, row_key in ipairs(row_list) do
            ordered[index] = cfg.by_key[row_key]
            ordered[index].items.root.LayoutOrder = index
        end
        cfg.rows = ordered
        cfg._updating = false
        update_controls()
        changed("set", nil, explicit_context or {source = "code", phase = "commit"})
        return true
    end

    function cfg:Destroy(from_root)
        if cfg._destroyed then return end
        cfg._destroyed = true
        for _, row in ipairs(table.clone(cfg.rows)) do
            for index = #row._controls, 1, -1 do row._controls[index]:Destroy() end
        end
        table.clear(cfg.rows)
        table.clear(cfg.by_key)
        if flag then
            config_flags[flag] = nil
            library.config_validators[flag] = nil
            library.used_flags[flag] = nil
            flags[flag] = nil
            for old_flag, new_flag in pairs(library.flag_migrations) do if new_flag == flag then library.flag_migrations[old_flag] = nil end end
        end
        library.used_ids[id] = nil
        if not from_root and items.root.Parent then items.root:Destroy() end
    end

    items.add.Activated:Connect(function()
        if not cfg._destroyed and #cfg.rows < cfg.max_items then cfg:Add(nil, nil, {source = "user", phase = "commit"}) end
    end)

    while #cfg.rows < cfg.min_items do
        cfg.next_key += 1
        local key = "item-" .. tostring(cfg.next_key)
        make_row(key, "Item " .. tostring(cfg.next_key))
    end
    if flag then flags[flag] = row_keys() end
    if flag then
        library:register_config_flag(flag, function(value) return cfg:Set(value, library.change_context) end, function(value)
            if type(value) ~= "table" then return false, nil, "expected a list of row keys" end
            local count, highest_index, seen = 0, 0, {}
            for index, key in pairs(value) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then return false, nil, "row keys must be a dense array" end
                if type(key) ~= "string" or key == "" or seen[key] then return false, nil, "row keys must be unique non-empty strings" end
                seen[key] = true
                count += 1
                highest_index = math.max(highest_index, index)
            end
            if count ~= highest_index or count < cfg.min_items or count > cfg.max_items then return false, nil, "row count is outside group limits" end
            return true, table.clone(value)
        end, cfg.legacy_flags)
    end
    items.root.Destroying:Connect(function()
        if not cfg._destroyed then cfg:Destroy(true) end
    end)
    update_controls()
    return cfg
end
end

    end,
    ["src/Kaeryn/IconRegistry.luau"] = function(__kaeryn_require)
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

    end,
    ["src/Kaeryn/Init.luau"] = function(__kaeryn_require)
local context = __kaeryn_require("src/Kaeryn/Bootstrap.luau")

__kaeryn_require("src/Kaeryn/Core.luau")(context)
__kaeryn_require("src/Kaeryn/Localization.luau")(context)
__kaeryn_require("src/Kaeryn/Config/ConfigManager.luau")(context)
__kaeryn_require("src/Kaeryn/Themes.luau")(context)
__kaeryn_require("src/Kaeryn/Lifecycle.luau")(context)
__kaeryn_require("src/Kaeryn/IconRegistry.luau")(context, __kaeryn_require("src/Kaeryn/LucideIcons.luau"))
__kaeryn_require("src/Kaeryn/Scopes.luau")(context)
__kaeryn_require("src/Kaeryn/InputManager.luau")(context)
__kaeryn_require("src/Kaeryn/KeybindManager.luau")(context)
__kaeryn_require("src/Kaeryn/Layout.luau")(context)
__kaeryn_require("src/Kaeryn/Groups.luau")(context)
__kaeryn_require("src/Kaeryn/Search.luau")(context)
__kaeryn_require("src/Kaeryn/Dialogs.luau")(context)
__kaeryn_require("src/Kaeryn/Window.luau")(context)
__kaeryn_require("src/Kaeryn/Navigation.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Toggle.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Slider.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Dropdown.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Label.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Colorpicker.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Segmented.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Stepper.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Textbox.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Keybind.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Button.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/Settings.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/List.luau")(context)
__kaeryn_require("src/Kaeryn/Config/ConfigUI.luau")(context)
__kaeryn_require("src/Kaeryn/Notifications.luau")(context)
__kaeryn_require("src/Kaeryn/Controls/DataTable.luau")(context)

return context.library

    end,
    ["src/Kaeryn/InputManager.luau"] = function(__kaeryn_require)
return function(__kaeryn)
local uis = __kaeryn.uis
local library = __kaeryn.library
local active_drag

local function same_touch(first, second)
    return first == second or (first and second
        and first.UserInputType == Enum.UserInputType.Touch
        and second.UserInputType == Enum.UserInputType.Touch
        and first.TouchId == second.TouchId)
end

local function contains(gui_object, position)
    if not gui_object or not gui_object.Parent or not gui_object.Visible then return false end
    local origin = gui_object.AbsolutePosition
    local size = gui_object.AbsoluteSize
    return size.X > 0 and size.Y > 0
        and position.X >= origin.X and position.X <= origin.X + size.X
        and position.Y >= origin.Y and position.Y <= origin.Y + size.Y
end

function library:begin_pointer_drag(input, on_changed, on_ended, owner)
    if active_drag then return false end
    if input and input.UserInputType ~= Enum.UserInputType.Touch then return false end
    active_drag = {
        input = input,
        on_changed = on_changed,
        on_ended = on_ended,
        owner = owner,
        touch = input ~= nil,
    }
    return true
end

function library:cancel_pointer_drag(owner)
    local drag = active_drag
    if owner and (not drag or drag.owner ~= owner) then return false end
    active_drag = nil
    if drag and type(drag.on_ended) == "function" then
        pcall(drag.on_ended)
    end
    return drag ~= nil
end

library:connection(uis.InputChanged, function(input)
    local drag = active_drag
    if not drag then return end
    local matches = drag.touch and same_touch(input, drag.input)
        or (not drag.touch and input.UserInputType == Enum.UserInputType.MouseMovement)
    if matches and type(drag.on_changed) == "function" then
        pcall(drag.on_changed, input.Position)
    end
end)

library:connection(uis.InputEnded, function(input)
    local drag = active_drag
    if not drag then return end
    local ended = drag.touch and same_touch(input, drag.input)
        or (not drag.touch and input.UserInputType == Enum.UserInputType.MouseButton1)
    if ended then library:cancel_pointer_drag() end
end)

library:connection(uis.InputBegan, function(input)
    local input_type = input.UserInputType
    if input_type ~= Enum.UserInputType.Touch and input_type ~= Enum.UserInputType.MouseButton1 then return end

    local current = library.current_open
    if not current or not current.items then return end
    local items = current.items
    local position = input.Position
    if contains(items.dropdown_holder, position)
        or contains(items.colorpicker_holder, position)
        or contains(items.outline, position)
        or contains(items.dropdown, position)
        or contains(items.colorpicker, position)
        or contains(items.tick, position) then
        return
    end

    library:close_element()
end)
end

    end,
    ["src/Kaeryn/KeybindManager.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local uis = __kaeryn.uis
    local library = __kaeryn.library
    local keys = __kaeryn.keys

local bindings = {}
local manager = {active_context = "default", capturing = nil}
library.keybind_manager = manager

local function selected_key(input)
    if input.UserInputType == Enum.UserInputType.Keyboard or string.find(input.UserInputType.Name, "Gamepad", 1, true) then
        return input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or nil
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3 then
        return input.UserInputType
    end
    return nil
end

local function same_key(first, second)
    return first ~= nil and first ~= "NONE" and first == second
end

local function scopes_overlap(first, second)
    return first == "global" or second == "global" or first == second
end

local function can_run(control)
    return not control._destroyed and control._enabled and control.key ~= "NONE"
        and (control.context == "global" or control.context == manager.active_context)
end

local function refresh_conflicts()
    for _, control in ipairs(bindings) do
        local conflict = false
        for _, other in ipairs(bindings) do
            if other ~= control and not other._destroyed and same_key(control.key, other.key)
                and scopes_overlap(control.context, other.context) then
                conflict = true
                break
            end
        end
        if control.items.conflict then control.items.conflict.Visible = conflict end
    end
end

function library:register_keybind(control)
    table.insert(bindings, control)
    refresh_conflicts()
end

function library:unregister_keybind(control)
    for index = #bindings, 1, -1 do
        if bindings[index] == control then table.remove(bindings, index) end
    end
    if manager.capturing == control then manager.capturing = nil end
    refresh_conflicts()
end

function library:clear_keybinds()
    self:cancel_keybind_capture()
    table.clear(bindings)
    manager.active_context = "default"
end

function library:get_keybind_conflicts(control)
    local conflicts = {}
    for _, other in ipairs(bindings) do
        if other ~= control and not other._destroyed and same_key(control.key, other.key)
            and scopes_overlap(control.context, other.context) then
            table.insert(conflicts, other)
        end
    end
    return conflicts
end

function library:set_keybind_context(context)
    if context == nil then context = "default" end
    assert(type(context) == "string" and context:gsub("%s", "") ~= "", "keybind context must be a non-empty string")
    manager.active_context = context
    for _, binding in ipairs(bindings) do
        if binding.mode == "Hold" and binding.active and binding.context ~= "global" and binding.context ~= context then
            library:with_change_context("user", "change", binding.set, false)
        end
    end
    return true
end

function library:cancel_keybind_capture(control)
    if control and manager.capturing ~= control then return false end
    local previous = manager.capturing
    if not previous then return false end
    manager.capturing = nil
    local token = previous.binding
    previous.binding = nil
    if token then token.Connected = false end
    if previous.refresh_key_label then previous:refresh_key_label() end
    return true
end

function library:begin_keybind_capture(control)
    if control._destroyed or not control._enabled then return nil end
    self:cancel_keybind_capture()
    manager.capturing = control
    local token = {Connected = true}
    function token:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        library:cancel_keybind_capture(control)
    end
    control.binding = token
    if control.refresh_key_label then control:refresh_key_label() end
    return token
end

library:connection(uis.InputBegan, function(input, game_processed)
    local control = manager.capturing
    if control then
        local key = selected_key(input)
        if key then
            library:with_change_context("user", "commit", control.set, key == Enum.KeyCode.Escape and "NONE" or key)
            library:cancel_keybind_capture(control)
        end
        return
    end
    if game_processed or uis:GetFocusedTextBox() then return end

    local key = selected_key(input)
    local matches = {}
    for _, binding in ipairs(bindings) do
        if can_run(binding) and same_key(binding.key, key) then table.insert(matches, binding) end
    end
    if #matches ~= 1 then return end

    local binding = matches[1]
    if binding.mode == "Toggle" then
        library:with_change_context("user", "change", binding.set, not binding.active)
    elseif binding.mode == "Hold" then
        library:with_change_context("user", "change", binding.set, true)
    end
end)

library:connection(uis.InputEnded, function(input)
    local key = selected_key(input)
    for _, binding in ipairs(bindings) do
        if not binding._destroyed and binding._enabled and binding.mode == "Hold" and same_key(binding.key, key) and binding.active then
            library:with_change_context("user", "change", binding.set, false)
        end
    end
end)

library:connection(uis.WindowFocusReleased, function()
    for _, binding in ipairs(bindings) do
        if binding.mode == "Hold" and binding.active then library:with_change_context("user", "change", binding.set, false) end
    end
end)

library.get_keybind_label = function(key)
    return tostring(keys[key] or (typeof(key) == "EnumItem" and key.Name) or "NONE")
end

library.refresh_keybind_conflicts = refresh_conflicts
end

    end,
    ["src/Kaeryn/Layout.luau"] = function(__kaeryn_require)
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

function library:get_breakpoint(viewport)
    viewport = viewport or (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or vec2(1280, 800)
    if min(viewport.X, viewport.Y) < 620 then return "phone" end
    if viewport.X < 1024 or viewport.Y < 680 then return "tablet" end
    return "desktop"
end

function library:refresh_responsive_layout(window)
    if library.unloaded or not window or library.is_mobile then return end
    local camera = ws.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local breakpoint = library:get_breakpoint(viewport)
    library.breakpoint = breakpoint

    local items = window.items
    local main = items.main
    if not main or not main.Parent then return end
    local current = main.AbsoluteSize
    if window._responsive_applied_size and main.Size ~= window._responsive_applied_size then
        window._responsive_preferred_size = current
    elseif not window._responsive_preferred_size then
        window._responsive_preferred_size = current
    end
    local preferred = window._responsive_preferred_size
    local max_width = max(1, viewport.X - 16)
    local max_height = max(1, viewport.Y - 16)
    local width = math.min(preferred.X, max_width)
    local height = math.min(preferred.Y, max_height)
    if breakpoint == "phone" then
        width = max_width
        height = max_height
    end
    main.Size = dim_offset(width, height)
    window._responsive_applied_size = main.Size

    local left = clamp(main.Position.X.Offset, 0, max(0, viewport.X - width))
    local top = clamp(main.Position.Y.Offset, 0, max(0, viewport.Y - height))
    main.Position = dim_offset(left, top)

    local side = breakpoint == "phone" and 54 or breakpoint == "tablet" and 164 or 196
    local header = breakpoint == "phone" and 48 or 56
    local footer = 25
    library.responsive_sidebar_width = side
    library.responsive_header_height = header
    items.side_frame.Size = dim2(0, side, 1, -footer)
    items.multi_holder.Position = dim_offset(side, 0)
    items.multi_holder.Size = dim2(1, -side, 0, header)
    items.global_fade.Position = dim_offset(side, header)
    items.global_fade.Size = dim2(1, -side, 1, -(header + footer))
    items.title.Position = dim_offset(breakpoint == "phone" and 0 or 11, 0)
    items.title.Size = dim_offset(breakpoint == "phone" and side or side - 22, 48)
    items.title.TextSize = breakpoint == "phone" and 18 or breakpoint == "tablet" and 19 or 28
    items.title.TextXAlignment = breakpoint == "phone" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    items.title.TextWrapped = false
    items.title.TextTruncate = Enum.TextTruncate.AtEnd
    items.title.Text = breakpoint == "phone" and string.upper(window.name:match("[%w]") or "?")
        or string.format('<u>%s</u><font color = "rgb(255, 255, 255)">%s</font>', window.name, window.suffix)
    items.button_holder.Position = dim_offset(0, header)
    items.button_holder.Size = dim2(1, 0, 1, -(header + 4))
    for _, child in ipairs(items.button_holder:GetChildren()) do
        if child:IsA("TextLabel") then
            child.Visible = breakpoint ~= "phone"
            child.TextSize = breakpoint == "tablet" and 13 or 16
        end
    end

    for _, tab in ipairs(window.tabs or {}) do
        local tab_items = tab.items
        if tab_items and tab_items.tab_holder then
            tab_items.tab_holder.Position = dim_offset(side, header)
            tab_items.tab_holder.Size = dim2(1, -side, 1, -(header + footer))
            tab_items.multi_section_button_holder.Size = dim2(1, -82, 1, 0)
            tab_items.name.Visible = breakpoint ~= "phone"
            tab_items.name.AutomaticSize = Enum.AutomaticSize.None
            tab_items.name.Position = dim_offset(40, 0)
            tab_items.name.Size = dim2(1, -48, 1, 0)
            tab_items.name.TextWrapped = false
            tab_items.name.TextTruncate = Enum.TextTruncate.AtEnd
            tab_items.icon.Position = dim2(0, breakpoint == "phone" and 15 or 11, 0.5, 0)
            tab_items.icon.Size = dim_offset(breakpoint == "phone" and 24 or 22, breakpoint == "phone" and 24 or 22)
            if tab_items.compact_mark then
                tab_items.icon.Visible = breakpoint ~= "phone"
                tab_items.compact_mark.Visible = breakpoint == "phone"
            else
                tab_items.icon.Visible = true
            end
            tab_items.name.TextSize = breakpoint == "tablet" and 14 or 16
            tab_items.name.TextTruncate = breakpoint == "phone" and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
        end
    end
end

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
        name_offset = items.outline and -61 or -69
    elseif kind == "keybind" then
        name_offset = -82
    elseif kind == "label" then
        name_offset = -41
    end
    name.Size = dim2(1, name_offset, 0, 0)
    if kind == "toggle" then
        name.TextSize = 15
        name.TextWrapped = false
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.AutomaticSize = Enum.AutomaticSize.None
        name.Size = dim2(1, name_offset, 0, 22)
    end
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
            items.right_components.Position = dim2(1, -4, 0, kind == "toggle" and 0 or 4)
            if kind == "toggle" then
                items.right_components.Size = dim_offset(items.outline and 32 or 57, 26)
            else
                items.right_components.Size = dim_offset(kind == "keybind" and 68 or 26, 25)
            end
        end
        if kind == "keybind" then name.Size = dim2(1, -82, 0, 0) end
        if kind == "label" and not items.right_components then name.Size = dim2(1, -8, 0, 0) end
        if kind == "toggle" and items.toggle_button then
            items.toggle_button.Size = dim_offset(items.outline and 24 or 42, 22)
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
            elseif kind == "toggle" then
                items.info.TextSize = 13
                items.info.Position = dim_offset(4, label_y + 6)
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
    library.breakpoint = library:get_breakpoint(viewport)
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
            t.multi_section_button_holder.Size = dim2(1, -82, 1, 0)
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
    if library.unloaded then return false end
    if library.cancel_pointer_drag then library:cancel_pointer_drag() end
    if library.clear_keybinds then library:clear_keybinds() end
    if library.window and library.window._fire_destroy then library.window:_fire_destroy() end
    library.unloaded = true
    for index = #library.scopes, 1, -1 do
        local scope = library.scopes[index]
        if scope then scope:Destroy() end
    end
    if library.search_locale_connection then
        library.search_locale_connection:Disconnect()
        library.search_locale_connection = nil
    end
    for index = #library.locale_callbacks, 1, -1 do
        library.locale_callbacks[index]:Disconnect()
    end
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
    table.clear(library.notifications.records)
    for _, group in pairs(themes.utility) do
        for _, objects in pairs(group) do table.clear(objects) end
    end
    for _, objects in pairs(themes.scale_utility) do table.clear(objects) end
    return true
end

library.unload = library.unload_menu
end

    end,
    ["src/Kaeryn/Lifecycle.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local insert = __kaeryn.insert
    local library = __kaeryn.library

function library:connection(signal, callback, owner)
    local connection = signal:Connect(callback)

    insert(library.connections, connection)
    if owner then
        owner._connections = owner._connections or {}
        insert(owner._connections, connection)
    end

    return connection
end

function library:close_element(new_path)
    local previous = library.current_open
    if previous ~= new_path then
        library.current_open = nil
        if previous and type(previous.set_visible) == "function" then
            previous.open = false
            previous.set_visible(false)
        end
        library.current_open = new_path
    end
end

function library:create(instance, options)
    local ins = Instance.new(instance)

    for prop, value in options do
        if prop == "Image" and type(value) == "string" then
            value = library:resolve_icon(value)
        end
        ins[prop] = value
        if library.track_theme then library:track_theme(ins, prop, value) end
        if library.track_theme_scale then library:track_theme_scale(ins, prop, value) end
        if (prop == "Text" or prop == "PlaceholderText") and library._track_localized_text then
            library:_track_localized_text(ins, prop, value)
        end
    end

    return ins
end
end

    end,
    ["src/Kaeryn/Localization.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local library = __kaeryn.library
    local entries = setmetatable({}, {__mode = "k"})
    local listeners = {}
    local known_keys = {}
    library.locale_callbacks = listeners
    library.locale_keys = known_keys

    library.language = "en"
    library.locales = {
        en = {},
        es = {
            ["Search"] = "Buscar",
            ["Find"] = "Buscar",
            ["Search controls..."] = "Buscar controles...",
            ["Type to search controls"] = "Escribe para buscar controles",
            ["No controls found"] = "No se encontraron controles",
            ["Search options..."] = "Buscar opciones...",
            ["No options found"] = "No hay opciones",
            ["Notice"] = "Aviso",
            ["Confirm"] = "Confirmar",
            ["Cancel"] = "Cancelar",
            ["OK"] = "Aceptar",
            ["Enter a value..."] = "Escribe un valor...",
            ["Save"] = "Guardar",
            ["Load"] = "Cargar",
            ["Delete"] = "Eliminar",
            ["Configs"] = "Configuraciones",
            ["Settings"] = "Ajustes",
        },
    }

    local function valid_translation(value)
        if type(value) == "string" then return true end
        if type(value) ~= "table" or type(value.other) ~= "string" then return false end
        for key, translation in pairs(value) do
            if key ~= "zero" and key ~= "one" and key ~= "other" then return false end
            if type(translation) ~= "string" then return false end
        end
        return true
    end

    function library:translate(text, variables)
        if type(text) ~= "string" then return text end
        known_keys[text] = true
        local translations = self.locales[self.language]
        local translated = translations and translations[text]
        if translated == nil then translated = self.locales.en[text] or text end

        if type(variables) == "number" then variables = {count = variables} end
        if type(translated) == "table" then
            local count = type(variables) == "table" and variables.count or nil
            local category = count == 0 and "zero" or count == 1 and "one" or "other"
            translated = translated[category] or translated.other
        end
        if type(translated) ~= "string" then translated = text end
        if type(variables) == "table" then
            translated = translated:gsub("{([%w_]+)}", function(key)
                local value = variables[key]
                return value == nil and "{" .. key .. "}" or tostring(value)
            end)
        end
        return translated
    end

    function library:_track_localized_text(instance, property, text)
        if type(text) ~= "string" or text == "" then return end
        local instance_entries = entries[instance]
        if not instance_entries then
            instance_entries = {}
            entries[instance] = instance_entries
        end
        local translated = self:translate(text)
        instance_entries[property] = {key = text, current = translated}
        if translated ~= text then instance[property] = translated end
    end

    function library:localize(instance, key, property)
        property = property or "Text"
        assert(instance and type(key) == "string", "localize expects an instance and a string key")
        self:_track_localized_text(instance, property, key)
        return instance[property]
    end

    function library:set_language(language)
        assert(type(language) == "string" and language:match("^[%a][%w_-]*$"), "language must be a locale code")
        language = string.lower(language)
        if not self.locales[language] then return false, "Locale '" .. language .. "' is not registered" end
        self.language = language

        for instance, properties in pairs(entries) do
            local exists = pcall(function() return instance.Parent end)
            if not exists then
                entries[instance] = nil
            else
                for property, entry in pairs(properties) do
                    local ok, current = pcall(function() return instance[property] end)
                    if ok then
                        if current ~= entry.current then entry.key = current end
                        local translated = self:translate(entry.key)
                        pcall(function() instance[property] = translated end)
                        entry.current = translated
                    end
                end
            end
        end
        for _, listener in ipairs(listeners) do
            if listener.connected then
                local ok, err = pcall(listener.callback, language)
                if not ok then warn("[Kaeryn] language listener error: " .. tostring(err)) end
            end
        end
        return true
    end

    function library:register_locale(language, translations)
        assert(type(language) == "string" and language:match("^[%a][%w_-]*$"), "language must be a locale code")
        assert(type(translations) == "table", "translations must be a table")
        language = string.lower(language)
        local locale = self.locales[language] or {}
        for key, value in pairs(translations) do
            assert(type(key) == "string" and valid_translation(value), "translation values must be strings or plural tables with a string 'other' value")
            locale[key] = value
        end
        self.locales[language] = locale
        if self.language == language then return self:set_language(language) end
        return true
    end

    function library:validate_locale(language, reference_language)
        assert(type(language) == "string", "language must be a locale code")
        language = string.lower(language)
        reference_language = string.lower(reference_language or "en")
        local locale = self.locales[language]
        local reference = self.locales[reference_language]
        if not locale then return false, {error = "Locale '" .. language .. "' is not registered", missing = {}, invalid = {}} end
        if not reference then return false, {error = "Reference locale '" .. reference_language .. "' is not registered", missing = {}, invalid = {}} end

        local keys = {}
        for key in pairs(reference) do keys[key] = true end
        for key in pairs(known_keys) do keys[key] = true end
        local report = {language = language, reference = reference_language, missing = {}, invalid = {}}
        for key in pairs(keys) do
            if locale[key] == nil then
                table.insert(report.missing, key)
            elseif not valid_translation(locale[key]) then
                table.insert(report.invalid, key)
            end
        end
        table.sort(report.missing)
        table.sort(report.invalid)
        return #report.missing == 0 and #report.invalid == 0, report
    end

    function library:register_locale_callback(callback)
        assert(type(callback) == "function", "locale callback must be a function")
        local listener = {callback = callback, connected = true}
        table.insert(listeners, listener)
        function listener:Disconnect()
            if not self.connected then return end
            self.connected = false
            for index = #listeners, 1, -1 do
                if listeners[index] == self then table.remove(listeners, index) end
            end
        end
        return listener
    end
end

    end,
    ["src/Kaeryn/LucideIcons.luau"] = function(__kaeryn_require)
-- Copyright (c) 2025 Footages. MIT; see third_party/Footagesus-Icons-LICENSE.txt.
-- Vendored from Footagesus/Icons at 46d30c19ba7bc601d6ec794a48dc3a89568b1eec.
-- This file is automatically @generated by Tree Hub CLI.

return {
	["a-arrow-down"] = "rbxassetid://92867583610071",
	["a-arrow-up"] = "rbxassetid://132318504999733",
	["a-large-small"] = "rbxassetid://111491496660216",
	["accessibility"] = "rbxassetid://114029945302017",
	["activity"] = "rbxassetid://94212016861936",
	["air-vent"] = "rbxassetid://81517226012329",
	["airplay"] = "rbxassetid://115020759309179",
	["alarm-clock-check"] = "rbxassetid://76437352099157",
	["alarm-clock-minus"] = "rbxassetid://77364179863205",
	["alarm-clock-off"] = "rbxassetid://97904885874823",
	["alarm-clock-plus"] = "rbxassetid://80468822979214",
	["alarm-clock"] = "rbxassetid://126259032907535",
	["alarm-smoke"] = "rbxassetid://96965448419685",
	["album"] = "rbxassetid://127358331163602",
	["align-center-horizontal"] = "rbxassetid://81570549209434",
	["align-center-vertical"] = "rbxassetid://118470463752466",
	["align-end-horizontal"] = "rbxassetid://139502909745427",
	["align-end-vertical"] = "rbxassetid://96528869059554",
	["align-horizontal-distribute-center"] = "rbxassetid://97220086126656",
	["align-horizontal-distribute-end"] = "rbxassetid://106128590702022",
	["align-horizontal-distribute-start"] = "rbxassetid://76074660002997",
	["align-horizontal-justify-center"] = "rbxassetid://75732302772427",
	["align-horizontal-justify-end"] = "rbxassetid://129167626402283",
	["align-horizontal-justify-start"] = "rbxassetid://130161830325281",
	["align-horizontal-space-around"] = "rbxassetid://91646106782950",
	["align-horizontal-space-between"] = "rbxassetid://103886093046990",
	["align-start-horizontal"] = "rbxassetid://125674804697729",
	["align-start-vertical"] = "rbxassetid://105020230154823",
	["align-vertical-distribute-center"] = "rbxassetid://93791183635525",
	["align-vertical-distribute-end"] = "rbxassetid://139354223511433",
	["align-vertical-distribute-start"] = "rbxassetid://74961997822126",
	["align-vertical-justify-center"] = "rbxassetid://134754696166569",
	["align-vertical-justify-end"] = "rbxassetid://92569381441969",
	["align-vertical-justify-start"] = "rbxassetid://99692844572718",
	["align-vertical-space-around"] = "rbxassetid://96206012459190",
	["align-vertical-space-between"] = "rbxassetid://124998077349706",
	["ambulance"] = "rbxassetid://78599995190651",
	["ampersand"] = "rbxassetid://75272915739209",
	["ampersands"] = "rbxassetid://126947193455996",
	["amphora"] = "rbxassetid://137370389604364",
	["anchor"] = "rbxassetid://92181172123618",
	["angry"] = "rbxassetid://74237056000103",
	["annoyed"] = "rbxassetid://80064369052011",
	["antenna"] = "rbxassetid://99628923540956",
	["anvil"] = "rbxassetid://100203029845919",
	["aperture"] = "rbxassetid://83396154449972",
	["app-window-mac"] = "rbxassetid://79587216113811",
	["app-window"] = "rbxassetid://93142176757189",
	["apple"] = "rbxassetid://104349242902442",
	["archive-restore"] = "rbxassetid://78956681942188",
	["archive-x"] = "rbxassetid://75830115088395",
	["archive"] = "rbxassetid://122180020814574",
	["armchair"] = "rbxassetid://105384358373973",
	["arrow-big-down-dash"] = "rbxassetid://137987229582002",
	["arrow-big-down"] = "rbxassetid://81081164158885",
	["arrow-big-left-dash"] = "rbxassetid://97827621354677",
	["arrow-big-left"] = "rbxassetid://85973092492641",
	["arrow-big-right-dash"] = "rbxassetid://117825834972403",
	["arrow-big-right"] = "rbxassetid://82960676755590",
	["arrow-big-up-dash"] = "rbxassetid://99260194327483",
	["arrow-big-up"] = "rbxassetid://93136954756149",
	["arrow-down-0-1"] = "rbxassetid://120961896217875",
	["arrow-down-1-0"] = "rbxassetid://93474255891850",
	["arrow-down-a-z"] = "rbxassetid://99554596207900",
	["arrow-down-from-line"] = "rbxassetid://132045845807798",
	["arrow-down-left"] = "rbxassetid://102899325237364",
	["arrow-down-narrow-wide"] = "rbxassetid://129105261655061",
	["arrow-down-right"] = "rbxassetid://123109928624974",
	["arrow-down-to-dot"] = "rbxassetid://101675355931221",
	["arrow-down-to-line"] = "rbxassetid://87050478931254",
	["arrow-down-up"] = "rbxassetid://85780258549577",
	["arrow-down-wide-narrow"] = "rbxassetid://88461733425991",
	["arrow-down-z-a"] = "rbxassetid://76115279362232",
	["arrow-down"] = "rbxassetid://98764963621439",
	["arrow-left-from-line"] = "rbxassetid://87857914437603",
	["arrow-left-right"] = "rbxassetid://131324733048447",
	["arrow-left-to-line"] = "rbxassetid://118645136026970",
	["arrow-left"] = "rbxassetid://102531941843733",
	["arrow-right-from-line"] = "rbxassetid://74073639809355",
	["arrow-right-left"] = "rbxassetid://77015754304300",
	["arrow-right-to-line"] = "rbxassetid://78632510329852",
	["arrow-right"] = "rbxassetid://113692007244654",
	["arrow-up-0-1"] = "rbxassetid://105257823943016",
	["arrow-up-1-0"] = "rbxassetid://134175521693798",
	["arrow-up-a-z"] = "rbxassetid://77763416595160",
	["arrow-up-down"] = "rbxassetid://81019887641527",
	["arrow-up-from-dot"] = "rbxassetid://124408496673275",
	["arrow-up-from-line"] = "rbxassetid://95777664626453",
	["arrow-up-left"] = "rbxassetid://123490598231261",
	["arrow-up-narrow-wide"] = "rbxassetid://73006024672636",
	["arrow-up-right"] = "rbxassetid://129280608535523",
	["arrow-up-to-line"] = "rbxassetid://108818207813537",
	["arrow-up-wide-narrow"] = "rbxassetid://87437426951568",
	["arrow-up-z-a"] = "rbxassetid://107546173611884",
	["arrow-up"] = "rbxassetid://89282378235317",
	["arrows-up-from-line"] = "rbxassetid://133710016938621",
	["asterisk"] = "rbxassetid://88552752106723",
	["at-sign"] = "rbxassetid://79059152889146",
	["atom"] = "rbxassetid://73167696981648",
	["audio-lines"] = "rbxassetid://70930641819242",
	["audio-waveform"] = "rbxassetid://86462036665209",
	["award"] = "rbxassetid://132740088158419",
	["axe"] = "rbxassetid://132405197863294",
	["axis-3d"] = "rbxassetid://122438676546804",
	["baby"] = "rbxassetid://93472926933440",
	["backpack"] = "rbxassetid://140420225386018",
	["badge-alert"] = "rbxassetid://101829200081951",
	["badge-cent"] = "rbxassetid://133345018873154",
	["badge-check"] = "rbxassetid://76078495178149",
	["badge-dollar-sign"] = "rbxassetid://127139803581141",
	["badge-euro"] = "rbxassetid://120016477674659",
	["badge-indian-rupee"] = "rbxassetid://75659682309981",
	["badge-info"] = "rbxassetid://131995373201472",
	["badge-japanese-yen"] = "rbxassetid://99081574588615",
	["badge-minus"] = "rbxassetid://140321561183881",
	["badge-percent"] = "rbxassetid://121359224294885",
	["badge-plus"] = "rbxassetid://100325578561866",
	["badge-pound-sterling"] = "rbxassetid://119688217279444",
	["badge-question-mark"] = "rbxassetid://121464963737502",
	["badge-russian-ruble"] = "rbxassetid://108839463659864",
	["badge-swiss-franc"] = "rbxassetid://91447608372740",
	["badge-turkish-lira"] = "rbxassetid://137839965873529",
	["badge-x"] = "rbxassetid://122931434733842",
	["badge"] = "rbxassetid://116620312917084",
	["baggage-claim"] = "rbxassetid://86922213051957",
	["ban"] = "rbxassetid://90767043015246",
	["banana"] = "rbxassetid://140713420056179",
	["bandage"] = "rbxassetid://129660129590770",
	["banknote-arrow-down"] = "rbxassetid://139366449345199",
	["banknote-arrow-up"] = "rbxassetid://133758343082529",
	["banknote-x"] = "rbxassetid://95348701438065",
	["banknote"] = "rbxassetid://104840231536668",
	["barcode"] = "rbxassetid://118473018143689",
	["barrel"] = "rbxassetid://130647115622774",
	["baseline"] = "rbxassetid://124677132511270",
	["bath"] = "rbxassetid://76031400297942",
	["battery-charging"] = "rbxassetid://80139357470047",
	["battery-full"] = "rbxassetid://70906718268972",
	["battery-low"] = "rbxassetid://139659256984314",
	["battery-medium"] = "rbxassetid://105934079398915",
	["battery-plus"] = "rbxassetid://91931341486966",
	["battery-warning"] = "rbxassetid://115230083817257",
	["battery"] = "rbxassetid://70765800346189",
	["beaker"] = "rbxassetid://80902539995520",
	["bean-off"] = "rbxassetid://98164436608714",
	["bean"] = "rbxassetid://89491967076869",
	["bed-double"] = "rbxassetid://73820193212911",
	["bed-single"] = "rbxassetid://113423940880634",
	["bed"] = "rbxassetid://97726529032925",
	["beef"] = "rbxassetid://105850162318915",
	["beer-off"] = "rbxassetid://120333134736361",
	["beer"] = "rbxassetid://116404978807744",
	["bell-dot"] = "rbxassetid://93161277118810",
	["bell-electric"] = "rbxassetid://100277767266983",
	["bell-minus"] = "rbxassetid://126334890449727",
	["bell-off"] = "rbxassetid://78560046118930",
	["bell-plus"] = "rbxassetid://77014333795836",
	["bell-ring"] = "rbxassetid://94612128913941",
	["bell"] = "rbxassetid://97392696311902",
	["between-horizontal-end"] = "rbxassetid://81602774794322",
	["between-horizontal-start"] = "rbxassetid://76112384929846",
	["between-vertical-end"] = "rbxassetid://72817612571631",
	["between-vertical-start"] = "rbxassetid://85278312190301",
	["biceps-flexed"] = "rbxassetid://82004462003936",
	["bike"] = "rbxassetid://102930322246035",
	["binary"] = "rbxassetid://91751953950088",
	["binoculars"] = "rbxassetid://101460003267896",
	["biohazard"] = "rbxassetid://95956532900432",
	["bird"] = "rbxassetid://132284145117371",
	["birdhouse"] = "rbxassetid://83999157401433",
	["bitcoin"] = "rbxassetid://95459240442938",
	["blend"] = "rbxassetid://111679612185257",
	["blinds"] = "rbxassetid://71164165283925",
	["blocks"] = "rbxassetid://72212693357737",
	["bluetooth-connected"] = "rbxassetid://96315134002985",
	["bluetooth-off"] = "rbxassetid://80600044218117",
	["bluetooth-searching"] = "rbxassetid://100673019606426",
	["bluetooth"] = "rbxassetid://90506573139443",
	["bold"] = "rbxassetid://116141470019166",
	["bolt"] = "rbxassetid://102881251417484",
	["bomb"] = "rbxassetid://139223800924636",
	["bone"] = "rbxassetid://111242153474115",
	["book-a"] = "rbxassetid://104067275658465",
	["book-alert"] = "rbxassetid://124159928044853",
	["book-audio"] = "rbxassetid://109208148317037",
	["book-check"] = "rbxassetid://115999656081696",
	["book-copy"] = "rbxassetid://108543407492005",
	["book-dashed"] = "rbxassetid://127430784795958",
	["book-down"] = "rbxassetid://101011730128222",
	["book-headphones"] = "rbxassetid://108670200799574",
	["book-heart"] = "rbxassetid://112788845135284",
	["book-image"] = "rbxassetid://80808285757226",
	["book-key"] = "rbxassetid://116024426170705",
	["book-lock"] = "rbxassetid://118765061220571",
	["book-marked"] = "rbxassetid://73211024251780",
	["book-minus"] = "rbxassetid://112724962046282",
	["book-open-check"] = "rbxassetid://130848362492667",
	["book-open-text"] = "rbxassetid://100629528672195",
	["book-open"] = "rbxassetid://129845326810392",
	["book-plus"] = "rbxassetid://140267785051233",
	["book-text"] = "rbxassetid://94011772484232",
	["book-type"] = "rbxassetid://97817304725443",
	["book-up-2"] = "rbxassetid://130161620853665",
	["book-up"] = "rbxassetid://98640174079190",
	["book-user"] = "rbxassetid://128489189240523",
	["book-x"] = "rbxassetid://118754548186537",
	["book"] = "rbxassetid://125383279695672",
	["bookmark-check"] = "rbxassetid://93940443347986",
	["bookmark-minus"] = "rbxassetid://96807096039910",
	["bookmark-plus"] = "rbxassetid://121469724491615",
	["bookmark-x"] = "rbxassetid://112272342584706",
	["bookmark"] = "rbxassetid://121093149326239",
	["boom-box"] = "rbxassetid://99901322535868",
	["bot-message-square"] = "rbxassetid://96145330292478",
	["bot-off"] = "rbxassetid://140417690560013",
	["bot"] = "rbxassetid://80451686744860",
	["bottle-wine"] = "rbxassetid://131675403196921",
	["bow-arrow"] = "rbxassetid://124089655150375",
	["box"] = "rbxassetid://101768155599700",
	["boxes"] = "rbxassetid://136372617578355",
	["braces"] = "rbxassetid://117761094704041",
	["brackets"] = "rbxassetid://74368995728099",
	["brain-circuit"] = "rbxassetid://70547962410202",
	["brain-cog"] = "rbxassetid://132039205501538",
	["brain"] = "rbxassetid://92424107303177",
	["brick-wall-fire"] = "rbxassetid://92980588705520",
	["brick-wall-shield"] = "rbxassetid://75954432775071",
	["brick-wall"] = "rbxassetid://112878522258821",
	["briefcase-business"] = "rbxassetid://129135125207283",
	["briefcase-conveyor-belt"] = "rbxassetid://108665725653714",
	["briefcase-medical"] = "rbxassetid://119917756334087",
	["briefcase"] = "rbxassetid://96754188164225",
	["bring-to-front"] = "rbxassetid://132975903553748",
	["brush-cleaning"] = "rbxassetid://71728977448805",
	["brush"] = "rbxassetid://127035535799640",
	["bubbles"] = "rbxassetid://106183424168227",
	["bug-off"] = "rbxassetid://88020025049245",
	["bug-play"] = "rbxassetid://80107955888092",
	["bug"] = "rbxassetid://83626408925438",
	["building-2"] = "rbxassetid://77873775611951",
	["building"] = "rbxassetid://110616258983082",
	["bus-front"] = "rbxassetid://89863432456045",
	["bus"] = "rbxassetid://133798469717463",
	["cable-car"] = "rbxassetid://128643682205596",
	["cable"] = "rbxassetid://128449944504901",
	["cake-slice"] = "rbxassetid://136769828413242",
	["cake"] = "rbxassetid://103131590503275",
	["calculator"] = "rbxassetid://74915716529646",
	["calendar-1"] = "rbxassetid://98458364171044",
	["calendar-arrow-down"] = "rbxassetid://108415736543437",
	["calendar-arrow-up"] = "rbxassetid://70574654109118",
	["calendar-check-2"] = "rbxassetid://120231170248276",
	["calendar-check"] = "rbxassetid://71551019465748",
	["calendar-clock"] = "rbxassetid://119132152594595",
	["calendar-cog"] = "rbxassetid://122402172360287",
	["calendar-days"] = "rbxassetid://99072017568595",
	["calendar-fold"] = "rbxassetid://117368871270394",
	["calendar-heart"] = "rbxassetid://88839008103676",
	["calendar-minus-2"] = "rbxassetid://98846170279891",
	["calendar-minus"] = "rbxassetid://137354318924383",
	["calendar-off"] = "rbxassetid://109726151749217",
	["calendar-plus-2"] = "rbxassetid://112264562093883",
	["calendar-plus"] = "rbxassetid://125266115249843",
	["calendar-range"] = "rbxassetid://103641849247576",
	["calendar-search"] = "rbxassetid://92010083223634",
	["calendar-sync"] = "rbxassetid://78082218499697",
	["calendar-x-2"] = "rbxassetid://107518051061147",
	["calendar-x"] = "rbxassetid://106703374806500",
	["calendar"] = "rbxassetid://114792700814035",
	["camera-off"] = "rbxassetid://81057636835256",
	["camera"] = "rbxassetid://79950339943067",
	["candy-cane"] = "rbxassetid://71689468772492",
	["candy-off"] = "rbxassetid://110232752314832",
	["candy"] = "rbxassetid://107812129154678",
	["cannabis"] = "rbxassetid://98792006538601",
	["captions-off"] = "rbxassetid://105223545364193",
	["captions"] = "rbxassetid://104960225031445",
	["car-front"] = "rbxassetid://87380942739063",
	["car-taxi-front"] = "rbxassetid://122455403384057",
	["car"] = "rbxassetid://121065933462582",
	["caravan"] = "rbxassetid://120070979471783",
	["card-sim"] = "rbxassetid://134490550095771",
	["carrot"] = "rbxassetid://119118221444304",
	["case-lower"] = "rbxassetid://129303130603241",
	["case-sensitive"] = "rbxassetid://125410273293056",
	["case-upper"] = "rbxassetid://111633433531325",
	["cassette-tape"] = "rbxassetid://137065788934157",
	["cast"] = "rbxassetid://98202245922071",
	["castle"] = "rbxassetid://119275077187784",
	["cat"] = "rbxassetid://124252153404931",
	["cctv"] = "rbxassetid://99979894766624",
	["chart-area"] = "rbxassetid://123446436762366",
	["chart-bar-big"] = "rbxassetid://72336824986044",
	["chart-bar-decreasing"] = "rbxassetid://107217459044963",
	["chart-bar-increasing"] = "rbxassetid://88268905998571",
	["chart-bar-stacked"] = "rbxassetid://98478751113024",
	["chart-bar"] = "rbxassetid://105389816384108",
	["chart-candlestick"] = "rbxassetid://125676898615697",
	["chart-column-big"] = "rbxassetid://98598733210787",
	["chart-column-decreasing"] = "rbxassetid://73586137373563",
	["chart-column-increasing"] = "rbxassetid://120421615068601",
	["chart-column-stacked"] = "rbxassetid://86031449675105",
	["chart-column"] = "rbxassetid://97915995538580",
	["chart-gantt"] = "rbxassetid://88811660555940",
	["chart-line"] = "rbxassetid://101833156055618",
	["chart-network"] = "rbxassetid://104027882693561",
	["chart-no-axes-column-decreasing"] = "rbxassetid://123371717192542",
	["chart-no-axes-column-increasing"] = "rbxassetid://140383830943049",
	["chart-no-axes-column"] = "rbxassetid://94078751170351",
	["chart-no-axes-combined"] = "rbxassetid://121424233161912",
	["chart-no-axes-gantt"] = "rbxassetid://131936541106368",
	["chart-pie"] = "rbxassetid://113412261630136",
	["chart-scatter"] = "rbxassetid://108217585014571",
	["chart-spline"] = "rbxassetid://90307460742494",
	["check-check"] = "rbxassetid://95183312173858",
	["check-line"] = "rbxassetid://115122343485290",
	["check"] = "rbxassetid://93898873302694",
	["chef-hat"] = "rbxassetid://121744015002573",
	["cherry"] = "rbxassetid://139519182403183",
	["chess-bishop"] = "rbxassetid://121701705580238",
	["chess-king"] = "rbxassetid://90885687223462",
	["chess-knight"] = "rbxassetid://96467707042169",
	["chess-pawn"] = "rbxassetid://111318574652751",
	["chess-queen"] = "rbxassetid://98304702099749",
	["chess-rook"] = "rbxassetid://76223925830262",
	["chevron-down"] = "rbxassetid://134243273101015",
	["chevron-first"] = "rbxassetid://105243363790238",
	["chevron-last"] = "rbxassetid://89268452603731",
	["chevron-left"] = "rbxassetid://73780377692148",
	["chevron-right"] = "rbxassetid://92473583511724",
	["chevron-up"] = "rbxassetid://122444883127455",
	["chevrons-down-up"] = "rbxassetid://139404716013205",
	["chevrons-down"] = "rbxassetid://100524612205956",
	["chevrons-left-right-ellipsis"] = "rbxassetid://125035817741526",
	["chevrons-left-right"] = "rbxassetid://87910685945204",
	["chevrons-left"] = "rbxassetid://82617201744347",
	["chevrons-right-left"] = "rbxassetid://87149546686569",
	["chevrons-right"] = "rbxassetid://139121276490483",
	["chevrons-up-down"] = "rbxassetid://131833120209646",
	["chevrons-up"] = "rbxassetid://100467452364672",
	["chromium"] = "rbxassetid://128165143739006",
	["church"] = "rbxassetid://113714744350666",
	["cigarette-off"] = "rbxassetid://77797883078452",
	["circle-alert"] = "rbxassetid://83898160590116",
	["circle-arrow-down"] = "rbxassetid://95901860261344",
	["circle-arrow-left"] = "rbxassetid://102148876968988",
	["circle-arrow-out-down-left"] = "rbxassetid://140598097856694",
	["circle-arrow-out-down-right"] = "rbxassetid://119952801379305",
	["circle-arrow-out-up-left"] = "rbxassetid://132858212688303",
	["circle-arrow-out-up-right"] = "rbxassetid://81783743753173",
	["circle-arrow-right"] = "rbxassetid://70786767999559",
	["circle-arrow-up"] = "rbxassetid://84395128546494",
	["circle-check-big"] = "rbxassetid://93202927221730",
	["circle-check"] = "rbxassetid://85262178816537",
	["circle-chevron-down"] = "rbxassetid://137069490345718",
	["circle-chevron-left"] = "rbxassetid://130250009740827",
	["circle-chevron-right"] = "rbxassetid://125943696958495",
	["circle-chevron-up"] = "rbxassetid://111223574026321",
	["circle-dashed"] = "rbxassetid://126799443883746",
	["circle-divide"] = "rbxassetid://106398997754208",
	["circle-dollar-sign"] = "rbxassetid://91106238890387",
	["circle-dot-dashed"] = "rbxassetid://111451232827180",
	["circle-dot"] = "rbxassetid://82947033619201",
	["circle-ellipsis"] = "rbxassetid://91687150884779",
	["circle-equal"] = "rbxassetid://95133963751438",
	["circle-fading-arrow-up"] = "rbxassetid://104648212910336",
	["circle-fading-plus"] = "rbxassetid://91847890443490",
	["circle-gauge"] = "rbxassetid://108157549473765",
	["circle-minus"] = "rbxassetid://133556159576809",
	["circle-off"] = "rbxassetid://97923456918886",
	["circle-parking-off"] = "rbxassetid://128369410981252",
	["circle-parking"] = "rbxassetid://124034962915196",
	["circle-pause"] = "rbxassetid://139337739700879",
	["circle-percent"] = "rbxassetid://133311912860256",
	["circle-play"] = "rbxassetid://120408917249739",
	["circle-plus"] = "rbxassetid://113157136350384",
	["circle-pound-sterling"] = "rbxassetid://105476153083828",
	["circle-power"] = "rbxassetid://140676030155098",
	["circle-question-mark"] = "rbxassetid://97516698664325",
	["circle-slash-2"] = "rbxassetid://136766902186549",
	["circle-slash"] = "rbxassetid://125206439913049",
	["circle-small"] = "rbxassetid://73685402843600",
	["circle-star"] = "rbxassetid://120318414957104",
	["circle-stop"] = "rbxassetid://87400503942659",
	["circle-user-round"] = "rbxassetid://95489465399880",
	["circle-user"] = "rbxassetid://136220511671311",
	["circle-x"] = "rbxassetid://76821953846248",
	["circle"] = "rbxassetid://130359823580534",
	["circuit-board"] = "rbxassetid://107695264369312",
	["citrus"] = "rbxassetid://139018222976433",
	["clapperboard"] = "rbxassetid://132660667070200",
	["clipboard-check"] = "rbxassetid://92649798577170",
	["clipboard-clock"] = "rbxassetid://123957515687745",
	["clipboard-copy"] = "rbxassetid://125851897718493",
	["clipboard-list"] = "rbxassetid://96460215958908",
	["clipboard-minus"] = "rbxassetid://107968008485671",
	["clipboard-paste"] = "rbxassetid://74382068849983",
	["clipboard-pen-line"] = "rbxassetid://77711589791615",
	["clipboard-pen"] = "rbxassetid://75290966822953",
	["clipboard-plus"] = "rbxassetid://134285318675662",
	["clipboard-type"] = "rbxassetid://89949374318028",
	["clipboard-x"] = "rbxassetid://102222456890103",
	["clipboard"] = "rbxassetid://89601995828423",
	["clock-1"] = "rbxassetid://129363225422045",
	["clock-10"] = "rbxassetid://104332695855541",
	["clock-11"] = "rbxassetid://119023205186105",
	["clock-12"] = "rbxassetid://117789618723068",
	["clock-2"] = "rbxassetid://134710777209413",
	["clock-3"] = "rbxassetid://136385631189327",
	["clock-4"] = "rbxassetid://121808839832144",
	["clock-5"] = "rbxassetid://85082019959457",
	["clock-6"] = "rbxassetid://71009733505593",
	["clock-7"] = "rbxassetid://103111188546225",
	["clock-8"] = "rbxassetid://110059272125337",
	["clock-9"] = "rbxassetid://77610027126437",
	["clock-alert"] = "rbxassetid://97157344465162",
	["clock-arrow-down"] = "rbxassetid://92349314416042",
	["clock-arrow-up"] = "rbxassetid://111484286332629",
	["clock-check"] = "rbxassetid://85231630218857",
	["clock-fading"] = "rbxassetid://93205297285245",
	["clock-plus"] = "rbxassetid://93367709263150",
	["clock"] = "rbxassetid://121808839832144",
	["closed-caption"] = "rbxassetid://99832644030788",
	["cloud-alert"] = "rbxassetid://91967273658626",
	["cloud-check"] = "rbxassetid://97318598202432",
	["cloud-cog"] = "rbxassetid://96497764065749",
	["cloud-download"] = "rbxassetid://121435581993566",
	["cloud-drizzle"] = "rbxassetid://139525315752605",
	["cloud-fog"] = "rbxassetid://76650233148776",
	["cloud-hail"] = "rbxassetid://72320462748242",
	["cloud-lightning"] = "rbxassetid://133517088924849",
	["cloud-moon-rain"] = "rbxassetid://127667837827018",
	["cloud-moon"] = "rbxassetid://71938114737914",
	["cloud-off"] = "rbxassetid://131907154501444",
	["cloud-rain-wind"] = "rbxassetid://107414583736721",
	["cloud-rain"] = "rbxassetid://105547081967408",
	["cloud-snow"] = "rbxassetid://72307126270226",
	["cloud-sun-rain"] = "rbxassetid://99041604425705",
	["cloud-sun"] = "rbxassetid://86114208148727",
	["cloud-upload"] = "rbxassetid://93307473217005",
	["cloud"] = "rbxassetid://121226497050352",
	["cloudy"] = "rbxassetid://105360479023346",
	["clover"] = "rbxassetid://74925550436750",
	["club"] = "rbxassetid://108490365816628",
	["code-xml"] = "rbxassetid://130150477351734",
	["code"] = "rbxassetid://107380207681249",
	["codepen"] = "rbxassetid://135643965971885",
	["codesandbox"] = "rbxassetid://106911852964823",
	["coffee"] = "rbxassetid://106864403231093",
	["cog"] = "rbxassetid://116544501716299",
	["coins"] = "rbxassetid://116510979641930",
	["columns-2"] = "rbxassetid://113004100221850",
	["columns-3-cog"] = "rbxassetid://121589691981064",
	["columns-3"] = "rbxassetid://115223357399375",
	["columns-4"] = "rbxassetid://130807991968419",
	["combine"] = "rbxassetid://79908476334048",
	["command"] = "rbxassetid://93648221906330",
	["compass"] = "rbxassetid://115123411028382",
	["component"] = "rbxassetid://110027788875080",
	["computer"] = "rbxassetid://77480056459407",
	["concierge-bell"] = "rbxassetid://140384259310436",
	["cone"] = "rbxassetid://97759550688437",
	["construction"] = "rbxassetid://106539489968173",
	["contact-round"] = "rbxassetid://71907624112229",
	["contact"] = "rbxassetid://75868297719012",
	["container"] = "rbxassetid://91507237573499",
	["contrast"] = "rbxassetid://112796643981497",
	["cookie"] = "rbxassetid://73159504540002",
	["cooking-pot"] = "rbxassetid://94959783129799",
	["copy-check"] = "rbxassetid://91177247988892",
	["copy-minus"] = "rbxassetid://109524509933035",
	["copy-plus"] = "rbxassetid://113618379616952",
	["copy-slash"] = "rbxassetid://93805787810390",
	["copy-x"] = "rbxassetid://106557557978061",
	["copy"] = "rbxassetid://78979572434545",
	["copyleft"] = "rbxassetid://78559055698593",
	["copyright"] = "rbxassetid://129433635747111",
	["corner-down-left"] = "rbxassetid://90473561177832",
	["corner-down-right"] = "rbxassetid://86512767702085",
	["corner-left-down"] = "rbxassetid://139876989150630",
	["corner-left-up"] = "rbxassetid://126228268096099",
	["corner-right-down"] = "rbxassetid://89237035551302",
	["corner-right-up"] = "rbxassetid://112851237026705",
	["corner-up-left"] = "rbxassetid://84669279763024",
	["corner-up-right"] = "rbxassetid://115099889693145",
	["cpu"] = "rbxassetid://77549309870247",
	["creative-commons"] = "rbxassetid://90408210735312",
	["credit-card"] = "rbxassetid://99163352872346",
	["croissant"] = "rbxassetid://130710485559420",
	["crop"] = "rbxassetid://116344601101413",
	["cross"] = "rbxassetid://101833377863588",
	["crosshair"] = "rbxassetid://134242818164054",
	["crown"] = "rbxassetid://127843403295538",
	["cuboid"] = "rbxassetid://75618807946111",
	["cup-soda"] = "rbxassetid://121098640829562",
	["currency"] = "rbxassetid://90551250119972",
	["cylinder"] = "rbxassetid://90569677179169",
	["dam"] = "rbxassetid://76874486231393",
	["database-backup"] = "rbxassetid://103403210984699",
	["database-zap"] = "rbxassetid://131199921258418",
	["database"] = "rbxassetid://126791525623846",
	["decimals-arrow-left"] = "rbxassetid://120198500638749",
	["decimals-arrow-right"] = "rbxassetid://118263047146797",
	["delete"] = "rbxassetid://126279426372342",
	["dessert"] = "rbxassetid://71508133278830",
	["diameter"] = "rbxassetid://97429051503783",
	["diamond-minus"] = "rbxassetid://128989071438290",
	["diamond-percent"] = "rbxassetid://107717860105959",
	["diamond-plus"] = "rbxassetid://134701163723675",
	["diamond"] = "rbxassetid://105846996304890",
	["dice-1"] = "rbxassetid://112650149591038",
	["dice-2"] = "rbxassetid://112278274566793",
	["dice-3"] = "rbxassetid://118526270626312",
	["dice-4"] = "rbxassetid://113365650364004",
	["dice-5"] = "rbxassetid://72768312430593",
	["dice-6"] = "rbxassetid://85376239182543",
	["dices"] = "rbxassetid://81268120302865",
	["diff"] = "rbxassetid://135052708609715",
	["disc-2"] = "rbxassetid://91419420404185",
	["disc-3"] = "rbxassetid://135470554736048",
	["disc-album"] = "rbxassetid://74693460404344",
	["disc"] = "rbxassetid://101908120120777",
	["divide"] = "rbxassetid://136678191878278",
	["dna-off"] = "rbxassetid://89612426361540",
	["dna"] = "rbxassetid://74007982981741",
	["dock"] = "rbxassetid://121997427160252",
	["dog"] = "rbxassetid://71920105558570",
	["dollar-sign"] = "rbxassetid://127320961224019",
	["donut"] = "rbxassetid://72204922742657",
	["door-closed-locked"] = "rbxassetid://74027613267551",
	["door-closed"] = "rbxassetid://136249099949073",
	["door-open"] = "rbxassetid://91306356501736",
	["dot"] = "rbxassetid://137321056643916",
	["download"] = "rbxassetid://134814648082393",
	["drafting-compass"] = "rbxassetid://99701976182841",
	["drama"] = "rbxassetid://110297795801577",
	["dribbble"] = "rbxassetid://80231809663849",
	["drill"] = "rbxassetid://108644821412796",
	["drone"] = "rbxassetid://117299095794783",
	["droplet-off"] = "rbxassetid://119365002225172",
	["droplet"] = "rbxassetid://100597455015098",
	["droplets"] = "rbxassetid://140111846025180",
	["drum"] = "rbxassetid://136979060344890",
	["drumstick"] = "rbxassetid://104662462521709",
	["dumbbell"] = "rbxassetid://80277236776212",
	["ear-off"] = "rbxassetid://87421916192807",
	["ear"] = "rbxassetid://121894949934209",
	["earth-lock"] = "rbxassetid://88814147073745",
	["earth"] = "rbxassetid://76231597751076",
	["eclipse"] = "rbxassetid://114829622118222",
	["egg-fried"] = "rbxassetid://90622538210545",
	["egg-off"] = "rbxassetid://92288321309285",
	["egg"] = "rbxassetid://117851493400222",
	["ellipsis-vertical"] = "rbxassetid://117978708573781",
	["ellipsis"] = "rbxassetid://140019550645825",
	["equal-approximately"] = "rbxassetid://105382689698323",
	["equal-not"] = "rbxassetid://76864449458032",
	["equal"] = "rbxassetid://123467780715624",
	["eraser"] = "rbxassetid://133957773112410",
	["ethernet-port"] = "rbxassetid://75391715149314",
	["euro"] = "rbxassetid://72229646524456",
	["ev-charger"] = "rbxassetid://97906158859623",
	["expand"] = "rbxassetid://137492887754537",
	["external-link"] = "rbxassetid://129331830773832",
	["eye-closed"] = "rbxassetid://111063268625789",
	["eye-off"] = "rbxassetid://135928786788378",
	["eye"] = "rbxassetid://100033680381365",
	["facebook"] = "rbxassetid://72098528632192",
	["factory"] = "rbxassetid://102170024318039",
	["fan"] = "rbxassetid://78391400440696",
	["fast-forward"] = "rbxassetid://121615540167909",
	["feather"] = "rbxassetid://91872927606406",
	["fence"] = "rbxassetid://123451565578029",
	["ferris-wheel"] = "rbxassetid://79729205796176",
	["figma"] = "rbxassetid://134182122852301",
	["file-archive"] = "rbxassetid://77018106869967",
	["file-axis-3d"] = "rbxassetid://133912328009885",
	["file-badge"] = "rbxassetid://74564895394477",
	["file-box"] = "rbxassetid://119264004071690",
	["file-braces-corner"] = "rbxassetid://77253337986109",
	["file-braces"] = "rbxassetid://95314128621234",
	["file-chart-column-increasing"] = "rbxassetid://134449481172067",
	["file-chart-column"] = "rbxassetid://82048481252560",
	["file-chart-line"] = "rbxassetid://71954360551345",
	["file-chart-pie"] = "rbxassetid://81072193564497",
	["file-check-corner"] = "rbxassetid://76295552859171",
	["file-check"] = "rbxassetid://82604001452455",
	["file-clock"] = "rbxassetid://102325208830990",
	["file-code-corner"] = "rbxassetid://78293841184371",
	["file-code"] = "rbxassetid://130978036895504",
	["file-cog"] = "rbxassetid://101385347151368",
	["file-diff"] = "rbxassetid://96147216772241",
	["file-digit"] = "rbxassetid://89220220354580",
	["file-down"] = "rbxassetid://120650154178290",
	["file-exclamation-point"] = "rbxassetid://102821865889635",
	["file-headphone"] = "rbxassetid://100533735901986",
	["file-heart"] = "rbxassetid://132214916401696",
	["file-image"] = "rbxassetid://123334057511782",
	["file-input"] = "rbxassetid://124728604166044",
	["file-key"] = "rbxassetid://118790255921100",
	["file-lock"] = "rbxassetid://72170228691242",
	["file-minus-corner"] = "rbxassetid://119263271735124",
	["file-minus"] = "rbxassetid://111014798459222",
	["file-music"] = "rbxassetid://134948051536671",
	["file-output"] = "rbxassetid://92146832572911",
	["file-pen-line"] = "rbxassetid://104622936345006",
	["file-pen"] = "rbxassetid://79556179730240",
	["file-play"] = "rbxassetid://89006821567838",
	["file-plus-corner"] = "rbxassetid://76544604043974",
	["file-plus"] = "rbxassetid://78881710800060",
	["file-question-mark"] = "rbxassetid://127617422859576",
	["file-scan"] = "rbxassetid://129480105228213",
	["file-search-corner"] = "rbxassetid://90974165234008",
	["file-search"] = "rbxassetid://97780235974933",
	["file-signal"] = "rbxassetid://122070252538165",
	["file-sliders"] = "rbxassetid://85787771732439",
	["file-spreadsheet"] = "rbxassetid://134501869359270",
	["file-stack"] = "rbxassetid://138929929862605",
	["file-symlink"] = "rbxassetid://91865722036510",
	["file-terminal"] = "rbxassetid://116757454755476",
	["file-text"] = "rbxassetid://90496405707281",
	["file-type-corner"] = "rbxassetid://124902230275209",
	["file-type"] = "rbxassetid://115272552799361",
	["file-up"] = "rbxassetid://131173039312748",
	["file-user"] = "rbxassetid://99552018455009",
	["file-video-camera"] = "rbxassetid://81719056173960",
	["file-volume"] = "rbxassetid://111264764438958",
	["file-x-corner"] = "rbxassetid://87554136773609",
	["file-x"] = "rbxassetid://107333775515154",
	["file"] = "rbxassetid://74748492079329",
	["files"] = "rbxassetid://102806336233202",
	["film"] = "rbxassetid://120978945609706",
	["fingerprint"] = "rbxassetid://112173305232811",
	["fire-extinguisher"] = "rbxassetid://111643493006960",
	["fish-off"] = "rbxassetid://89756724887508",
	["fish-symbol"] = "rbxassetid://118475177681618",
	["fish"] = "rbxassetid://124360663785796",
	["flag-off"] = "rbxassetid://112944528856799",
	["flag-triangle-left"] = "rbxassetid://88045221285272",
	["flag-triangle-right"] = "rbxassetid://108292480304566",
	["flag"] = "rbxassetid://78183383236196",
	["flame-kindling"] = "rbxassetid://139728976917928",
	["flame"] = "rbxassetid://98218034436456",
	["flashlight-off"] = "rbxassetid://79780362871740",
	["flashlight"] = "rbxassetid://100286985600444",
	["flask-conical-off"] = "rbxassetid://112597970025298",
	["flask-conical"] = "rbxassetid://128406680901165",
	["flask-round"] = "rbxassetid://127508287324940",
	["flip-horizontal-2"] = "rbxassetid://103726993598186",
	["flip-horizontal"] = "rbxassetid://122937530107837",
	["flip-vertical-2"] = "rbxassetid://103836358956328",
	["flip-vertical"] = "rbxassetid://108003917346888",
	["flower-2"] = "rbxassetid://72934574245145",
	["flower"] = "rbxassetid://86129438272762",
	["focus"] = "rbxassetid://87493973153317",
	["fold-horizontal"] = "rbxassetid://92835712442240",
	["fold-vertical"] = "rbxassetid://108873727253656",
	["folder-archive"] = "rbxassetid://97312009460206",
	["folder-check"] = "rbxassetid://128492920904557",
	["folder-clock"] = "rbxassetid://111964836738545",
	["folder-closed"] = "rbxassetid://118286209350843",
	["folder-code"] = "rbxassetid://70624096349370",
	["folder-cog"] = "rbxassetid://85299519462846",
	["folder-dot"] = "rbxassetid://138687772725278",
	["folder-down"] = "rbxassetid://118044108459225",
	["folder-git-2"] = "rbxassetid://101394054141166",
	["folder-git"] = "rbxassetid://121885778095158",
	["folder-heart"] = "rbxassetid://79104747211105",
	["folder-input"] = "rbxassetid://90699920697871",
	["folder-kanban"] = "rbxassetid://78313285104072",
	["folder-key"] = "rbxassetid://85270407596791",
	["folder-lock"] = "rbxassetid://119201572260567",
	["folder-minus"] = "rbxassetid://85648718999010",
	["folder-open-dot"] = "rbxassetid://74741494767354",
	["folder-open"] = "rbxassetid://76018996254888",
	["folder-output"] = "rbxassetid://101532447937612",
	["folder-pen"] = "rbxassetid://112770491173911",
	["folder-plus"] = "rbxassetid://91865663406119",
	["folder-root"] = "rbxassetid://103333751154693",
	["folder-search-2"] = "rbxassetid://71276453442655",
	["folder-search"] = "rbxassetid://110568075123861",
	["folder-symlink"] = "rbxassetid://127485747227189",
	["folder-sync"] = "rbxassetid://91544602659796",
	["folder-tree"] = "rbxassetid://85577554337861",
	["folder-up"] = "rbxassetid://72008269765857",
	["folder-x"] = "rbxassetid://91699618247635",
	["folder"] = "rbxassetid://80846616596607",
	["folders"] = "rbxassetid://110351216219061",
	["footprints"] = "rbxassetid://139192589041315",
	["forklift"] = "rbxassetid://72030930983101",
	["forward"] = "rbxassetid://97545944739523",
	["frame"] = "rbxassetid://109080612832751",
	["framer"] = "rbxassetid://108384807262391",
	["frown"] = "rbxassetid://124407301067982",
	["fuel"] = "rbxassetid://106447647274511",
	["fullscreen"] = "rbxassetid://77793665526178",
	["funnel-plus"] = "rbxassetid://100780233821928",
	["funnel-x"] = "rbxassetid://70984385812555",
	["funnel"] = "rbxassetid://108829540827529",
	["gallery-horizontal-end"] = "rbxassetid://74672430161161",
	["gallery-horizontal"] = "rbxassetid://80004001442122",
	["gallery-thumbnails"] = "rbxassetid://136219289862706",
	["gallery-vertical-end"] = "rbxassetid://106461402088317",
	["gallery-vertical"] = "rbxassetid://119299431466725",
	["gamepad-2"] = "rbxassetid://92483947987410",
	["gamepad-directional"] = "rbxassetid://84342305212226",
	["gamepad"] = "rbxassetid://121607283959010",
	["gauge"] = "rbxassetid://110273524101447",
	["gavel"] = "rbxassetid://78952298198456",
	["gem"] = "rbxassetid://112904952151156",
	["georgian-lari"] = "rbxassetid://98084432591687",
	["ghost"] = "rbxassetid://113822048130017",
	["gift"] = "rbxassetid://109855212076373",
	["git-branch-minus"] = "rbxassetid://97385010649411",
	["git-branch-plus"] = "rbxassetid://125944221134316",
	["git-branch"] = "rbxassetid://90490195516649",
	["git-commit-horizontal"] = "rbxassetid://133646041800147",
	["git-commit-vertical"] = "rbxassetid://122098032990350",
	["git-compare-arrows"] = "rbxassetid://84874426520216",
	["git-compare"] = "rbxassetid://91945124438792",
	["git-fork"] = "rbxassetid://89954992404765",
	["git-graph"] = "rbxassetid://86166832019304",
	["git-merge"] = "rbxassetid://131833355158059",
	["git-pull-request-arrow"] = "rbxassetid://94507974577439",
	["git-pull-request-closed"] = "rbxassetid://78070600389091",
	["git-pull-request-create-arrow"] = "rbxassetid://127422677061091",
	["git-pull-request-create"] = "rbxassetid://105929577383926",
	["git-pull-request-draft"] = "rbxassetid://76173459869943",
	["git-pull-request"] = "rbxassetid://138463010991471",
	["github"] = "rbxassetid://120349554354380",
	["gitlab"] = "rbxassetid://114054627192933",
	["glass-water"] = "rbxassetid://115526102400988",
	["glasses"] = "rbxassetid://87936407455373",
	["globe-lock"] = "rbxassetid://134065526704402",
	["globe"] = "rbxassetid://114238209622913",
	["goal"] = "rbxassetid://120517954878160",
	["gpu"] = "rbxassetid://95577823614219",
	["graduation-cap"] = "rbxassetid://93771896340220",
	["grape"] = "rbxassetid://134760640415561",
	["grid-2x2-check"] = "rbxassetid://138468840220821",
	["grid-2x2-plus"] = "rbxassetid://91811610580247",
	["grid-2x2-x"] = "rbxassetid://72407303981388",
	["grid-2x2"] = "rbxassetid://99050491897640",
	["grid-3x2"] = "rbxassetid://95528684210010",
	["grid-3x3"] = "rbxassetid://70419024781206",
	["grip-horizontal"] = "rbxassetid://136255899715930",
	["grip-vertical"] = "rbxassetid://137183678565296",
	["grip"] = "rbxassetid://109058783556768",
	["group"] = "rbxassetid://107643418926671",
	["guitar"] = "rbxassetid://75915531867926",
	["ham"] = "rbxassetid://74465607934635",
	["hamburger"] = "rbxassetid://93086916815495",
	["hammer"] = "rbxassetid://83545120140895",
	["hand-coins"] = "rbxassetid://126990543175462",
	["hand-fist"] = "rbxassetid://83341608917591",
	["hand-grab"] = "rbxassetid://88867162163985",
	["hand-heart"] = "rbxassetid://117507367668412",
	["hand-helping"] = "rbxassetid://89897738419446",
	["hand-metal"] = "rbxassetid://113619498548713",
	["hand-platter"] = "rbxassetid://88594727743168",
	["hand"] = "rbxassetid://130703864968637",
	["handbag"] = "rbxassetid://135675846264061",
	["handshake"] = "rbxassetid://78442115255814",
	["hard-drive-download"] = "rbxassetid://73913801230614",
	["hard-drive-upload"] = "rbxassetid://85762133615118",
	["hard-drive"] = "rbxassetid://88183305858463",
	["hard-hat"] = "rbxassetid://128050846767382",
	["hash"] = "rbxassetid://82890331678520",
	["hat-glasses"] = "rbxassetid://101165538224815",
	["haze"] = "rbxassetid://108857561768901",
	["hdmi-port"] = "rbxassetid://103693661037020",
	["heading-1"] = "rbxassetid://118129315662110",
	["heading-2"] = "rbxassetid://110209069670094",
	["heading-3"] = "rbxassetid://90267885237062",
	["heading-4"] = "rbxassetid://129625620307602",
	["heading-5"] = "rbxassetid://120386663181267",
	["heading-6"] = "rbxassetid://90959079775093",
	["heading"] = "rbxassetid://129254312067735",
	["headphone-off"] = "rbxassetid://85038251615641",
	["headphones"] = "rbxassetid://118833729589183",
	["headset"] = "rbxassetid://129269236787694",
	["heart-crack"] = "rbxassetid://110987638564119",
	["heart-handshake"] = "rbxassetid://111483078692002",
	["heart-minus"] = "rbxassetid://96827380163326",
	["heart-off"] = "rbxassetid://89748414415617",
	["heart-plus"] = "rbxassetid://94877796283249",
	["heart-pulse"] = "rbxassetid://129352925579546",
	["heart"] = "rbxassetid://116559368303288",
	["heater"] = "rbxassetid://140478466880916",
	["helicopter"] = "rbxassetid://111557171735930",
	["hexagon"] = "rbxassetid://127592089339199",
	["highlighter"] = "rbxassetid://77411555641113",
	["history"] = "rbxassetid://123980022019922",
	["hop-off"] = "rbxassetid://103386036934034",
	["hop"] = "rbxassetid://82778923997672",
	["hospital"] = "rbxassetid://105868763850707",
	["hotel"] = "rbxassetid://132283390859718",
	["hourglass"] = "rbxassetid://86160434939203",
	["house-heart"] = "rbxassetid://136054771868597",
	["house-plug"] = "rbxassetid://71438263712075",
	["house-plus"] = "rbxassetid://118495165208309",
	["house-wifi"] = "rbxassetid://126495519725698",
	["house"] = "rbxassetid://98755624629571",
	["ice-cream-bowl"] = "rbxassetid://124867218454386",
	["ice-cream-cone"] = "rbxassetid://90751397288639",
	["id-card-lanyard"] = "rbxassetid://90761480469224",
	["id-card"] = "rbxassetid://75354294622640",
	["image-down"] = "rbxassetid://78972295741235",
	["image-minus"] = "rbxassetid://101066016918565",
	["image-off"] = "rbxassetid://81934811700938",
	["image-play"] = "rbxassetid://129501806784210",
	["image-plus"] = "rbxassetid://70391970623917",
	["image-up"] = "rbxassetid://126610009605241",
	["image-upscale"] = "rbxassetid://106963545024679",
	["images"] = "rbxassetid://79350649395557",
	["import"] = "rbxassetid://116545008906029",
	["inbox"] = "rbxassetid://112591360302868",
	["indian-rupee"] = "rbxassetid://113038778381805",
	["infinity"] = "rbxassetid://98083086936965",
	["info"] = "rbxassetid://124560466474914",
	["inspection-panel"] = "rbxassetid://70905313146088",
	["instagram"] = "rbxassetid://119864798614855",
	["italic"] = "rbxassetid://96220378864282",
	["iteration-ccw"] = "rbxassetid://140221832794083",
	["iteration-cw"] = "rbxassetid://95534489554662",
	["japanese-yen"] = "rbxassetid://106362863465813",
	["joystick"] = "rbxassetid://99416790224739",
	["kanban"] = "rbxassetid://125934100055431",
	["kayak"] = "rbxassetid://136107544609389",
	["key-round"] = "rbxassetid://83619031955390",
	["key-square"] = "rbxassetid://94621420033649",
	["key"] = "rbxassetid://96510194465420",
	["keyboard-music"] = "rbxassetid://121058541758636",
	["keyboard-off"] = "rbxassetid://92466375369772",
	["keyboard"] = "rbxassetid://121474456068237",
	["lamp-ceiling"] = "rbxassetid://80032758469141",
	["lamp-desk"] = "rbxassetid://85290686983238",
	["lamp-floor"] = "rbxassetid://104585881375892",
	["lamp-wall-down"] = "rbxassetid://91271394132073",
	["lamp-wall-up"] = "rbxassetid://132141464337445",
	["lamp"] = "rbxassetid://110730830653382",
	["land-plot"] = "rbxassetid://96449039620294",
	["landmark"] = "rbxassetid://76885079756393",
	["languages"] = "rbxassetid://90816903776498",
	["laptop-minimal-check"] = "rbxassetid://114352019833865",
	["laptop-minimal"] = "rbxassetid://136705765566068",
	["laptop"] = "rbxassetid://111387063244975",
	["lasso-select"] = "rbxassetid://105609719912753",
	["lasso"] = "rbxassetid://121072936884007",
	["laugh"] = "rbxassetid://104491311361166",
	["layers-2"] = "rbxassetid://70536710516357",
	["layers"] = "rbxassetid://81973586053257",
	["layout-dashboard"] = "rbxassetid://139929981863901",
	["layout-grid"] = "rbxassetid://81344910161871",
	["layout-list"] = "rbxassetid://87462136296578",
	["layout-panel-left"] = "rbxassetid://125092469751491",
	["layout-panel-top"] = "rbxassetid://91943941515944",
	["layout-template"] = "rbxassetid://115564446417985",
	["leaf"] = "rbxassetid://119951075637174",
	["leafy-green"] = "rbxassetid://105146290493154",
	["lectern"] = "rbxassetid://106166425183862",
	["library-big"] = "rbxassetid://106794530191412",
	["library"] = "rbxassetid://114334671982047",
	["life-buoy"] = "rbxassetid://81168450671956",
	["ligature"] = "rbxassetid://111397873269411",
	["lightbulb-off"] = "rbxassetid://83795722296178",
	["lightbulb"] = "rbxassetid://103871245626488",
	["line-squiggle"] = "rbxassetid://109555164424447",
	["link-2-off"] = "rbxassetid://76885956296867",
	["link-2"] = "rbxassetid://86072351557466",
	["link"] = "rbxassetid://131607023382430",
	["linkedin"] = "rbxassetid://132842789255788",
	["list-check"] = "rbxassetid://72374358471156",
	["list-checks"] = "rbxassetid://99809353635593",
	["list-chevrons-down-up"] = "rbxassetid://137409641500711",
	["list-chevrons-up-down"] = "rbxassetid://81825351389084",
	["list-collapse"] = "rbxassetid://124505247702401",
	["list-end"] = "rbxassetid://77650610048119",
	["list-filter-plus"] = "rbxassetid://96385120752336",
	["list-filter"] = "rbxassetid://103321376129527",
	["list-indent-decrease"] = "rbxassetid://137879979228193",
	["list-indent-increase"] = "rbxassetid://79051053161201",
	["list-minus"] = "rbxassetid://138507965142671",
	["list-music"] = "rbxassetid://126380635781840",
	["list-ordered"] = "rbxassetid://83212528113913",
	["list-plus"] = "rbxassetid://112384738137814",
	["list-restart"] = "rbxassetid://91703153577421",
	["list-start"] = "rbxassetid://84828348299727",
	["list-todo"] = "rbxassetid://132980603752108",
	["list-tree"] = "rbxassetid://97685396239010",
	["list-video"] = "rbxassetid://93648525452489",
	["list-x"] = "rbxassetid://113025303988861",
	["list"] = "rbxassetid://113179976918783",
	["loader-circle"] = "rbxassetid://116535712789945",
	["loader-pinwheel"] = "rbxassetid://108513357940900",
	["loader"] = "rbxassetid://78408734580845",
	["locate-fixed"] = "rbxassetid://137367361548433",
	["locate-off"] = "rbxassetid://73729216338137",
	["locate"] = "rbxassetid://84467676590391",
	["lock-keyhole-open"] = "rbxassetid://110863509313073",
	["lock-keyhole"] = "rbxassetid://78672912777756",
	["lock-open"] = "rbxassetid://93597915325122",
	["lock"] = "rbxassetid://134724289526879",
	["log-in"] = "rbxassetid://103768533135201",
	["log-out"] = "rbxassetid://84895399304975",
	["logs"] = "rbxassetid://89772091251787",
	["lollipop"] = "rbxassetid://84681611583044",
	["luggage"] = "rbxassetid://76619236486400",
	["magnet"] = "rbxassetid://135162361226972",
	["mail-check"] = "rbxassetid://86921536259917",
	["mail-minus"] = "rbxassetid://81989813236553",
	["mail-open"] = "rbxassetid://122785416858638",
	["mail-plus"] = "rbxassetid://104886401588341",
	["mail-question-mark"] = "rbxassetid://126540170949819",
	["mail-search"] = "rbxassetid://135616173775287",
	["mail-warning"] = "rbxassetid://81495303676089",
	["mail-x"] = "rbxassetid://74607841705644",
	["mail"] = "rbxassetid://103945161245599",
	["mailbox"] = "rbxassetid://82765503320335",
	["mails"] = "rbxassetid://90673453450080",
	["map-minus"] = "rbxassetid://129525760577747",
	["map-pin-check-inside"] = "rbxassetid://107130529843809",
	["map-pin-check"] = "rbxassetid://118110914690154",
	["map-pin-house"] = "rbxassetid://80546885029816",
	["map-pin-minus-inside"] = "rbxassetid://79005529692964",
	["map-pin-minus"] = "rbxassetid://74518762643623",
	["map-pin-off"] = "rbxassetid://82474689391020",
	["map-pin-pen"] = "rbxassetid://113515395277504",
	["map-pin-plus-inside"] = "rbxassetid://134639656514430",
	["map-pin-plus"] = "rbxassetid://91875228967029",
	["map-pin-x-inside"] = "rbxassetid://126235934252379",
	["map-pin-x"] = "rbxassetid://101085273547316",
	["map-pin"] = "rbxassetid://84279202219901",
	["map-pinned"] = "rbxassetid://103963788475034",
	["map-plus"] = "rbxassetid://129388826743495",
	["map"] = "rbxassetid://95107167260947",
	["mars-stroke"] = "rbxassetid://131973193186828",
	["mars"] = "rbxassetid://111287112372511",
	["martini"] = "rbxassetid://82977695401058",
	["maximize-2"] = "rbxassetid://73085922906397",
	["maximize"] = "rbxassetid://76045941763188",
	["medal"] = "rbxassetid://79016002264450",
	["megaphone-off"] = "rbxassetid://124280774193935",
	["megaphone"] = "rbxassetid://118759541854879",
	["meh"] = "rbxassetid://132197867028557",
	["memory-stick"] = "rbxassetid://93212591343119",
	["menu"] = "rbxassetid://77021539815611",
	["merge"] = "rbxassetid://126201866476775",
	["message-circle-code"] = "rbxassetid://112865244991651",
	["message-circle-dashed"] = "rbxassetid://81525157881897",
	["message-circle-heart"] = "rbxassetid://101990756073677",
	["message-circle-more"] = "rbxassetid://92856823884663",
	["message-circle-off"] = "rbxassetid://134955643890328",
	["message-circle-plus"] = "rbxassetid://106562979649273",
	["message-circle-question-mark"] = "rbxassetid://107700302759934",
	["message-circle-reply"] = "rbxassetid://137071749508334",
	["message-circle-warning"] = "rbxassetid://119020096067894",
	["message-circle-x"] = "rbxassetid://126843387725536",
	["message-circle"] = "rbxassetid://127255077587058",
	["message-square-code"] = "rbxassetid://110968863152123",
	["message-square-dashed"] = "rbxassetid://107653455516238",
	["message-square-diff"] = "rbxassetid://75472190472625",
	["message-square-dot"] = "rbxassetid://127806382463916",
	["message-square-heart"] = "rbxassetid://75612811742074",
	["message-square-lock"] = "rbxassetid://81268215619563",
	["message-square-more"] = "rbxassetid://120139782405970",
	["message-square-off"] = "rbxassetid://99961019005789",
	["message-square-plus"] = "rbxassetid://76934450256199",
	["message-square-quote"] = "rbxassetid://116670768629340",
	["message-square-reply"] = "rbxassetid://130985622754637",
	["message-square-share"] = "rbxassetid://131017005324026",
	["message-square-text"] = "rbxassetid://94899503194205",
	["message-square-warning"] = "rbxassetid://138432903962261",
	["message-square-x"] = "rbxassetid://137285463279462",
	["message-square"] = "rbxassetid://83881670383280",
	["messages-square"] = "rbxassetid://97532166733358",
	["mic-off"] = "rbxassetid://82123034444822",
	["mic-vocal"] = "rbxassetid://99082286164362",
	["mic"] = "rbxassetid://89640799126523",
	["microchip"] = "rbxassetid://73937907669903",
	["microscope"] = "rbxassetid://116875530102782",
	["microwave"] = "rbxassetid://108411735353008",
	["milestone"] = "rbxassetid://101618292325920",
	["milk-off"] = "rbxassetid://72388480962742",
	["milk"] = "rbxassetid://96221903896918",
	["minimize-2"] = "rbxassetid://116269596042539",
	["minimize"] = "rbxassetid://121304296213645",
	["minus"] = "rbxassetid://118026365011536",
	["monitor-check"] = "rbxassetid://86651948439229",
	["monitor-cloud"] = "rbxassetid://85931096038318",
	["monitor-cog"] = "rbxassetid://94345128715799",
	["monitor-dot"] = "rbxassetid://130394010063680",
	["monitor-down"] = "rbxassetid://97466933743423",
	["monitor-off"] = "rbxassetid://74395526657953",
	["monitor-pause"] = "rbxassetid://76002184067562",
	["monitor-play"] = "rbxassetid://133018824306217",
	["monitor-smartphone"] = "rbxassetid://84335680433378",
	["monitor-speaker"] = "rbxassetid://81744810060380",
	["monitor-stop"] = "rbxassetid://98708958984757",
	["monitor-up"] = "rbxassetid://96035360858377",
	["monitor-x"] = "rbxassetid://126265210441423",
	["monitor"] = "rbxassetid://72664649203050",
	["moon-star"] = "rbxassetid://82782200506348",
	["moon"] = "rbxassetid://83380517901735",
	["motorbike"] = "rbxassetid://94580787368233",
	["mountain-snow"] = "rbxassetid://105315495740588",
	["mountain"] = "rbxassetid://73269957566415",
	["mouse-off"] = "rbxassetid://75267871697595",
	["mouse-pointer-2-off"] = "rbxassetid://104701076865632",
	["mouse-pointer-2"] = "rbxassetid://117093892862228",
	["mouse-pointer-ban"] = "rbxassetid://106849413057133",
	["mouse-pointer-click"] = "rbxassetid://107150227368485",
	["mouse-pointer"] = "rbxassetid://72322454962935",
	["mouse"] = "rbxassetid://73096068864710",
	["move-3d"] = "rbxassetid://103365982054003",
	["move-diagonal-2"] = "rbxassetid://117298577948096",
	["move-diagonal"] = "rbxassetid://101433481954184",
	["move-down-left"] = "rbxassetid://102819433534567",
	["move-down-right"] = "rbxassetid://101479760041877",
	["move-down"] = "rbxassetid://70510115135583",
	["move-horizontal"] = "rbxassetid://88513523439149",
	["move-left"] = "rbxassetid://137614740247980",
	["move-right"] = "rbxassetid://132455779472989",
	["move-up-left"] = "rbxassetid://139079815540148",
	["move-up-right"] = "rbxassetid://105885140592646",
	["move-up"] = "rbxassetid://84505444262658",
	["move-vertical"] = "rbxassetid://86234730730899",
	["move"] = "rbxassetid://116138709011735",
	["music-2"] = "rbxassetid://134397426600888",
	["music-3"] = "rbxassetid://94466120066498",
	["music-4"] = "rbxassetid://132459323665838",
	["music"] = "rbxassetid://113343203848535",
	["navigation-2-off"] = "rbxassetid://116569611780763",
	["navigation-2"] = "rbxassetid://81889066747907",
	["navigation-off"] = "rbxassetid://87003270290777",
	["navigation"] = "rbxassetid://79308213542922",
	["network"] = "rbxassetid://127410729922644",
	["newspaper"] = "rbxassetid://123479530460544",
	["nfc"] = "rbxassetid://76822396542242",
	["non-binary"] = "rbxassetid://78442360386235",
	["notebook-pen"] = "rbxassetid://140380614761023",
	["notebook-tabs"] = "rbxassetid://127371085570083",
	["notebook-text"] = "rbxassetid://93061585217270",
	["notebook"] = "rbxassetid://136132108664987",
	["notepad-text-dashed"] = "rbxassetid://135793446376219",
	["notepad-text"] = "rbxassetid://93404682958966",
	["nut-off"] = "rbxassetid://78795397311573",
	["nut"] = "rbxassetid://127146410705656",
	["octagon-alert"] = "rbxassetid://140438367956051",
	["octagon-minus"] = "rbxassetid://74720436795421",
	["octagon-pause"] = "rbxassetid://103161463909039",
	["octagon-x"] = "rbxassetid://90498161006311",
	["octagon"] = "rbxassetid://120803515514852",
	["omega"] = "rbxassetid://70414080018786",
	["option"] = "rbxassetid://100776883894054",
	["orbit"] = "rbxassetid://108926136860562",
	["origami"] = "rbxassetid://136020626667101",
	["package-2"] = "rbxassetid://70394974762575",
	["package-check"] = "rbxassetid://102374216055130",
	["package-minus"] = "rbxassetid://114492858789692",
	["package-open"] = "rbxassetid://132890233237818",
	["package-plus"] = "rbxassetid://129261988138366",
	["package-search"] = "rbxassetid://95465120894145",
	["package-x"] = "rbxassetid://70818501607442",
	["package"] = "rbxassetid://97261141732706",
	["paint-bucket"] = "rbxassetid://124275586663284",
	["paint-roller"] = "rbxassetid://115248074358348",
	["paintbrush-vertical"] = "rbxassetid://105151296591292",
	["paintbrush"] = "rbxassetid://125572663700289",
	["palette"] = "rbxassetid://86350350950064",
	["panda"] = "rbxassetid://132509022802512",
	["panel-bottom-close"] = "rbxassetid://74287004071159",
	["panel-bottom-dashed"] = "rbxassetid://131084651621603",
	["panel-bottom-open"] = "rbxassetid://107768659586540",
	["panel-bottom"] = "rbxassetid://132127145048511",
	["panel-left-close"] = "rbxassetid://126579818823552",
	["panel-left-dashed"] = "rbxassetid://75536606374585",
	["panel-left-open"] = "rbxassetid://111075816195767",
	["panel-left-right-dashed"] = "rbxassetid://110100707973959",
	["panel-left"] = "rbxassetid://97419752870313",
	["panel-right-close"] = "rbxassetid://139528655524132",
	["panel-right-dashed"] = "rbxassetid://94959793877311",
	["panel-right-open"] = "rbxassetid://118114419142794",
	["panel-right"] = "rbxassetid://116365035443156",
	["panel-top-bottom-dashed"] = "rbxassetid://134737235653344",
	["panel-top-close"] = "rbxassetid://83578325777808",
	["panel-top-dashed"] = "rbxassetid://70522913169237",
	["panel-top-open"] = "rbxassetid://137959875507454",
	["panel-top"] = "rbxassetid://75838479462875",
	["panels-left-bottom"] = "rbxassetid://72996856149149",
	["panels-right-bottom"] = "rbxassetid://90659068960726",
	["panels-top-left"] = "rbxassetid://79858853850600",
	["paperclip"] = "rbxassetid://92088291163453",
	["parentheses"] = "rbxassetid://78950955173096",
	["parking-meter"] = "rbxassetid://84652733960568",
	["party-popper"] = "rbxassetid://111626795712193",
	["pause"] = "rbxassetid://74873705394436",
	["paw-print"] = "rbxassetid://112218825427601",
	["pc-case"] = "rbxassetid://122978648019101",
	["pen-line"] = "rbxassetid://109108135755303",
	["pen-off"] = "rbxassetid://84807123119438",
	["pen-tool"] = "rbxassetid://106145404953445",
	["pen"] = "rbxassetid://72037878096321",
	["pencil-line"] = "rbxassetid://88392917053533",
	["pencil-off"] = "rbxassetid://103330927652832",
	["pencil-ruler"] = "rbxassetid://110120288284597",
	["pencil"] = "rbxassetid://137986121120732",
	["pentagon"] = "rbxassetid://79184802179890",
	["percent"] = "rbxassetid://130155041032013",
	["person-standing"] = "rbxassetid://125020872044147",
	["philippine-peso"] = "rbxassetid://91173798254675",
	["phone-call"] = "rbxassetid://70555587592860",
	["phone-forwarded"] = "rbxassetid://113269614319737",
	["phone-incoming"] = "rbxassetid://82863576359288",
	["phone-missed"] = "rbxassetid://130156165198376",
	["phone-off"] = "rbxassetid://133318623553383",
	["phone-outgoing"] = "rbxassetid://104576478735825",
	["phone"] = "rbxassetid://128804946640049",
	["pi"] = "rbxassetid://74936036243146",
	["piano"] = "rbxassetid://85008880789520",
	["pickaxe"] = "rbxassetid://105888023317688",
	["picture-in-picture-2"] = "rbxassetid://112803319544468",
	["picture-in-picture"] = "rbxassetid://80579597835123",
	["piggy-bank"] = "rbxassetid://79498575790721",
	["pilcrow-left"] = "rbxassetid://103803000849583",
	["pilcrow-right"] = "rbxassetid://104881733911870",
	["pilcrow"] = "rbxassetid://139512780392871",
	["pill-bottle"] = "rbxassetid://118394692404597",
	["pill"] = "rbxassetid://73280534813448",
	["pin-off"] = "rbxassetid://127696372451750",
	["pin"] = "rbxassetid://120978111007514",
	["pipette"] = "rbxassetid://133167932934404",
	["pizza"] = "rbxassetid://126964453193501",
	["plane-landing"] = "rbxassetid://122555692211889",
	["plane-takeoff"] = "rbxassetid://117179478829575",
	["plane"] = "rbxassetid://126985561580989",
	["play"] = "rbxassetid://135609604299893",
	["plug-2"] = "rbxassetid://97912386476366",
	["plug-zap"] = "rbxassetid://74506269884055",
	["plug"] = "rbxassetid://99782373064495",
	["plus"] = "rbxassetid://111774323017047",
	["pocket-knife"] = "rbxassetid://134075428063965",
	["pocket"] = "rbxassetid://136686762542964",
	["podcast"] = "rbxassetid://109577075549215",
	["pointer-off"] = "rbxassetid://95488389312794",
	["pointer"] = "rbxassetid://92615117311099",
	["popcorn"] = "rbxassetid://139446511232750",
	["popsicle"] = "rbxassetid://112696318077073",
	["pound-sterling"] = "rbxassetid://127482649469130",
	["power-off"] = "rbxassetid://118768311012214",
	["power"] = "rbxassetid://96479131758775",
	["presentation"] = "rbxassetid://106134583757890",
	["printer-check"] = "rbxassetid://130273549443689",
	["printer"] = "rbxassetid://76080649734247",
	["projector"] = "rbxassetid://103281856385283",
	["proportions"] = "rbxassetid://130046855997237",
	["puzzle"] = "rbxassetid://136837798892463",
	["pyramid"] = "rbxassetid://107811442374127",
	["qr-code"] = "rbxassetid://105329945723350",
	["quote"] = "rbxassetid://103271711590001",
	["rabbit"] = "rbxassetid://98580518804206",
	["radar"] = "rbxassetid://138528222906635",
	["radiation"] = "rbxassetid://104499586848433",
	["radical"] = "rbxassetid://132758286926047",
	["radio-receiver"] = "rbxassetid://129598303378835",
	["radio-tower"] = "rbxassetid://93958663130054",
	["radio"] = "rbxassetid://85611589536956",
	["radius"] = "rbxassetid://89814505307129",
	["rail-symbol"] = "rbxassetid://134295386306962",
	["rainbow"] = "rbxassetid://132488862841895",
	["rat"] = "rbxassetid://127400975953159",
	["ratio"] = "rbxassetid://126369423897295",
	["receipt-cent"] = "rbxassetid://91557573925201",
	["receipt-euro"] = "rbxassetid://94015722210295",
	["receipt-indian-rupee"] = "rbxassetid://89718170439990",
	["receipt-japanese-yen"] = "rbxassetid://132472560758851",
	["receipt-pound-sterling"] = "rbxassetid://73934967569625",
	["receipt-russian-ruble"] = "rbxassetid://105164576936853",
	["receipt-swiss-franc"] = "rbxassetid://72503668620116",
	["receipt-text"] = "rbxassetid://138483536013737",
	["receipt-turkish-lira"] = "rbxassetid://91950765836342",
	["receipt"] = "rbxassetid://77877895901792",
	["rectangle-circle"] = "rbxassetid://100642423153903",
	["rectangle-ellipsis"] = "rbxassetid://112919953980965",
	["rectangle-goggles"] = "rbxassetid://98605436666727",
	["rectangle-horizontal"] = "rbxassetid://90224199814966",
	["rectangle-vertical"] = "rbxassetid://117277050590967",
	["recycle"] = "rbxassetid://140417023381961",
	["redo-2"] = "rbxassetid://70451039017914",
	["redo-dot"] = "rbxassetid://94252981719732",
	["redo"] = "rbxassetid://116150342119054",
	["refresh-ccw-dot"] = "rbxassetid://106702246753270",
	["refresh-ccw"] = "rbxassetid://117913330389477",
	["refresh-cw-off"] = "rbxassetid://140179498843054",
	["refresh-cw"] = "rbxassetid://138133190015277",
	["refrigerator"] = "rbxassetid://102614042652753",
	["regex"] = "rbxassetid://100727200791841",
	["remove-formatting"] = "rbxassetid://112833162022628",
	["repeat-1"] = "rbxassetid://130144534857095",
	["repeat-2"] = "rbxassetid://85927537182704",
	["repeat"] = "rbxassetid://121886242955173",
	["replace-all"] = "rbxassetid://127862728198635",
	["replace"] = "rbxassetid://128404082279430",
	["reply-all"] = "rbxassetid://71723137343562",
	["reply"] = "rbxassetid://109788633497028",
	["rewind"] = "rbxassetid://95205297521988",
	["ribbon"] = "rbxassetid://94265331526851",
	["rocket"] = "rbxassetid://87412317685854",
	["rocking-chair"] = "rbxassetid://110420269495360",
	["roller-coaster"] = "rbxassetid://112426178972099",
	["rose"] = "rbxassetid://126336840238769",
	["rotate-3d"] = "rbxassetid://76300551576392",
	["rotate-ccw-key"] = "rbxassetid://74976035240976",
	["rotate-ccw-square"] = "rbxassetid://90515853170424",
	["rotate-ccw"] = "rbxassetid://110116685948665",
	["rotate-cw-square"] = "rbxassetid://77095448159303",
	["rotate-cw"] = "rbxassetid://84183336178654",
	["route-off"] = "rbxassetid://106350402024079",
	["route"] = "rbxassetid://89968303228953",
	["router"] = "rbxassetid://102130331994471",
	["rows-2"] = "rbxassetid://112556185960101",
	["rows-3"] = "rbxassetid://117215586961375",
	["rows-4"] = "rbxassetid://125646021959055",
	["rss"] = "rbxassetid://131789058984793",
	["ruler-dimension-line"] = "rbxassetid://70673861371412",
	["ruler"] = "rbxassetid://81432445547423",
	["russian-ruble"] = "rbxassetid://126357936542156",
	["sailboat"] = "rbxassetid://87110567187540",
	["salad"] = "rbxassetid://128864507821603",
	["sandwich"] = "rbxassetid://104573187458917",
	["satellite-dish"] = "rbxassetid://136742443888305",
	["satellite"] = "rbxassetid://134967053164645",
	["saudi-riyal"] = "rbxassetid://102282769104635",
	["save-all"] = "rbxassetid://116946975799440",
	["save-off"] = "rbxassetid://87085435778560",
	["save"] = "rbxassetid://126116963775616",
	["scale-3d"] = "rbxassetid://72414199620352",
	["scale"] = "rbxassetid://108203682317477",
	["scaling"] = "rbxassetid://122360365318466",
	["scan-barcode"] = "rbxassetid://96889457154761",
	["scan-eye"] = "rbxassetid://99244790601968",
	["scan-face"] = "rbxassetid://109959345069668",
	["scan-heart"] = "rbxassetid://106280819776142",
	["scan-line"] = "rbxassetid://126544908146540",
	["scan-qr-code"] = "rbxassetid://105409149549927",
	["scan-search"] = "rbxassetid://80009010551347",
	["scan-text"] = "rbxassetid://73702396787766",
	["scan"] = "rbxassetid://123104789658180",
	["school"] = "rbxassetid://76351530290068",
	["scissors-line-dashed"] = "rbxassetid://122237447974173",
	["scissors"] = "rbxassetid://118665510911274",
	["screen-share-off"] = "rbxassetid://107677572669805",
	["screen-share"] = "rbxassetid://85137895705653",
	["scroll-text"] = "rbxassetid://97321022666868",
	["scroll"] = "rbxassetid://74072101474951",
	["search-check"] = "rbxassetid://75442076191356",
	["search-code"] = "rbxassetid://117114794592802",
	["search-slash"] = "rbxassetid://96483932261041",
	["search-x"] = "rbxassetid://137319957522951",
	["search"] = "rbxassetid://121018724060431",
	["section"] = "rbxassetid://91732188298948",
	["send-horizontal"] = "rbxassetid://111734392411664",
	["send-to-back"] = "rbxassetid://75340312862253",
	["send"] = "rbxassetid://127751956873796",
	["separator-horizontal"] = "rbxassetid://84864453699927",
	["separator-vertical"] = "rbxassetid://84031801478581",
	["server-cog"] = "rbxassetid://138470287250966",
	["server-crash"] = "rbxassetid://132810618000212",
	["server-off"] = "rbxassetid://114048751507723",
	["server"] = "rbxassetid://92188766517878",
	["settings-2"] = "rbxassetid://135684703553372",
	["settings"] = "rbxassetid://80758916183665",
	["shapes"] = "rbxassetid://129989433311409",
	["share-2"] = "rbxassetid://71210767962065",
	["share"] = "rbxassetid://87340985053299",
	["sheet"] = "rbxassetid://134902122480171",
	["shell"] = "rbxassetid://140212943563599",
	["shield-alert"] = "rbxassetid://114995877719925",
	["shield-ban"] = "rbxassetid://108765041044649",
	["shield-check"] = "rbxassetid://87354736164608",
	["shield-ellipsis"] = "rbxassetid://114794739892123",
	["shield-half"] = "rbxassetid://117842634172647",
	["shield-minus"] = "rbxassetid://89965059528921",
	["shield-off"] = "rbxassetid://133426959132690",
	["shield-plus"] = "rbxassetid://100664857995498",
	["shield-question-mark"] = "rbxassetid://135722075265150",
	["shield-user"] = "rbxassetid://124832775645347",
	["shield-x"] = "rbxassetid://73370117343811",
	["shield"] = "rbxassetid://110987169760162",
	["ship-wheel"] = "rbxassetid://130797795829448",
	["ship"] = "rbxassetid://83995100553930",
	["shirt"] = "rbxassetid://106579555405966",
	["shopping-bag"] = "rbxassetid://71885477293226",
	["shopping-basket"] = "rbxassetid://138646411956433",
	["shopping-cart"] = "rbxassetid://128420521375441",
	["shovel"] = "rbxassetid://102465000512056",
	["shower-head"] = "rbxassetid://75884944024117",
	["shredder"] = "rbxassetid://122125164414463",
	["shrimp"] = "rbxassetid://102625900815307",
	["shrink"] = "rbxassetid://90953687918880",
	["shrub"] = "rbxassetid://127326280714343",
	["shuffle"] = "rbxassetid://132382786975101",
	["sigma"] = "rbxassetid://126884244870899",
	["signal-high"] = "rbxassetid://130436670012270",
	["signal-low"] = "rbxassetid://73674683500458",
	["signal-medium"] = "rbxassetid://125003021367019",
	["signal-zero"] = "rbxassetid://130045332414754",
	["signal"] = "rbxassetid://78424889355261",
	["signature"] = "rbxassetid://114402748013000",
	["signpost-big"] = "rbxassetid://115780185675001",
	["signpost"] = "rbxassetid://106584743791433",
	["siren"] = "rbxassetid://134210267818039",
	["skip-back"] = "rbxassetid://70466132711334",
	["skip-forward"] = "rbxassetid://124844823753990",
	["skull"] = "rbxassetid://137726256442333",
	["slack"] = "rbxassetid://96089719516736",
	["slash"] = "rbxassetid://117792185664263",
	["slice"] = "rbxassetid://95810504278179",
	["sliders-horizontal"] = "rbxassetid://85538382643347",
	["sliders-vertical"] = "rbxassetid://101190569086853",
	["smartphone-charging"] = "rbxassetid://102837532613995",
	["smartphone-nfc"] = "rbxassetid://82326425754446",
	["smartphone"] = "rbxassetid://96623008834511",
	["smile-plus"] = "rbxassetid://131981881472144",
	["smile"] = "rbxassetid://105880397565283",
	["snail"] = "rbxassetid://70904536548363",
	["snowflake"] = "rbxassetid://101235206534566",
	["soap-dispenser-droplet"] = "rbxassetid://77258480479465",
	["sofa"] = "rbxassetid://114427687218324",
	["solar-panel"] = "rbxassetid://132448188047921",
	["soup"] = "rbxassetid://115092551871618",
	["space"] = "rbxassetid://87072088914178",
	["spade"] = "rbxassetid://131444449466462",
	["sparkle"] = "rbxassetid://111044800239623",
	["sparkles"] = "rbxassetid://138635884129147",
	["speaker"] = "rbxassetid://96227183003618",
	["speech"] = "rbxassetid://87013139446349",
	["spell-check-2"] = "rbxassetid://81556731785534",
	["spell-check"] = "rbxassetid://91913483031334",
	["spline-pointer"] = "rbxassetid://84842840956804",
	["spline"] = "rbxassetid://129406685807412",
	["split"] = "rbxassetid://105112438805988",
	["spool"] = "rbxassetid://124541981347743",
	["spotlight"] = "rbxassetid://77571742539344",
	["spray-can"] = "rbxassetid://128372039366326",
	["sprout"] = "rbxassetid://100091687832508",
	["square-activity"] = "rbxassetid://89496630185293",
	["square-arrow-down-left"] = "rbxassetid://108194680296901",
	["square-arrow-down-right"] = "rbxassetid://99403846801050",
	["square-arrow-down"] = "rbxassetid://135962519626588",
	["square-arrow-left"] = "rbxassetid://111671474549238",
	["square-arrow-out-down-left"] = "rbxassetid://125714881756353",
	["square-arrow-out-down-right"] = "rbxassetid://89971003001390",
	["square-arrow-out-up-left"] = "rbxassetid://103759986579087",
	["square-arrow-out-up-right"] = "rbxassetid://91221896066807",
	["square-arrow-right"] = "rbxassetid://113920471701361",
	["square-arrow-up-left"] = "rbxassetid://112424670290693",
	["square-arrow-up-right"] = "rbxassetid://76602291406940",
	["square-arrow-up"] = "rbxassetid://106998604646718",
	["square-asterisk"] = "rbxassetid://89186832353625",
	["square-bottom-dashed-scissors"] = "rbxassetid://79076980104803",
	["square-chart-gantt"] = "rbxassetid://104034017316411",
	["square-check-big"] = "rbxassetid://115320390907184",
	["square-check"] = "rbxassetid://134682053539509",
	["square-chevron-down"] = "rbxassetid://91032307924592",
	["square-chevron-left"] = "rbxassetid://73143404829510",
	["square-chevron-right"] = "rbxassetid://90612077729930",
	["square-chevron-up"] = "rbxassetid://85565910197337",
	["square-code"] = "rbxassetid://81604576616881",
	["square-dashed-bottom-code"] = "rbxassetid://100354801563230",
	["square-dashed-bottom"] = "rbxassetid://101102319625624",
	["square-dashed-kanban"] = "rbxassetid://90388067649847",
	["square-dashed-mouse-pointer"] = "rbxassetid://121016142178467",
	["square-dashed-top-solid"] = "rbxassetid://117157577548540",
	["square-dashed"] = "rbxassetid://136905537847606",
	["square-divide"] = "rbxassetid://99894657101970",
	["square-dot"] = "rbxassetid://116613421354866",
	["square-equal"] = "rbxassetid://110283363706707",
	["square-function"] = "rbxassetid://86075219551088",
	["square-kanban"] = "rbxassetid://114537101260131",
	["square-library"] = "rbxassetid://73810931222081",
	["square-m"] = "rbxassetid://117662700410577",
	["square-menu"] = "rbxassetid://104067089444415",
	["square-minus"] = "rbxassetid://116764432015770",
	["square-mouse-pointer"] = "rbxassetid://76141850603920",
	["square-parking-off"] = "rbxassetid://100857293535141",
	["square-parking"] = "rbxassetid://133116656122387",
	["square-pause"] = "rbxassetid://86608552787615",
	["square-pen"] = "rbxassetid://120239476110475",
	["square-percent"] = "rbxassetid://87111930314567",
	["square-pi"] = "rbxassetid://75383328781618",
	["square-pilcrow"] = "rbxassetid://131854284699367",
	["square-play"] = "rbxassetid://108186325238481",
	["square-plus"] = "rbxassetid://114713264461873",
	["square-power"] = "rbxassetid://129240437805187",
	["square-radical"] = "rbxassetid://132645931868292",
	["square-round-corner"] = "rbxassetid://104592745113567",
	["square-scissors"] = "rbxassetid://110601255612411",
	["square-sigma"] = "rbxassetid://113231244246816",
	["square-slash"] = "rbxassetid://105477013908757",
	["square-split-horizontal"] = "rbxassetid://76095370148660",
	["square-split-vertical"] = "rbxassetid://88589192032058",
	["square-square"] = "rbxassetid://136555087357875",
	["square-stack"] = "rbxassetid://100463396619394",
	["square-star"] = "rbxassetid://94506958703720",
	["square-stop"] = "rbxassetid://80018708472943",
	["square-terminal"] = "rbxassetid://83969264476798",
	["square-user-round"] = "rbxassetid://86484997229302",
	["square-user"] = "rbxassetid://70771214183445",
	["square-x"] = "rbxassetid://125136183850190",
	["square"] = "rbxassetid://86304921356806",
	["squares-exclude"] = "rbxassetid://102345385822324",
	["squares-intersect"] = "rbxassetid://120869602570119",
	["squares-subtract"] = "rbxassetid://131484650948795",
	["squares-unite"] = "rbxassetid://96673080107843",
	["squircle-dashed"] = "rbxassetid://129936702532522",
	["squircle"] = "rbxassetid://82426632573807",
	["squirrel"] = "rbxassetid://112864252085343",
	["stamp"] = "rbxassetid://92370779813368",
	["star-half"] = "rbxassetid://117449275562979",
	["star-off"] = "rbxassetid://75742832732503",
	["star"] = "rbxassetid://136141469398409",
	["step-back"] = "rbxassetid://108672750005121",
	["step-forward"] = "rbxassetid://126131872136145",
	["stethoscope"] = "rbxassetid://122331031702148",
	["sticker"] = "rbxassetid://79938203791608",
	["sticky-note"] = "rbxassetid://111894074643919",
	["store"] = "rbxassetid://90338129673705",
	["stretch-horizontal"] = "rbxassetid://87665042192343",
	["stretch-vertical"] = "rbxassetid://95265463417122",
	["strikethrough"] = "rbxassetid://103417324549613",
	["subscript"] = "rbxassetid://74553514785183",
	["sun-dim"] = "rbxassetid://129141645592715",
	["sun-medium"] = "rbxassetid://130278807964710",
	["sun-moon"] = "rbxassetid://75752898854559",
	["sun-snow"] = "rbxassetid://112791898014579",
	["sun"] = "rbxassetid://110150589884127",
	["sunrise"] = "rbxassetid://134705665494098",
	["sunset"] = "rbxassetid://75904872203588",
	["superscript"] = "rbxassetid://96887696590118",
	["swatch-book"] = "rbxassetid://126786244872453",
	["swiss-franc"] = "rbxassetid://113497920041625",
	["switch-camera"] = "rbxassetid://76841154349737",
	["sword"] = "rbxassetid://124448418211665",
	["swords"] = "rbxassetid://81872698913435",
	["syringe"] = "rbxassetid://123891270479254",
	["table-2"] = "rbxassetid://95751552281545",
	["table-cells-merge"] = "rbxassetid://95363715175258",
	["table-cells-split"] = "rbxassetid://114799086088649",
	["table-columns-split"] = "rbxassetid://111011625447949",
	["table-of-contents"] = "rbxassetid://135044763275414",
	["table-properties"] = "rbxassetid://125062886015372",
	["table-rows-split"] = "rbxassetid://96443733673997",
	["table"] = "rbxassetid://109109148250737",
	["tablet-smartphone"] = "rbxassetid://133680859813404",
	["tablet"] = "rbxassetid://128403991264386",
	["tablets"] = "rbxassetid://80835787970735",
	["tag"] = "rbxassetid://129104970103940",
	["tags"] = "rbxassetid://107179263080798",
	["tally-1"] = "rbxassetid://115301298241643",
	["tally-2"] = "rbxassetid://110363186864027",
	["tally-3"] = "rbxassetid://97655344572540",
	["tally-4"] = "rbxassetid://102633494371890",
	["tally-5"] = "rbxassetid://88031817475886",
	["tangent"] = "rbxassetid://123263132981724",
	["target"] = "rbxassetid://87563802520297",
	["telescope"] = "rbxassetid://91755049143647",
	["tent-tree"] = "rbxassetid://76698322463977",
	["tent"] = "rbxassetid://109779587826330",
	["terminal"] = "rbxassetid://106783148545356",
	["test-tube-diagonal"] = "rbxassetid://75662704378840",
	["test-tube"] = "rbxassetid://98801015650164",
	["test-tubes"] = "rbxassetid://92555361447433",
	["text-align-center"] = "rbxassetid://84051028246390",
	["text-align-end"] = "rbxassetid://130041738343555",
	["text-align-justify"] = "rbxassetid://80279880143030",
	["text-align-start"] = "rbxassetid://134489585487649",
	["text-cursor-input"] = "rbxassetid://107551944047171",
	["text-cursor"] = "rbxassetid://115984654447300",
	["text-initial"] = "rbxassetid://129458097472087",
	["text-quote"] = "rbxassetid://139278366448736",
	["text-search"] = "rbxassetid://92345384671606",
	["text-select"] = "rbxassetid://117087320884956",
	["text-wrap"] = "rbxassetid://114804318314018",
	["theater"] = "rbxassetid://108558145549163",
	["thermometer-snowflake"] = "rbxassetid://121876188028425",
	["thermometer-sun"] = "rbxassetid://106693240074310",
	["thermometer"] = "rbxassetid://106546011492311",
	["thumbs-down"] = "rbxassetid://87794009914015",
	["thumbs-up"] = "rbxassetid://111137070767020",
	["ticket-check"] = "rbxassetid://105428777212507",
	["ticket-minus"] = "rbxassetid://78966299769328",
	["ticket-percent"] = "rbxassetid://80834774406405",
	["ticket-plus"] = "rbxassetid://110086734392189",
	["ticket-slash"] = "rbxassetid://89045681172265",
	["ticket-x"] = "rbxassetid://88674114109926",
	["ticket"] = "rbxassetid://126527071492145",
	["tickets-plane"] = "rbxassetid://100367018248695",
	["tickets"] = "rbxassetid://135268612687833",
	["timer-off"] = "rbxassetid://110916370767271",
	["timer-reset"] = "rbxassetid://110052125369932",
	["timer"] = "rbxassetid://85473888890506",
	["toggle-left"] = "rbxassetid://85887872573050",
	["toggle-right"] = "rbxassetid://90411952142550",
	["toilet"] = "rbxassetid://80930782432931",
	["tool-case"] = "rbxassetid://87533537832522",
	["tornado"] = "rbxassetid://88358291515768",
	["torus"] = "rbxassetid://70855707283051",
	["touchpad-off"] = "rbxassetid://78784008075456",
	["touchpad"] = "rbxassetid://74882354908014",
	["tower-control"] = "rbxassetid://95937619060532",
	["toy-brick"] = "rbxassetid://86293483924633",
	["tractor"] = "rbxassetid://103376704722051",
	["traffic-cone"] = "rbxassetid://74110220470369",
	["train-front-tunnel"] = "rbxassetid://105194827005114",
	["train-front"] = "rbxassetid://125237934215370",
	["train-track"] = "rbxassetid://77451032453723",
	["tram-front"] = "rbxassetid://93315182364998",
	["transgender"] = "rbxassetid://135530817673639",
	["trash-2"] = "rbxassetid://109843431391323",
	["trash"] = "rbxassetid://106723740584310",
	["tree-deciduous"] = "rbxassetid://123124389219004",
	["tree-palm"] = "rbxassetid://103846705893963",
	["tree-pine"] = "rbxassetid://124662547202594",
	["trees"] = "rbxassetid://121203841375919",
	["trello"] = "rbxassetid://130987241149527",
	["trending-down"] = "rbxassetid://139309232226438",
	["trending-up-down"] = "rbxassetid://85083293981691",
	["trending-up"] = "rbxassetid://81819858538839",
	["triangle-alert"] = "rbxassetid://125920361880643",
	["triangle-dashed"] = "rbxassetid://124324079103935",
	["triangle-right"] = "rbxassetid://116930791412791",
	["triangle"] = "rbxassetid://126330486745540",
	["trophy"] = "rbxassetid://131545003268773",
	["truck-electric"] = "rbxassetid://111873446387359",
	["truck"] = "rbxassetid://86662707764771",
	["turkish-lira"] = "rbxassetid://114589876174070",
	["turntable"] = "rbxassetid://129870346487856",
	["turtle"] = "rbxassetid://118295081560334",
	["tv-minimal-play"] = "rbxassetid://99201833426972",
	["tv-minimal"] = "rbxassetid://100382201729427",
	["tv"] = "rbxassetid://135687724791776",
	["twitch"] = "rbxassetid://71383308134888",
	["twitter"] = "rbxassetid://88791703276842",
	["type-outline"] = "rbxassetid://80108627791690",
	["type"] = "rbxassetid://133543553793564",
	["umbrella-off"] = "rbxassetid://72395143739955",
	["umbrella"] = "rbxassetid://127502210274589",
	["underline"] = "rbxassetid://123709229216544",
	["undo-2"] = "rbxassetid://113885292059932",
	["undo-dot"] = "rbxassetid://132055277744844",
	["undo"] = "rbxassetid://111258459077271",
	["unfold-horizontal"] = "rbxassetid://117128358526398",
	["unfold-vertical"] = "rbxassetid://116593025265499",
	["ungroup"] = "rbxassetid://106674800451003",
	["university"] = "rbxassetid://84652528263642",
	["unlink-2"] = "rbxassetid://128131898892572",
	["unlink"] = "rbxassetid://139835795227752",
	["unplug"] = "rbxassetid://90171381619874",
	["upload"] = "rbxassetid://138212042425501",
	["usb"] = "rbxassetid://117230058949613",
	["user-check"] = "rbxassetid://81775205032725",
	["user-cog"] = "rbxassetid://92795491530865",
	["user-lock"] = "rbxassetid://78892639693821",
	["user-minus"] = "rbxassetid://126976941957511",
	["user-pen"] = "rbxassetid://87445472574836",
	["user-plus"] = "rbxassetid://118514469915884",
	["user-round-check"] = "rbxassetid://118794737621941",
	["user-round-cog"] = "rbxassetid://78239503290053",
	["user-round-minus"] = "rbxassetid://98944176636447",
	["user-round-pen"] = "rbxassetid://108155244324878",
	["user-round-plus"] = "rbxassetid://113301899567470",
	["user-round-search"] = "rbxassetid://71565774381870",
	["user-round-x"] = "rbxassetid://122367980560930",
	["user-round"] = "rbxassetid://136485052187963",
	["user-search"] = "rbxassetid://101335649828115",
	["user-star"] = "rbxassetid://98777846316000",
	["user-x"] = "rbxassetid://139748155894754",
	["user"] = "rbxassetid://81589895647169",
	["users-round"] = "rbxassetid://103005444008339",
	["users"] = "rbxassetid://115398113982385",
	["utensils-crossed"] = "rbxassetid://109520762270383",
	["utensils"] = "rbxassetid://139952569804235",
	["utility-pole"] = "rbxassetid://101965541238242",
	["variable"] = "rbxassetid://104743088438151",
	["vault"] = "rbxassetid://108049164599845",
	["vector-square"] = "rbxassetid://86713728565344",
	["vegan"] = "rbxassetid://119489190688082",
	["venetian-mask"] = "rbxassetid://102636443033920",
	["venus-and-mars"] = "rbxassetid://120227752103771",
	["venus"] = "rbxassetid://82891342220859",
	["vibrate-off"] = "rbxassetid://113446447326246",
	["vibrate"] = "rbxassetid://108330910738733",
	["video-off"] = "rbxassetid://132239189859305",
	["video"] = "rbxassetid://107587444636945",
	["videotape"] = "rbxassetid://114816894323398",
	["view"] = "rbxassetid://118717253976805",
	["voicemail"] = "rbxassetid://134313454010227",
	["volleyball"] = "rbxassetid://83889351124153",
	["volume-1"] = "rbxassetid://98514588731639",
	["volume-2"] = "rbxassetid://89344380902620",
	["volume-off"] = "rbxassetid://103047478058767",
	["volume-x"] = "rbxassetid://139252359189540",
	["volume"] = "rbxassetid://103236289817396",
	["vote"] = "rbxassetid://89409762851246",
	["wallet-cards"] = "rbxassetid://129728715308337",
	["wallet-minimal"] = "rbxassetid://137800448816116",
	["wallet"] = "rbxassetid://132331555762628",
	["wallpaper"] = "rbxassetid://74682121235494",
	["wand-sparkles"] = "rbxassetid://82546429942392",
	["wand"] = "rbxassetid://114580617777835",
	["warehouse"] = "rbxassetid://78388887451080",
	["washing-machine"] = "rbxassetid://104194127573858",
	["watch"] = "rbxassetid://130544621618405",
	["waves-ladder"] = "rbxassetid://101808619355514",
	["waves"] = "rbxassetid://96340135183647",
	["waypoints"] = "rbxassetid://102450133666017",
	["webcam"] = "rbxassetid://104148487911129",
	["webhook-off"] = "rbxassetid://96370548093471",
	["webhook"] = "rbxassetid://112812457747322",
	["weight"] = "rbxassetid://103860559844854",
	["wheat-off"] = "rbxassetid://133294844612307",
	["wheat"] = "rbxassetid://85261952080359",
	["whole-word"] = "rbxassetid://90111083954485",
	["wifi-cog"] = "rbxassetid://110500263326209",
	["wifi-high"] = "rbxassetid://81954601342139",
	["wifi-low"] = "rbxassetid://138217335635913",
	["wifi-off"] = "rbxassetid://74113634330106",
	["wifi-pen"] = "rbxassetid://91290205064712",
	["wifi-sync"] = "rbxassetid://84043971055177",
	["wifi-zero"] = "rbxassetid://124286465246123",
	["wifi"] = "rbxassetid://104669375183960",
	["wind-arrow-down"] = "rbxassetid://127753987414870",
	["wind"] = "rbxassetid://114551690399915",
	["wine-off"] = "rbxassetid://108294164302317",
	["wine"] = "rbxassetid://115743721332829",
	["workflow"] = "rbxassetid://99186544029189",
	["worm"] = "rbxassetid://115752311548091",
	["wrench"] = "rbxassetid://112148279212860",
	["x"] = "rbxassetid://110786993356448",
	["youtube"] = "rbxassetid://123663668456341",
	["zap-off"] = "rbxassetid://81385483183652",
	["zap"] = "rbxassetid://130551565616516",
	["zoom-in"] = "rbxassetid://127956924984803",
	["zoom-out"] = "rbxassetid://108334162607319",
	["balloon"] = "rbxassetid://97489111621526",
	["beef-off"] = "rbxassetid://99869959725200",
	["book-search"] = "rbxassetid://132585409504950",
	["calendars"] = "rbxassetid://130944763042289",
	["cannabis-off"] = "rbxassetid://101938500363812",
	["cctv-off"] = "rbxassetid://75925370187295",
	["cigarette"] = "rbxassetid://137149549886852",
	["circle-pile"] = "rbxassetid://116353155251541",
	["cloud-backup"] = "rbxassetid://111649579696132",
	["cloud-sync"] = "rbxassetid://79393911188593",
	["database-search"] = "rbxassetid://92017137080138",
	["ellipse"] = "rbxassetid://71559658267482",
	["fingerprint-pattern"] = "rbxassetid://80934710831288",
	["fishing-hook"] = "rbxassetid://121038780855899",
	["fishing-rod"] = "rbxassetid://71754848048049",
	["form"] = "rbxassetid://72999643971000",
	["git-merge-conflict"] = "rbxassetid://85677801675703",
	["globe-off"] = "rbxassetid://77775243585824",
	["globe-x"] = "rbxassetid://109268097029296",
	["hd"] = "rbxassetid://71682790698278",
	["image"] = "rbxassetid://112751259236831",
	["layers-plus"] = "rbxassetid://77587765623057",
	["lens-concave"] = "rbxassetid://94819631937027",
	["lens-convex"] = "rbxassetid://74736504195474",
	["line-dot-right-horizontal"] = "rbxassetid://104718593155221",
	["line-style"] = "rbxassetid://90176717785772",
	["map-pin-search"] = "rbxassetid://89065012915078",
	["message-circle-check"] = "rbxassetid://132772297689418",
	["message-square-check"] = "rbxassetid://125789987055668",
	["metronome"] = "rbxassetid://101991829345965",
	["mirror-rectangular"] = "rbxassetid://109046769760336",
	["mirror-round"] = "rbxassetid://121534049429097",
	["mouse-left"] = "rbxassetid://99144293708743",
	["mouse-right"] = "rbxassetid://88331710212594",
	["printer-x"] = "rbxassetid://103002721801548",
	["radio-off"] = "rbxassetid://80359258046586",
	["road"] = "rbxassetid://120251329173530",
	["scooter"] = "rbxassetid://100035452787934",
	["search-alert"] = "rbxassetid://127597984617505",
	["shelving-unit"] = "rbxassetid://80116568514793",
	["shield-cog-corner"] = "rbxassetid://111694066132698",
	["shield-cog"] = "rbxassetid://129235695057857",
	["sport-shoe"] = "rbxassetid://120495992692630",
	["square-arrow-right-enter"] = "rbxassetid://138867831495334",
	["square-arrow-right-exit"] = "rbxassetid://133688575845430",
	["square-centerline-dashed-horizontal"] = "rbxassetid://77780104374341",
	["square-centerline-dashed-vertical"] = "rbxassetid://107878435803525",
	["stone"] = "rbxassetid://135161057497830",
	["toolbox"] = "rbxassetid://85341033903792",
	["towel-rack"] = "rbxassetid://125223915620991",
	["user-key"] = "rbxassetid://105403041782190",
	["user-round-key"] = "rbxassetid://124547549008939",
	["van"] = "rbxassetid://122066377022942",
	["waves-arrow-down"] = "rbxassetid://129215220911792",
	["waves-arrow-up"] = "rbxassetid://102314705716217",
	["weight-tilde"] = "rbxassetid://112081212176951",
	["x-line-top"] = "rbxassetid://140592656289509",
	["zodiac-aquarius"] = "rbxassetid://74560047770362",
	["zodiac-aries"] = "rbxassetid://73255859670234",
	["zodiac-cancer"] = "rbxassetid://131985162532947",
	["zodiac-capricorn"] = "rbxassetid://97859568140652",
	["zodiac-gemini"] = "rbxassetid://80997588122992",
	["zodiac-leo"] = "rbxassetid://75509406718106",
	["zodiac-libra"] = "rbxassetid://113222735060218",
	["zodiac-ophiuchus"] = "rbxassetid://129180108892480",
	["zodiac-pisces"] = "rbxassetid://95845819440327",
	["zodiac-sagittarius"] = "rbxassetid://82651026742181",
	["zodiac-scorpio"] = "rbxassetid://113640924054631",
	["zodiac-taurus"] = "rbxassetid://123053219704400",
	["zodiac-virgo"] = "rbxassetid://99462994613661",
}

    end,
    ["src/Kaeryn/Navigation.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local rgbseq = __kaeryn.rgbseq
    local rgbkey = __kaeryn.rgbkey
    local insert = __kaeryn.insert
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts
    local safe_callback = __kaeryn.safe_callback

function library:tab(properties)
    properties = properties or {}
    local tab_name = properties.name or properties.Name or "visuals"
    local tab_id = properties.id or tab_name
    assert(type(tab_id) == "string" and tab_id:gsub("%s", "") ~= "", "tab id must be a non-empty string")
    assert(type(tab_name) == "string" and tab_name:gsub("%s", "") ~= "", "tab name must be a non-empty string")
    assert(properties.on_enter == nil or type(properties.on_enter) == "function", "tab on_enter must be a function")
    assert(properties.on_leave == nil or type(properties.on_leave) == "function", "tab on_leave must be a function")
    for _, registered_tab in ipairs(library.tabs or {}) do
        assert(registered_tab.id ~= tab_id, "duplicate tab id '" .. tab_id .. "'")
    end
    local cfg = {
        id = tab_id;
        name = tab_name;
        on_enter = properties.on_enter;
        on_leave = properties.on_leave;
        icon = properties.icon or properties.Icon or "lucide:layout-dashboard";
        custom_icon = properties.icon ~= nil or properties.Icon ~= nil;

        tabs = properties.tabs or properties.Tabs or {"Main", "Misc.", "Settings"};
        pages = {};
        current_multi;

        items = {};
    }
    self.tabs = self.tabs or {}
    insert(self.tabs, cfg)

    function cfg:OnEnter(callback)
        assert(type(callback) == "function", "OnEnter expects a function")
        self.on_enter = callback
        return self
    end

    function cfg:OnLeave(callback)
        assert(type(callback) == "function", "OnLeave expects a function")
        self.on_leave = callback
        return self
    end

    local items = cfg.items; do
        items[ "tab_holder" ] = library:create( "Frame" , {
            Parent = library.cache;
            Name = "\0";
            Visible = false;
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 56);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -216, 1, -101);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "button_holder" ];
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 0, 35);
            BorderSizePixel = 0;
            TextSize = 16;
            BackgroundColor3 = rgb(29, 29, 29)
        });

        items[ "icon" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "button" ];
            AnchorPoint = vec2(0, 0.5);
            Image = cfg.icon;
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 22, 0, 22);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "icon" ], "accent", "ImageColor3");

        if not cfg.custom_icon then
            items["compact_mark"] = library:create("TextLabel", {
                Parent = items["button"],
                Name = "CompactMark",
                AnchorPoint = vec2(0.5, 0.5),
                Position = dim2(0.5, 0, 0.5, 0),
                Size = dim_offset(28, 28),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = fonts.font,
                Text = string.upper(cfg.name:match("[%w]") or "?"),
                TextColor3 = rgb(72, 72, 73),
                TextSize = 15,
                Visible = false,
            })
            library:apply_theme(items["compact_mark"], "accent", "TextColor3")
        end

        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            Size = dim2(0, 0, 1, 0);
            Position = dim2(0, 40, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });

        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 7)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "button" ];
            Enabled = false;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        items[ "multi_section_button_holder" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = library.cache;
            BackgroundTransparency = 1;
            Name = "\0";
            Visible = false;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -82, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        if library.is_mobile then
            local holder = items.multi_section_button_holder
            holder.Active = true
            holder.ClipsDescendants = true
            holder.ScrollBarThickness = 0
            holder.ScrollingDirection = Enum.ScrollingDirection.X
            holder.AutomaticCanvasSize = Enum.AutomaticSize.X
            holder.CanvasSize = dim_offset(0, 0)
        end

        library:create( "UIListLayout" , {
            Parent = items[ "multi_section_button_holder" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });

        library:create( "UIPadding" , {
            PaddingTop = dim(0, 8);
            PaddingBottom = dim(0, 7);
            Parent = items[ "multi_section_button_holder" ];
            PaddingRight = dim(0, 7);
            PaddingLeft = dim(0, 7)
        });

        for _, section in ipairs(cfg.tabs) do
            local definition = type(section) == "table" and section or {name = section}
            local section_name = definition.name or definition.Name
            local section_id = definition.id or section_name
            assert(type(section_name) == "string" and section_name:gsub("%s", "") ~= "", "tab page name must be a non-empty string")
            assert(type(section_id) == "string" and section_id:gsub("%s", "") ~= "", "tab page id must be a non-empty string")
            for _, existing_page in ipairs(cfg.pages) do
                assert(existing_page.id ~= section_id, "duplicate page id '" .. section_id .. "' in tab '" .. tab_id .. "'")
            end
            assert(definition.lazy == nil or type(definition.lazy) == "function", "tab page lazy must be a function")
            assert(definition.on_enter == nil or type(definition.on_enter) == "function", "tab page on_enter must be a function")
            assert(definition.on_leave == nil or type(definition.on_leave) == "function", "tab page on_leave must be a function")
            local data = {
                id = section_id,
                name = section_name,
                items = {},
                _tab = cfg,
                _lazy_builder = definition.lazy,
                _built = definition.lazy == nil,
                _on_enter = definition.on_enter,
                _on_leave = definition.on_leave,
                _scopes = {},
            }

            local multi_items = data.items; do
                multi_items[ "button" ] = library:create( "TextButton" , {
                    FontFace = fonts.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    AutoButtonColor = false;
                    Text = "";
                    Parent = items[ "multi_section_button_holder" ];
                    Name = "\0";
                    Size = dim2(0, 0, 0, 39);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.X;
                    TextSize = 16;
                    BackgroundColor3 = rgb(25, 25, 29)
                });

                multi_items[ "name" ] = library:create( "TextLabel" , {
                    FontFace = fonts.font;
                    TextColor3 = rgb(62, 62, 63);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = section_name;
                    Parent = multi_items[ "button" ];
                    Name = "\0";
                    Size = dim2(0, 0, 1, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 16;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                library:create( "UIPadding" , {
                    Parent = multi_items[ "name" ];
                    PaddingRight = dim(0, 5);
                    PaddingLeft = dim(0, 5)
                });

                multi_items[ "accent" ] = library:create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    AnchorPoint = vec2(0, 1);
                    Parent = multi_items[ "button" ];
                    BackgroundTransparency = 1;
                    Position = dim2(0, 10, 1, 4);
                    Name = "\0";
                    Size = dim2(1, -20, 0, 6);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                }); library:apply_theme(multi_items[ "accent" ], "accent", "BackgroundColor3");

                library:create( "UICorner" , {
                    Parent = multi_items[ "accent" ];
                    CornerRadius = dim(0, 999)
                });

                library:create( "UIPadding" , {
                    Parent = multi_items[ "button" ];
                    PaddingRight = dim(0, 10);
                    PaddingLeft = dim(0, 10)
                });

                library:create( "UICorner" , {
                    Parent = multi_items[ "button" ];
                    CornerRadius = dim(0, 7)
                });

                multi_items[ "tab" ] = library:create( "Frame" , {
                    Parent = library.cache;
                    BackgroundTransparency = 1;
                    Name = "\0";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -20, 1, -20);
                    BorderSizePixel = 0;
                    Visible = false;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                library:create( "UIListLayout" , {
                    FillDirection = Enum.FillDirection.Vertical;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = multi_items[ "tab" ];
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                });

                library:create( "UIPadding" , {
                    PaddingTop = dim(0, 7);
                    PaddingBottom = dim(0, 7);
                    Parent = multi_items[ "tab" ];
                    PaddingRight = dim(0, 7);
                    PaddingLeft = dim(0, 7)
                });
            end

            data.text = multi_items[ "name" ]
            data.accent = multi_items[ "accent" ]
            data.button = multi_items[ "button" ]
            data.page = multi_items[ "tab" ]
            data.parent = setmetatable(data, library):sub_tab({}).items[ "tab_parent" ]

            function data:OnEnter(callback)
                assert(type(callback) == "function", "OnEnter expects a function")
                self._on_enter = callback
                return self
            end

            function data:OnLeave(callback)
                assert(type(callback) == "function", "OnLeave expects a function")
                self._on_leave = callback
                return self
            end

            function data:CreateScope()
                local scope = library:scope()
                table.insert(self._scopes, scope)
                return scope
            end

            local function leave_page(page)
                if not page or not page._active then return end
                page._active = false
                if page._on_leave then safe_callback(page._on_leave, page) end
                for scope_index = #page._scopes, 1, -1 do
                    page._scopes[scope_index]:Destroy()
                    page._scopes[scope_index] = nil
                end
            end

            function data.open_page()
                if data._active then return true end
                if data._build_error then return false, data._build_error end
                if not data._built and data._lazy_builder then
                    data._built = true
                    local build_ok, build_error = pcall(data._lazy_builder, data)
                    if not build_ok then
                        data._build_error = tostring(build_error)
                        warn("[Kaeryn] lazy builder failed for page '" .. data.id .. "': " .. data._build_error)
                        return false, data._build_error
                    end
                end
                local page = cfg.current_multi;

                if page and page ~= data then leave_page(page) end

                if page and page.text ~= data.text then
                    self.items[ "global_fade" ].BackgroundTransparency = 0
                    library:tween(self.items[ "global_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)

                    local old_size = page.page.Size
                    page.page.Size = dim2(1, -20, 1, -20)
                end

                if page then
                    library:tween(page.text, {TextColor3 = rgb(62, 62, 63)})
                    library:tween(page.accent, {BackgroundTransparency = 1})
                    library:tween(page.button, {BackgroundTransparency = 1})

                    page.page.Visible = false
                    page.page.Parent = library[ "cache" ]
                end

                library:tween(data.text, {TextColor3 = rgb(255, 255, 255)})
                library:tween(data.accent, {BackgroundTransparency = 0})
                library:tween(data.button, {BackgroundTransparency = 0})
                library:tween(data.page, {Size = dim2(1, 0, 1, 0)}, Enum.EasingStyle.Quad, 0.4)

                data.page.Visible = true
                data.page.Parent = items["tab_holder"]

                cfg.current_multi = data
                data._active = true
                if data._on_enter then safe_callback(data._on_enter, data) end

                library:close_element()
                return true
            end

            multi_items[ "button" ].Activated:Connect(function()
                data.open_page()
            end)

            cfg.pages[#cfg.pages + 1] = setmetatable(data, library)
        end

    end

    function cfg.open_tab(skip_default_page)
        if self._selected_tab_object == cfg then return true end
        local selected_tab = self.selected_tab
        local previous_tab = self._selected_tab_object
        if previous_tab then
            if previous_tab.on_leave then safe_callback(previous_tab.on_leave, previous_tab) end
            if previous_tab.current_multi then
                local current = previous_tab.current_multi
                if current._active then
                    current._active = false
                    if current._on_leave then safe_callback(current._on_leave, current) end
                    for scope_index = #current._scopes, 1, -1 do
                        current._scopes[scope_index]:Destroy()
                        current._scopes[scope_index] = nil
                    end
                end
            end
        end

        if selected_tab then
            if selected_tab[ 4 ] ~= items[ "tab_holder" ] then
                self.items[ "global_fade" ].BackgroundTransparency = 0

                library:tween(self.items[ "global_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
                local side = library.responsive_sidebar_width or 196
                local header = library.responsive_header_height or 56
                selected_tab[ 4 ].Size = library.is_mobile and selected_tab[ 4 ].Size or dim2(1, -side - 20, 1, -(header + 25 + 20))
            end

            library:tween(selected_tab[ 1 ], {BackgroundTransparency = 1})
            library:tween(selected_tab[ 2 ], {ImageColor3 = rgb(72, 72, 73)})
            library:tween(selected_tab[ 3 ], {TextColor3 = rgb(72, 72, 73)})
            if selected_tab[6] then
                library:tween(selected_tab[6], {TextColor3 = rgb(72, 72, 73)})
            end

            selected_tab[ 4 ].Visible = false
            selected_tab[ 4 ].Parent = library[ "cache" ]
            selected_tab[ 5 ].Visible = false
            selected_tab[ 5 ].Parent = library[ "cache" ]
        end

        library:tween(items[ "button" ], {BackgroundTransparency = 0})
        library:tween(items[ "icon" ], {ImageColor3 = themes.preset.accent})
        library:tween(items[ "name" ], {TextColor3 = rgb(255, 255, 255)})
        if items["compact_mark"] then
            library:tween(items["compact_mark"], {TextColor3 = themes.preset.accent})
        end
        if not library.is_mobile then
            local side = library.responsive_sidebar_width or 196
            local header = library.responsive_header_height or 56
            library:tween(items[ "tab_holder" ], {Size = dim2(1, -side, 1, -(header + 25))}, Enum.EasingStyle.Quad, 0.4)
        end

        items[ "tab_holder" ].Visible = true
        items[ "tab_holder" ].Parent = self.items[ "main" ]
        items[ "multi_section_button_holder" ].Visible = true
        items[ "multi_section_button_holder" ].Parent = self.items[ "multi_holder" ]

        self.selected_tab = {
            items[ "button" ];
            items[ "icon" ];
            items[ "name" ];
            items[ "tab_holder" ];
            items[ "multi_section_button_holder" ];
            items["compact_mark"];
        }
        self._selected_tab_object = cfg

        library:close_element()
        if not skip_default_page and cfg.current_multi and not cfg.current_multi._active then
            cfg.current_multi._active = true
            if cfg.current_multi._on_enter then safe_callback(cfg.current_multi._on_enter, cfg.current_multi) end
        elseif cfg.pages[1] and not skip_default_page then
            local opened, reason = cfg.pages[1].open_page()
            if not opened then return false, reason end
        end
        if cfg.on_enter then safe_callback(cfg.on_enter, cfg) end
        if library.is_mobile then library:queue_mobile_layout() end
        return true
    end

    items[ "button" ].Activated:Connect(function()
        cfg.open_tab()
    end)

    if not self.selected_tab then
        cfg.open_tab()
    end

    if library.is_mobile then
        insert(library.mobile_tabs, cfg)
        library:queue_mobile_layout()
    else
        library:refresh_responsive_layout(self)
    end
    return unpack(cfg.pages)
end

function library:separator(properties)
    properties = properties or {}
    assert(type(properties) == "table", "separator options must be a table")
    if properties.Name ~= nil then
        if not library.deprecated_option_warnings["separator_method:Name"] then
            library.deprecated_option_warnings["separator_method:Name"] = true
            warn("[Kaeryn] option 'Name' for separator is deprecated; use 'name'")
        end
        if properties.name ~= nil then error("Conflicting options 'Name' and 'name' for separator", 2) end
    end
    for key in pairs(properties) do
        if key ~= "name" and key ~= "Name" then error("Unknown option '" .. tostring(key) .. "' for separator", 2) end
    end
    local cfg = {items = {}, name = properties.name or properties.Name or "General"}

    local items = cfg.items do
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = self.items[ "button_holder" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, 40, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
    end;

    return setmetatable(cfg, library)
end

function library:seperator(properties)
    if not library.deprecated_option_warnings["method:seperator"] then
        library.deprecated_option_warnings["method:seperator"] = true
        warn("[Kaeryn] method 'seperator' is deprecated; use 'separator'")
    end
    return self:separator(properties)
end

function library:column(properties)
    local cfg = {items = {}, size = properties.size or 1}
    cfg._page = self

    local items = cfg.items; do
        items[ "column" ] = library:create( "Frame" , {
            Parent = self[ "parent" ] or self.items["tab_parent"];
            BackgroundTransparency = 1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, cfg.size, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        if library.is_mobile then
            items.column:SetAttribute("KaerynSectionSize", cfg.size)
            insert(library.mobile_columns, items.column)
            library:queue_mobile_layout()
        end
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 10);
            Parent = items[ "column" ]
        });

        library:create( "UIListLayout" , {
            Parent = items[ "column" ];
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            Padding = dim(0, 10);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder
        });
    end

    return setmetatable(cfg, library)
end

function library:sub_tab(properties)
    local cfg = {items = {}, order = properties.order or 0; size = properties.size or 1}

    local items = cfg.items; do
        items[ "tab_parent" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = self.items[ "tab" ];
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(0,0,cfg.size,0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            Visible = true;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        if library.is_mobile then
            local page = items.tab_parent
            page.Active = true
            page.ScrollBarThickness = 3
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.CanvasSize = dim_offset(0, 0)
            insert(library.mobile_pages, page)
        end
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            VerticalFlex = Enum.UIFlexAlignment.Fill;
            Parent = items[ "tab_parent" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
        });
    end

    return setmetatable(cfg, library)
end

function library:section(properties)
    properties = properties or {}
    local cfg = {
        name = properties.name or properties.Name or "section";
        side = properties.side or properties.Side or "left";
        default = properties.default or properties.Default or false;
        size = properties.size or properties.Size or self.size or 0.5;
        icon = properties.icon or properties.Icon or "lucide:settings";
        fading_toggle = properties.fading or properties.Fading or false;
        items = {};
    };
    cfg._column = self

    local elements_layout
    local items = cfg.items; do
        items[ "outline" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = self.items[ "column" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, cfg.size, -3);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });

        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 7)
        });

        items[ "scrolling" ] = library:create( "ScrollingFrame" , {
            ScrollBarImageColor3 = rgb(44, 44, 46);
            Active = true;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            ScrollBarThickness = 2;
            Parent = items[ "inline" ];
            Name = "\0";
            Size = dim2(1, 0, 1, -40);
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 35);
            BackgroundColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            CanvasSize = dim2(0, 0, 0, 0)
        });

        items[ "elements" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "scrolling" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0, 10);
            Size = dim2(1, -20, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        elements_layout = library:create( "UIListLayout" , {
            Parent = items[ "elements" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 15);
            Parent = items[ "elements" ]
        });

        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 0, 35);
            BorderSizePixel = 0;
            TextSize = 16;
            BackgroundColor3 = rgb(19, 19, 21)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "button" ];
            Enabled = false;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 7)
        });

        items[ "Icon" ] = library:create( "ImageLabel" , {
            ImageColor3 = themes.preset.accent;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "button" ];
            AnchorPoint = vec2(0, 0.5);
            Image = cfg.icon;
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 22, 0, 22);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "Icon" ], "accent", "ImageColor3");

        items[ "section_title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            Size = dim2(0, 0, 1, 0);
            Position = dim2(0, 40, 0, -1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "button" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });

        if cfg.fading_toggle then
            items[ "toggle" ] = library:create( "TextButton" , {
                FontFace = fonts.small;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                AutoButtonColor = false;
                Text = "";
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "button" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, 36, 0, 18);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = rgb(58, 58, 62)
            });  library:apply_theme(items[ "toggle" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle" ];
                CornerRadius = dim(0, 999)
            });

            items[ "toggle_outline" ] = library:create( "Frame" , {
                Parent = items[ "toggle" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(50, 50, 50)
            });  library:apply_theme(items[ "toggle_outline" ], "accent", "BackgroundColor3");

            library:create( "UICorner" , {
                Parent = items[ "toggle_outline" ];
                CornerRadius = dim(0, 999)
            });

            library:create( "UIGradient" , {
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
                Parent = items[ "toggle_outline" ]
            });

            items[ "toggle_circle" ] = library:create( "Frame" , {
                Parent = items[ "toggle_outline" ];
                Name = "\0";
                Position = dim2(0, 2, 0, 2);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 12, 0, 12);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(86, 86, 88)
            });

            library:create( "UICorner" , {
                Parent = items[ "toggle_circle" ];
                CornerRadius = dim(0, 999)
            });

            library:create( "UICorner" , {
                Parent = items[ "outline" ];
                CornerRadius = dim(0, 7)
            });

            items[ "fade" ] = library:create( "Frame" , {
                Parent = items[ "outline" ];
                BackgroundTransparency = 0.800000011920929;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, 0, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(0, 0, 0)
            });

            library:create( "UICorner" , {
                Parent = items[ "fade" ];
                CornerRadius = dim(0, 7)
            });
        end
    end;

    if cfg.fading_toggle then
        items[ "toggle" ].MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)
        items[ "button" ].MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)

        function cfg.toggle_section(bool)
            library:tween(items[ "toggle" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
            library:tween(items[ "toggle_outline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(50, 50, 50)}, Enum.EasingStyle.Quad)
            library:tween(items[ "toggle_circle" ], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -14, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
            library:tween(items[ "fade" ], {BackgroundTransparency = bool and 1 or 0.8}, Enum.EasingStyle.Quad)
        end
        cfg.toggle_section(cfg.default)
    end

    if library.is_mobile then
        items.scrolling.ScrollingEnabled = false
        items.scrolling.AutomaticCanvasSize = Enum.AutomaticSize.None
        items.scrolling.ScrollBarThickness = 0
        insert(library.mobile_sections, {outline = items.outline, layout = elements_layout, elements = items.elements, scrolling = items.scrolling, size = cfg.size})
        library:connection(elements_layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            library:queue_mobile_layout()
        end)
        library:queue_mobile_layout()
    end
    return setmetatable(cfg, library)
end
end

    end,
    ["src/Kaeryn/Notifications.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local insert = __kaeryn.insert
    local remove = __kaeryn.remove
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local notifications = __kaeryn.notifications
    local fonts = __kaeryn.fonts

notifications.records = notifications.records or {}
notifications.max_visible = notifications.max_visible or 4

local type_tokens = {info = "info", success = "success", warning = "warning", error = "error"}
local start_timer

function notifications:refresh_notifs()
    local offset = 50
    for _, frame in ipairs(self.notifs) do
        if frame and frame.Parent then
            library:tween(frame, {Position = dim_offset(20, offset)}, Enum.EasingStyle.Quad, 0.3)
            offset += max(frame.AbsoluteSize.Y, 53) + 10
        end
    end
    return offset
end

function notifications:fade(path, is_fading)
    if library.unloaded or not path or not path.Parent then return end
    local opacity = is_fading and 1 or 0
    library:tween(path, {BackgroundTransparency = opacity}, Enum.EasingStyle.Quad, 0.2)
    for _, instance in ipairs(path:GetDescendants()) do
        if instance:IsA("UIStroke") then
            library:tween(instance, {Transparency = opacity}, Enum.EasingStyle.Quad, 0.2)
        elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            library:tween(instance, {TextTransparency = opacity}, Enum.EasingStyle.Quad, 0.2)
        elseif instance:IsA("Frame") and instance.Name ~= "NotificationContent" then
            local desired = instance:GetAttribute("KaerynBaseTransparency")
            if desired == nil then
                desired = instance.BackgroundTransparency
                instance:SetAttribute("KaerynBaseTransparency", desired)
            end
            library:tween(instance, {BackgroundTransparency = is_fading and 1 or desired}, Enum.EasingStyle.Quad, 0.2)
        end
    end
end

local function update_content(record, options)
    local cfg = record.handle
    if options.name ~= nil then cfg.name = tostring(options.name) end
    if options.info ~= nil then cfg.info = tostring(options.info) end
    if options.type ~= nil then cfg.type = options.type end
    if options._replace_action then cfg.action = options.action end
    if options.dismissible ~= nil then cfg.dismissible = options.dismissible end
    cfg.lifetime = options.lifetime == nil and cfg.lifetime or options.lifetime
    record.remaining = cfg.lifetime
    record.items.title.Text = cfg.name
    record.items.info.Text = cfg.info
    record.items.bar.BackgroundColor3 = themes.preset[type_tokens[cfg.type]]
    library:track_theme(record.items.bar, "BackgroundColor3", record.items.bar.BackgroundColor3)
    record.items.action.Visible = cfg.action ~= nil
    if cfg.action then record.items.action.Text = cfg.action.label end
    record.items.close.Visible = cfg.dismissible
    record.items.bar.Visible = cfg.lifetime > 0
    record.items.bar.Size = dim2(1, 0, 0, 3)
    if start_timer then start_timer(record) end
end

local function remove_record(record, immediate)
    if record.closed then return end
    record.closed = true
    local index = table.find(notifications.records, record)
    if index then remove(notifications.records, index) end
    index = table.find(notifications.notifs, record.items.notification)
    if index then remove(notifications.notifs, index) end
    notifications:refresh_notifs()
    if immediate then
        if record.items.notification.Parent then record.items.notification:Destroy() end
        return
    end
    notifications:fade(record.items.notification, true)
    library:tween(record.items.notification, {AnchorPoint = vec2(1, 0)}, Enum.EasingStyle.Quad, 0.2)
    task.delay(0.25, function()
        if record.items.notification.Parent then record.items.notification:Destroy() end
    end)
end

function notifications:create_notification(options)
    assert(type(options) == "table", "notification options must be a table")
    assert(not library.unloaded and library.items, "cannot create a notification before opening a window or after unloading Kaeryn")
    local kind = options.type or "info"
    assert(type_tokens[kind], "notification type must be info, success, warning, or error")
    assert(options.dismissible == nil or type(options.dismissible) == "boolean", "dismissible must be a boolean")
    if options.action ~= nil then
        assert(type(options.action) == "table" and type(options.action.label) == "string" and options.action.label ~= "", "notification action needs a non-empty label")
        assert(type(options.action.callback) == "function", "notification action needs a callback")
    end
    local lifetime = options.lifetime or 3
    assert(type(lifetime) == "number" and lifetime == lifetime and lifetime >= 0 and lifetime < math.huge, "notification lifetime must be a finite non-negative number")
    local dedupe_key = options.dedupe_key
    if dedupe_key ~= nil then assert(type(dedupe_key) == "string" and dedupe_key ~= "", "dedupe_key must be a non-empty string") end

    if dedupe_key then
        for _, existing in ipairs(notifications.records) do
            if not existing.closed and existing.handle.dedupe_key == dedupe_key then
                existing.handle.type = kind
                update_content(existing, {name = options.name, info = options.info, type = kind, action = options.action,
                    _replace_action = true, lifetime = lifetime, dismissible = options.dismissible ~= false})
                return existing.handle
            end
        end
    end

    local max_visible = tonumber(notifications.max_visible)
    if not max_visible or max_visible ~= max_visible or max_visible == math.huge or max_visible == -math.huge then max_visible = 4 end
    max_visible = max(1, math.floor(max_visible))
    while #notifications.records >= max_visible do
        remove_record(notifications.records[1], true)
    end

    local cfg = {
        control_type = "notification",
        name = tostring(options.name or "Kaeryn"),
        info = tostring(options.info or ""),
        type = kind,
        lifetime = lifetime,
        action = options.action,
        dedupe_key = dedupe_key,
        dismissible = options.dismissible ~= false,
    }
    local items = {}
    local record = {handle = cfg, items = items, remaining = lifetime, paused = false, closed = false}
    cfg.Close = function() remove_record(record) end

    items.notification = library:create("Frame", {
        Parent = library.items;
        Size = dim2(0, 230, 0, 0);
        Name = "Notification";
        AutomaticSize = Enum.AutomaticSize.Y;
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.background;
        AnchorPoint = vec2(1, 0);
        Position = dim_offset(20, notifications:refresh_notifs());
    })
    library:create("UICorner", {Parent = items.notification; CornerRadius = dim(0, 5)})
    library:create("UIStroke", {Color = themes.preset.border; Parent = items.notification; ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    items.content = library:create("Frame", {
        Parent = items.notification;
        Name = "NotificationContent";
        Position = dim2(0, 9, 0, 7);
        Size = dim2(1, -18, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    library:create("UIListLayout", {Parent = items.content; Padding = dim(0, 4); SortOrder = Enum.SortOrder.LayoutOrder})
    items.header = library:create("Frame", {
        Parent = items.content;
        Name = "TitleRow";
        LayoutOrder = 1;
        Size = dim2(1, 0, 0, 20);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.title = library:create("TextLabel", {
        Parent = items.header;
        Name = "Title";
        Size = dim2(1, -24, 1, 0);
        Text = cfg.name;
        FontFace = fonts.font;
        TextSize = 14;
        TextColor3 = themes.preset.text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextTruncate = Enum.TextTruncate.AtEnd;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.close = library:create("TextButton", {
        Parent = items.header;
        Name = "Close";
        AnchorPoint = vec2(1, 0);
        Position = dim2(1, 0, 0, 0);
        Size = dim2(0, 20, 1, 0);
        Text = "×";
        FontFace = fonts.small;
        TextSize = 16;
        TextColor3 = themes.preset.muted;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        AutoButtonColor = false;
        Visible = cfg.dismissible;
    })
    items.info = library:create("TextLabel", {
        Parent = items.content;
        Name = "Info";
        LayoutOrder = 2;
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        Text = cfg.info;
        FontFace = fonts.small;
        TextSize = 13;
        TextColor3 = themes.preset.muted;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.action = library:create("TextButton", {
        Parent = items.content;
        Name = "Action";
        LayoutOrder = 3;
        Size = dim2(1, 0, 0, 24);
        Text = cfg.action and cfg.action.label or "";
        FontFace = fonts.small;
        TextSize = 12;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
        Visible = cfg.action ~= nil;
    })
    library:create("UICorner", {Parent = items.action; CornerRadius = dim(0, 4)})
    items.bar = library:create("Frame", {
        Parent = items.content;
        Name = "Lifetime";
        LayoutOrder = 4;
        Size = dim2(1, 0, 0, 3);
        BackgroundColor3 = themes.preset[type_tokens[kind]];
        BorderSizePixel = 0;
        Visible = lifetime > 0;
    })
    library:create("UICorner", {Parent = items.bar; CornerRadius = dim(0, 999)})
    library:create("UIPadding", {
        Parent = items.notification;
        PaddingBottom = dim(0, 7);
    })

    insert(notifications.records, record)
    insert(notifications.notifs, items.notification)
    notifications:fade(items.notification, false)
    library:tween(items.notification, {AnchorPoint = vec2(0, 0)}, Enum.EasingStyle.Quad, 0.2)
    notifications:refresh_notifs()

    local hovered, focused = false, false
    local function update_pause() record.paused = hovered or focused end
    items.notification.MouseEnter:Connect(function() hovered = true; update_pause() end)
    items.notification.MouseLeave:Connect(function() hovered = false; update_pause() end)
    for _, button in ipairs({items.action, items.close}) do
        button.SelectionGained:Connect(function() focused = true; update_pause() end)
        button.SelectionLost:Connect(function() focused = false; update_pause() end)
    end
    items.close.Activated:Connect(function() cfg:Close() end)
    items.action.Activated:Connect(function()
        if record.closed or not cfg.action then return end
        library:dispatch_control_callback(cfg, cfg.action.callback, {source = "user", phase = "commit"})
        if cfg.action.close ~= false then cfg:Close() end
    end)

    start_timer = function(target)
        target.timer_generation = (target.timer_generation or 0) + 1
        local generation = target.timer_generation
        if target.handle.lifetime <= 0 then return end
        task.spawn(function()
        local previous = os.clock()
        while not target.closed and target.timer_generation == generation and target.items.notification.Parent do
            task.wait(0.05)
            local now = os.clock()
            if not target.paused then target.remaining = max(0, target.remaining - (now - previous)) end
            previous = now
            target.items.bar.Size = dim2(target.remaining / target.handle.lifetime, 0, 0, 3)
            if target.remaining <= 0 then break end
        end
        if not target.closed and target.timer_generation == generation and target.remaining <= 0 then target.handle:Close() end
        end)
    end
    start_timer(record)
    return cfg
end

function library:notify(options)
    return notifications:create_notification(options)
end
end

    end,
    ["src/Kaeryn/Scopes.luau"] = function(__kaeryn_require)
return function(context)
    local library = context.library
    library.scopes = {}

    local function cleanup_resource(resource)
        if type(resource) == "function" then
            resource()
        elseif type(resource) == "thread" then
            if coroutine.status(resource) ~= "dead" and task and task.cancel then task.cancel(resource) end
        elseif typeof(resource) == "RBXScriptConnection" then
            resource:Disconnect()
        elseif typeof(resource) == "Instance" then
            resource:Destroy()
        elseif type(resource) == "table" then
            for _, method_name in ipairs({"Destroy", "Disconnect", "Cancel", "Close"}) do
                local cleanup = resource[method_name]
                if type(cleanup) == "function" then cleanup(resource); break end
            end
        end
    end

    function library:scope()
        assert(not self.unloaded, "Kaeryn has been unloaded")
        local scope = {_cleanups = {}, _destroyed = false}

        function scope:AddCleanup(callback)
            assert(type(callback) == "function", "scope cleanup must be a function")
            if self._destroyed then
                pcall(callback)
                return false
            end
            table.insert(self._cleanups, callback)
            return true
        end

        function scope:Give(resource)
            assert(resource ~= nil, "scope resource cannot be nil")
            local supported = type(resource) == "function" or type(resource) == "thread"
                or typeof(resource) == "RBXScriptConnection" or typeof(resource) == "Instance"
            if type(resource) == "table" then
                supported = type(resource.Destroy) == "function" or type(resource.Disconnect) == "function"
                    or type(resource.Cancel) == "function" or type(resource.Close) == "function"
            end
            assert(supported, "scope resource must be a function, task, connection, instance, or cleanup object")
            self:AddCleanup(function() cleanup_resource(resource) end)
            return resource
        end

        function scope:Connect(signal, callback)
            assert(not self._destroyed, "scope has been destroyed")
            assert(signal and type(callback) == "function", "scope:Connect expects a signal and callback")
            return self:Give(library:connection(signal, callback, self))
        end

        function scope:Destroy()
            if self._destroyed then return false end
            self._destroyed = true
            for index = #self._cleanups, 1, -1 do pcall(self._cleanups[index]) end
            table.clear(self._cleanups)
            for index = #library.scopes, 1, -1 do
                if library.scopes[index] == self then table.remove(library.scopes, index); break end
            end
            return true
        end

        table.insert(library.scopes, scope)
        return scope
    end
end

    end,
    ["src/Kaeryn/Search.luau"] = function(__kaeryn_require)
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
        local button = library:create("TextButton", {
            Parent = items.multi_holder,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = dim2(1, -9, 0.5, -2),
            Size = dim2(0, 66, 0, 30),
            BackgroundColor3 = themes.preset.surface_hover,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            FontFace = fonts.small,
            Text = "Find",
            TextColor3 = themes.preset.text,
            TextSize = 13,
            ZIndex = 5,
        })
        library:create("UICorner", {Parent = button, CornerRadius = dim(0, 5)})
        library:apply_theme(button, "surface_hover", "BackgroundColor3")
        library:apply_theme(button, "text", "TextColor3")
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

    end,
    ["src/Kaeryn/Themes.luau"] = function(__kaeryn_require)
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

    end,
    ["src/Kaeryn/Window.luau"] = function(__kaeryn_require)
return function(__kaeryn)
    local ws = __kaeryn.ws
    local coregui = __kaeryn.coregui
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local rect = __kaeryn.rect
    local dim_offset = __kaeryn.dim_offset
    local color = __kaeryn.color
    local rgb = __kaeryn.rgb
    local floor = __kaeryn.floor
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local fonts = __kaeryn.fonts

function library:window(properties)
    assert(not library.unloaded, "Kaeryn has been unloaded")
    assert(not library.items, "This Kaeryn instance already has a window; load a new instance for another window")
    properties = properties or {}
    local background_image = properties.background
    if background_image == nil then background_image = properties.background_image end
    if background_image == nil then background_image = properties.Background end
    if background_image == "" then background_image = nil end
    assert(background_image == nil or (type(background_image) == "string"
        and (background_image:match("^rbxassetid://%d+$") or background_image:match("^https?://%S+$"))),
        "window background must be a Roblox image asset or an HTTP(S) image URL")

    local background_transparency = properties.background_transparency
    if background_transparency == nil then background_transparency = properties.background_image_transparency end
    if background_transparency == nil then background_transparency = properties.BackgroundImageTransparency end
    if background_transparency == nil then background_transparency = 0 end
    assert(type(background_transparency) == "number" and background_transparency == background_transparency
        and background_transparency >= 0 and background_transparency <= 1,
        "window background_transparency must be a number between 0 and 1")

    local cfg = {
        suffix = properties.suffix or properties.Suffix or "tech";
        name = properties.name or properties.Name or "nebula";
        game_name = properties.gameInfo or properties.game_info or properties.GameInfo or "Kaeryn";
        size = properties.size or properties.Size or dim2(0, 700, 0, 565);
        background = background_image;
        background_transparency = background_transparency;
        min_size = properties.min_size or properties.MinSize or vec2(420, 320);
        max_size = properties.max_size or properties.MaxSize;
        selected_tab;
        items = {};

        tween;
    }
    assert(typeof(cfg.min_size) == "Vector2" and cfg.min_size.X > 0 and cfg.min_size.Y > 0
        and cfg.min_size.X < math.huge and cfg.min_size.Y < math.huge, "window min_size must be a finite positive Vector2")
    assert(cfg.max_size == nil or typeof(cfg.max_size) == "Vector2", "window max_size must be a Vector2")
    if cfg.max_size then
        assert(cfg.max_size.X > 0 and cfg.max_size.Y > 0 and cfg.max_size.X < math.huge and cfg.max_size.Y < math.huge,
            "window max_size values must be finite and positive")
        assert(cfg.max_size.X >= cfg.min_size.X and cfg.max_size.Y >= cfg.min_size.Y, "window max_size must be greater than or equal to min_size")
    end

    library[ "items" ] = library:create( "ScreenGui" , {
        Parent = coregui;
        Name = "\0";
        Enabled = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Global;
        IgnoreGuiInset = true;
    });

    library[ "other" ] = library:create( "ScreenGui" , {
        Parent = coregui;
        Name = "\0";
        Enabled = false;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        IgnoreGuiInset = true;
    });

    library.cache = library:create("Folder", {Name = "TabCache", Parent = library.other})
    local initial_viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
    local items = cfg.items; do
        items[ "main" ] = library:create( "Frame" , {
            Parent = library[ "items" ];
            Size = cfg.size;
            Name = "\0";
            Position = dim_offset(
                floor((initial_viewport.X - (initial_viewport.X * cfg.size.X.Scale + cfg.size.X.Offset)) / 2),
                floor((initial_viewport.Y - (initial_viewport.Y * cfg.size.Y.Scale + cfg.size.Y.Offset)) / 2)
            );
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16)
        });

        items["background_image"] = library:create("ImageLabel", {
            Parent = items.main;
            Name = "WindowBackground";
            Size = dim2(1, 0, 1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Image = cfg.background;
            ImageTransparency = cfg.background_transparency;
            ScaleType = Enum.ScaleType.Crop;
            Visible = cfg.background ~= nil;
            ZIndex = 1;
        })
        library:create("UICorner", {Parent = items.background_image, CornerRadius = dim(0, 10)})

        library:create( "UICorner" , {
            Parent = items[ "main" ];
            CornerRadius = dim(0, 10)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "main" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        items[ "side_frame" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            BackgroundTransparency = 1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 196, 1, -25);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16)
        });

        library:create( "Frame" , {
            AnchorPoint = vec2(1, 0);
            Parent = items[ "side_frame" ];
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 1, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });

        items[ "button_holder" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = items[ "side_frame" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 60);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, -60);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.button_holder = items[ "button_holder" ];
        if library.is_mobile then
            items.button_holder.Active = true
            items.button_holder.ScrollingDirection = Enum.ScrollingDirection.Y
            items.button_holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
            items.button_holder.ScrollBarThickness = 2
            items.button_holder.CanvasSize = dim_offset(0, 0)
            items.button_holder.ClipsDescendants = true
        end

        library:create( "UIListLayout" , {
            Parent = items[ "button_holder" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });

        library:create( "UIPadding" , {
            PaddingTop = dim(0, 16);
            PaddingBottom = dim(0, 36);
            Parent = items[ "button_holder" ];
            PaddingRight = dim(0, 11);
            PaddingLeft = dim(0, 10)
        });

        local accent = themes.preset.accent
        items[ "title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "side_frame" ];
            Name = "\0";
            Text = string.format('<u>%s</u><font color = "rgb(255, 255, 255)">%s</font>', cfg.name, cfg.suffix);
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 70);
            TextColor3 = themes.preset.accent;
            BorderSizePixel = 0;
            RichText = true;
            TextSize = 30;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "title" ], "accent", "TextColor3");

        items[ "multi_holder" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 0, 56);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.multi_holder = items[ "multi_holder" ];

        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "multi_holder" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });

        items[ "shadow" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(0, 0, 0);
            ScaleType = Enum.ScaleType.Slice;
            Parent = items[ "main" ];
            BorderColor3 = rgb(0, 0, 0);
            Name = "\0";
            BackgroundColor3 = rgb(255, 255, 255);
            Size = dim2(1, 75, 1, 75);
            AnchorPoint = vec2(0.5, 0.5);
            Image = "rbxassetid://112971167999062";
            BackgroundTransparency = 1;
            Position = dim2(0.5, 0, 0.5, 0);
            SliceScale = 0.75;
            ZIndex = -100;
            BorderSizePixel = 0;
            SliceCenter = rect(vec2(112, 112), vec2(147, 147))
        });

        items[ "global_fade" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 56);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 1, -81);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16);
            ZIndex = 2;
        });

        library:create( "UICorner" , {
            Parent = items[ "shadow" ];
            CornerRadius = dim(0, 5)
        });

        items[ "info" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "main" ];
            Name = "\0";
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 25);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(23, 23, 25)
        });

        library:create( "UICorner" , {
            Parent = items[ "info" ];
            CornerRadius = dim(0, 10)
        });

        items[ "grey_fill" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "info" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(23, 23, 25)
        });

        items[ "game" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            Parent = items[ "info" ];
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.game_name;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 10, 0.5, -1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "other_info" ] = library:create( "TextLabel" , {
            Parent = items[ "info" ];
            RichText = true;
            Name = "\0";
            TextColor3 = themes.preset.accent;
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name .. cfg.suffix;
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, -10, 0.5, -1);
            AnchorPoint = vec2(0, 0.5);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Right;
            AutomaticSize = Enum.AutomaticSize.XY;
            FontFace = fonts.font;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "other_info" ], "accent", "TextColor3");
    end

    do
        if library.is_mobile then
            library.mobile_window = cfg
            library:mobile_drag(items.title, items.main)
            cfg.sidebar_toggle = library:create("TextButton", {
                Parent = items.side_frame,
                Name = "MobileSidebarToggle",
                Text = "+",
                FontFace = fonts.font,
                TextSize = 17,
                TextColor3 = rgb(175, 169, 221),
                BackgroundColor3 = rgb(32, 31, 38),
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Size = dim_offset(24, 27),
                ZIndex = 8,
            })
            library:create("UICorner", {Parent = cfg.sidebar_toggle, CornerRadius = dim(0, 6)})
            library:connection(cfg.sidebar_toggle.MouseButton1Click, function()
                local compact = library.mobile_sidebar_preference
                if compact == nil then
                    local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(450, 800)
                    compact = false
                end
                library.mobile_sidebar_preference = not compact
                library:queue_mobile_layout()
            end)
            cfg.mobile_button = library:create("TextButton", {
                Parent = library.items,
                Name = "MobileMenu",
                Text = "☰",
                FontFace = fonts.font,
                TextSize = 24,
                TextColor3 = rgb(255, 255, 255),
                BackgroundColor3 = rgb(25, 25, 29),
                BorderSizePixel = 0,
                Size = dim_offset(38, 38),
                Position = dim2(1, -49, 0, 8),
                ZIndex = 50
            })
            library:create("UICorner", {Parent = cfg.mobile_button, CornerRadius = dim(0, 9)})
            library:connection(cfg.mobile_button.Activated, function() cfg:Toggle() end, cfg)
            local viewport_connection
            local function track_viewport()
                if viewport_connection then viewport_connection:Disconnect() end
                if ws.CurrentCamera then
                    viewport_connection = library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
                        library:queue_mobile_layout()
                    end)
                end
                library:queue_mobile_layout()
            end
            library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), track_viewport)
            track_viewport()
            library:refresh_mobile_layout()
        else
            library:draggify(items[ "main" ])
            library:resizify(items[ "main" ], cfg)
            local viewport_connection
            local function track_viewport()
                if viewport_connection then viewport_connection:Disconnect() end
                if ws.CurrentCamera then
                    viewport_connection = library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
                        library:refresh_responsive_layout(cfg)
                    end)
                    library:refresh_responsive_layout(cfg)
                end
            end
            library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), track_viewport)
            track_viewport()
        end
    end

    local function fire_lifecycle(event)
        local callback = cfg["_on_" .. event]
        if type(callback) ~= "function" then return end
        local ok, err = pcall(callback, cfg)
        if not ok then warn("[Kaeryn] window " .. event .. " callback failed: " .. tostring(err)) end
    end

    function cfg:OnOpen(callback)
        assert(type(callback) == "function", "OnOpen expects a function")
        self._on_open = callback
        return self
    end

    function cfg:OnClose(callback)
        assert(type(callback) == "function", "OnClose expects a function")
        self._on_close = callback
        return self
    end

    function cfg:OnDestroy(callback)
        assert(type(callback) == "function", "OnDestroy expects a function")
        self._on_destroy = callback
        return self
    end

    function cfg:SetBackgroundImage(image)
        if self._destroyed_window then return false, "window has been destroyed" end
        if image == "" then image = nil end
        if image ~= nil and (type(image) ~= "string"
            or not (image:match("^rbxassetid://%d+$") or image:match("^https?://%S+$"))) then
            return false, "background must be a Roblox image asset or an HTTP(S) image URL"
        end
        self.background = image
        items.background_image.Image = image or ""
        items.background_image.Visible = image ~= nil
        return true
    end

    function cfg:SetBackgroundImageTransparency(transparency)
        if self._destroyed_window then return false, "window has been destroyed" end
        if type(transparency) ~= "number" or transparency ~= transparency or transparency < 0 or transparency > 1 then
            return false, "background transparency must be a number between 0 and 1"
        end
        self.background_transparency = transparency
        items.background_image.ImageTransparency = transparency
        return true
    end

    function cfg:IsOpen()
        if self._destroyed_window then return false end
        if library.is_mobile then return items.main.Visible end
        return library.items.Enabled
    end

    function cfg:Open()
        if self._destroyed_window then return false, "window has been destroyed" end
        local was_open = self:IsOpen()
        if library.is_mobile then items.main.Visible = true else library.items.Enabled = true end
        if not was_open then fire_lifecycle("open") end
        return true
    end

    function cfg:Close()
        if self._destroyed_window then return false, "window has been destroyed" end
        local was_open = self:IsOpen()
        if library.is_mobile then items.main.Visible = false else library.items.Enabled = false end
        library:close_element()
        if was_open then fire_lifecycle("close") end
        return true
    end

    function cfg:Toggle()
        if self:IsOpen() then self:Close() else self:Open() end
        return self:IsOpen()
    end

    function cfg:_fire_destroy()
        if self._destroyed_window then return false end
        if self:IsOpen() then self:Close() end
        self._destroyed_window = true
        fire_lifecycle("destroy")
        return true
    end

    function cfg:Destroy()
        return library:unload_menu()
    end

    function cfg:SetResizeLimits(minimum, maximum)
        if self._destroyed_window then return false, "window has been destroyed" end
        if typeof(minimum) ~= "Vector2" or minimum.X ~= minimum.X or minimum.Y ~= minimum.Y
            or minimum.X <= 0 or minimum.Y <= 0 or minimum.X == math.huge or minimum.Y == math.huge then
            return false, "min_size must be a positive Vector2"
        end
        if maximum ~= nil and (typeof(maximum) ~= "Vector2" or maximum.X ~= maximum.X or maximum.Y ~= maximum.Y
            or maximum.X <= 0 or maximum.Y <= 0 or maximum.X < minimum.X or maximum.Y < minimum.Y
            or maximum.X == math.huge or maximum.Y == math.huge) then
            return false, "max_size must be a Vector2 greater than or equal to min_size"
        end
        self.min_size, self.max_size = minimum, maximum
        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
        local max_width = math.min(maximum and maximum.X or viewport.X, viewport.X)
        local max_height = math.min(maximum and maximum.Y or viewport.Y, viewport.Y)
        local min_width = math.min(minimum.X, max_width)
        local min_height = math.min(minimum.Y, max_height)
        local width = math.clamp(items.main.AbsoluteSize.X, min_width, max_width)
        local height = math.clamp(items.main.AbsoluteSize.Y, min_height, max_height)
        local left = math.clamp(items.main.AbsolutePosition.X, 0, math.max(0, viewport.X - width))
        local top = math.clamp(items.main.AbsolutePosition.Y, 0, math.max(0, viewport.Y - height))
        items.main.Size = dim_offset(width, height)
        items.main.Position = dim_offset(left, top)
        if library.is_mobile then library:queue_mobile_layout() else library:refresh_responsive_layout(self) end
        return true
    end

    function cfg:SaveLayout()
        if self._destroyed_window then return nil, "window has been destroyed" end
        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
        local position, size = items.main.AbsolutePosition, items.main.AbsoluteSize
        local available_x, available_y = math.max(0, viewport.X - size.X), math.max(0, viewport.Y - size.Y)
        local current_tab = self._selected_tab_object
        local current_page = current_tab and current_tab.current_multi
        return {
            version = 1,
            position = {x = available_x > 0 and position.X / available_x or 0, y = available_y > 0 and position.Y / available_y or 0},
            size = {x = viewport.X > 0 and size.X / viewport.X or 1, y = viewport.Y > 0 and size.Y / viewport.Y or 1},
            tab = current_tab and current_tab.id or nil,
            page = current_page and current_page.id or nil,
        }
    end

    function cfg:LoadLayout(layout)
        if self._destroyed_window then return false, "window has been destroyed" end
        if type(layout) ~= "table" or type(layout.position) ~= "table" or type(layout.size) ~= "table" then
            return false, "layout must contain position and size tables"
        end
        if layout.version ~= nil and layout.version ~= 1 then return false, "unsupported layout version" end
        local function valid_fraction(value)
            return type(value) == "number" and value == value and math.abs(value) < math.huge
        end
        local fractions = {layout.position.x, layout.position.y, layout.size.x, layout.size.y}
        for index = 1, 4 do
            if not valid_fraction(fractions[index]) then return false, "layout fractions must be finite numbers" end
        end
        local target_tab, target_page
        for _, tab in ipairs(library.tabs or {}) do
            if layout.tab ~= nil and tab.id == layout.tab then target_tab = tab; break end
        end
        if layout.tab ~= nil and not target_tab then return false, "layout references unknown tab '" .. tostring(layout.tab) .. "'" end
        if layout.page ~= nil then
            for _, page in ipairs(target_tab and target_tab.pages or {}) do
                if page.id == layout.page then target_page = page; break end
            end
            if not target_page then return false, "layout references unknown page '" .. tostring(layout.page) .. "'" end
        end

        local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
        local max_width = math.min(self.max_size and self.max_size.X or viewport.X, viewport.X)
        local max_height = math.min(self.max_size and self.max_size.Y or viewport.Y, viewport.Y)
        local min_width = math.min(self.min_size.X, max_width)
        local min_height = math.min(self.min_size.Y, max_height)
        local width = math.clamp(layout.size.x * viewport.X, min_width, max_width)
        local height = math.clamp(layout.size.y * viewport.Y, min_height, max_height)
        local left = math.clamp(layout.position.x, 0, 1) * math.max(0, viewport.X - width)
        local top = math.clamp(layout.position.y, 0, 1) * math.max(0, viewport.Y - height)
        items.main.Size = dim_offset(width, height)
        items.main.Position = dim_offset(left, top)
        if library.is_mobile then library:queue_mobile_layout() else library:refresh_responsive_layout(self) end
        if target_tab then
            local opened, reason = target_tab.open_tab(target_page ~= nil)
            if not opened then return false, reason end
        end
        if target_page then
            local opened, reason = target_page.open_page()
            if not opened then return false, reason end
        end
        return true
    end

    cfg.toggle_menu = function(bool)
        if bool == nil then return cfg:Toggle() end
        if bool then return cfg:Open() end
        return cfg:Close()
    end

    library:init_search(cfg)
    if library.is_mobile then library:queue_mobile_layout() end

    library.window = cfg
    return setmetatable(cfg, library)
end
end

    end,
}

local __kaeryn_cache = {}
local function __kaeryn_require(id)
    if __kaeryn_cache[id] ~= nil then return __kaeryn_cache[id] end
    local factory = __kaeryn_modules[id]
    if not factory then error("Unknown bundled module: " .. tostring(id), 2) end
    local value = factory(__kaeryn_require)
    __kaeryn_cache[id] = value
    return value
end

return __kaeryn_require("src/Kaeryn/Init.luau")
