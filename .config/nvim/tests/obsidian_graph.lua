-- Run: nvim --headless -u NONE -l tests/obsidian_graph.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local index = require("obsidian_graph.index")
local layout = require("obsidian_graph.layout")
local root = "/tmp/opencode/obsidian-graph-test-" .. tostring(vim.uv.hrtime())
vim.fn.mkdir(root .. "/folder", "p")
vim.fn.mkdir(root .. "/.hidden", "p")
local function write(path, lines)
	vim.fn.writefile(lines, root .. "/" .. path)
end
local function eq(actual, expected, message)
	assert(
		vim.deep_equal(actual, expected),
		(message or "Mismatch") .. ": " .. vim.inspect(actual) .. " != " .. vim.inspect(expected)
	)
end

local ok, err = xpcall(function()
	local links = index.parse({
		"[[One|alias]] [[Two#heading]] ![[Three]]",
		"```md",
		"[[Not a link]]",
		"```",
		"`[[Code]]` <!-- [[Comment]]",
		"[[Still comment]] --> [four](folder/Four%20Note.md#heading)",
		"[web](https://example.com)",
	})
	eq(#links, 5, "Ignore code/comments")
	eq(links[4].target, "folder/Four Note.md", "Decode Markdown targets")
	local function node(rel, targets, meta)
		local parsed = index.parse(targets or {})
		return { rel = rel, path = root .. "/" .. rel, label = rel, links = parsed, meta = meta or {} }
	end
	local a = node("A.md", { "[[B]] [[Bee]] [[unique-id]] [C](folder/C.md) [[B#x]] [[Missing]] ![[image.png]]" })
	local b = node("B.md", { "[[A]]" }, { aliases = { "Bee" }, id = "unique-id" })
	local c = node("folder/C.md", { "[A](../A.md)" })
	local graph = index.build(root, { a, b, c })
	eq(#graph.edges, 2, "Resolve aliases, IDs, relative links; deduplicate")
	eq(a.degree, 2)
	eq(#index.subgraph(graph, b, 1).nodes, 2)
	eq(#index.subgraph(graph, b, 2).nodes, 3)
	layout.seed(graph)
	for _ = 1, 20 do
		layout.step(graph, 1)
	end
	for _, n in ipairs(graph.nodes) do
		assert(n.x == n.x and n.y == n.y, "Finite layout")
	end
	-- Duplicate stems should resolve locally, never randomly across folders.
	local d = node("folder/B.md")
	local e = node("folder/E.md", { "[[B]]" })
	local duplicate = index.build(root, { b, d, e })
	assert(e.neighbors[d] and not e.neighbors[b], "Prefer source-local duplicate stem")
	write("A.md", { "[[B]]" })
	write("B.md", { "[[folder/C]]" })
	write("folder/C.md", { "# C" })
	write(".hidden/Secret.md", { "[[A]]" })
	write("file.txt", { "[[A]]" })
	local scanned
	index.scan(root, function(value)
		scanned = value
	end, function()
		return false
	end)
	assert(
		vim.wait(5000, function()
			return scanned ~= nil
		end),
		"Index completed"
	)
	eq(#scanned.nodes, 3, "Skip hidden and non-Markdown files")
	eq(#scanned.edges, 2)
	local buf = vim.fn.bufadd(root .. "/A.md")
	vim.fn.bufload(buf)
	vim.bo[buf].modified = false
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "[[folder/C]]" })
	local unsaved
	index.scan(root, function(value)
		unsaved = value
	end, function()
		return false
	end)
	assert(vim.wait(5000, function()
		return unsaved ~= nil
	end))
	assert(unsaved.by_path[root .. "/A.md"].neighbors[unsaved.by_path[root .. "/folder/C.md"]], "Include unsaved buffers")
	vim.api.nvim_set_current_buf(buf)
	local origin = vim.api.nvim_get_current_win()
	local ui = require("obsidian_graph")
	ui.setup()
	local s = ui.open({ root = root, local_view = true })
	assert(
		vim.wait(5000, function()
			return s.graph ~= nil and not s.loading
		end),
		"UI indexed"
	)
	assert(vim.api.nvim_win_is_valid(s.win), "Graph window exists")
	eq(#s.view.nodes, 2, "Local view contains current note and neighbor")
	local function press(key)
		local mapping = vim.fn.maparg(key, "n", false, true)
		assert(type(mapping.callback) == "function", "Mapped " .. key)
		mapping.callback()
	end
	press("+")
	press("h")
	press("f")
	press("b")
	press("<Tab>")
	press("g")
	eq(#s.view.nodes, 3, "Global toggle")
	press("r")
	press("g")
	assert(
		vim.wait(5000, function()
			return not s.loading
		end),
		"Toggle during refresh does not cancel indexing"
	)
	vim.api.nvim_win_set_config(s.win, { width = 12, height = 4 })
	press("f")
	press("+")
	press("-")
	vim.api.nvim_exec_autocmds("VimResized", {})
	assert(vim.api.nvim_win_get_width(s.win) > 12, "Resize handled")
	press("?")
	assert(vim.api.nvim_get_current_win() ~= s.win, "Help popup")
	press("q")
	eq(vim.api.nvim_get_current_win(), s.win, "Close help")
	press("p")
	press("q")
	local dest = s.selected.path
	press("<CR>")
	eq(vim.api.nvim_get_current_win(), origin, "Open in original window")
	eq(vim.api.nvim_buf_get_name(0), dest, "Selected note opened")
	assert(not vim.api.nvim_win_is_valid(s.win), "Graph closed")
	-- Closing during indexing must prevent stale scheduled work reopening anything.
	local cancelled = ui.open({ root = root })
	press("q")
	vim.wait(100)
	assert(not vim.api.nvim_win_is_valid(cancelled.win))
	local manually_closed = ui.open({ root = root })
	vim.api.nvim_win_close(manually_closed.win, true)
	local reopened = ui.open({ root = root })
	vim.wait(100)
	assert(not vim.api.nvim_buf_is_valid(manually_closed.buf), "Manual close cleans buffer")
	assert(#vim.api.nvim_get_autocmds({ group = reopened.group }) > 0, "Old cleanup cannot remove new view handlers")
	press("q")
	-- Empty vault and tiny terminal must also render safely.
	vim.fn.mkdir(root .. "/empty", "p")
	local empty = ui.open({ root = root .. "/empty" })
	assert(vim.wait(5000, function()
		return empty.graph ~= nil
	end))
	eq(#empty.view.nodes, 0)
	press("f")
	press("<Tab>")
	press("q")
	write("empty/Notes | 名字.md", { "# Unicode note" })
	local unicode = ui.open({ root = root .. "/empty" })
	assert(vim.wait(5000, function()
		return unicode.graph ~= nil
	end))
	press("<CR>")
	eq(
		vim.api.nvim_buf_get_name(0),
		root .. "/empty/Notes | 名字.md",
		"Open spaces, Unicode, and Ex metacharacters safely"
	)
end, debug.traceback)
vim.fn.delete(root, "rf")
if not ok then
	error(err)
end
print("Obsidian graph tests passed")
