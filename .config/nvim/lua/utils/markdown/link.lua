local M = {}

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_url(s)
	return s:match("^%a[%w+.-]*://%S+$") ~= nil or s:match("^mailto:%S+$") ~= nil or s:match("^www%.%S+$") ~= nil
end

local function read_reg(name)
	local ok, value = pcall(vim.fn.getreg, name)
	return ok and trim(value:gsub("\n", " ")) or ""
end

-- Replace the range (0-based, end-exclusive) with `[text](url)`
local function wrap(range, url)
	local lines = vim.api.nvim_buf_get_text(0, range[1], range[2], range[3], range[4], {})
	local text = table.concat(lines, " ")
	vim.api.nvim_buf_set_text(0, range[1], range[2], range[3], range[4], { ("[%s](%s)"):format(text, url) })
	-- leave the cursor on the closing paren
	vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] + #text + #url + 3 })
end

-- Selection (or word under cursor, in normal mode) as a 0-based end-exclusive range
local function get_range()
	local mode = vim.fn.mode()
	if not mode:match("^[vV\22]") then
		vim.cmd("normal! viw")
		mode = "v"
	end
	local regions = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
	vim.cmd("normal! \27")
	if #regions == 0 then
		return nil
	end
	local first, last = regions[1][1], regions[#regions][2]
	local last_line = vim.api.nvim_buf_get_lines(0, last[2] - 1, last[2], false)[1] or ""
	local last_char = vim.fn.strcharpart(last_line:sub(last[3]), 0, 1)
	local end_col = math.min(last[3] - 1 + math.max(#last_char, 1), #last_line)
	local first_line = vim.api.nvim_buf_get_lines(0, first[2] - 1, first[2], false)[1] or ""
	-- linewise: skip indentation so the link doesn't swallow it
	local start_col = first[3] - 1
	if mode == "V" then
		start_col = #first_line:match("^%s*")
		end_col = #last_line
	end
	return { first[2] - 1, start_col, last[2] - 1, end_col }
end

local function pick_register(range)
	local items, seen = {}, {}
	local names = { '"', "+", "*", "0" }
	for c in ("123456789abcdefghijklmnopqrstuvwxyz"):gmatch(".") do
		names[#names + 1] = c
	end
	for _, name in ipairs(names) do
		local value = read_reg(name)
		if value ~= "" and not seen[value] then
			seen[value] = true
			items[#items + 1] = { name = name, value = value, url = is_url(value) }
		end
	end
	-- URLs first, keeping register order otherwise
	table.sort(items, function(a, b)
		if a.url ~= b.url then
			return a.url
		end
		return false
	end)
	if #items == 0 then
		return vim.notify("All registers are empty", vim.log.levels.WARN)
	end
	vim.ui.select(items, {
		prompt = "Link target from register",
		format_item = function(item)
			local v = #item.value > 80 and item.value:sub(1, 77) .. "..." or item.value
			return ('"%s  %s'):format(item.name, v)
		end,
	}, function(choice)
		if choice then
			wrap(range, choice.value)
		end
	end)
end

--- Turn the selection (or word under cursor) into `[text](url)`.
---
--- Source of the url, in order:
---   * the register given as a prefix (`"a`), if any
---   * the system clipboard (`+`), if it contains a URL
---   * a picker over all non-empty registers
---@param opts? { pick?: boolean } pick = always show the register picker
function M.link(opts)
	opts = opts or {}
	-- must be read before get_range(): `normal!` resets v:register
	local explicit = vim.v.register ~= '"' and vim.v.register or nil
	local range = get_range()
	if not range then
		return
	end
	if opts.pick then
		return pick_register(range)
	end
	local url = read_reg(explicit or "+")
	if explicit and url ~= "" then
		return wrap(range, url)
	end
	if is_url(url) then
		return wrap(range, url)
	end
	pick_register(range)
end

return M
