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
        ins[prop] = value
        if library.track_theme then library:track_theme(ins, prop, value) end
        if (prop == "Text" or prop == "PlaceholderText") and library._track_localized_text then
            library:_track_localized_text(ins, prop, value)
        end
    end

    return ins
end
end
