local M = {}

function M.next(nodes, selected, direction, zoom)
	local best, best_score
	for _, node in ipairs(nodes) do
		if node ~= selected then
			-- Compare terminal cells, not world units: rows have twice the height.
			local dx = (node.x - selected.x) * zoom
			local dy = (node.y - selected.y) * zoom / 2
			local forward = dx * direction[1] + dy * direction[2]
			local sideways = math.abs(dx * direction[2] - dy * direction[1])
			-- Keep Emeraldian's distance + 2 * off-axis scoring, but restrict its
			-- forward half-plane to a 60-degree cone around the requested direction.
			-- This admits useful diagonals without letting a nearly vertical node
			-- win a horizontal move just because it is slightly left/right.
			if forward > 0 and sideways <= forward * math.sqrt(3) then
				local score = math.sqrt(dx * dx + dy * dy) + sideways * 2
				if not best or score < best_score then
					best, best_score = node, score
				end
			end
		end
	end
	return best
end

return M
