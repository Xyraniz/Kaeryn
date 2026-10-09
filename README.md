# Kaeryn

Kaeryn is a modular Luau UI library. Its source lives in `src/Kaeryn/` as `.luau` files, and the generated `dist/Kaeryn.luau` stays self-contained for simple loading.

## Build

Requires Node.js; the build uses only Node's built-in modules.

```sh
npm run build
npm test
```

## Use the single-file bundle

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xyraniz/Kaeryn/main/dist/Kaeryn.luau"))()
```

Give controls explicit, stable IDs and flags for saved configs. If omitted, named controls keep the previous key derived from their type, section, and name. Unnamed persistent controls need an explicit `id` or `flag`. Duplicate IDs or flags stop setup with an error so one control cannot silently take over another control's identity or config setter.

```lua
section:toggle({name = "Enabled", flag = "aim.enabled"})
```

Configs are validated before any setter runs. `library:set_theme` updates color tokens and UI scale tokens such as text size, density, corner radius, and animation speed.

## Stable IDs and config migrations

Give a control an `id` that does not depend on its visible name or section. For stateful controls, the `id` is also the config flag by default; provide `flag` when those identities should differ.

```lua
local strength = section:slider({
    id = "combat.strength",
    name = "Strength",
    min = 0,
    max = 100,
})
```

If an old config used a different flag, list it in `legacy_flags`. Kaeryn also maps the previous type/section/name flag to the new flag when a control first receives an explicit `id` or `flag`. Use `register_flag_migration` for app-wide migrations, including old generated keys that cannot be inferred from a control name.

```lua
section:toggle({
    id = "combat.enabled",
    name = "Combat",
    legacy_flags = {"flagnumber12", "old.combat.toggle"},
})

library:register_flag_migration("settings.old_scale", "combat.strength")
```

Config loading follows migration chains before validating values. If multiple saved keys resolve to the same current flag, loading fails with a conflict message rather than choosing one value silently.

## Options and control handles

Each built-in control has a schema in `library.option_schemas`. Schemas describe accepted fields, types, defaults, value ranges, and enum choices. Unknown fields, invalid types, and invalid limits raise an error naming the option and control. Use lowercase canonical names such as `name`, `default`, `separator`, `min`, `max`, and `interval`. Legacy spellings including `Name`, `Seperator`, `seperator`, `minimum`, `maximum`, `decimal`, and `onCommit` still work where applicable and warn once; passing both an alias and its canonical field is an error. The old `seperator()` method also remains as a deprecated alias for `separator()`.

All control handles expose the same methods:

```lua
local value = strength:Get()
strength:Set(45)
strength:SetRange(0, 200, 5)
strength:SetDescription("Updated at runtime")
strength:SetVisible(true)
strength:SetEnabled(false)
strength:Destroy()
```

Dropdowns and lists also expose `SetOptions(options)`. Controls that do not represent a value (such as buttons) still have `Get` and `Set`; `Set` returns `false` with a reason when that control has no value setter. A description can be added or updated without recreating the control.

## Change events and callback errors

The existing `callback` receives its original values, followed by a metadata table. Existing callbacks that ignore extra arguments continue to work. `OnChanged` fires for each value update; `OnCommitted` fires after an edit is complete. Sliders additionally accept `on_commit`, which fires once when the user releases the slider.

```lua
strength:OnChanged(function(value, change)
    print(value, change.source, change.phase)
end)

strength:OnCommitted(function(value, change)
    print("saved value", value, change.id, change.flag)
end)
```

Metadata includes `source` (`user`, `config`, `code`, or `initialization`), `phase` (`change`, `commit`, `initialize`, or `rollback`), and the control's `id`, `flag`, `name`, and `type`. Callback failures are caught and reported with the action and control identity; the latest error is also available as `library.last_callback_error`.

## Search, language, dialogs, and responsive layouts

Every window includes a control search button; `Ctrl+K` opens it on desktop. Search checks control names, IDs, flags, descriptions, and their tab/section path. Selecting a result opens the right tab and scrolls to the control. You can also use the search API directly:

```lua
window.search.open()
local matches = library:search_controls("strength")
```

Kaeryn ships English and Spanish UI text. Switch the built-in UI to Spanish with `library:set_language("es")`. Add another language or translate your own visible strings with `register_locale` and `localize`:

```lua
library:register_locale("fr", {Find = "Rechercher", Confirm = "Confirmer"})
library:set_language("fr")
```

Use `library:alert`, `library:confirm`, and `library:prompt` for shared modal dialogs. Each accepts `title`, `message`, and the matching action labels; `on_confirm` receives `true` for alerts, a boolean for confirmations, or the entered string for prompts. Confirmations and prompts can also set `on_cancel`.

Window layout adapts to phone, tablet, and desktop viewports. The current breakpoint is available as `library.breakpoint` (`phone`, `tablet`, or `desktop`) and can be queried with `library:get_breakpoint(viewport_size)`.

## Dropdown values, labels, and large option lists

Dropdowns keep config values stable while showing a separate label. Existing string options still work. Add `group` and `disabled` where needed; lists with eight or more items get search by default, and `searchable = false` or `true` can override that choice. The popup virtualizes its visible rows for long lists.

```lua
local region = section:dropdown({
    id = "account.region",
    name = "Region",
    searchable = true,
    items = {
        {value = "na", label = "North America", group = "Americas"},
        {value = "sa", label = "South America", group = "Americas"},
        {value = "eu", label = "Europe", group = "EMEA"},
    },
    default = "na",
})

print(region:Get()) -- "na"; the menu displays "North America"
```

Dropdown configs save the stable `value`. During loading, old label-based values are still accepted and converted to their matching stable values.

## Keybind contexts, segmented controls, and numeric steppers

Keybinds are handled by one manager. Global bindings work in every context; scoped bindings run only while their exact context is active. Duplicate keys whose scopes overlap are reported by `GetConflicts()` and suppressed until resolved. `Rebind()` starts key capture on keyboard/mouse layouts, `Reset()` restores the configured key and mode, and `library:set_keybind_context()` switches the active scope.

```lua
local toggle_map = section:keybind({
    id = "combat.map",
    name = "Map",
    key = Enum.KeyCode.M,
    context = "combat",
})

library:set_keybind_context("combat")
local conflicts = toggle_map:GetConflicts()
toggle_map:Rebind()
toggle_map:Reset()
```

Use `segmented` for a short, exclusive choice and `stepper` when people need exact numeric adjustments.

```lua
local mode = section:segmented({
    id = "render.mode",
    name = "Mode",
    items = {{value = "fast", label = "Fast"}, {value = "quality", label = "Quality"}},
    default = "quality",
})

local scale = section:stepper({id = "render.scale", name = "Scale", min = 50, max = 150, step = 5, default = 100, suffix = "%"})
scale:SetRange(25, 200, 5)
```

Segmented controls accept two to five options and save each stable `value`; labels can change independently. Steppers clamp values to their range, snap them to `step`, and accept `on_commit` for work that should run after a user finishes editing.

## Repeated control groups

`section:group()` creates a list of rows that can be added, removed, and reordered. Give the group a stable `id` to save its row keys in configs; controls inside each row automatically receive IDs and flags scoped to that row.

```lua
local rules = section:group({id = "rules", name = "Rules", max_items = 8})
local safety = rules:Add("safety", "Safety")
safety:toggle({id = "enabled", name = "Enabled", default = true})
rules:Add("economy", "Economy")
rules:Move("economy", 1)
rules:Remove("safety")
```

Rows use stable keys, not their displayed titles. `group:Get()` returns the current keys, `group:Get(key)` returns a row, and `group:Set(keys)` replaces the list. Set `min_items` or `max_items` to constrain the collection. A group callback receives the action, changed key, current key list, and the usual callback metadata.

## Text validation and actionable notifications

Textboxes can enforce required values, length limits, or a custom validator. A validator returns `true` when valid, or `false, message` to show an inline error. Invalid user text stays visible for correction but does not replace the saved flag value.

```lua
local username = section:textbox({
    id = "profile.username",
    name = "Username",
    required = true,
    min_length = 3,
    max_length = 20,
    validate = function(value)
        local valid = value:match("^[%w_]+$") ~= nil
        return valid, "Use letters, numbers, or underscores"
    end,
})
```

Call `library:notify()` for a typed toast. Notifications support `info`, `success`, `warning`, and `error`, an optional action button, dismissal, a dedupe key, and `lifetime = 0` for a toast that stays until dismissed. Hovering or focusing a toast pauses its timer; the returned handle also has `Close()`. The default visible limit is four and can be changed with `library.notifications.max_visible`.

```lua
library:notify({
    type = "success",
    name = "Saved",
    info = "Profile updated",
    dedupe_key = "profile-save",
    action = {label = "Undo", callback = undo_save},
})
```

## Theme scale tokens

Color tokens still accept `Color3` values. `text_scale`, `density`, `radius_scale`, and `motion_scale` are numeric: density below `1` tightens padding, while motion scale `0` disables tween duration. Supported ranges are `0.75–1.5` for text, `0.65–1.5` for density, and `0–2` for radius and motion.

```lua
library:set_theme({
    accent = Color3.fromRGB(120, 160, 255),
    success = Color3.fromRGB(80, 190, 125),
    text_scale = 1.1,
    density = 0.9,
    radius_scale = 1.2,
    motion_scale = 0.6,
})
```

## Custom controls

Register a control factory once, then create it from a section without adding a module to Kaeryn's source tree. The factory receives the section, normalized options, and library. Return a table with `items.root` and, for value controls, a `set` function. Call `dispatch_control_callback` from the setter to provide the same metadata and events as built-in controls. A custom value control can register its config setter through `register_config_flag`.

```lua
library:register_control("badge", function(section, options, lib)
    local root = lib:create("Frame", {
        Parent = section.items.elements,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    })
    local label = lib:create("TextLabel", {
        Parent = root,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = options.default,
    })
    local control = {id = options.id, flag = options.flag, name = options.name, value = options.default, items = {root = root}}

    function control.set(value)
        control.value = value
        label.Text = value
        if control.flag then lib.flags[control.flag] = value end
        lib:dispatch_control_callback(control, nil, nil, value)
    end

    if control.flag then
        lib.flags[control.flag] = control.value
        lib:register_config_flag(control.flag, control.set, function(value)
            if type(value) ~= "string" then return false, nil, "expected a string" end
            return true, value
        end, options.legacy_flags)
    end
    return control
end, {
    fields = {default = {type = "string", default = "Ready"}},
})

local badge = section:custom_control("badge", {
    id = "status.badge",
    flag = "status.badge",
    name = "Status",
})
badge:Set("Connected")
```
