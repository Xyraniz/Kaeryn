return function(__kaeryn)
local uis = __kaeryn.uis
local library = __kaeryn.library
local active_drag

local function same_touch(first, second)
    return first == second or (first and second
        and first.UserInputType == Enum.UserInputType.Touch
        and second.UserInputType == Enum.UserInputType.Touch
        and first.TouchId == second.TouchId)
end

local function contains(gui_object, position)
    if not gui_object or not gui_object.Parent or not gui_object.Visible then return false end
    local origin = gui_object.AbsolutePosition
    local size = gui_object.AbsoluteSize
    return size.X > 0 and size.Y > 0
        and position.X >= origin.X and position.X <= origin.X + size.X
        and position.Y >= origin.Y and position.Y <= origin.Y + size.Y
end

function library:begin_pointer_drag(input, on_changed, on_ended, owner)
    if active_drag then return false end
    if input and input.UserInputType ~= Enum.UserInputType.Touch then return false end
    active_drag = {
        input = input,
        on_changed = on_changed,
        on_ended = on_ended,
        owner = owner,
        touch = input ~= nil,
    }
    return true
end

function library:cancel_pointer_drag(owner)
    local drag = active_drag
    if owner and (not drag or drag.owner ~= owner) then return false end
    active_drag = nil
    if drag and type(drag.on_ended) == "function" then
        pcall(drag.on_ended)
    end
    return drag ~= nil
end

library:connection(uis.InputChanged, function(input)
    local drag = active_drag
    if not drag then return end
    local matches = drag.touch and same_touch(input, drag.input)
        or (not drag.touch and input.UserInputType == Enum.UserInputType.MouseMovement)
    if matches and type(drag.on_changed) == "function" then
        pcall(drag.on_changed, input.Position)
    end
end)

library:connection(uis.InputEnded, function(input)
    local drag = active_drag
    if not drag then return end
    local ended = drag.touch and same_touch(input, drag.input)
        or (not drag.touch and input.UserInputType == Enum.UserInputType.MouseButton1)
    if ended then library:cancel_pointer_drag() end
end)

library:connection(uis.InputBegan, function(input)
    local input_type = input.UserInputType
    if input_type ~= Enum.UserInputType.Touch and input_type ~= Enum.UserInputType.MouseButton1 then return end

    local current = library.current_open
    if not current or not current.items then return end
    local items = current.items
    local position = input.Position
    if contains(items.dropdown_holder, position)
        or contains(items.colorpicker_holder, position)
        or contains(items.outline, position)
        or contains(items.dropdown, position)
        or contains(items.colorpicker, position)
        or contains(items.tick, position) then
        return
    end

    library:close_element()
end)
end
