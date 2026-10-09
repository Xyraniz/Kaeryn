return function(__kaeryn)
    local vec2 = __kaeryn.vec2
    local dim2 = __kaeryn.dim2
    local dim = __kaeryn.dim
    local dim_offset = __kaeryn.dim_offset
    local rgb = __kaeryn.rgb
    local max = __kaeryn.max
    local insert = __kaeryn.insert
    local find = __kaeryn.find
    local remove = __kaeryn.remove
    local library = __kaeryn.library
    local themes = __kaeryn.themes
    local notifications = __kaeryn.notifications
    local fonts = __kaeryn.fonts

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
    library:tween(path, {BackgroundTransparency = opacity}, Enum.EasingStyle.Quad, 0.3)
    for _, instance in ipairs(path:GetDescendants()) do
        if instance:IsA("UIStroke") then
            library:tween(instance, {Transparency = opacity}, Enum.EasingStyle.Quad, 0.3)
        elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            library:tween(instance, {TextTransparency = opacity}, Enum.EasingStyle.Quad, 0.3)
        elseif instance:IsA("Frame") and instance.Name ~= "notification" then
            local desired = instance:GetAttribute("KaerynBaseTransparency")
            if desired == nil then
                desired = instance.BackgroundTransparency
                instance:SetAttribute("KaerynBaseTransparency", desired)
            end
            library:tween(instance, {BackgroundTransparency = is_fading and 1 or desired}, Enum.EasingStyle.Quad, 0.3)
        end
    end
end

function notifications:create_notification(options)
    local cfg = {
        name = options.name or "This is a title!";
        info = options.info or "This is extra info!";
        lifetime = options.lifetime or 3;
        items = {};
        outline;
    }

    local items = cfg.items; do
        items[ "notification" ] = library:create( "Frame" , {
            Parent = library[ "items" ];
            Size = dim2(0, 210, 0, 53);
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            AnchorPoint = vec2(1, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(14, 14, 16)
        });

        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "notification" ];
            Transparency = 1;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        items[ "title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "notification" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 7, 0, 6);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UICorner" , {
            Parent = items[ "notification" ];
            CornerRadius = dim(0, 3)
        });

        items[ "info" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(145, 145, 145);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.info;
            Parent = items[ "notification" ];
            Name = "\0";
            Position = dim2(0, 9, 0, 22);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 17);
            PaddingRight = dim(0, 8);
            Parent = items[ "info" ]
        });

        items[ "bar" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "notification" ];
            Name = "\0";
            Position = dim2(0, 8, 1, -6);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 0, 5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.accent
        });

        library:create( "UICorner" , {
            Parent = items[ "bar" ];
            CornerRadius = dim(0, 999)
        });

        library:create( "UIPadding" , {
            PaddingRight = dim(0, 8);
            Parent = items[ "notification" ]
        });
    end

    table.insert(notifications.notifs, items.notification)

    notifications:fade(items[ "notification" ], false)

    local offset = notifications:refresh_notifs()

    items[ "notification" ].Position = dim_offset(20, offset)

    library:tween(items[ "notification" ], {AnchorPoint = vec2(0, 0)}, Enum.EasingStyle.Quad, 1)
    library:tween(items[ "bar" ], {Size = dim2(1, -8, 0, 5)}, Enum.EasingStyle.Quad, cfg.lifetime)

    task.spawn(function()
        task.wait(cfg.lifetime)

        if library.unloaded or not items.notification.Parent then return end
        local index = table.find(notifications.notifs, items.notification)
        if index then table.remove(notifications.notifs, index) end
        notifications:refresh_notifs()
        notifications:fade(items[ "notification" ], true)

        library:tween(items[ "notification" ], {AnchorPoint = vec2(1, 0)}, Enum.EasingStyle.Quad, 1)

        task.wait(1)

        if items.notification.Parent then items.notification:Destroy() end
    end)
end
end
