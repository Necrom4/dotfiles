--------------------------------------------------------------------------
-- Clipboard History Manager (Raycast-style)
--
-- Features:
--   • Tracks text, URLs, file paths, and images
--   • Records source app (name + bundle ID + icon) for each entry
--   • Pin entries (kept at top, never auto-evicted)
--   • Type filters: prefix the query with `:text`, `:url`, `:image`,
--     `:file`, `:pinned` to filter the list
--   • MRU ordering: selecting an entry bumps it to the top
--   • Image thumbnails shown inline in the chooser
--   • Persistent across reloads (~/.hammerspoon/clipboard_history.json)
--
-- Hotkeys:
--   ⌘⇧V          – open clipboard history
--   ⌘⇧⌥V         – clear all history
--
-- Inside the chooser:
--   ↵            – paste selected entry into the previous app
--   ⌘↵           – copy to clipboard without pasting
--   ⌥↵           – paste as plain text (strips formatting)
--   ⌘.           – pin / unpin selected entry
--   ⌘⌫           – delete selected entry
--------------------------------------------------------------------------

local M = {}

----------------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------------

local maxHistory       = 100
local maxTextLength    = 1024 * 1024 -- 1 MB; ignore absurd text payloads
local pollInterval     = 0.4
local imageDir         = os.getenv("HOME") .. "/.hammerspoon/clipboard_images"
local historyFile      = os.getenv("HOME") .. "/.hammerspoon/clipboard_history.json"
local thumbSize        = 48 -- chooser row image size

-- Make sure the image cache directory exists
hs.fs.mkdir(imageDir)

----------------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------------

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function flatten(s)
	return (s:gsub("%s+", " "))
end

local function shorten(s, n)
	s = flatten(trim(s))
	if #s > n then
		return s:sub(1, n) .. "…"
	end
	return s
end

local function humanBytes(n)
	if n < 1024 then
		return string.format("%d B", n)
	elseif n < 1024 * 1024 then
		return string.format("%.1f KB", n / 1024)
	else
		return string.format("%.1f MB", n / 1024 / 1024)
	end
end

local function looksLikeURL(s)
	return s:match("^https?://[%w%-_%.]+") ~= nil
		or s:match("^ftp://[%w%-_%.]+") ~= nil
		or s:match("^file://") ~= nil
end

local function looksLikeFilePath(s)
	-- Rough heuristic: starts with / and points at something that exists
	if s:sub(1, 1) ~= "/" then
		return false
	end
	if s:find("\n") then
		return false
	end
	return hs.fs.attributes(s) ~= nil
end

----------------------------------------------------------------------------
-- Persistence
----------------------------------------------------------------------------

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
	-- Atomic write
	local tmp = historyFile .. ".tmp"
	local f = io.open(tmp, "w")
	if not f then
		return
	end
	f:write(encoded)
	f:close()
	os.rename(tmp, historyFile)
end

----------------------------------------------------------------------------
-- Source-app metadata + icon cache
----------------------------------------------------------------------------

local iconCache = {}

local function getAppIcon(bundleID)
	if not bundleID then
		return nil
	end
	if iconCache[bundleID] ~= nil then
		return iconCache[bundleID] or nil
	end
	local img = hs.image.imageFromAppBundle(bundleID)
	iconCache[bundleID] = img or false
	return img
end

local function getFrontmostInfo()
	local app = hs.application.frontmostApplication()
	if not app then
		return nil
	end
	return {
		name = app:name(),
		bundleID = app:bundleID(),
	}
end

----------------------------------------------------------------------------
-- Capture
----------------------------------------------------------------------------

local typeIcon = {
	text  = "📝",
	url   = "🔗",
	file  = "📁",
	image = "🖼️ ",
}

local function classifyText(text)
	if looksLikeURL(text) then
		return "url"
	end
	if looksLikeFilePath(text) then
		return "file"
	end
	return "text"
end

-- Try to grab an image from the pasteboard, save it to disk, return entry.
local function captureImage(source)
	local img = hs.pasteboard.readImage()
	if not img then
		return nil
	end
	local size = img:size()
	-- Use timestamp + a short hash to name the file
	local filename = string.format("%s/clip-%d-%d.png", imageDir, os.time(), math.random(100000, 999999))
	local ok = img:saveToFile(filename, "png")
	if not ok then
		return nil
	end
	local attrs = hs.fs.attributes(filename) or {}
	return {
		kind = "image",
		path = filename,
		width = math.floor(size.w),
		height = math.floor(size.h),
		bytes = attrs.size or 0,
		time = os.time(),
		source = source,
	}
end

local function captureText(source)
	local text = hs.pasteboard.getContents()
	if type(text) ~= "string" or text == "" then
		return nil
	end
	if #text > maxTextLength then
		return nil
	end
	return {
		kind = classifyText(text),
		text = text,
		bytes = #text,
		time = os.time(),
		source = source,
	}
end

local function entryEquals(a, b)
	if a.kind ~= b.kind then
		return false
	end
	if a.kind == "image" then
		-- Same byte count + dimensions == probably the same image
		return a.bytes == b.bytes and a.width == b.width and a.height == b.height
	end
	return a.text == b.text
end

local function addEntry(entry)
	if not entry then
		return false
	end

	-- Find and remove duplicate (but keep its `pinned` flag)
	for i, item in ipairs(M.history) do
		if entryEquals(item, entry) then
			entry.pinned = item.pinned or entry.pinned
			-- If we're keeping the older image, no need to keep the new file
			if entry.kind == "image" and item.path ~= entry.path then
				os.remove(entry.path)
				entry.path = item.path
			end
			table.remove(M.history, i)
			break
		end
	end

	table.insert(M.history, 1, entry)

	-- Trim non-pinned entries beyond limit
	local kept = {}
	local nonPinned = 0
	for _, item in ipairs(M.history) do
		if item.pinned then
			table.insert(kept, item)
		else
			nonPinned = nonPinned + 1
			if nonPinned <= maxHistory then
				table.insert(kept, item)
			else
				-- evicted
				if item.kind == "image" and item.path then
					os.remove(item.path)
				end
			end
		end
	end
	M.history = kept

	saveHistory()
	return true
end

----------------------------------------------------------------------------
-- Polling
----------------------------------------------------------------------------

M.history = loadHistory()
M.lastChangeCount = hs.pasteboard.changeCount()

local function checkPasteboard()
	local cc = hs.pasteboard.changeCount()
	if cc == M.lastChangeCount then
		return
	end
	M.lastChangeCount = cc

	local source = getFrontmostInfo()
	local types = hs.pasteboard.typesAvailable()

	-- Prefer image when available and there's no plain text the user actually
	-- copied (lots of apps put both image + text representations on the
	-- pasteboard; if both are present, store the text and skip the image so
	-- code copies don't suddenly turn into pictures).
	if types.image and not types.string then
		local entry = captureImage(source)
		if entry then
			addEntry(entry)
			return
		end
	end

	if types.string or types.styledText then
		local entry = captureText(source)
		if entry then
			addEntry(entry)
			return
		end
	end

	-- Pure image case (no string at all)
	if types.image then
		local entry = captureImage(source)
		if entry then
			addEntry(entry)
		end
	end
end

M.pollTimer = hs.timer.new(pollInterval, checkPasteboard)
M.pollTimer:start()

----------------------------------------------------------------------------
-- Restore an entry to the system pasteboard
----------------------------------------------------------------------------

local function restoreEntry(entry, asPlainText)
	if entry.kind == "image" then
		local img = hs.image.imageFromPath(entry.path)
		if img then
			hs.pasteboard.writeObjects(img)
		end
	else
		-- For URL/file/text — always set as a plain string. Raycast's
		-- "paste as plain text" vs "paste with formatting" only matters when
		-- you have rich-text data; we don't preserve styled text in history.
		if asPlainText or true then
			hs.pasteboard.setContents(entry.text)
		end
	end
	M.lastChangeCount = hs.pasteboard.changeCount()
end

----------------------------------------------------------------------------
-- Chooser
----------------------------------------------------------------------------

local activeFilter = nil -- nil | "text" | "url" | "file" | "image" | "pinned"

local function entryMatchesFilter(entry)
	if not activeFilter then
		return true
	end
	if activeFilter == "pinned" then
		return entry.pinned == true
	end
	return entry.kind == activeFilter
end

local function describeSize(entry)
	if entry.kind == "image" then
		return string.format("%d×%d · %s", entry.width, entry.height, humanBytes(entry.bytes))
	end
	return humanBytes(entry.bytes or #(entry.text or ""))
end

local function buildChoices()
	local choices = {}
	for i, entry in ipairs(M.history) do
		if entryMatchesFilter(entry) then
			local title
			if entry.kind == "image" then
				title = string.format("%s Image (%d×%d)", typeIcon.image, entry.width, entry.height)
			else
				local emoji = typeIcon[entry.kind] or typeIcon.text
				title = emoji .. " " .. shorten(entry.text, 120)
			end

			if entry.pinned then
				title = "📌 " .. title
			end

			-- subText: source app · time · size
			local parts = {}
			if entry.source and entry.source.name then
				table.insert(parts, "from " .. entry.source.name)
			end
			table.insert(parts, os.date("%Y-%m-%d %H:%M:%S", entry.time))
			table.insert(parts, describeSize(entry))

			-- Pick the row image: image thumbnail, app icon, or generic icon
			local rowImage
			if entry.kind == "image" then
				rowImage = hs.image.imageFromPath(entry.path)
			elseif entry.source and entry.source.bundleID then
				rowImage = getAppIcon(entry.source.bundleID)
			end

			table.insert(choices, {
				text = title,
				subText = table.concat(parts, " · "),
				image = rowImage,
				index = i,
			})
		end
	end
	return choices
end

local function refreshChooser()
	M.chooser:choices(buildChoices())
end

local function pasteAfterDismiss()
	-- Small delay so the chooser is fully gone and focus is back on prev app
	hs.timer.doAfter(0.08, function()
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end)
end

local function performAction(entry, action)
	if not entry then
		return
	end

	if action == "copy" then
		restoreEntry(entry)
	elseif action == "paste" or action == "paste-plain" then
		restoreEntry(entry, action == "paste-plain")
		-- Move to top (MRU)
		for i, item in ipairs(M.history) do
			if item == entry then
				table.remove(M.history, i)
				table.insert(M.history, 1, entry)
				break
			end
		end
		saveHistory()
		pasteAfterDismiss()
	elseif action == "togglePin" then
		entry.pinned = not entry.pinned
		saveHistory()
		hs.alert.show(entry.pinned and "Pinned" or "Unpinned")
	elseif action == "delete" then
		for i, item in ipairs(M.history) do
			if item == entry then
				if item.kind == "image" and item.path then
					os.remove(item.path)
				end
				table.remove(M.history, i)
				break
			end
		end
		saveHistory()
	end
end

M.chooser = hs.chooser.new(function(choice)
	-- Default action when user presses ↵: paste with active app
	if not choice then
		return
	end
	local entry = M.history[choice.index]
	performAction(entry, "paste")
end)

M.chooser:searchSubText(true)
M.chooser:rows(10)
M.chooser:width(45)
M.chooser:placeholderText("Search clipboard… (try :image, :url, :file, :pinned)")

-- Type-filter via query prefix
M.chooser:queryChangedCallback(function(query)
	local prefix = query:match("^:(%a+)")
	local newFilter = nil
	if prefix then
		prefix = prefix:lower()
		if prefix == "text" or prefix == "url" or prefix == "file"
				or prefix == "image" or prefix == "pinned" then
			newFilter = prefix
		end
	end
	if newFilter ~= activeFilter then
		activeFilter = newFilter
		refreshChooser()
	end
end)

-- Right-click → context menu
M.chooser:rightClickCallback(function(row)
	if row == 0 then
		return
	end
	local choiceList = buildChoices()
	local choice = choiceList[row]
	if not choice then
		return
	end
	local entry = M.history[choice.index]
	if not entry then
		return
	end

	local menu = hs.menubar.new(false)
	local items = {
		{ title = "Paste", fn = function()
			M.chooser:hide()
			performAction(entry, "paste")
		end },
		{ title = "Copy to Clipboard", fn = function()
			M.chooser:hide()
			performAction(entry, "copy")
		end },
		{ title = "-" },
		{ title = entry.pinned and "Unpin" or "Pin", fn = function()
			performAction(entry, "togglePin")
			refreshChooser()
		end },
		{ title = "Delete", fn = function()
			performAction(entry, "delete")
			refreshChooser()
		end },
	}
	if entry.kind == "image" then
		table.insert(items, { title = "-" })
		table.insert(items, { title = "Reveal in Finder", fn = function()
			hs.execute(string.format("open -R %q", entry.path))
		end })
	elseif entry.kind == "url" then
		table.insert(items, { title = "-" })
		table.insert(items, { title = "Open URL", fn = function()
			hs.urlevent.openURL(entry.text)
		end })
	end
	menu:setMenu(items)
	menu:popupMenu(hs.mouse.absolutePosition(), true)
end)

----------------------------------------------------------------------------
-- Hotkeys
----------------------------------------------------------------------------

hs.hotkey.bind({ "cmd", "shift" }, "v", function()
	-- Catch any pending change before showing
	checkPasteboard()
	activeFilter = nil
	refreshChooser()
	if #M.history == 0 then
		hs.alert.show("Clipboard history is empty")
		return
	end
	M.chooser:query("")
	M.chooser:show()
end)

hs.hotkey.bind({ "cmd", "shift", "alt" }, "v", function()
	-- Wipe history and stored images
	for _, item in ipairs(M.history) do
		if item.kind == "image" and item.path then
			os.remove(item.path)
		end
	end
	M.history = {}
	saveHistory()
	hs.alert.show("Clipboard history cleared")
end)

-- In-chooser bindings via a modal triggered while chooser is visible.
-- We use hs.hotkey.modal so the keys only intercept while the picker is open.
local pickerKeys = hs.hotkey.modal.new()

pickerKeys:bind({ "cmd" }, "return", nil, function()
	local row = M.chooser:selectedRow()
	local choice = buildChoices()[row]
	if choice then
		M.chooser:hide()
		performAction(M.history[choice.index], "copy")
	end
end)

pickerKeys:bind({ "alt" }, "return", nil, function()
	local row = M.chooser:selectedRow()
	local choice = buildChoices()[row]
	if choice then
		M.chooser:hide()
		performAction(M.history[choice.index], "paste-plain")
	end
end)

pickerKeys:bind({ "cmd" }, ".", nil, function()
	local row = M.chooser:selectedRow()
	local choice = buildChoices()[row]
	if choice then
		performAction(M.history[choice.index], "togglePin")
		refreshChooser()
	end
end)

pickerKeys:bind({ "cmd" }, "delete", nil, function()
	local row = M.chooser:selectedRow()
	local choice = buildChoices()[row]
	if choice then
		performAction(M.history[choice.index], "delete")
		refreshChooser()
	end
end)

M.chooser:showCallback(function() pickerKeys:enter() end)
M.chooser:hideCallback(function() pickerKeys:exit() end)

----------------------------------------------------------------------------
-- Diagnostics
----------------------------------------------------------------------------

function M.debug()
	print("--- clipboard module ---")
	print("history entries:", #M.history)
	print("lastChangeCount:", M.lastChangeCount)
	print("pasteboard changeCount:", hs.pasteboard.changeCount())
	print("pollTimer running:", M.pollTimer and M.pollTimer:running())
	print("active filter:", activeFilter or "(none)")
	for i, item in ipairs(M.history) do
		local desc = item.kind == "image"
			and string.format("[image %dx%d]", item.width or 0, item.height or 0)
			or string.format("[%s] %s", item.kind, (item.text or ""):sub(1, 60))
		local src = item.source and item.source.name or "?"
		print(i, item.pinned and "📌" or "  ", os.date("%H:%M:%S", item.time), src, desc)
	end
end

print(string.format("[clipboard] loaded; history=%d timer=%s",
	#M.history, tostring(M.pollTimer:running())))

return M
