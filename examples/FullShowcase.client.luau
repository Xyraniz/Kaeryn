-- quick full demo so u can poke every control, tweak away o.o

local source = game:HttpGet("https://raw.githubusercontent.com/Xyraniz/Kaeryn/main/dist/Kaeryn.luau?cb=" .. os.time())
local library = loadstring(source)()

local window = library:window({
    name = "Kaeryn",
    size = UDim2.fromOffset(760, 560),
})

window:separator({name = "Showcase"})

local controlsPage, choicesPage, toolsPage = window:tab({
    name = "Library demo",
    tabs = {"Controls", "Choices", "Tools"},
})

local function notify(name, info)
    library.notifications:create_notification({name = name, info = info, lifetime = 4})
end

local controlsLeft = controlsPage:column({})
local controlsRight = controlsPage:column({})
local basics = controlsLeft:section({name = "Toggles & sliders", default = true})
local textAndKeys = controlsRight:section({name = "Text & keybinds", default = true})

basics:label({
    name = "Every control in one place",
    info = "Try changing values, saving a config snapshot, then restoring it from the Tools tab.",
})

local enabled = basics:toggle({
    name = "Demo enabled",
    flag = "demo.enabled",
    default = true,
    callback = function(value)
        notify("Toggle", "Demo enabled: " .. tostring(value))
    end,
})

basics:toggle({
    name = "Checkbox style",
    flag = "demo.checkbox",
    type = "checkbox",
    default = false,
})

basics:slider({
    name = "Amount",
    flag = "demo.amount",
    min = 0,
    max = 100,
    interval = 1,
    default = 35,
    suffix = "%",
    callback = function(value)
        print("Amount:", value)
    end,
})

local advanced = enabled:settings({})
advanced:label({name = "Nested settings", info = "This popup is created with toggle:settings()."})
advanced:slider({
    name = "Nested scale",
    flag = "demo.advanced.scale",
    min = 0.25,
    max = 2,
    interval = 0.05,
    default = 1,
    callback = function(value)
        print("Nested scale:", value)
    end,
})
advanced:toggle({name = "Nested option", flag = "demo.advanced.enabled", default = true})

textAndKeys:label({name = "Inputs", info = "The keybind uses the Toggle mode by default."})
textAndKeys:textbox({
    name = "Profile name",
    placeholder = "Type a name...",
    default = "Player",
    flag = "demo.profile-name",
    callback = function(value)
        print("Profile name:", value)
    end,
})

textAndKeys:keybind({
    name = "Demo key",
    flag = "demo.key",
    key = Enum.KeyCode.RightShift,
    mode = "Toggle",
    default = false,
    callback = function(active)
        print("Keybind active:", active)
    end,
})

local choicesLeft = choicesPage:column({})
local choicesRight = choicesPage:column({})
local dropdowns = choicesLeft:section({name = "Dropdowns", default = true})
local selections = choicesRight:section({name = "Color & list", default = true})

dropdowns:dropdown({
    name = "Quality",
    flag = "demo.quality",
    items = {"Low", "Balanced", "High"},
    default = "Balanced",
    callback = function(value)
        print("Quality:", value)
    end,
})

dropdowns:dropdown({
    name = "Effects",
    flag = "demo.effects",
    items = {"Outline", "Glow", "Trail", "Particles"},
    multi = true,
    default = {"Outline", "Glow"},
    callback = function(values)
        print("Effects:", table.concat(values, ", "))
    end,
})

selections:colorpicker({
    name = "Preview tint",
    flag = "demo.preview-tint",
    color = Color3.fromRGB(120, 160, 255),
    callback = function(color, transparency)
        print("Tint:", color:ToHex(), transparency)
    end,
})

selections:list({
    name = "Preset",
    flag = "demo.preset",
    options = {"Default", "Warm", "Cool"},
    callback = function(value)
        print("Preset:", value)
    end,
})

local toolsLeft = toolsPage:column({})
local toolsRight = toolsPage:column({})
local actions = toolsLeft:section({name = "Actions", default = true})
local themeTools = toolsRight:section({name = "Theme & config", default = true})

actions:button({
    name = "Show notification",
    callback = function()
        notify("Kaeryn", "Notifications are working.")
    end,
})

local configSnapshot
themeTools:button({
    name = "Capture config snapshot",
    callback = function()
        configSnapshot = library:get_config()
        notify("Config", "Snapshot saved in memory.")
    end,
})

themeTools:button({
    name = "Restore config snapshot",
    callback = function()
        if not configSnapshot then
            notify("Config", "Capture a snapshot first.")
            return
        end
        local ok, err = library:load_config(configSnapshot)
        notify("Config", ok and "Snapshot restored." or tostring(err))
    end,
})

themeTools:button({
    name = "Apply sample palette",
    callback = function()
        local ok, err = library:set_theme({
            accent = Color3.fromRGB(119, 190, 168),
            background = Color3.fromRGB(14, 18, 20),
            surface = Color3.fromRGB(22, 29, 31),
        })
        if not ok then notify("Theme", tostring(err)) end
    end,
})

actions:button({
    name = "Unload library",
    callback = function()
        library:unload()
    end,
})

library:init_config(window)
