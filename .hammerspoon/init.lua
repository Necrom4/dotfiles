-- Command-line interface (`hs`): loads the IPC module so the `hs` terminal
-- tool can talk to this running Hammerspoon instance. Useful for scripting
-- Hammerspoon from the shell, quick REPL-style debugging (`hs -c "..."`),
-- and tooling such as generating Spoon docs.json via hs.doc.builder.
require("hs.ipc")

-- Alerts
local function alertStyle(color)
	return {
		fillColor = hs.drawing.color.asRGB({ alpha = 0.75 }),
		strokeColor = color,
		radius = 10,
	}
end

local styleOk = alertStyle(hs.drawing.color.asRGB({ red = 0.9, green = 0.75, blue = 0.0, alpha = 0.75 }))
local styleErr = alertStyle(hs.drawing.color.asRGB({ red = 0.9, green = 0.2, blue = 0.2, alpha = 0.75 }))

-- Auto-reload config
local function reloadConfig(files)
	local doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

local watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
watcher:start()
hs.alert.show("Config reloaded", styleOk)

-- Load modules
local modules = {
	"wifi",
}

for _, name in ipairs(modules) do
	local ok, err = pcall(require, "modules." .. name)
	if not ok then
		hs.alert("Error in [" .. name .. "]", styleErr)
		print("Error loading module: " .. name .. "\n" .. err)
	end
end

-- Load spoons
hs.loadSpoon("GridTile")

hs.hotkey.bind({ "ctrl", "shift" }, "w", function()
	spoon.GridTile:start()
end)

hs.loadSpoon("ClipboardHistory")
spoon.ClipboardHistory:bindHotkeys({
	show = { { "cmd", "shift" }, "v" },
	clear = { { "cmd", "shift", "alt" }, "v" },
})
spoon.ClipboardHistory:start()
