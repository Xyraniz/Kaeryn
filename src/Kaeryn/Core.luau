return function(__kaeryn)
    local uis = __kaeryn.uis
    local ws = __kaeryn.ws
    local tween_service = __kaeryn.tween_service
    local dim2 = __kaeryn.dim2
    local rgb = __kaeryn.rgb
    local camera = __kaeryn.camera
    local mouse = __kaeryn.mouse
    local keys = __kaeryn.keys
    local max = __kaeryn.max
    local min = __kaeryn.min
    local clamp = __kaeryn.clamp
    local insert = __kaeryn.insert
    local fonts = __kaeryn.fonts
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
            scrolling = descriptor("boolean", false), width = descriptor("number", 130, {min = 1}), ignore = descriptor("boolean", false),
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
            callback = descriptor("function", function() end), visible = descriptor("boolean", true)}),
        aliases = {Name = "name", placeholdertext = "placeholder", holder = "placeholder", holdertext = "placeholder"},
    },
    keybind = {
        fields = fields({name = descriptor("string"), key = descriptor({"string", "EnumItem"}), mode = descriptor("string", "Toggle", {values = {"Toggle", "Hold", "Always"}}),
            default = descriptor("boolean", false), ignore = descriptor("boolean", false), callback = descriptor("function", function() end)}),
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
                if #normalized.items > 0 and not table.find(normalized.items, selected) then
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
        if control_type == "dropdown" and type(option) ~= "string" then return false, "items must be strings" end
        if control_type == "list" and type(option) ~= "string" and type(option) ~= "number" and type(option) ~= "boolean" then
            return false, "options must contain strings, numbers, or booleans"
        end
        local key = tostring(option)
        if seen[key] then return false, "contains duplicate option '" .. key .. "'" end
        seen[key] = true
        count += 1
        highest_index = math.max(highest_index, index)
    end
    if count ~= highest_index then return false, "must be a dense array" end
    return true
end

function library:tween(obj, properties, easing_style, time)
    if library.unloaded or not obj then return nil end
    for property, value in pairs(properties) do
        if typeof(value) == "Color3" and library.track_theme then
            library:track_theme(obj, property, value)
        end
    end
    local tween = tween_service:Create(obj, TweenInfo.new(time or 0.25, easing_style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), properties)
    tween:Play()
    return tween
end

function library:resizify(frame)
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
    local start
    local og_size = frame.Size

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
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

            local current_size = dim2(
                start_size.X.Scale,
                math.clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    min(og_size.X.Offset, viewport_x),
                    viewport_x
                ),
                start_size.Y.Scale,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    min(og_size.Y.Offset, viewport_y),
                    viewport_y
                )
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

function library:attach_control(control, root)
    assert(type(control) == "table", "control handle must be a table")
    assert(type(control.id) == "string" and self.used_ids[control.id], "control handle needs a reserved id")
    control._ui_root = root
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
                local key = self.key
                self.items.key.Text = tostring(keys[key] or (typeof(key) == "EnumItem" and key.Name) or "NONE")
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
        if self.control_type == "dropdown" or self.control_type == "list" then
            local valid, reason = library:validate_option_list(self.control_type, options)
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
    local key = string.lower(tostring(control_type or ""))
    local definition = self.custom_control_types[key]
    if not definition then error("Unknown custom control type '" .. key .. "'", 2) end
    local normalized = self:normalize_options(key, options, definition.schema)
    local prior_migrations = table.clone(self.flag_migrations)
    local id, flag = self:resolve_identity(normalized, key, self.name, normalized.flag ~= nil)
    normalized.id, normalized.flag = id, flag
    local ok, control = pcall(function()
        local result = definition.factory(self, normalized, library)
        assert(type(result) == "table", "custom control factory must return a control handle")
        assert(not result.id or result.id == id, "Custom control factories cannot replace their registered id")
        assert(not result.flag or result.flag == flag, "Custom control flags must be declared in options")
        result.id = id
        result.flag = result.flag or flag
        result.name = result.name or normalized.name
        result.control_type = key
        result.legacy_flags = result.legacy_flags or normalized.legacy_flags
        if not result._ui_root then result._ui_root = result.items and result.items.root end
        if not result._attached then self:attach_control(result, result._ui_root) end
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
