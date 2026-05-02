--------------------------------------------------------------------------
-- Clipboard History Manager
--
-- Hotkeys:
--   ⌘⇧V          – open clipboard history
--   ⌘⇧⌥V         – clear all history
--
-- Inside the chooser:
--   ↵            – paste selected entry into the previous app
--   ⌘↵           – copy to clipboard without pasting
--   ⌘.           – pin / unpin selected entry
--   ⌘⌫           – delete selected entry
--
-- Filters: prefix the query with `:text`, `:url`, `:file`, `:image`, or
-- `:pinned` to narrow the list.
--------------------------------------------------------------------------

local M = {}

----------------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------------

local maxHistory    = 100
local maxTextLength = 1024 * 1024 -- 1 MB
local pollInterval  = 0.4
local imageDir      = os.getenv("HOME") .. "/.hammerspoon/clipboard_images"
local historyFile   = os.getenv("HOME") .. "/.hammerspoon/clipboard_history.json"

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
	if s:sub(1, 1) ~= "/" then
		return false
	end
	if s:find("\n") then
		return false
	end
	return hs.fs.attributes(s) ~= nil
end

-- Subsequence-based fuzzy match. Returns a score (higher is better) or nil
-- if the query characters don't all appear in haystack in order. Consecutive
-- matches and matches at word boundaries score higher.
local function fuzzyScore(haystack, needle)
	if needle == "" then
		return 0
	end
	haystack = haystack:lower()
	needle = needle:lower()
	local hi, ni = 1, 1
	local hLen, nLen = #haystack, #needle
	local score = 0
	local prevMatched = false
	while hi <= hLen and ni <= nLen do
		local hc = haystack:sub(hi, hi)
		local nc = needle:sub(ni, ni)
		if hc == nc then
			score = score + 1
			if prevMatched then
				score = score + 4
			end
			local prev = hi > 1 and haystack:sub(hi - 1, hi - 1) or " "
			if prev:match("[%s%p]") then
				score = score + 3
			end
			ni = ni + 1
			prevMatched = true
		else
			prevMatched = false
		end
		hi = hi + 1
	end
	if ni <= nLen then
		return nil
	end
	return score
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
	-- Write to a temp file then rename so a crash mid-write can't corrupt
	-- the history file.
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

local function classifyText(text)
	if looksLikeURL(text) then
		return "url"
	end
	if looksLikeFilePath(text) then
		return "file"
	end
	return "text"
end

local function captureImage(source)
	local img = hs.pasteboard.readImage()
	if not img then
		return nil
	end
	local size = img:size()
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
		-- Approximate image equality without hashing the pixels.
		return a.bytes == b.bytes and a.width == b.width and a.height == b.height
	end
	return a.text == b.text
end

local function addEntry(entry)
	if not entry then
		return false
	end

	-- A duplicate keeps the older entry's pinned flag and image file so a
	-- re-copy doesn't silently unpin or leave an orphan PNG on disk.
	for i, item in ipairs(M.history) do
		if entryEquals(item, entry) then
			entry.pinned = item.pinned or entry.pinned
			if entry.kind == "image" and item.path ~= entry.path then
				os.remove(entry.path)
				entry.path = item.path
			end
			table.remove(M.history, i)
			break
		end
	end

	table.insert(M.history, 1, entry)

	-- Pinned entries are kept regardless of position; only non-pinned
	-- entries count toward maxHistory.
	local kept = {}
	local nonPinned = 0
	for _, item in ipairs(M.history) do
		if item.pinned then
			table.insert(kept, item)
		else
			nonPinned = nonPinned + 1
			if nonPinned <= maxHistory then
				table.insert(kept, item)
			elseif item.kind == "image" and item.path then
				os.remove(item.path)
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

	-- Many apps publish both image and text representations of the same
	-- copy. Prefer text when both exist so e.g. selecting code in a browser
	-- isn't stored as a screenshot.
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

local function restoreEntry(entry)
	if entry.kind == "image" then
		local img = hs.image.imageFromPath(entry.path)
		if img then
			hs.pasteboard.writeObjects(img)
		end
	else
		hs.pasteboard.setContents(entry.text)
	end
	M.lastChangeCount = hs.pasteboard.changeCount()
end

----------------------------------------------------------------------------
-- Chooser
----------------------------------------------------------------------------

-- One of nil, "text", "url", "file", "image", "pinned".
local activeFilter = nil
local activeQuery = ""

local function entryMatchesFilter(entry)
	if not activeFilter then
		return true
	end
	if activeFilter == "pinned" then
		return entry.pinned == true
	end
	return entry.kind == activeFilter
end

-- Concatenated text used for searching: full content (or filename for
-- images), source app, formatted date and the type tag.
local function searchableText(entry)
	local parts = {}
	if entry.kind == "image" then
		table.insert(parts, entry.path:match("[^/]+$") or "")
	else
		table.insert(parts, entry.text or "")
	end
	if entry.source and entry.source.name then
		table.insert(parts, entry.source.name)
	end
	table.insert(parts, os.date("%Y-%m-%d %H:%M:%S", entry.time))
	table.insert(parts, entry.kind)
	return table.concat(parts, " ")
end

local function describeSize(entry)
	if entry.kind == "image" then
		return string.format("%d×%d · %s", entry.width, entry.height, humanBytes(entry.bytes))
	end
	return humanBytes(entry.bytes or #(entry.text or ""))
end

local function buildChoices()
	local matches = {}
	for i, entry in ipairs(M.history) do
		if entryMatchesFilter(entry) then
			local score = 0
			if activeQuery ~= "" then
				score = fuzzyScore(searchableText(entry), activeQuery)
			end
			if score then
				table.insert(matches, { entry = entry, index = i, score = score })
			end
		end
	end

	-- Stable sort by score when searching; otherwise preserve recency order.
	if activeQuery ~= "" then
		table.sort(matches, function(a, b)
			if a.score ~= b.score then
				return a.score > b.score
			end
			return a.index < b.index
		end)
	end

	local choices = {}
	for _, m in ipairs(matches) do
		local entry = m.entry
		local title
		if entry.kind == "image" then
			title = string.format("Image (%d×%d)", entry.width, entry.height)
		else
			title = shorten(entry.text, 120)
		end

		local parts = { entry.kind }
		if entry.pinned then
			table.insert(parts, "pinned")
		end
		if entry.source and entry.source.name then
			table.insert(parts, "from " .. entry.source.name)
		end
		table.insert(parts, os.date("%Y-%m-%d %H:%M:%S", entry.time))
		table.insert(parts, describeSize(entry))

		-- Image entries show their own thumbnail; everything else falls
		-- back to the source app's bundle icon.
		local rowImage
		if entry.kind == "image" then
			rowImage = hs.image.imageFromPath(entry.path)
		elseif entry.source and entry.source.bundleID then
			rowImage = getAppIcon(entry.source.bundleID)
		end

		-- The chooser's built-in matcher does case-insensitive substring
		-- containment on `text` (and `subText` if enabled). Our own fuzzy
		-- score has already filtered the rows, so we suffix the active
		-- query as zero-size text on `text` to guarantee the built-in
		-- matcher keeps every row we returned.
		local renderedText
		if activeQuery ~= "" then
			renderedText = hs.styledtext.new(title)
				.. hs.styledtext.new(" " .. activeQuery, { font = { size = 0.01 } })
		else
			renderedText = title
		end

		table.insert(choices, {
			text = renderedText,
			subText = table.concat(parts, " · "),
			image = rowImage,
			index = m.index,
		})
	end
	return choices
end

local function refreshChooser()
	M.chooser:choices(buildChoices())
end

local function pasteAfterDismiss()
	-- Wait until focus has returned to the previous app before pressing ⌘V.
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
	elseif action == "paste" then
		restoreEntry(entry)
		-- Most-recently-used: bump the chosen entry to the top.
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
	if not choice then
		return
	end
	local entry = M.history[choice.index]
	performAction(entry, "paste")
end)

M.chooser:rows(10)
M.chooser:width(45)
M.chooser:placeholderText("Search content, app, date… or :image / :url / :file / :pinned")

local validTags = {
	text = true, url = true, file = true, image = true, pinned = true,
}

M.chooser:queryChangedCallback(function(query)
	local newFilter = nil
	local rest = query

	-- Pull a leading ":tag " off the query if it matches a known filter.
	local tag, after = query:match("^:(%a+)%s*(.*)$")
	if tag and validTags[tag:lower()] then
		newFilter = tag:lower()
		rest = after or ""
	end

	rest = rest:gsub("^%s+", ""):gsub("%s+$", "")

	if newFilter ~= activeFilter or rest ~= activeQuery then
		activeFilter = newFilter
		activeQuery = rest
		refreshChooser()
	end
end)

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
	-- Capture anything copied since the last poll so it shows up immediately.
	checkPasteboard()
	activeFilter = nil
	activeQuery = ""
	refreshChooser()
	if #M.history == 0 then
		hs.alert.show("Clipboard history is empty")
		return
	end
	M.chooser:query("")
	M.chooser:show()
end)

hs.hotkey.bind({ "cmd", "shift", "alt" }, "v", function()
	for _, item in ipairs(M.history) do
		if item.kind == "image" and item.path then
			os.remove(item.path)
		end
	end
	M.history = {}
	saveHistory()
	hs.alert.show("Clipboard history cleared")
end)

-- A modal so these shortcuts only intercept keys while the chooser is open.
local pickerKeys = hs.hotkey.modal.new()

pickerKeys:bind({ "cmd" }, "return", nil, function()
	local row = M.chooser:selectedRow()
	local choice = buildChoices()[row]
	if choice then
		M.chooser:hide()
		performAction(M.history[choice.index], "copy")
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
		print(i, item.pinned and "[pinned]" or "        ", os.date("%H:%M:%S", item.time), src, desc)
	end
end

print(string.format("[clipboard] loaded; history=%d timer=%s",
	#M.history, tostring(M.pollTimer:running())))

return M
