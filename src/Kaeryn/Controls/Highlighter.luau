local keywords = {}
for _, keyword in ipairs({
    "and", "break", "continue", "do", "else", "elseif", "end", "export", "for", "function", "if", "in",
    "local", "not", "or", "repeat", "return", "then", "type", "until", "while",
}) do
    keywords[keyword] = true
end

local builtins = {}
for _, name in ipairs({
    "assert", "Axes", "BrickColor", "CFrame", "Color3", "Enum", "Instance", "ipairs", "math", "next", "pairs",
    "pcall", "print", "Random", "Ray", "RaycastParams", "Region3", "require", "select", "setmetatable", "shared",
    "string", "table", "task", "tonumber", "tostring", "type", "typeof", "UDim", "UDim2", "unpack", "utf8",
    "Vector2", "Vector3", "wait", "workspace", "xpcall",
}) do
    builtins[name] = true
end

local default_colors = {
    keyword = Color3.fromHex("#CBA6F7"),
    builtin = Color3.fromHex("#F38BA8"),
    literal = Color3.fromHex("#FAB387"),
    number = Color3.fromHex("#FAB387"),
    string = Color3.fromHex("#A6E3A1"),
    comment = Color3.fromHex("#9399B2"),
    operator = Color3.fromHex("#94E2D5"),
    call = Color3.fromHex("#89B4FA"),
    property = Color3.fromHex("#F9E2AF"),
    text = Color3.fromHex("#CDD6F4"),
}

local operators = {
    ["#"] = true, ["%"] = true, ["*"] = true, ["+"] = true, ["-"] = true, ["."] = true, ["/"] = true,
    ["<"] = true, ["="] = true, [">"] = true, ["^"] = true, ["~"] = true, [":"] = true,
}

local function long_bracket_end(source, start)
    local equals = source:sub(start):match("^%[(=*)%[")
    if equals == nil then return nil end
    local closing = "]" .. equals .. "]"
    local closing_start = source:find(closing, start + #equals + 2, true)
    return closing_start and closing_start + #closing or #source + 1
end

local function escape_markup(text)
    return text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
end

return function(source, custom_colors)
    local colors = table.clone(default_colors)
    for token, color in pairs(custom_colors or {}) do colors[token] = color end

    local output = {}
    local previous_significant
    local index = 1
    local length = #source

    local function emit(token, category)
        local color = colors[category or "text"]
        local value = escape_markup(token)
        if color then
            table.insert(output, '<font color="#' .. color:ToHex() .. '">' .. value .. "</font>")
        else
            table.insert(output, value)
        end
    end

    while index <= length do
        local first = source:sub(index, index)
        local token, category

        if source:sub(index, index + 1) == "--" then
            local long_end = long_bracket_end(source, index + 2)
            if long_end then
                token = source:sub(index, long_end - 1)
                index = long_end
            else
                local newline = source:find("\n", index, true)
                local last = newline and newline - 1 or length
                token = source:sub(index, last)
                index = last + 1
            end
            category = "comment"
        elseif first == "'" or first == '"' or first == "`" then
            local start = index
            local quote = first
            index += 1
            while index <= length do
                local char = source:sub(index, index)
                if char == "\\" then
                    index += 2
                elseif char == quote then
                    index += 1
                    break
                else
                    index += 1
                end
            end
            token = source:sub(start, index - 1)
            category = "string"
        elseif first == "[" and long_bracket_end(source, index) then
            local long_end = long_bracket_end(source, index)
            token = source:sub(index, long_end - 1)
            index = long_end
            category = "string"
        elseif first:match("%d") then
            local rest = source:sub(index)
            token = rest:match("^0[xX][%da-fA-F_]+")
                or rest:match("^%d[%d_]*%.%d[%d_]*[eE][%+%-]?[%d_]+")
                or rest:match("^%d[%d_]*[eE][%+%-]?[%d_]+")
                or rest:match("^%d[%d_]*%.%d[%d_]*")
                or rest:match("^%d[%d_]*")
            index += #token
            category = "number"
        elseif first:match("[_%a]") then
            token = source:sub(index):match("^[_%a][_%w]*")
            local after = source:sub(index + #token):match("^%s*%(") ~= nil
            if token == "true" or token == "false" or token == "nil" then
                category = "literal"
            elseif keywords[token] then
                category = "keyword"
            elseif builtins[token] then
                category = "builtin"
            elseif previous_significant == "." then
                category = "property"
            elseif after then
                category = "call"
            end
            index += #token
        elseif first:match("%s") then
            local start = index
            repeat index += 1 until index > length or not source:sub(index, index):match("%s")
            token = source:sub(start, index - 1)
        else
            local three = source:sub(index, index + 2)
            local two = source:sub(index, index + 1)
            if three == "..." then
                token = three
            elseif two == "==" or two == "~=" or two == "<=" or two == ">=" or two == ".." or two == "//" or two == "::" then
                token = two
            else
                token = first
            end
            index += #token
            if operators[first] or token == "..." or token == "==" or token == "~=" or token == "<=" or token == ">=" or token == ".." or token == "//" or token == "::" then
                category = "operator"
            end
        end

        emit(token, category)
        if token:find("\n", 1, true) then
            previous_significant = nil
        elseif not token:match("^%s+$") then
            previous_significant = token:sub(-1)
        end
    end

    return table.concat(output)
end
