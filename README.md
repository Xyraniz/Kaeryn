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

Configs are validated before any setter runs. Use `library:set_theme({accent = Color3.fromRGB(120, 160, 255), surface = Color3.fromRGB(20, 24, 32)})` to update palette tokens.

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
