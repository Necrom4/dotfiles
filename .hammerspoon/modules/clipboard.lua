-------------------------------
-- Clipboard History Manager --
-------------------------------

local clipboardHistory = {}
local maxHistory = 5
local lastContent = nil

-- Watch for clipboard changes
local clipboardWatcher = hs.pasteboard.watcher.new(function(content)
	if content == nil or content == lastContent then
		return
	end
	if type(content) ~= "string" then
		return
	end

	lastContent = content

	-- Remove duplicate if already in history
	for i, item in ipairs(clipboardHistory) do
		if item.text == content then
			table.remove(clipboardHistory, i)
			break
		end
	end

	-- Prepend to history
	table.insert(clipboardHistory, 1, {
		text = content,
		time = os.time(),
	})

	-- Trim to max size
	while #clipboardHistory > maxHistory do
		table.remove(clipboardHistory)
	end
end)

clipboardWatcher:start()

-- Build chooser rows from history
local function buildChoices()
	local choices = {}
	for i, item in ipairs(clipboardHistory) do
		local preview = item.text:gsub("^%s+", ""):gsub("%s+$", "") -- trim
		preview = preview:gsub("\n", " ") -- flatten newlines
		local subText = os.date("%H:%M:%S", item.time)
		table.insert(choices, {
			text = preview:sub(1, 80) .. (preview:len() > 80 and "…" or ""),
			subText = subText,
			index = i,
		})
	end
	return choices
end

-- The chooser popup
local chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	local item = clipboardHistory[choice.index]
	if not item then
		return
	end

	-- Put selected item on clipboard and paste it
	hs.pasteboard.setContents(item.text)
	lastContent = item.text -- avoid re-adding to history

	-- Small delay so the clipboard is ready, then paste
	hs.timer.doAfter(0.05, function()
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end)
end)

chooser:searchSubText(false)
chooser:rows(10)
chooser:width(50)

-- Bind hotkey
hs.hotkey.bind({ "cmd", "shift" }, "v", function()
	chooser:choices(buildChoices())
	chooser:show()
end)
