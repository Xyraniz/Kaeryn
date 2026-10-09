return function(__kaeryn)
    local uis = __kaeryn.uis
    local library = __kaeryn.library
    local active_drag

function library:begin_pointer_drag(input, on_changed, on_ended)
    if active_drag then return false end
    if input and input.UserInputType ~= Enum.UserInputType.Touch then return false end
    active_drag = {
        input = input,
        on_changed = on_changed,
        on_ended = on_ended,
        touch = input ~= nil,
    }
    return true
end

function library:cancel_pointer_drag()
    local drag = active_drag
    active_drag = nil
    if drag and type(drag.on_ended) == "function" then
        pcall(drag.on_ended)
    end
end

library:connection(uis.InputChanged, function(input)
    local drag = active_drag
    if not drag then return end
    local matches = drag.touch and input == drag.input
        or (not drag.touch and input.UserInputType == Enum.UserInputType.MouseMovement)
    if matches and type(drag.on_changed) == "function" then
        pcall(drag.on_changed, input.Position)
    end
end)

library:connection(uis.InputEnded, function(input)
    local drag = active_drag
    if not drag then return end
    local ended = drag.touch and input == drag.input
        or (not drag.touch and input.UserInputType == Enum.UserInputType.MouseButton1)
    if ended then library:cancel_pointer_drag() end
end)
end
