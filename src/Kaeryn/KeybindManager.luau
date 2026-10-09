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
