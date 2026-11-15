-- One owner for checkbox mutation. Do not follow daily links or rewrite other files.
local M = {}
local cycle = { [" "] = "/", ["/"] = "x", x = " ", X = " ", ["-"] = " " }

-- Include ordinary list items in the tree so they cannot accidentally become
-- siblings/children of an unrelated task. Ignore YAML and fenced examples.
function M.parse(lines)
	local nodes, rows, stack = {}, {}, {}
	local fence, fence_length, frontmatter
	for row, line in ipairs(lines) do
		local run, rest = line:match("^%s*([`~]+)(.*)$")
		if row == 1 and line == "---" then
			frontmatter = true
		elseif frontmatter then
			if line == "---" or line == "..." then
				frontmatter = false
			end
		elseif fence then
			if run and run:sub(1, 1) == fence and #run >= fence_length and rest:match("^%s*$") then
				fence = nil
			end
		elseif run and #run >= 3 and (run:match("^`+$") or run:match("^~+$")) then
			fence, fence_length, stack = run:sub(1, 1), #run, {}
		else
			local indent, prefix, text = line:match("^([ \t]*)([-+*]%s+)(.*)$")
			if not indent then
				indent, prefix, text = line:match("^([ \t]*)(%d+[.)]%s+)(.*)$")
			end
			if indent then
				local width = vim.fn.strdisplaywidth(indent)
				while #stack > 0 and stack[#stack].indent >= width do
					table.remove(stack)
				end
				local marker = text:match("^%[(.)%]%s") or text:match("^%[(.)%]$")
				local node = {
					row = row,
					indent = width,
					marker = marker,
					col = #indent + #prefix + 1,
					parent = stack[#stack],
					children = {},
				}
				if node.parent then
					table.insert(node.parent.children, node)
				end
				table.insert(nodes, node)
				rows[row] = node
				table.insert(stack, node)
			elseif line:match("%S") then
				local leading = line:match("^([ \t]*)")
				local width = vim.fn.strdisplaywidth(leading)
				while #stack > 0 and width <= stack[#stack].indent do
					table.remove(stack)
				end
			end
		end
	end
	return nodes, rows
end

local function set_marker(lines, node, marker)
	if node.marker == marker then
		return
	end
	local line = lines[node.row]
	lines[node.row] = line:sub(1, node.col) .. marker .. line:sub(node.col + 2)
	node.marker = marker
end

local function set_descendants(lines, node, marker)
	for _, child in ipairs(node.children) do
		-- Cancellation is intentional: neither bulk completion nor reopening
		-- should resurrect cancelled work or modify custom statuses like [?].
		if child.marker ~= "-" then
			if cycle[child.marker] then
				set_marker(lines, child, marker)
			end
			set_descendants(lines, child, marker)
		end
	end
end

local function update_parent(lines, node)
	if not cycle[node.marker] or node.marker == "-" then
		return
	end
	local total, resolved, started = 0, 0, false
	for _, child in ipairs(node.children) do
		if child.marker then
			total = total + 1
			if child.marker == "x" or child.marker == "X" or child.marker == "-" then
				resolved = resolved + 1
			elseif child.marker == "/" then
				started = true
			end
		end
	end
	if total > 0 then
		set_marker(lines, node, resolved == total and "x" or ((resolved > 0 or started) and "/" or " "))
	end
end

-- Pure transformation, also used by the headless regression tests.
function M.transform(lines, row)
	local _, rows = M.parse(lines)
	local node = rows[row]
	if not node or not cycle[node.marker] then
		return lines
	end
	local marker = cycle[node.marker]
	set_marker(lines, node, marker)
	-- Starting a parent does not claim all its children are actively started.
	if marker == "x" or marker == " " then
		set_descendants(lines, node, marker)
	end
	local parent = node.parent
	while parent do
		update_parent(lines, parent)
		parent = parent.parent
	end
	return lines
end

function M.cycle()
	if not vim.bo.modifiable or vim.bo.readonly then
		return
	end
	local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local after = M.transform(vim.deepcopy(before), vim.api.nvim_win_get_cursor(0)[1])
	local first, last
	for row, line in ipairs(after) do
		if line ~= before[row] then
			first, last = first or row, row
		end
	end
	if first then
		-- A single buffer edit gives one undo step and leaves the cursor in place.
		vim.api.nvim_buf_set_lines(0, first - 1, last, false, vim.list_slice(after, first, last))
	end
end

return M
