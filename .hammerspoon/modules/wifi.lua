local M = {}

local AUTOCONNECT_WINDOW = 8 -- seconds after wake to consider it "automatic"

local lastSSID = hs.wifi.currentNetwork()
local justWoke = false
local wakeTimer = nil

-- Mark wake events so we can detect the auto-connect window
local sleepWatcher = hs.caffeinate.watcher.new(function(event)
	local E = hs.caffeinate.watcher
	if event == E.systemDidWake or event == E.screensDidWake then
		justWoke = true
		if wakeTimer then
			wakeTimer:stop()
		end
		wakeTimer = hs.timer.doAfter(AUTOCONNECT_WINDOW, function()
			justWoke = false
		end)
	elseif event == E.systemWillSleep or event == E.screensDidSleep then
		justWoke = false
		lastSSID = nil
		if wakeTimer then
			wakeTimer:stop()
		end
	end
end)

-- Watch for network changes
local wifiWatcher = hs.wifi.watcher.new(function()
	local current = hs.wifi.currentNetwork()

	local didConnect = current and current ~= lastSSID
	local wasAutoJoined = justWoke

	lastSSID = current

	if didConnect and wasAutoJoined then
		hs.notify.new({ title = "Hammerspoon", informativeText = "Auto-joined: " .. current }):send()
	end
end)

function M.start()
	sleepWatcher:start()
	wifiWatcher:start()
end

function M.stop()
	sleepWatcher:stop()
	wifiWatcher:stop()
end

M.start()
return M
