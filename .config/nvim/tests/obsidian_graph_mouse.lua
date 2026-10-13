-- A real attached UI is needed for getmousepos(), borders and mouse dispatch.
local child = vim.fn.jobstart({ vim.v.progpath, "--embed", "--headless", "-u", "NONE" }, { rpc = true })
local function rpc(method, ...)
	return vim.rpcrequest(child, method, ...)
end
local root = "/tmp/opencode/graph-mouse-" .. vim.uv.hrtime()
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "[[B]]" }, root .. "/A.md")
vim.fn.writefile({ "# B" }, root .. "/B.md")
local ok, err = xpcall(function()
	rpc("nvim_ui_attach", 100, 35, { rgb = true })
	rpc(
		"nvim_exec_lua",
		[[
		local cwd, root = ...
		vim.opt.rtp:prepend(cwd)
		vim.o.mouse = "a"
		_G.graph = require("obsidian_graph").open({root=root})
	]],
		{ vim.fn.getcwd(), root }
	)
	assert(vim.wait(5000, function()
		return rpc("nvim_exec_lua", "return graph.view ~= nil", {})
	end))
	assert(
		vim.wait(2000, function()
			return rpc("nvim_exec_lua", "return math.abs(graph.camera.zoom - graph.zoom) < 0.001", {})
		end),
		"Initial camera settles"
	)
	-- Freeze layout, select a known nonselected node, then use actual screen coordinates.
	local hit = rpc(
		"nvim_exec_lua",
		[[
		graph.paused = true
		-- Disable the timer loop to model event-loop starvation under fast input.
		-- Drag events must advance physics themselves, without relying on it.
		graph.generation = graph.generation + 1
		vim.cmd("redraw")
		for _, hit in ipairs(graph.screen) do
			if hit.node ~= graph.selected then
				local pos = vim.fn.screenpos(graph.win, hit.y, 1)
				return {row=pos.row-1, col=pos.col+hit.x-2, path=hit.node.path}
			end
		end
	]],
		{}
	)
	assert(hit, "Nonselected visible node")
	rpc("nvim_input_mouse", "left", "press", "", 0, hit.row, hit.col)
	assert(
		vim.wait(1000, function()
			return rpc("nvim_exec_lua", "return graph.selected.path", {}) == hit.path
		end),
		"Real click selects node"
	)
	local original_x = rpc("nvim_exec_lua", "return graph.selected.x", {})
	local neighbor_x = rpc(
		"nvim_exec_lua",
		[[
		graph.paused = false
		for _, n in ipairs(graph.view.nodes) do
			if n ~= graph.selected then _G.neighbor = n; return n.x end
		end
	]],
		{}
	)
	rpc("nvim_input_mouse", "left", "drag", "", 0, hit.row + 2, hit.col + 3)
	assert(
		vim.wait(1000, function()
			return rpc("nvim_exec_lua", "return graph.selected.x", {}) ~= original_x
		end),
		"Dragging moves the selected node"
	)
	local burst_start = rpc("nvim_exec_lua", "return neighbor.x", {})
	for i = 1, 12 do
		local col = hit.col + 3 + i
		rpc("nvim_input_mouse", "left", "drag", "", 0, hit.row + 2, col)
		assert(
			vim.wait(1000, function()
				return rpc("nvim_exec_lua", "return graph.drag.x", {}) == col + 1
			end),
			"Fast drag event processed"
		)
		vim.wait(8)
	end
	assert(
		math.abs(rpc("nvim_exec_lua", "return neighbor.x", {}) - burst_start) > 0.05,
		"Neighbours animate during rapid drag even without timer callbacks"
	)
	assert(
		vim.wait(1500, function()
			return math.abs(rpc("nvim_exec_lua", "return neighbor.x", {}) - neighbor_x) > 0.05
		end),
		"Connected neighbour responds while a node is held"
	)
	rpc("nvim_exec_lua", "graph.paused = true", {})
	rpc("nvim_input_mouse", "left", "release", "", 0, hit.row + 2, hit.col + 3)
	assert(
		vim.wait(1000, function()
			return rpc("nvim_exec_lua", "return graph.drag == nil", {})
		end),
		"Release handled"
	)
	-- Click a label (not the glyph), then double-click to open its note.
	local label = rpc(
		"nvim_exec_lua",
		[[
		vim.cmd("redraw")
		for _, hit in ipairs(graph.screen) do
			if hit.label_y then
				assert(hit.label_y == hit.y + 1, "Filename is below its dot")
				assert(hit.label_x <= hit.x and hit.label_last >= hit.x, "Filename is centred under dot")
				local pos = vim.fn.screenpos(graph.win, hit.label_y, 1)
				return {row=pos.row-1, col=pos.col+hit.label_x-2, path=hit.node.path}
			end
		end
	]],
		{}
	)
	assert(label, "Visible label")
	rpc("nvim_input_mouse", "left", "press", "", 0, label.row, label.col)
	assert(
		vim.wait(1000, function()
			return rpc("nvim_exec_lua", "return graph.selected.path", {}) == label.path
		end),
		"Label click selects note"
	)
	rpc("nvim_input_mouse", "left", "release", "", 0, label.row, label.col)
	vim.wait(30)
	rpc("nvim_input_mouse", "left", "press", "", 0, label.row, label.col)
	assert(
		vim.wait(1000, function()
			return rpc("nvim_exec_lua", "return vim.api.nvim_buf_get_name(0)", {}) == label.path
		end),
		"Double click opens note"
	)
end, debug.traceback)
vim.fn.jobstop(child)
vim.fn.delete(root, "rf")
assert(ok, err)
print("Graph real-UI mouse tests passed")
