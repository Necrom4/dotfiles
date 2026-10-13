vim.opt.rtp:prepend(vim.fn.getcwd())
local navigation = require("obsidian_graph.navigation")
local origin = { x = 0, y = 0 }
local left = { x = -20, y = 0 }
local right = { x = 20, y = 0 }
local above = { x = 0, y = -40 }
local below = { x = 0, y = 40 }
local distractor = { x = -0.1, y = -30 }
local nodes = { origin, distractor, left, right, above, below }
assert(navigation.next(nodes, origin, { -1, 0 }, 1) == left, "Left must not jump up")
assert(navigation.next(nodes, origin, { 1, 0 }, 1) == right)
assert(navigation.next({ origin, left, right, above, below }, origin, { 0, -1 }, 1) == above, "Prefer aligned columns")
assert(navigation.next(nodes, origin, { 0, 1 }, 1) == below)
assert(navigation.next({ origin, right, above }, origin, { -1, 0 }, 1) == nil, "No forward candidate means no move")
assert(navigation.next({ origin, { x = 8, y = 12 } }, origin, { 1, 0 }, 1), "Account for terminal cell aspect ratio")
local diagonal = { x = -6, y = -8 }
assert(
	navigation.next({ origin, above, diagonal }, origin, { 0, -1 }, 1) == diagonal,
	"Up selects nearby diagonal instead of distant aligned node"
)
local diagonal_right = { x = 8, y = 6 }
assert(
	navigation.next({ origin, right, diagonal_right }, origin, { 1, 0 }, 1) == diagonal_right,
	"Right also prefers sufficiently close diagonal"
)
for _, zoom in ipairs({ 0.01, 0.1, 1, 5, 20 }) do
	assert(
		navigation.next({ origin, above, diagonal }, origin, { 0, -1 }, zoom) == diagonal,
		"Navigation ranking is independent of zoom"
	)
end
print("Graph directional navigation tests passed")
