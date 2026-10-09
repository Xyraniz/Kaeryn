return function(__kaeryn)
    local library = __kaeryn.library
    local entries = setmetatable({}, {__mode = "k"})
    local listeners = {}
    library.locale_callbacks = listeners

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

    function library:translate(text)
        if type(text) ~= "string" then return text end
        local translations = self.locales[self.language]
        return translations and translations[text] or text
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
            assert(type(key) == "string" and type(value) == "string", "translation keys and values must be strings")
            locale[key] = value
        end
        self.locales[language] = locale
        if self.language == language then return self:set_language(language) end
        return true
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
