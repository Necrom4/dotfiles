vim.opt.rtp:prepend(vim.fn.getcwd())
local layout = require("obsidian_graph.layout")
local a, b, c = { x = -32, y = 0 }, { x = 0, y = 0 }, { x = 32, y = 0 }
local graph = { nodes = { a, b, c }, edges = { { a, b }, { b, c } } }
layout.seed(graph)
for _ = 1, 600 do
	layout.step(graph)
end
assert(graph.settled, "Simulation settles")
local x = b.x
assert(not layout.step(graph) and b.x == x, "Idle graph does not move")
a.x, a.y = a.x - 40, 20
layout.reheat(graph)
local pinned_x, pinned_y, bx = a.x, a.y, b.x
for _ = 1, 30 do
	layout.step(graph, nil, a)
end
assert(a.x == pinned_x and a.y == pinned_y, "Dragged node remains pinned")
assert(b.x < bx - 0.5, "Spring pulls connected neighbour towards dragged node")
layout.reheat(graph)
for _ = 1, 600 do
	layout.step(graph)
end
assert(graph.settled and a.x ~= pinned_x, "Release unpins and settles again")
for _, node in ipairs(graph.nodes) do
	assert(node.x == node.x and node.y == node.y, "Finite positions")
end
print("Graph spring/reheat physics tests passed")
