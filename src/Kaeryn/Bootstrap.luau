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
