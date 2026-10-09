return function(context)
    local library = context.library
    library.scopes = {}

    local function cleanup_resource(resource)
        if type(resource) == "function" then
            resource()
        elseif type(resource) == "thread" then
            if coroutine.status(resource) ~= "dead" and task and task.cancel then task.cancel(resource) end
        elseif typeof(resource) == "RBXScriptConnection" then
            resource:Disconnect()
        elseif typeof(resource) == "Instance" then
            resource:Destroy()
        elseif type(resource) == "table" then
            for _, method_name in ipairs({"Destroy", "Disconnect", "Cancel", "Close"}) do
                local cleanup = resource[method_name]
                if type(cleanup) == "function" then cleanup(resource); break end
            end
        end
    end

    function library:scope()
        assert(not self.unloaded, "Kaeryn has been unloaded")
        local scope = {_cleanups = {}, _destroyed = false}

        function scope:AddCleanup(callback)
            assert(type(callback) == "function", "scope cleanup must be a function")
            if self._destroyed then
                pcall(callback)
                return false
            end
            table.insert(self._cleanups, callback)
            return true
        end

        function scope:Give(resource)
            assert(resource ~= nil, "scope resource cannot be nil")
            local supported = type(resource) == "function" or type(resource) == "thread"
                or typeof(resource) == "RBXScriptConnection" or typeof(resource) == "Instance"
            if type(resource) == "table" then
                supported = type(resource.Destroy) == "function" or type(resource.Disconnect) == "function"
                    or type(resource.Cancel) == "function" or type(resource.Close) == "function"
            end
            assert(supported, "scope resource must be a function, task, connection, instance, or cleanup object")
            self:AddCleanup(function() cleanup_resource(resource) end)
            return resource
        end

        function scope:Connect(signal, callback)
            assert(not self._destroyed, "scope has been destroyed")
            assert(signal and type(callback) == "function", "scope:Connect expects a signal and callback")
            return self:Give(library:connection(signal, callback, self))
        end

        function scope:Destroy()
            if self._destroyed then return false end
            self._destroyed = true
            for index = #self._cleanups, 1, -1 do pcall(self._cleanups[index]) end
            table.clear(self._cleanups)
            for index = #library.scopes, 1, -1 do
                if library.scopes[index] == self then table.remove(library.scopes, index); break end
            end
            return true
        end

        table.insert(library.scopes, scope)
        return scope
    end
end
