# Kaeryn

Kaeryn is a modular Luau UI library. Its source lives in `src/Kaeryn/` as `.luau` files, and the generated `dist/Kaeryn.luau` stays self-contained for simple loading.

## Build

Requires Node.js; the build uses only Node's built-in modules.

```sh
npm run build
npm test
```

## Use the single-file bundle

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xyraniz/Kaeryn/main/dist/Kaeryn.luau"))()
```

Give controls explicit, stable flags for saved configs. If omitted, named controls use a key derived from their type, section, and name. Unnamed controls need an explicit flag or name. Duplicate keys stop setup with a warning and an error so one control cannot silently take over another control's config setter.

```lua
section:toggle({name = "Enabled", flag = "aim.enabled"})
```

Configs are validated before any setter runs. Use `library:set_theme({accent = Color3.fromRGB(120, 160, 255), surface = Color3.fromRGB(20, 24, 32)})` to update palette tokens.

Older configs that use generated `flagnumberN` keys need their keys renamed to the new stable flags before loading.
