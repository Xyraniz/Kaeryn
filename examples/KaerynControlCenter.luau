local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xyraniz/Kaeryn/main/dist/Kaeryn.luau"))()

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

library:set_language("en")
library:register_locale("en", {
	["queue.item"] = {
		one = "{count} item in queue",
		other = "{count} items in queue",
	},
})
library:set_theme({
	accent = Color3.fromRGB(111, 145, 255),
	background = Color3.fromRGB(14, 16, 23),
	surface = Color3.fromRGB(21, 24, 34),
	surface_alt = Color3.fromRGB(28, 32, 44),
	surface_hover = Color3.fromRGB(39, 45, 60),
	border = Color3.fromRGB(42, 48, 65),
	text = Color3.fromRGB(245, 247, 255),
	text_soft = Color3.fromRGB(220, 226, 242),
	muted = Color3.fromRGB(148, 158, 182),
	text_muted = Color3.fromRGB(116, 128, 153),
	success = Color3.fromRGB(90, 205, 150),
	warning = Color3.fromRGB(244, 186, 91),
	error = Color3.fromRGB(240, 105, 119),
	text_scale = 1,
	density = 0.95,
	radius_scale = 1,
	motion_scale = 0.75,
})

local function announce(name, info, notification_type)
	library:notify({
		name = name,
		info = info,
		type = notification_type or "info",
	})
end

local function report_change(name, value, change)
	print("[Kaeryn]", name, value, change and change.source, change and change.phase)
end

library:register_control("status_badge", function(section, options, lib)
	local root = lib:create("Frame", {
		Parent = section.items.elements,
		Name = "ServiceStatus",
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Color3.fromRGB(28, 32, 44),
		BorderSizePixel = 0,
	})
	lib:apply_theme(root, "surface_alt", "BackgroundColor3")
	lib:create("UICorner", {Parent = root, CornerRadius = UDim.new(0, 6)})
	local label = lib:create("TextLabel", {
		Parent = root,
		Name = "Value",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(245, 247, 255),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	lib:apply_theme(label, "text", "TextColor3")

	local control = {
		id = options.id,
		flag = options.flag,
		name = options.name,
		value = options.default,
		items = {root = root},
	}

	local function render(value)
		label.Text = options.name .. ": " .. value
	end

	function control.set(value, context)
		if type(value) ~= "string" then return false, "status must be a string" end
		control.value = value
		lib.flags[control.flag] = value
		render(value)
		lib:dispatch_control_callback(control, nil, context, value)
		return true
	end

	render(control.value)
	lib.flags[control.flag] = control.value
	lib:register_config_flag(control.flag, function(value)
		control.set(value, {source = "config", phase = "commit"})
	end, function(value)
		if type(value) ~= "string" then return false, nil, "expected a string" end
		return true, value
	end, options.legacy_flags)

	return control
end, {
	fields = {
		default = {type = "string", default = "Online"},
	},
})

local window = library:window({
	name = "Kaeryn",
	size = UDim2.fromOffset(780, 590),
	min_size = Vector2.new(560, 420),
	max_size = Vector2.new(1180, 900),
	background = "rbxassetid://85347758476506",
	background_transparency = 0.48,
	toggle_button = {
		size = UDim2.fromOffset(46, 46),
		icon = "rbxassetid://77021539815611",
		draggable = true,
	},
})

local saved_layout
local saved_config
local uptime_label
local uptime_seconds = 0
local monitor_scope
local section_transparency_targets = {}
local section_transparency_selection = {"all"}
local section_transparency_value = 0.18
local section_transparency_picker

local function apply_section_transparency()
	local apply_all = table.find(section_transparency_selection, "all") ~= nil
	for id, section in pairs(section_transparency_targets) do
		if apply_all or table.find(section_transparency_selection, id) then
			section:SetBackgroundTransparency(section_transparency_value)
		end
	end
end

window:OnOpen(function()
	print("[Kaeryn] Window opened")
end)
window:OnClose(function()
	print("[Kaeryn] Window closed")
end)
window:OnDestroy(function()
	print("[Kaeryn] Panel resources released")
end)

local operation_overview, operation_controls, operation_inputs, operation_collections = window:tab({
	id = "operations",
	name = "Operations",
	icon = "lucide:layout-dashboard",
	on_enter = function()
		print("[Kaeryn] Operations section active")
	end,
	on_leave = function()
		library:set_keybind_context("global")
	end,
	tabs = {
		{
			id = "overview",
			name = "Overview",
			icon = "lucide:activity",
			on_enter = function(page)
				local scope = page:CreateScope()
				local elapsed = 0
				scope:Connect(RunService.Heartbeat, function(delta_time)
					elapsed += delta_time
					if elapsed >= 1 then
						uptime_seconds += math.floor(elapsed)
						elapsed %= 1
						if uptime_label then
							uptime_label.items.name.Text = "Uptime: " .. tostring(uptime_seconds) .. " s"
						end
					end
				end)
			end,
		},
		{id = "controls", name = "Controls", icon = "lucide:sliders-horizontal"},
		{id = "inputs", name = "Inputs", icon = "lucide:list", on_enter = function()
			library:set_keybind_context("inputs")
		end, on_leave = function()
			library:set_keybind_context("global")
		end},
		{id = "collections", name = "Collections", icon = "lucide:layers"},
		{
			id = "deferred",
			name = "Resources",
			icon = "lucide:box",
			lazy = function(page)
				local column = page:column({})
				local section = column:section({name = "On-demand loading", default = true, size = 1})
				section_transparency_targets.resources = section
				apply_section_transparency()
				section:label({
					id = "resources.lazy_note",
					name = "This page is built when opened",
					info = "Enter and leave callbacks also appear in the console.",
				})
				section:button({
					id = "resources.lazy_notice",
					name = "Show notification",
					callback = function()
						announce("Resources", "The lazy page is responding.", "success")
					end,
				})
			end,
		},
	},
})

local records_nodes = window:tab({
	id = "records",
	name = "Records",
	icon = "lucide:database",
	tabs = {{id = "nodes", name = "Nodes", icon = "lucide:server"}},
})

local system_utilities = window:tab({
	id = "system",
	name = "System",
	icon = "lucide:settings",
	tabs = {{id = "utilities", name = "Tools", icon = "lucide:wrench"}},
})

local overview_left = operation_overview:column({})
local overview_right = operation_overview:column({})
local session_section = overview_left:section({name = "Session", default = true, size = 1, icon = "lucide:activity"})
uptime_label = session_section:label({id = "session.uptime", name = "Uptime: 0 s"})

local connected = session_section:toggle({
	id = "session.connected",
	name = "Connection active",
	info = "State control with callbacks, flags, and persistence.",
	default = true,
	callback = function(value, change)
		report_change("Connection active", value, change)
	end,
})
	local connection_settings = connected:settings({})
	connection_settings:label({
		id = "session.connection_options",
		name = "Connection options",
		info = "Controls grouped in the toggle settings popup.",
	})
	connection_settings:toggle({
		id = "session.auto_reconnect",
		name = "Automatic reconnect",
		default = true,
	})
	connection_settings:slider({
		id = "session.retry_limit",
		name = "Maximum retries",
		min = 1,
		max = 10,
		default = 4,
	})
connected:OnChanged(function(value, change)
	print("[Kaeryn] Connection OnChanged", value, change.source)
end)

local compact_mode = session_section:toggle({
	id = "session.compact",
	name = "Compact mode",
	type = "checkbox",
	default = false,
})

local overview_section = overview_right:section({name = "Quick access", default = true, size = 1, icon = "lucide:monitor"})
overview_section:label({id = "session.shortcuts", name = "Available shortcuts", info = "Try opening search, changing the state, or showing a notification."})
overview_section:button({
	id = "session.notify",
	name = "Show notification",
	callback = function()
		library:notify({
			name = "Kaeryn",
			info = "The notification and its action are active.",
			type = "success",
			dedupe_key = "control-center-ready",
			action = {label = "Confirm", callback = function() print("[Kaeryn] Notification action") end},
		})
	end,
})
overview_section:button({
	id = "session.search",
	name = "Open search",
	callback = function()
		window.search.open()
	end,
})
overview_section:button({
	id = "session.flip_connection",
	name = "Toggle connection",
	callback = function()
		connected:Set(not connected:Get())
	end,
})

local controls_left = operation_controls:column({})
local controls_right = operation_controls:column({})
local range_section = controls_left:section({name = "Ranges", default = true, size = 1, icon = "lucide:sliders-horizontal", background_transparency = 0.18})
local power = range_section:slider({
	id = "render.power",
	name = "Intensity",
	info = "Live updates while dragging, followed by a commit on release.",
	min = 0,
	max = 100,
	interval = 1,
	default = 68,
	suffix = "%",
	callback = function(value, change)
		report_change("Intensity", value, change)
	end,
	on_commit = function(value, change)
		print("[Kaeryn] Slider committed", value, change.source)
	end,
})
power:OnChanged(function(value, change)
	print("[Kaeryn] Slider OnChanged", value, change.phase)
end)
power:OnCommitted(function(value, change)
	print("[Kaeryn] Slider OnCommitted", value, change.id)
end)

local sensitivity = range_section:slider({
	id = "render.sensitivity",
	name = "Sensitivity",
	min = 1,
	max = 20,
	interval = 0.5,
	default = 7.5,
	suffix = "x",
})

local range_visible = true
local range_enabled = true
range_section:button({
	id = "render.adjust_range",
	name = "Expand range",
	callback = function()
		power:SetRange(0, 150, 5)
		power:Set(75)
		power:SetDescription("Expanded from code; each step is 5%.")
	end,
})
range_section:button({
	id = "render.toggle_visibility",
	name = "Show or hide sensitivity",
	callback = function()
		range_visible = not range_visible
		sensitivity:SetVisible(range_visible)
	end,
})
range_section:button({
	id = "render.toggle_enabled",
	name = "Enable or disable sensitivity",
	callback = function()
		range_enabled = not range_enabled
		sensitivity:SetEnabled(range_enabled)
	end,
})

local modes_section = controls_right:section({name = "Modes and color", default = true, size = 1, icon = "lucide:circle-check", background_transparency = 0.18})
local render_mode = modes_section:segmented({
	id = "render.mode",
	name = "Image quality",
	items = {
		{value = "economy", label = "Power saver"},
		{value = "balanced", label = "Balanced"},
		{value = "detail", label = "Detail"},
	},
	default = "balanced",
	callback = function(value, change)
		report_change("Quality", value, change)
	end,
})
local scale = modes_section:stepper({
	id = "render.ui_scale",
	name = "Interface scale",
	min = 75,
	max = 150,
	step = 5,
	default = 100,
	suffix = "%",
	on_commit = function(value)
		library:set_theme({text_scale = value / 100})
	end,
})
local accent_picker = modes_section:colorpicker({
	id = "render.accent",
	name = "Accent color",
	info = "Change the accent and try the picker transparency.",
	color = Color3.fromRGB(111, 145, 255),
	alpha = 0.85,
	callback = function(value, change)
		library:update_theme("accent", value)
		report_change("Accent color", value, change)
	end,
	on_commit = function(value)
		print("[Kaeryn] Color committed", value)
	end,
})
modes_section:button({
	id = "render.reset_scale",
	name = "Reset scale and color",
	callback = function()
		scale:Set(100)
		accent_picker:Set(Color3.fromRGB(111, 145, 255))
		library:set_theme({text_scale = 1})
	end,
})

local inputs_left = operation_inputs:column({})
local inputs_right = operation_inputs:column({})
local dropdown_section = inputs_left:section({name = "Selection", default = true, size = 1, icon = "lucide:list"})
local region = dropdown_section:dropdown({
	id = "account.region",
	name = "Service region",
	searchable = true,
	items = {
		{value = "north", label = "North", group = "Americas"},
		{value = "south", label = "South", group = "Americas"},
		{value = "europe", label = "Europe", group = "Europe"},
		{value = "asia", label = "Asia Pacific", group = "Asia"},
		{value = "reserved", label = "Reserved", group = "System", disabled = true},
	},
	default = "north",
	callback = function(value, change)
		report_change("Region", value, change)
	end,
})

local modules = dropdown_section:dropdown({
	id = "account.modules",
	name = "Active modules",
	multi = true,
	searchable = true,
	items = {
		{value = "audit", label = "Auditing", group = "Operations"},
		{value = "alerts", label = "Alerts", group = "Operations"},
		{value = "reports", label = "Reports", group = "Analytics"},
		{value = "history", label = "History", group = "Analytics"},
		{value = "access", label = "Access", group = "Security"},
		{value = "sessions", label = "Sessions", group = "Security"},
		{value = "billing", label = "Billing", group = "Administration"},
		{value = "inventory", label = "Inventory", group = "Administration"},
		{value = "exports", label = "Exports", group = "Administration"},
	},
	default = {"audit", "alerts"},
	callback = function(value, change)
		report_change("Modules", table.concat(value, ", "), change)
	end,
})

local account_section = inputs_right:section({name = "Account and shortcuts", default = true, size = 1, icon = "lucide:settings"})
local operator_name = account_section:textbox({
	id = "account.operator",
	name = "Operator name",
	placeholder = "user_01",
	default = "operator_kaeryn",
	min_length = 3,
	max_length = 24,
	required = true,
	validate = function(value)
		local valid = value:match("^[%w_]+$") ~= nil
		return valid, "Use letters, numbers, and underscores."
	end,
	callback = function(value, change)
		report_change("Operator", value, change)
	end,
})
library:register_flag_migration("legacy.account.operator", "account.operator")

local keybind = account_section:keybind({
	id = "account.quick_action",
	name = "Action hotkey",
	key = Enum.KeyCode.F6,
	mode = "Toggle",
	context = "inputs",
	callback = function(active, change)
		print("[Kaeryn] Hotkey", active, change.source, change.phase)
	end,
})

local category_list = account_section:list({
	id = "account.category",
	name = "Active category",
	options = {"Operations", "Analytics", "Security", "Administration"},
	default = "Operations",
	callback = function(value, change)
		report_change("Category", value, change)
	end,
})

local inputs_buttons = inputs_right:section({name = "Input actions", default = true, size = 0.55, icon = "lucide:wrench"})
inputs_buttons:button({
	id = "account.rebind",
	name = "Capture a new hotkey",
	callback = function()
		local ok, reason = keybind:Rebind()
		if ok then announce("Hotkey", "Press a key to assign it.")
		else announce("Hotkey", tostring(reason), "warning") end
	end,
})
inputs_buttons:button({
	id = "account.reset_key",
	name = "Reset hotkey",
	callback = function()
		keybind:Reset()
	end,
})
inputs_buttons:button({
	id = "account.refresh_options",
	name = "Change region options",
	callback = function()
		region:SetOptions({
			{value = "north", label = "North", group = "Americas"},
			{value = "south", label = "South", group = "Americas"},
			{value = "europe", label = "Europe", group = "Europe"},
		})
	end,
})
inputs_buttons:button({
	id = "account.refresh_list",
	name = "Change category options",
	callback = function()
		category_list:SetOptions({"Operations", "Analytics", "Security", "Support"})
	end,
})
inputs_buttons:button({
	id = "account.show_migration",
	name = "Preview legacy flag",
	callback = function()
		local legacy_json = HttpService:JSONEncode({["legacy.account.operator"] = "new_operator"})
		local ok, result = library:preview_config(legacy_json)
		if ok then
			announce("Migration", tostring(#result.migrations) .. " legacy flag(s) recognized.", "success")
			for _, migration in ipairs(result.migrations) do print(migration.from, "->", migration.to) end
		else
			announce("Migration", tostring(result), "error")
		end
	end,
})

local collections_left = operation_collections:column({})
local collections_right = operation_collections:column({})
local rule_section = collections_left:section({name = "Rules", default = true, size = 1, icon = "lucide:list-check"})
local rules = rule_section:group({
	id = "rules.targets",
	name = "Monitored targets",
	min_items = 1,
	max_items = 5,
	callback = function(action, key, keys, change)
		print("[Kaeryn] Group", action, key, table.concat(keys, ", "), change.source)
	end,
})
local primary_rule = rules:Add("primary", "Primary")
primary_rule:toggle({id = "enabled", name = "Monitoring", default = true})
primary_rule:slider({id = "threshold", name = "Threshold", min = 0, max = 100, default = 60, suffix = "%"})
local backup_rule = rules:Add("backup", "Backup")
backup_rule:toggle({id = "enabled", name = "Monitoring", default = false})
backup_rule:slider({id = "threshold", name = "Threshold", min = 0, max = 100, default = 35, suffix = "%"})

local rule_actions = collections_left:section({name = "Manage rules", default = true, size = 0.48, icon = "lucide:wrench"})
rule_actions:button({
	id = "rules.add",
	name = "Add target",
	callback = function()
		local row, reason = rules:Add("support", "Support")
		if row then
			row:toggle({id = "enabled", name = "Monitoring", default = true})
			row:slider({id = "threshold", name = "Threshold", min = 0, max = 100, default = 50, suffix = "%"})
		else
			announce("Rules", tostring(reason), "warning")
		end
	end,
})
rule_actions:button({
	id = "rules.move",
	name = "Move backup to the top",
	callback = function()
		local ok, reason = rules:Move("backup", 1)
		if not ok then announce("Rules", tostring(reason), "warning") end
	end,
})
rule_actions:button({
	id = "rules.remove",
	name = "Remove support target",
	callback = function()
		local ok, reason = rules:Remove("support")
		if not ok then announce("Rules", tostring(reason), "warning") end
	end,
})

local custom_section = collections_right:section({name = "Custom control", default = true, size = 1, icon = "lucide:box"})
local service_state = custom_section:custom_control("status_badge", {
	id = "system.service_state",
	flag = "system.service_state",
	name = "Service",
	default = "Online",
})
service_state:OnChanged(function(value, change)
	report_change("Service", value, change)
end)
custom_section:button({
	id = "system.cycle_service",
	name = "Toggle service status",
	callback = function()
		service_state:Set(service_state:Get() == "Online" and "Paused" or "Online")
	end,
})
custom_section:label({id = "system.custom_help", name = "The custom status is included in configuration too."})

local records_left = records_nodes:column({})
local records_right = records_nodes:column({})
local table_section = records_left:section({name = "Nodes", default = true, size = 1, icon = "lucide:database", background_transparency = 0.18})
local initial_rows = {
	{id = "node-west", zone = "West", status = "Operational", latency = 34},
	{id = "node-east", zone = "East", status = "Operational", latency = 48},
	{id = "node-eu", zone = "Europe", status = "Under review", latency = 72},
	{id = "node-apac", zone = "Asia Pacific", status = "Operational", latency = 96},
}
local nodes = table_section:data_table({
	id = "records.nodes",
	name = "Node status",
	info = "Select a row or click a header to sort.",
	columns = {
		{key = "zone", label = "Zone", width = 0.28},
		{key = "status", label = "Status", width = 0.32},
		{key = "latency", label = "ms", width = 0.16},
		{key = "id", label = "ID", width = 0.16},
	},
	rows = initial_rows,
	default = "node-west",
	max_height = 300,
	row_height = 32,
	sortable = true,
	callback = function(id, row, change)
		print("[Kaeryn] Selected node", id, row and row.zone, change.source)
	end,
})

local record_actions = records_right:section({name = "Update records", default = true, size = 1, icon = "lucide:wrench", background_transparency = 0.18})
record_actions:label({id = "records.selected", name = "Select a row to see its callback."})
record_actions:button({
	id = "records.update",
	name = "Update West latency",
	callback = function()
		local ok, reason = nodes:UpdateRow("node-west", {latency = 27, status = "Operational"})
		if not ok then announce("Nodes", tostring(reason), "warning") end
	end,
})
record_actions:button({
	id = "records.sort",
	name = "Sort by latency",
	callback = function()
		nodes:Sort("latency", true)
	end,
})
record_actions:button({
	id = "records.remove",
	name = "Remove selected row",
	callback = function()
		local selected_id = nodes:Get()
		if selected_id then
			local ok, reason = nodes:RemoveRow(selected_id)
			if not ok then announce("Nodes", tostring(reason), "warning") end
		end
	end,
})
record_actions:button({
	id = "records.restore",
	name = "Restore records",
	callback = function()
		nodes:SetRows(initial_rows)
		nodes:Sort("latency", true)
	end,
})

local system_left = system_utilities:column({})
local system_right = system_utilities:column({})
local actions_section = system_right:section({name = "Window and dialogs", default = true, size = 1, icon = "lucide:bell"})
local appearance_section = system_left:section({name = "Appearance", default = true, size = 1, icon = "lucide:settings", background_transparency = 0.18})
section_transparency_targets = {
	session = session_section,
	quick_access = overview_section,
	ranges = range_section,
	modes = modes_section,
	selection = dropdown_section,
	account = account_section,
	input_actions = inputs_buttons,
	rules = rule_section,
	manage_rules = rule_actions,
	custom_control = custom_section,
	nodes = table_section,
	update_records = record_actions,
	appearance = appearance_section,
	window_actions = actions_section,
}
section_transparency_picker = appearance_section:dropdown({
	id = "appearance.section_transparency_targets",
	name = "Sections to adjust",
	info = "Choose All sections or select specific sections.",
	multi = true,
	items = {
		{value = "all", label = "All sections"},
		{value = "session", label = "Session"},
		{value = "quick_access", label = "Quick access"},
		{value = "ranges", label = "Ranges"},
		{value = "modes", label = "Modes and color"},
		{value = "selection", label = "Selection"},
		{value = "account", label = "Account and shortcuts"},
		{value = "input_actions", label = "Input actions"},
		{value = "rules", label = "Rules"},
		{value = "manage_rules", label = "Manage rules"},
		{value = "custom_control", label = "Custom control"},
		{value = "nodes", label = "Nodes"},
		{value = "update_records", label = "Update records"},
		{value = "appearance", label = "Appearance"},
		{value = "window_actions", label = "Window and dialogs"},
		{value = "resources", label = "On-demand loading"},
		{value = "config_list", label = "Config list"},
		{value = "config_settings", label = "Config settings"},
	},
	default = {"all"},
	callback = function(value)
		local all_selected = table.find(value, "all") ~= nil
		local all_was_selected = table.find(section_transparency_selection, "all") ~= nil
		if all_selected and #value > 1 then
			local normalized = {}
			if all_was_selected then
				for _, id in ipairs(value) do
					if id ~= "all" then table.insert(normalized, id) end
				end
			else
				normalized = {"all"}
			end
			section_transparency_picker:Set(normalized)
			return
		end
		section_transparency_selection = table.clone(value)
		apply_section_transparency()
	end,
})
appearance_section:slider({
	id = "appearance.section_transparency",
	name = "Section transparency",
	info = "Adjust the selected section cards.",
	min = 0,
	max = 100,
	interval = 1,
	default = 18,
	suffix = "%",
	callback = function(value)
		section_transparency_value = value / 100
		apply_section_transparency()
	end,
})
local background_amount = appearance_section:slider({
	id = "appearance.background_transparency",
	name = "Background transparency",
	min = 0,
	max = 100,
	default = 48,
	suffix = "%",
	callback = function(value)
		window:SetBackgroundImageTransparency(value / 100)
	end,
})
appearance_section:button({
	id = "appearance.restore_background",
	name = "Reset background",
	callback = function()
		window:SetBackgroundImage("rbxassetid://85347758476506")
		background_amount:Set(48)
	end,
})
appearance_section:button({
	id = "appearance.clear_background",
	name = "Clear background",
	callback = function()
		window:SetBackgroundImage(nil)
	end,
})
appearance_section:button({
	id = "appearance.show_icon",
	name = "Resolve Lucide icon",
	callback = function()
		local icon = library:resolve_icon("search")
		print("[Kaeryn] Resolved search icon", icon)
		announce("Icons", "The search icon resolved to " .. icon, "success")
	end,
})
appearance_section:button({
	id = "appearance.show_locale_report",
	name = "Check Spanish locale coverage",
	callback = function()
		local complete, report = library:validate_locale("es")
		announce("Translations", tostring(#report.missing) .. " missing; " .. tostring(#report.invalid) .. " invalid.", complete and "success" or "warning")
		print("[Kaeryn] Locale report", report)
	end,
})

actions_section:button({
	id = "system.confirm",
	name = "Open confirmation",
	callback = function()
		library:confirm({
			title = "Apply changes",
			message = "Do you want to confirm this action?",
			confirm_text = "Apply",
			on_confirm = function(accepted)
				if accepted then announce("Changes", "Confirmation received.", "success") end
			end,
		})
	end,
})
actions_section:button({
	id = "system.prompt",
	name = "Open text prompt",
	callback = function()
		library:prompt({
			title = "Operations note",
			message = "Enter text to send a notification.",
			placeholder = "Note",
			confirm_text = "Send",
			on_confirm = function(value)
				if value then announce("Note received", value, "success") end
			end,
		})
	end,
})
actions_section:button({
	id = "system.alert",
	name = "Open alert",
	callback = function()
		library:alert({title = "Operations Center", message = "The alert dialog is working."})
	end,
})
actions_section:button({
	id = "system.save_layout",
	name = "Save window layout",
	callback = function()
		saved_layout = window:SaveLayout()
		announce("Window", "Window position, size, and selected page saved in memory.", "success")
	end,
})
actions_section:button({
	id = "system.restore_layout",
	name = "Restore window layout",
	callback = function()
		if not saved_layout then announce("Window", "Save a layout first.", "warning"); return end
		local ok, reason = window:LoadLayout(saved_layout)
		if not ok then announce("Window", tostring(reason), "error") end
	end,
})
actions_section:button({
	id = "system.preview_config",
	name = "Save current state in memory",
	callback = function()
		saved_config = library:get_config()
		local ok, preview = library:preview_config(saved_config)
		if ok then announce("Configuration", tostring(#preview.changes) .. " change(s) after reloading.", "success")
		else announce("Configuration", tostring(preview), "error") end
	end,
})
actions_section:button({
	id = "system.load_config",
	name = "Reload saved state",
	callback = function()
		if not saved_config then announce("Configuration", "Save the state first.", "warning"); return end
		local ok, result = library:load_config(saved_config)
		if ok then announce("Configuration", "State reloaded.", "success")
		else announce("Configuration", tostring(result), "error") end
	end,
})
actions_section:button({
	id = "system.plural",
	name = "Test plural translation",
	callback = function()
		local message = library:translate("queue.item", 4)
		announce("Translation", message)
	end,
})
actions_section:button({
	id = "system.search_results",
	name = "Count matching controls",
	callback = function()
		local results = library:search_controls("region")
		announce("Search", tostring(#results) .. " result(s).")
	end,
})
actions_section:button({
	id = "system.scope_start",
	name = "Start scoped monitor",
	callback = function()
		if monitor_scope then monitor_scope:Destroy() end
		monitor_scope = library:scope()
		local elapsed, ticks = 0, 0
		monitor_scope:Connect(RunService.Heartbeat, function(delta_time)
			elapsed += delta_time
			if elapsed >= 1 then
				ticks += 1
				elapsed %= 1
				print("[Kaeryn] Monitor active", ticks)
			end
		end)
		announce("Scope", "Monitor started. It is cleaned up when stopped or when the panel closes.", "success")
	end,
})
actions_section:button({
	id = "system.scope_stop",
	name = "Stop scoped monitor",
	callback = function()
		if monitor_scope then monitor_scope:Destroy(); monitor_scope = nil end
		announce("Scope", "Connection released.")
	end,
})
actions_section:button({
	id = "system.close",
	name = "Close panel",
	callback = function()
		window:Close()
	end,
})
actions_section:button({
	id = "system.destroy",
	name = "Destroy panel",
	callback = function()
		window:Destroy()
	end,
})

window:separator({name = "Persistence"})
local config_sections = library:init_config(window)
section_transparency_targets.config_list = config_sections.list
section_transparency_targets.config_settings = config_sections.settings
apply_section_transparency()

print("[Kaeryn] Control center started", window:IsOpen(), library.breakpoint)
