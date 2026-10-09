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
