local M = {}

function M.next(nodes, selected, direction, zoom)
	local best, best_band, best_score
	for _, node in ipairs(nodes) do
		if node ~= selected then
			-- Compare terminal cells, not world units: rows have twice the height.
			local dx = (node.x - selected.x) * zoom
			local dy = (node.y - selected.y) * zoom / 2
			local forward = dx * direction[1] + dy * direction[2]
			local sideways = math.abs(dx * direction[2] - dy * direction[1])
			-- A left/right candidate must be predominantly horizontal (and vice versa).
			-- Do not fall back to nearly vertical nodes merely because x differs slightly.
			if forward > 0 and sideways <= forward then
				local band = sideways <= 1 and 0 or 1
				local score = math.sqrt(dx * dx + dy * dy) + sideways * 2
				if not best or band < best_band or (band == best_band and score < best_score) then
					best, best_band, best_score = node, band, score
				end
			end
		end
	end
	return best
end

return M
