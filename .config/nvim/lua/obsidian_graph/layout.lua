local M = {}

-- Emeraldian's layout informed this implementation: Barnes-Hut repulsion,
-- degree-aware springs, damped velocities, cooling and pin/reheat on drag.
-- Algorithm reference: iamrohithrnair/emeraldian, emeraldian-core/src/graph.rs.
function M.seed(graph)
	local radius = math.max(10, math.sqrt(#graph.nodes) * 8)
	for i, node in ipairs(graph.nodes) do
		local angle = i * 2.3999632297287
		local distance = radius * math.sqrt(i / #graph.nodes)
		node.x = node.x or math.cos(angle) * distance
		node.y = node.y or math.sin(angle) * distance
		node.vx, node.vy = 0, 0
	end
	graph.alpha, graph.steps, graph.settled = 1, 0, false
end

function M.reheat(graph)
	graph.alpha = math.max(graph.alpha or 0, 0.5)
	graph.steps, graph.settled = 0, false
end

local function tree(nodes, x, y, half, depth, degree)
	local cell = { x = x, y = y, half = half, mass = 0, mx = 0, my = 0 }
	for _, node in ipairs(nodes) do
		local mass = 1 + degree[node]
		cell.mass = cell.mass + mass
		cell.mx, cell.my = cell.mx + node.x * mass, cell.my + node.y * mass
	end
	cell.mx, cell.my = cell.mx / cell.mass, cell.my / cell.mass
	if #nodes <= 1 or half < 0.05 or depth >= 24 then
		cell.nodes = nodes
	else
		local groups = { {}, {}, {}, {} }
		for _, node in ipairs(nodes) do
			local quadrant = 1 + (node.x >= x and 1 or 0) + (node.y >= y and 2 or 0)
			table.insert(groups[quadrant], node)
		end
		cell.children = {}
		for quadrant, group in ipairs(groups) do
			if #group > 0 then
				local ox = (quadrant == 2 or quadrant == 4) and 1 or -1
				local oy = quadrant >= 3 and 1 or -1
				table.insert(cell.children, tree(group, x + ox * half / 2, y + oy * half / 2, half / 2, depth + 1, degree))
			end
		end
	end
	return cell
end

function M.step(graph, _, pinned)
	if graph.settled or #graph.nodes == 0 then
		return false
	end
	local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
	local degree = {}
	for _, node in ipairs(graph.nodes) do
		minx, miny = math.min(minx, node.x), math.min(miny, node.y)
		maxx, maxy = math.max(maxx, node.x), math.max(maxy, node.y)
		degree[node] = 0
	end
	for _, edge in ipairs(graph.edges) do
		degree[edge[1]], degree[edge[2]] = degree[edge[1]] + 1, degree[edge[2]] + 1
	end
	local root =
		tree(graph.nodes, (minx + maxx) / 2, (miny + maxy) / 2, math.max(1, maxx - minx, maxy - miny) * 0.525, 0, degree)
	local forces = {}
	for i, node in ipairs(graph.nodes) do
		local fx, fy = -node.x * 0.06, -node.y * 0.06
		local function repel(x, y, mass)
			local dx, dy = node.x - x, node.y - y
			local distance = math.sqrt(dx * dx + dy * dy)
			if distance < 0.001 then
				dx, dy, distance = math.cos(i * 0.7), math.sin(i * 0.7), 1
			end
			local strength = 300 * mass / math.max(1, distance * distance)
			fx, fy = fx + dx / distance * strength, fy + dy / distance * strength
		end
		local function visit(cell)
			if cell.nodes then
				for _, other in ipairs(cell.nodes) do
					if other ~= node then
						repel(other.x, other.y, 1 + (degree[other] or 0))
					end
				end
				return
			end
			local dx, dy = node.x - cell.mx, node.y - cell.my
			local contains = math.abs(node.x - cell.x) <= cell.half and math.abs(node.y - cell.y) <= cell.half
			if not contains and cell.half * 2 / math.max(0.001, math.sqrt(dx * dx + dy * dy)) < 0.8 then
				repel(cell.mx, cell.my, cell.mass)
			else
				for _, child in ipairs(cell.children) do
					visit(child)
				end
			end
		end
		visit(root)
		forces[node] = { fx, fy }
	end
	for _, edge in ipairs(graph.edges) do
		local a, b = edge[1], edge[2]
		local dx, dy = b.x - a.x, b.y - a.y
		local distance = math.max(0.01, math.sqrt(dx * dx + dy * dy))
		local strength = (distance - 32) * 0.06 / (1 + math.min(degree[a], degree[b])) / distance
		forces[a][1], forces[a][2] = forces[a][1] + dx * strength, forces[a][2] + dy * strength
		forces[b][1], forces[b][2] = forces[b][1] - dx * strength, forces[b][2] - dy * strength
	end
	local energy, alpha = 0, graph.alpha or 1
	for _, node in ipairs(graph.nodes) do
		if node == pinned then
			node.vx, node.vy = 0, 0
		else
			node.vx = ((node.vx or 0) + forces[node][1] * 0.85) * 0.82
			node.vy = ((node.vy or 0) + forces[node][2] * 0.85) * 0.82
			local speed = math.sqrt(node.vx * node.vx + node.vy * node.vy)
			if speed ~= speed or speed == math.huge then
				node.vx, node.vy, speed = 0, 0, 0
			end
			if speed > 40 then
				node.vx, node.vy = node.vx * 40 / speed, node.vy * 40 / speed
			end
			node.x, node.y = node.x + node.vx * alpha, node.y + node.vy * alpha
			energy = energy + math.min(speed, 40) * alpha
		end
	end
	graph.alpha, graph.steps = alpha * 0.985, (graph.steps or 0) + 1
	graph.settled = not pinned
		and (graph.alpha < 0.02 or graph.steps >= 600 or (graph.steps > 30 and energy / #graph.nodes < 0.06))
	return true
end

return M
