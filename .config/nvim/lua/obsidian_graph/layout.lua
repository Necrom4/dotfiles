local M = {}

function M.seed(graph)
	local radius = math.max(10, math.sqrt(#graph.nodes) * 8)
	for i, node in ipairs(graph.nodes) do
		local angle = i * 2.3999632297287
		local distance = radius * math.sqrt(i / #graph.nodes)
		node.x, node.y = math.cos(angle) * distance, math.sin(angle) * distance
	end
end

-- Spatially bucket repulsion so large vaults do not need all-pairs physics.
function M.step(graph, temperature)
	local cells, forces = {}, {}
	local size = math.max(25, math.sqrt(#graph.nodes) * 3)
	for _, n in ipairs(graph.nodes) do
		local cx, cy = math.floor(n.x / size), math.floor(n.y / size)
		local id = cx .. ":" .. cy
		local cell = cells[id] or { x = 0, y = 0, count = 0, nodes = {} }
		cells[id] = cell
		cell.x, cell.y, cell.count = cell.x + n.x, cell.y + n.y, cell.count + 1
		table.insert(cell.nodes, n)
		forces[n] = { -n.x * 0.004, -n.y * 0.004 }
	end
	for _, cell in pairs(cells) do
		cell.x, cell.y = cell.x / cell.count, cell.y / cell.count
	end
	for _, n in ipairs(graph.nodes) do
		local f = forces[n]
		local function repel(x, y, mass)
			local dx, dy = n.x - x, n.y - y
			local d2 = math.max(1, dx * dx + dy * dy)
			f[1], f[2] = f[1] + dx * 70 * mass / d2, f[2] + dy * 70 * mass / d2
		end
		for _, cell in pairs(cells) do
			local dx, dy = n.x - cell.x, n.y - cell.y
			if dx * dx + dy * dy > size * size * 4 then
				repel(cell.x, cell.y, cell.count)
			else
				for _, other in ipairs(cell.nodes) do
					if other ~= n then
						repel(other.x, other.y, 1)
					end
				end
			end
		end
	end
	for _, edge in ipairs(graph.edges) do
		local a, b = edge[1], edge[2]
		local dx, dy = b.x - a.x, b.y - a.y
		local distance = math.sqrt(dx * dx + dy * dy)
		local force = (distance - 18) * 0.035 / math.max(distance, 1)
		forces[a][1], forces[a][2] = forces[a][1] + dx * force, forces[a][2] + dy * force
		forces[b][1], forces[b][2] = forces[b][1] - dx * force, forces[b][2] - dy * force
	end
	for _, n in ipairs(graph.nodes) do
		local f = forces[n]
		local length = math.sqrt(f[1] * f[1] + f[2] * f[2])
		local scale = math.min(temperature / math.max(length, 0.001), 1)
		n.x, n.y = n.x + f[1] * scale, n.y + f[2] * scale
	end
end

return M
