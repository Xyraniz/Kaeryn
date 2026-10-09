return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local insert = __kaeryn.insert
    local remove = __kaeryn.remove
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local notifications = __kaeryn.notifications
    local fonts = __kaeryn.fonts

notifications.records = notifications.records or {}
notifications.max_visible = notifications.max_visible or 4

local type_tokens = {info = "info", success = "success", warning = "warning", error = "error"}
local start_timer

function notifications:refresh_notifs()
    local offset = 50
    for _, frame in ipairs(self.notifs) do
        if frame and frame.Parent then
            library:tween(frame, {Position = dim_offset(20, offset)}, Enum.EasingStyle.Quad, 0.3)
            offset += max(frame.AbsoluteSize.Y, 53) + 10
        end
    end
    return offset
end

function notifications:fade(path, is_fading)
    if library.unloaded or not path or not path.Parent then return end
    local opacity = is_fading and 1 or 0
    library:tween(path, {BackgroundTransparency = opacity}, Enum.EasingStyle.Quad, 0.2)
    for _, instance in ipairs(path:GetDescendants()) do
        if instance:IsA("UIStroke") then
            library:tween(instance, {Transparency = opacity}, Enum.EasingStyle.Quad, 0.2)
        elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            library:tween(instance, {TextTransparency = opacity}, Enum.EasingStyle.Quad, 0.2)
        elseif instance:IsA("Frame") and instance.Name ~= "NotificationContent" then
            local desired = instance:GetAttribute("KaerynBaseTransparency")
            if desired == nil then
                desired = instance.BackgroundTransparency
                instance:SetAttribute("KaerynBaseTransparency", desired)
            end
            library:tween(instance, {BackgroundTransparency = is_fading and 1 or desired}, Enum.EasingStyle.Quad, 0.2)
        end
    end
end

local function update_content(record, options)
    local cfg = record.handle
    if options.name ~= nil then cfg.name = tostring(options.name) end
    if options.info ~= nil then cfg.info = tostring(options.info) end
    if options.type ~= nil then cfg.type = options.type end
    if options._replace_action then cfg.action = options.action end
    if options.dismissible ~= nil then cfg.dismissible = options.dismissible end
    cfg.lifetime = options.lifetime == nil and cfg.lifetime or options.lifetime
    record.remaining = cfg.lifetime
    record.items.title.Text = cfg.name
    record.items.info.Text = cfg.info
    record.items.bar.BackgroundColor3 = themes.preset[type_tokens[cfg.type]]
    library:track_theme(record.items.bar, "BackgroundColor3", record.items.bar.BackgroundColor3)
    record.items.action.Visible = cfg.action ~= nil
    if cfg.action then record.items.action.Text = cfg.action.label end
    record.items.close.Visible = cfg.dismissible
    record.items.bar.Visible = cfg.lifetime > 0
    record.items.bar.Size = dim2(1, 0, 0, 3)
    if start_timer then start_timer(record) end
end

local function remove_record(record, immediate)
    if record.closed then return end
    record.closed = true
    local index = table.find(notifications.records, record)
    if index then remove(notifications.records, index) end
    index = table.find(notifications.notifs, record.items.notification)
    if index then remove(notifications.notifs, index) end
    notifications:refresh_notifs()
    if immediate then
        if record.items.notification.Parent then record.items.notification:Destroy() end
        return
    end
    notifications:fade(record.items.notification, true)
    library:tween(record.items.notification, {AnchorPoint = vec2(1, 0)}, Enum.EasingStyle.Quad, 0.2)
    task.delay(0.25, function()
        if record.items.notification.Parent then record.items.notification:Destroy() end
    end)
end

function notifications:create_notification(options)
    assert(type(options) == "table", "notification options must be a table")
    assert(not library.unloaded and library.items, "cannot create a notification before opening a window or after unloading Kaeryn")
    local kind = options.type or "info"
    assert(type_tokens[kind], "notification type must be info, success, warning, or error")
    assert(options.dismissible == nil or type(options.dismissible) == "boolean", "dismissible must be a boolean")
    if options.action ~= nil then
        assert(type(options.action) == "table" and type(options.action.label) == "string" and options.action.label ~= "", "notification action needs a non-empty label")
        assert(type(options.action.callback) == "function", "notification action needs a callback")
    end
    local lifetime = options.lifetime or 3
    assert(type(lifetime) == "number" and lifetime == lifetime and lifetime >= 0 and lifetime < math.huge, "notification lifetime must be a finite non-negative number")
    local dedupe_key = options.dedupe_key
    if dedupe_key ~= nil then assert(type(dedupe_key) == "string" and dedupe_key ~= "", "dedupe_key must be a non-empty string") end

    if dedupe_key then
        for _, existing in ipairs(notifications.records) do
            if not existing.closed and existing.handle.dedupe_key == dedupe_key then
                existing.handle.type = kind
                update_content(existing, {name = options.name, info = options.info, type = kind, action = options.action,
                    _replace_action = true, lifetime = lifetime, dismissible = options.dismissible ~= false})
                return existing.handle
            end
        end
    end

    local max_visible = tonumber(notifications.max_visible)
    if not max_visible or max_visible ~= max_visible or max_visible == math.huge or max_visible == -math.huge then max_visible = 4 end
    max_visible = max(1, math.floor(max_visible))
    while #notifications.records >= max_visible do
        remove_record(notifications.records[1], true)
    end

    local cfg = {
        control_type = "notification",
        name = tostring(options.name or "Kaeryn"),
        info = tostring(options.info or ""),
        type = kind,
        lifetime = lifetime,
        action = options.action,
        dedupe_key = dedupe_key,
        dismissible = options.dismissible ~= false,
    }
    local items = {}
    local record = {handle = cfg, items = items, remaining = lifetime, paused = false, closed = false}
    cfg.Close = function() remove_record(record) end

    items.notification = library:create("Frame", {
        Parent = library.items;
        Size = dim2(0, 230, 0, 0);
        Name = "Notification";
        AutomaticSize = Enum.AutomaticSize.Y;
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.background;
        AnchorPoint = vec2(1, 0);
        Position = dim_offset(20, notifications:refresh_notifs());
    })
    library:create("UICorner", {Parent = items.notification; CornerRadius = dim(0, 5)})
    library:create("UIStroke", {Color = themes.preset.border; Parent = items.notification; ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    items.content = library:create("Frame", {
        Parent = items.notification;
        Name = "NotificationContent";
        Position = dim2(0, 9, 0, 7);
        Size = dim2(1, -18, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    library:create("UIListLayout", {Parent = items.content; Padding = dim(0, 4); SortOrder = Enum.SortOrder.LayoutOrder})
    items.header = library:create("Frame", {
        Parent = items.content;
        Name = "TitleRow";
        LayoutOrder = 1;
        Size = dim2(1, 0, 0, 20);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.title = library:create("TextLabel", {
        Parent = items.header;
        Name = "Title";
        Size = dim2(1, -24, 1, 0);
        Text = cfg.name;
        FontFace = fonts.font;
        TextSize = 14;
        TextColor3 = themes.preset.text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextTruncate = Enum.TextTruncate.AtEnd;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.close = library:create("TextButton", {
        Parent = items.header;
        Name = "Close";
        AnchorPoint = vec2(1, 0);
        Position = dim2(1, 0, 0, 0);
        Size = dim2(0, 20, 1, 0);
        Text = "×";
        FontFace = fonts.small;
        TextSize = 16;
        TextColor3 = themes.preset.muted;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        AutoButtonColor = false;
        Visible = cfg.dismissible;
    })
    items.info = library:create("TextLabel", {
        Parent = items.content;
        Name = "Info";
        LayoutOrder = 2;
        Size = dim2(1, 0, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        Text = cfg.info;
        FontFace = fonts.small;
        TextSize = 13;
        TextColor3 = themes.preset.muted;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    })
    items.action = library:create("TextButton", {
        Parent = items.content;
        Name = "Action";
        LayoutOrder = 3;
        Size = dim2(1, 0, 0, 24);
        Text = cfg.action and cfg.action.label or "";
        FontFace = fonts.small;
        TextSize = 12;
        TextColor3 = themes.preset.text_soft;
        BackgroundColor3 = themes.preset.surface_alt;
        BorderSizePixel = 0;
        AutoButtonColor = false;
        Visible = cfg.action ~= nil;
    })
    library:create("UICorner", {Parent = items.action; CornerRadius = dim(0, 4)})
    items.bar = library:create("Frame", {
        Parent = items.content;
        Name = "Lifetime";
        LayoutOrder = 4;
        Size = dim2(1, 0, 0, 3);
        BackgroundColor3 = themes.preset[type_tokens[kind]];
        BorderSizePixel = 0;
        Visible = lifetime > 0;
    })
    library:create("UICorner", {Parent = items.bar; CornerRadius = dim(0, 999)})
    library:create("UIPadding", {
        Parent = items.notification;
        PaddingBottom = dim(0, 7);
    })

    insert(notifications.records, record)
    insert(notifications.notifs, items.notification)
    notifications:fade(items.notification, false)
    library:tween(items.notification, {AnchorPoint = vec2(0, 0)}, Enum.EasingStyle.Quad, 0.2)
    notifications:refresh_notifs()

    local hovered, focused = false, false
    local function update_pause() record.paused = hovered or focused end
    items.notification.MouseEnter:Connect(function() hovered = true; update_pause() end)
    items.notification.MouseLeave:Connect(function() hovered = false; update_pause() end)
    for _, button in ipairs({items.action, items.close}) do
        button.SelectionGained:Connect(function() focused = true; update_pause() end)
        button.SelectionLost:Connect(function() focused = false; update_pause() end)
    end
    items.close.Activated:Connect(function() cfg:Close() end)
    items.action.Activated:Connect(function()
        if record.closed or not cfg.action then return end
        library:dispatch_control_callback(cfg, cfg.action.callback, {source = "user", phase = "commit"})
        if cfg.action.close ~= false then cfg:Close() end
    end)

    start_timer = function(target)
        target.timer_generation = (target.timer_generation or 0) + 1
        local generation = target.timer_generation
        if target.handle.lifetime <= 0 then return end
        task.spawn(function()
        local previous = os.clock()
        while not target.closed and target.timer_generation == generation and target.items.notification.Parent do
            task.wait(0.05)
            local now = os.clock()
            if not target.paused then target.remaining = max(0, target.remaining - (now - previous)) end
            previous = now
            target.items.bar.Size = dim2(target.remaining / target.handle.lifetime, 0, 0, 3)
            if target.remaining <= 0 then break end
        end
        if not target.closed and target.timer_generation == generation and target.remaining <= 0 then target.handle:Close() end
        end)
    end
    start_timer(record)
    return cfg
end

function library:notify(options)
    return notifications:create_notification(options)
end
end
