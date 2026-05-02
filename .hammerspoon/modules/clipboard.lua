-------------------------------
-- Clipboard History Manager --
-------------------------------

local M = {}

local maxHistory = 5
local pollInterval = 0.5

M.history = {}
M.lastChangeCount = hs.pasteboard.changeCount()

local function addEntry(text)
	if type(text) ~= "string" or text == "" then
		return
	end

	-- Remove any existing duplicate
	for i, item in ipairs(M.history) do
		if item.text == text then
			table.remove(M.history, i)
			break
		end
	end

	table.insert(M.history, 1, {
		text = text,
		time = os.time(),
	})

	while #M.history > maxHistory do
		table.remove(M.history)
	end
end

-- The pasteboard watcher's callback in Hammerspoon does NOT receive the new
-- contents — you have to read them yourself. Use a polling timer based on
-- changeCount(), which is the most reliable approach across content types.
-- The timer is stored on the module table so it isn't garbage-collected.
M.pollTimer = hs.timer.new(pollInterval, function()
	local cc = hs.pasteboard.changeCount()
	if cc == M.lastChangeCount then
		return
	end
	M.lastChangeCount = cc

	local content = hs.pasteboard.getContents()
	if content and content ~= "" then
		addEntry(content)
	end
end)
M.pollTimer:start()

-- Build chooser rows from history
local function buildChoices()
	local choices = {}
	for i, item in ipairs(M.history) do
		local preview = item.text:gsub("^%s+", ""):gsub("%s+$", "")
		preview = preview:gsub("%s+", " ")
		if #preview > 80 then
			preview = preview:sub(1, 80) .. "…"
		end
		table.insert(choices, {
			text = preview,
			subText = os.date("%H:%M:%S", item.time),
			index = i,
		})
	end
	return choices
end

-- The chooser popup
M.chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	local item = M.history[choice.index]
	if not item then
		return
	end

	hs.pasteboard.setContents(item.text)
	M.lastChangeCount = hs.pasteboard.changeCount()

	hs.timer.doAfter(0.05, function()
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end)
end)

M.chooser:searchSubText(false)
M.chooser:rows(10)
M.chooser:width(50)

-- Bind hotkey
hs.hotkey.bind({ "cmd", "shift" }, "v", function()
	M.chooser:choices(buildChoices())
	M.chooser:show()
end)

return M
