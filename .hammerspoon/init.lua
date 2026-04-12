local function reloadConfig(files)
	local shouldReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			shouldReload = true
		end
	end
	if shouldReload then
		hs.reload()
	end
end

local watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
watcher:start()

hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
