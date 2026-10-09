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
