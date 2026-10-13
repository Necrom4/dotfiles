-- A real attached UI is needed for getmousepos(), borders and mouse dispatch.
local api = vim.api
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
	-- Freeze layout, select a known nonselected node, then use actual screen coordinates.
	local hit = rpc(
		"nvim_exec_lua",
		[[
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
	rpc("nvim_input_mouse", "left", "drag", "", 0, hit.row + 2, hit.col + 3)
	rpc("nvim_input_mouse", "left", "release", "", 0, hit.row + 2, hit.col + 3)
	assert(
		vim.wait(1000, function()
			return rpc("nvim_exec_lua", "return graph.drag == nil", {})
		end),
		"Release handled"
	)
	rpc("nvim_input", "q")
end, debug.traceback)
vim.fn.jobstop(child)
vim.fn.delete(root, "rf")
assert(ok, err)
print("Graph real-UI mouse tests passed")
