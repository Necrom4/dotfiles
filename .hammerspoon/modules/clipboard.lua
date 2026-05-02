-------------------------------
-- Clipboard History Manager --
-------------------------------

local M = {}

local maxHistory = 50
local pollInterval = 0.5
local historyFile = os.getenv("HOME") .. "/.hammerspoon/clipboard_history.json"

-- Persistence ---------------------------------------------------------------

local function loadHistory()
	local f = io.open(historyFile, "r")
	if not f then
		return {}
	end
	local raw = f:read("*a")
	f:close()
	if not raw or raw == "" then
		return {}
	end
	local ok, decoded = pcall(hs.json.decode, raw)
	if ok and type(decoded) == "table" then
		return decoded
	end
	return {}
end

local function saveHistory()
	local ok, encoded = pcall(hs.json.encode, M.history)
	if not ok then
		return
	end
	local f = io.open(historyFile, "w")
	if not f then
		return
	end
	f:write(encoded)
	f:close()
end

M.history = loadHistory()
M.lastChangeCount = hs.pasteboard.changeCount()

-- Capture -------------------------------------------------------------------

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

	saveHistory()
end

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

-- Chooser -------------------------------------------------------------------

local function buildChoices()
	local choices = {}
	for i, item in ipairs(M.history) do
		local preview = item.text:gsub("^%s+", ""):gsub("%s+$", "")
		preview = preview:gsub("%s+", " ")
		if #preview > 100 then
			preview = preview:sub(1, 100) .. "…"
		end
		table.insert(choices, {
			text = preview,
			subText = os.date("%Y-%m-%d %H:%M:%S", item.time),
			index = i,
		})
	end
	return choices
end

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

	-- Move the entry to the top (MRU)
	table.remove(M.history, choice.index)
	table.insert(M.history, 1, item)
	saveHistory()

	hs.timer.doAfter(0.05, function()
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end)
end)

M.chooser:searchSubText(false)
M.chooser:rows(10)
M.chooser:width(40)

-- Hotkeys -------------------------------------------------------------------

hs.hotkey.bind({ "cmd", "shift" }, "v", function()
	M.chooser:choices(buildChoices())
	M.chooser:query("")
	if #M.history == 0 then
		hs.alert.show("Clipboard history is empty")
		return
	end
	M.chooser:show()
end)

hs.hotkey.bind({ "cmd", "shift", "alt" }, "v", function()
	M.history = {}
	saveHistory()
	hs.alert.show("Clipboard history cleared")
end)

return M
