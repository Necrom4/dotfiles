vim.opt.rtp:prepend(vim.fn.getcwd())
local navigation = require("obsidian_graph.navigation")
local origin = { x = 0, y = 0 }
local left = { x = -20, y = 0 }
local right = { x = 20, y = 0 }
local above = { x = 0, y = -40 }
local below = { x = 0, y = 40 }
local distractor = { x = -0.1, y = -3 }
local nodes = { origin, distractor, left, right, above, below }
assert(navigation.next(nodes, origin, { -1, 0 }, 1) == left, "Left must not jump up")
assert(navigation.next(nodes, origin, { 1, 0 }, 1) == right)
assert(navigation.next({ origin, left, right, above, below }, origin, { 0, -1 }, 1) == above, "Prefer aligned columns")
assert(navigation.next(nodes, origin, { 0, 1 }, 1) == below)
assert(navigation.next({ origin, distractor }, origin, { -1, 0 }, 1) == nil, "No horizontal candidate means no move")
assert(navigation.next({ origin, { x = 8, y = 12 } }, origin, { 1, 0 }, 1), "Account for terminal cell aspect ratio")
print("Graph directional navigation tests passed")
