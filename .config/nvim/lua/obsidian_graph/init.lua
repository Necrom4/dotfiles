local M = {}
local api = vim.api
local index = require("obsidian_graph.index")
local layout = require("obsidian_graph.layout")
local ns = api.nvim_create_namespace("obsidian_graph")
local active

local help = {
	"h j k l / arrows    Pan (counts supported)",
	"+ / = / -          Zoom in / out",
	"f                  Fit graph",
	"c                  Centre selected note",
	"Tab / Shift-Tab    Select next / previous note",
	"H J K L            Select nearest node in that direction",
	"/                  Find/select a note (path and aliases)",
	"Enter              Close graph and open selected note",
	"s / v / t          Open note in split / vsplit / tab",
	"p                  Preview selected note",
	"g                  Toggle vault / local graph",
	"[ / ]              Decrease / increase local depth (1–5)",
	"L is directional; b toggles labels",
	"r                  Reindex notes and rebuild layout",
	"Space              Pause/resume physics animation",
	"Left click         Select node or label",
	"Double click       Open node",
	"Left drag          Move node; drag background to pan",
	"Mouse wheel        Zoom",
	"?                  Show this help",
	"q / Esc            Close graph without changing your note",
	"",
	"Links are undirected; only existing Markdown notes are shown.",
	"Hidden folders and symlinks are excluded. r includes unsaved buffers.",
	"Wikilinks, Markdown links, frontmatter IDs and aliases are resolved.",
	"Attachments, tags and unresolved links are not displayed.",
	"Physics runs continuously up to 1,000 nodes; larger graphs settle.",
	"Animations pause behind previews/pickers. Space freezes physics.",
}

local function dimensions()
	return {
		relative = "editor",
		row = 1,
		col = 2,
		width = math.max(1, vim.o.columns - 6),
		height = math.max(1, vim.o.lines - 6),
		style = "minimal",
		border = "rounded",
		title = " Obsidian graph ",
		title_pos = "center",
	}
end

local function alive(s)
	return active == s and api.nvim_win_is_valid(s.win) and api.nvim_buf_is_valid(s.buf)
end

local function close(s)
	if active == s then
		active = nil
	end
	s.generation = s.generation + 1
	if s.group then
		pcall(api.nvim_del_augroup_by_id, s.group)
	end
	for _, win in ipairs(s.popups or {}) do
		if api.nvim_win_is_valid(win) then
			api.nvim_win_close(win, true)
		end
	end
	if api.nvim_win_is_valid(s.win) then
		api.nvim_win_close(s.win, true)
	end
	if api.nvim_buf_is_valid(s.buf) then
		api.nvim_buf_delete(s.buf, { force = true })
	end
end

local function fit(s)
	if not s.view or #s.view.nodes == 0 then
		return
	end
	local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
	for _, n in ipairs(s.view.nodes) do
		minx, maxx, miny, maxy = math.min(minx, n.x), math.max(maxx, n.x), math.min(miny, n.y), math.max(maxy, n.y)
	end
	s.cx, s.cy = (minx + maxx) / 2, (miny + maxy) / 2
	s.zoom = math.min((s.width - 12) / math.max(20, maxx - minx), (s.height - 5) * 2 / math.max(20, maxy - miny)) * 0.85
	s.zoom = math.max(0.01, s.zoom)
end

local function project(s, n)
	local camera = s.camera or { cx = s.cx, cy = s.cy, zoom = s.zoom }
	return (n.x - camera.cx) * camera.zoom + s.width / 2, (n.y - camera.cy) * camera.zoom / 2 + (s.height - 2) / 2 + 1
end

local function clipped(text, width)
	local out, used = {}, 0
	for _, char in ipairs(vim.fn.split(text:gsub("[%c]", " "), "\\zs")) do
		local size = vim.fn.strdisplaywidth(char)
		if used + size > width then
			break
		end
		table.insert(out, char)
		used = used + size
	end
	return table.concat(out)
end

local function render(s)
	if not alive(s) then
		return
	end
	s.width, s.height = api.nvim_win_get_width(s.win), api.nvim_win_get_height(s.win)
	local now = vim.uv.hrtime()
	local dt = math.min(0.1, (now - (s.last_frame or now)) / 1e9)
	s.last_frame = now
	s.camera = s.camera or { cx = s.cx, cy = s.cy, zoom = s.zoom }
	local moving = false
	for _, key in ipairs({ "cx", "cy", "zoom" }) do
		local diff = s[key] - s.camera[key]
		local tolerance = key == "zoom" and 0.0001 or 0.01
		if math.abs(diff) > tolerance then
			s.camera[key] = s.camera[key] + diff * (s.drag and 1 or (1 - math.exp(-dt * 14)))
			moving = true
		else
			s.camera[key] = s[key]
		end
	end
	if moving and not s.camera_pending then
		s.camera_pending = true
		vim.defer_fn(function()
			s.camera_pending = false
			if alive(s) then
				render(s)
			end
		end, 16)
	end
	local cells, colors = {}, {}
	for y = 1, s.height do
		cells[y], colors[y] = {}, {}
		for x = 1, s.width do
			cells[y][x] = " "
		end
	end
	local function put(x, y, text, hl)
		if y < 1 or y > s.height then
			return
		end
		for _, char in ipairs(vim.fn.split(text, "\\zs")) do
			local width = vim.fn.strdisplaywidth(char)
			if x >= 1 and x + width - 1 <= s.width and width > 0 then
				-- Erase whole glyphs when overwriting a double-width note label.
				for col = x, x + width - 1 do
					local first = col
					while first > 1 and cells[y][first] == "" do
						first = first - 1
					end
					local old_width = vim.fn.strdisplaywidth(cells[y][first])
					for c = first, math.min(s.width, first + old_width - 1) do
						cells[y][c] = " "
						colors[y][c] = nil
					end
				end
				cells[y][x] = char
				for c = x, x + width - 1 do
					colors[y][c] = hl
				end
				for c = x + 1, x + width - 1 do
					cells[y][c] = ""
				end
			end
			x = x + width
		end
	end
	local selected = s.selected
	local header = s.loading and " Indexing vault…"
		or string.format(
			" %s | %d notes · %d links | depth %d | %s",
			s.local_view and "LOCAL" or "VAULT",
			#(s.view and s.view.nodes or {}),
			#(s.view and s.view.edges or {}),
			s.depth,
			s.root
		)
	put(1, 1, clipped(header, s.width), "Title")
	s.screen = {}
	if s.view then
		-- Braille edge raster: 2×4 subpixels per terminal cell.
		local dots = {}
		local bits = { { 1, 2, 4, 64 }, { 8, 16, 32, 128 } }
		local function dot(px, py, focused)
			local x, y = math.floor(px / 2) + 1, math.floor(py / 4) + 1
			if x < 1 or x > s.width or y < 2 or y >= s.height then
				return
			end
			local id = y * s.width + x
			local d = dots[id] or { x = x, y = y, mask = 0 }
			d.mask = bit.bor(d.mask, bits[px % 2 + 1][py % 4 + 1])
			d.focused = d.focused or focused
			dots[id] = d
		end
		for _, edge in ipairs(s.view.edges) do
			local ax, ay = project(s, edge[1])
			local bx, by = project(s, edge[2])
			ax, ay, bx, by = (ax - 1) * 2, (ay - 1) * 4, (bx - 1) * 2, (by - 1) * 4
			local dx, dy = bx - ax, by - ay
			-- Clip before rasterizing so zooming cannot generate huge offscreen lines.
			local lo, hi = 0, 1
			for _, bound in ipairs({
				{ -dx, ax },
				{ dx, s.width * 2 - 1 - ax },
				{ -dy, ay - 4 },
				{ dy, (s.height - 1) * 4 - 1 - ay },
			}) do
				local p, q = bound[1], bound[2]
				if p == 0 then
					if q < 0 then
						hi = -1
					end
				elseif p < 0 then
					lo = math.max(lo, q / p)
				else
					hi = math.min(hi, q / p)
				end
			end
			if lo <= hi then
				local steps = math.max(1, math.ceil(math.max(math.abs(dx), math.abs(dy)) * (hi - lo)))
				for i = 0, steps do
					local t = lo + (hi - lo) * i / steps
					dot(math.floor(ax + dx * t), math.floor(ay + dy * t), edge[1] == selected or edge[2] == selected)
				end
			end
		end
		for _, d in pairs(dots) do
			put(d.x, d.y, vim.fn.nr2char(0x2800 + d.mask), d.focused and "ObsidianGraphLink" or "Comment")
		end
		local ordered = {}
		for _, n in ipairs(s.view.nodes) do
			if n ~= selected then
				table.insert(ordered, n)
			end
		end
		if selected then
			table.insert(ordered, selected)
		end
		local occupied, labels = {}, {}
		for _, n in ipairs(ordered) do
			local x, y = project(s, n)
			occupied[math.floor(y) .. ":" .. math.floor(x)] = true
		end
		for _, n in ipairs(ordered) do
			local x, y = project(s, n)
			x, y = math.floor(x), math.floor(y)
			if x >= 1 and x <= s.width and y > 1 and y < s.height then
				local hl = n == selected and "ObsidianGraphSelected"
					or selected and selected.neighbors[n] and "ObsidianGraphNeighbor"
					or "ObsidianGraphNode"
				put(x, y, n == selected and "◆" or "●", hl)
				local last = x
				if s.labels or n == selected then
					local label = clipped(" " .. n.label, math.min(30, s.width - x))
					local width = vim.fn.strdisplaywidth(label)
					table.insert(labels, { x = x, y = y, width = width, text = label, hl = hl, node = n })
				end
				table.insert(s.screen, { node = n, x = x, y = y, last = last })
			end
		end
		-- Selected label gets first choice; later labels cannot overwrite it.
		for i = #labels, 1, -1 do
			local label = labels[i]
			local free = true
			for col = label.x + 1, label.x + label.width do
				if occupied[label.y .. ":" .. col] then
					free = false
				end
			end
			if free then
				put(label.x + 1, label.y, label.text, label.hl)
				for col = label.x + 1, label.x + label.width do
					occupied[label.y .. ":" .. col] = true
				end
				for _, hit in ipairs(s.screen) do
					if hit.node == label.node then
						hit.last = label.x + label.width
					end
				end
			end
		end
	end
	if not s.loading and s.view and #s.view.nodes == 0 then
		put(3, 3, clipped("No notes in this view. Use g for vault graph or / to select a note.", s.width - 3), "Comment")
	end
	local footer = selected
			and string.format(
				" %s · %d connections | Enter open · / find · g local/vault · ? help · q close",
				selected.rel,
				selected.degree
			)
		or " Tab select · / find · ? help · q close"
	put(1, s.height, clipped(footer, s.width), "Title")
	local lines, offsets = {}, {}
	for y, row in ipairs(cells) do
		offsets[y] = {}
		local bytes = 0
		for x, char in ipairs(row) do
			offsets[y][x] = bytes
			bytes = bytes + #char
		end
		offsets[y][s.width + 1] = bytes
		lines[y] = table.concat(row)
	end
	vim.bo[s.buf].modifiable = true
	api.nvim_buf_set_lines(s.buf, 0, -1, false, lines)
	vim.bo[s.buf].modifiable = false
	api.nvim_buf_clear_namespace(s.buf, ns, 0, -1)
	-- Highlight only the final composited cells, never overlapping edge/label ranges.
	for y = 1, s.height do
		local x = 1
		while x <= s.width do
			local hl, first = colors[y][x], x
			x = x + 1
			while x <= s.width and colors[y][x] == hl do
				x = x + 1
			end
			if hl and offsets[y][x] > offsets[y][first] then
				api.nvim_buf_set_extmark(s.buf, ns, y - 1, offsets[y][first], {
					end_col = offsets[y][x],
					hl_group = hl,
					priority = 110,
				})
			end
		end
	end
	for _, n in ipairs(s.screen) do
		if n.node == selected then
			api.nvim_win_set_cursor(s.win, { n.y, offsets[n.y][n.x] })
			return
		end
	end
	api.nvim_win_set_cursor(s.win, { 1, 0 })
end

local function center(s)
	if s.selected then
		s.cx, s.cy = s.selected.x, s.selected.y
	end
end

local function rebuild_view(s)
	if not s.graph then
		return
	end
	s.view = s.local_view and index.subgraph(s.graph, s.focus, s.depth) or s.graph
	if not vim.tbl_contains(s.view.nodes, s.selected) then
		s.selected = s.focus or s.view.nodes[1]
	end
	layout.seed(s.view)
	fit(s)
	s.generation = s.generation + 1
	local generation, iteration = s.generation, 0
	local function tick()
		if not alive(s) or s.generation ~= generation then
			return
		end
		if not s.paused and api.nvim_get_current_win() == s.win then
			iteration = iteration + 1
			layout.step(s.view, math.max(0.08, 2 * math.exp(-iteration / 120)), s.drag and s.drag.node)
		end
		if not s.interacted then
			fit(s)
		end
		render(s)
		if #s.view.nodes > 0 and (#s.view.nodes <= 1000 or iteration < 160) then
			vim.defer_fn(tick, #s.view.nodes <= 500 and 16 or 33)
		end
	end
	render(s)
	vim.schedule(tick)
end

local function refresh(s)
	s.generation = s.generation + 1
	local generation = s.generation
	s.loading = true
	render(s)
	local selected_path = s.selected and s.selected.path or s.origin_path
	local focus_path = s.focus and s.focus.path or s.origin_path
	index.scan(s.root, function(graph)
		if not alive(s) then
			return
		end
		s.graph, s.loading, s.interacted = graph, false, false
		s.selected = graph.by_path[selected_path] or graph.nodes[1]
		s.focus = graph.by_path[focus_path] or s.selected
		if #graph.warnings > 0 then
			vim.notify("Obsidian graph: could not read " .. #graph.warnings .. " notes", vim.log.levels.WARN)
		end
		rebuild_view(s)
	end, function()
		return not alive(s) or generation ~= s.generation
	end)
end

local function open_note(s, command)
	if not s.selected then
		return
	end
	local path, origin = s.selected.path, s.origin_win
	close(s)
	if api.nvim_win_is_valid(origin) then
		api.nvim_set_current_win(origin)
	end
	-- Structured command arguments avoid Ex injection and preserve modified buffers.
	local ok, err = pcall(vim.cmd, { cmd = command, args = { path } })
	if not ok then
		vim.notify(tostring(err), vim.log.levels.ERROR)
	end
end

local function popup(s, lines, filetype)
	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype, vim.bo[buf].bufhidden, vim.bo[buf].modifiable = filetype, "wipe", false
	local width, height = math.max(1, math.min(90, s.width - 4)), math.max(1, math.min(30, s.height - 2))
	local win = api.nvim_open_win(buf, true, {
		relative = "win",
		win = s.win,
		row = 1,
		col = 2,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
	s.popups = s.popups or {}
	table.insert(s.popups, win)
	vim.wo[win].wrap = true
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, function()
			if api.nvim_win_is_valid(win) then
				api.nvim_win_close(win, true)
			end
		end, { buffer = buf, silent = true })
	end
end

local function mappings(s)
	local function map(keys, fn, desc)
		for _, lhs in ipairs(type(keys) == "table" and keys or { keys }) do
			vim.keymap.set("n", lhs, function()
				if alive(s) then
					fn()
				end
			end, { buffer = s.buf, silent = true, desc = desc })
		end
	end
	for key, delta in pairs({ h = { -1, 0 }, j = { 0, 1 }, k = { 0, -1 }, l = { 1, 0 } }) do
		map({ key, ({ h = "<Left>", j = "<Down>", k = "<Up>", l = "<Right>" })[key] }, function()
			s.interacted = true
			-- Keyboard panning is discrete, not an accumulating camera tween.
			if s.camera then
				s.cx, s.cy, s.zoom = s.camera.cx, s.camera.cy, s.camera.zoom
			end
			s.cx, s.cy = s.cx + delta[1] * 4 * vim.v.count1 / s.zoom, s.cy + delta[2] * 8 * vim.v.count1 / s.zoom
			if s.camera then
				s.camera.cx, s.camera.cy = s.cx, s.cy
			end
			render(s)
		end, "Pan graph")
		map(key:upper(), function()
			if not s.selected or not s.view then
				return
			end
			local best, score
			for _, node in ipairs(s.view.nodes) do
				local dx, dy = node.x - s.selected.x, node.y - s.selected.y
				local forward, sideways = dx * delta[1] + dy * delta[2], math.abs(dx * delta[2] - dy * delta[1])
				local distance = math.sqrt(dx * dx + dy * dy) + sideways * 2
				if forward > 0 and (not score or distance < score) then
					best, score = node, distance
				end
			end
			if best then
				s.selected = best
				s.interacted = true
				center(s)
				render(s)
			end
		end, "Select directional node")
	end
	local function zoom(factor)
		s.interacted = true
		s.zoom = math.max(0.01, math.min(20, s.zoom * factor))
		render(s)
	end
	map({ "+", "=", "<ScrollWheelUp>" }, function()
		zoom(1.25)
	end, "Zoom in")
	map({ "-", "<ScrollWheelDown>" }, function()
		zoom(0.8)
	end, "Zoom out")
	map("f", function()
		s.interacted = true
		fit(s)
		render(s)
	end, "Fit graph")
	map("c", function()
		s.interacted = true
		center(s)
		render(s)
	end, "Centre selection")
	for key, direction in pairs({ ["<Tab>"] = 1, ["<S-Tab>"] = -1 }) do
		map(key, function()
			if not s.view or #s.view.nodes == 0 then
				return
			end
			local current = 1
			for i, n in ipairs(s.view.nodes) do
				if n == s.selected then
					current = i
				end
			end
			s.selected = s.view.nodes[(current - 1 + direction * vim.v.count1) % #s.view.nodes + 1]
			s.interacted = true
			center(s)
			render(s)
		end, "Cycle graph notes")
	end
	map("/", function()
		if not s.graph or s.loading then
			return
		end
		vim.ui.select(s.graph.nodes, {
			prompt = "Graph: select note",
			format_item = function(n)
				local aliases = n.meta.aliases
				if type(aliases) == "string" then
					aliases = { aliases }
				end
				return n.rel .. (type(aliases) == "table" and #aliases > 0 and " [" .. table.concat(aliases, ", ") .. "]" or "")
			end,
		}, function(node)
			if node and alive(s) then
				s.selected, s.interacted = node, true
				if s.local_view then
					s.focus = node
					rebuild_view(s)
				end
				center(s)
				render(s)
			end
		end)
	end, "Find graph note")
	map("<CR>", function()
		open_note(s, "edit")
	end, "Open note")
	for key, cmd in pairs({ s = "split", v = "vsplit", t = "tabedit" }) do
		map(key, function()
			open_note(s, cmd)
		end, "Open note in " .. cmd)
	end
	map("p", function()
		if not s.selected then
			return
		end
		local buf = vim.fn.bufnr(s.selected.path)
		local ok, lines = pcall(function()
			return buf >= 0 and api.nvim_buf_is_loaded(buf) and api.nvim_buf_get_lines(buf, 0, -1, false)
				or vim.fn.readfile(s.selected.path)
		end)
		if ok then
			popup(s, lines, "markdown")
		else
			vim.notify(tostring(lines), vim.log.levels.ERROR)
		end
	end, "Preview graph note")
	map("g", function()
		if s.loading then
			return
		end
		s.local_view = not s.local_view
		s.focus = s.selected
		s.interacted = false
		rebuild_view(s)
	end, "Toggle local graph")
	for key, delta in pairs({ ["["] = -1, ["]"] = 1 }) do
		map(key, function()
			if s.loading then
				return
			end
			s.depth = math.max(1, math.min(5, s.depth + delta))
			s.interacted = false
			rebuild_view(s)
		end, "Change local graph depth")
	end
	map("b", function()
		s.labels = not s.labels
		render(s)
	end, "Toggle labels")
	map("r", function()
		refresh(s)
	end, "Refresh graph")
	map("<Space>", function()
		s.paused = not s.paused
	end, "Pause/resume graph physics")
	map("?", function()
		popup(s, help, "text")
	end, "Graph help")
	map({ "q", "<Esc>" }, function()
		close(s)
	end, "Close graph")
	local function mouse(open)
		local pos = vim.fn.getmousepos()
		if pos.winid ~= s.win or pos.line < 1 then
			return
		end
		local line = api.nvim_buf_get_lines(s.buf, pos.line - 1, pos.line, false)[1] or ""
		local x = vim.fn.strdisplaywidth(line:sub(1, pos.column - 1)) + 1 + (pos.coladd or 0)
		s.drag = { x = pos.screencol, y = pos.screenrow }
		for i = #s.screen, 1, -1 do
			local hit = s.screen[i]
			if pos.line == hit.y and x >= hit.x and x <= hit.last then
				s.drag.node = hit.node
				s.selected, s.interacted = hit.node, true
				if open then
					open_note(s, "edit")
				else
					render(s)
				end
				return
			end
		end
	end
	map("<LeftMouse>", function()
		mouse(false)
	end, "Select graph node")
	map("<2-LeftMouse>", function()
		mouse(true)
	end, "Open graph node")
	map("<LeftDrag>", function()
		if not s.drag then
			return
		end
		local pos = vim.fn.getmousepos()
		local zoom = s.camera and s.camera.zoom or s.zoom
		local dx, dy = (pos.screencol - s.drag.x) / zoom, (pos.screenrow - s.drag.y) * 2 / zoom
		if s.drag.node then
			local n = s.drag.node
			n.x, n.y = n.x + dx, n.y + dy
		else
			s.cx, s.cy = s.cx - dx, s.cy - dy
		end
		s.drag.x, s.drag.y, s.interacted = pos.screencol, pos.screenrow, true
		render(s)
	end, "Drag node or pan graph")
	map("<LeftRelease>", function()
		s.drag = nil
	end, "Release graph drag")
end

function M.open(opts)
	opts = opts or {}
	if active and alive(active) then
		close(active)
	end
	local root = opts.root
	if not root then
		local state = rawget(_G, "Obsidian")
		root = state and state.dir and tostring(state.dir)
		if not root then
			local ok, obsidian = pcall(require, "obsidian")
			if ok then
				local success, client = pcall(obsidian.get_client)
				if success then
					root = tostring(client.dir)
				end
			end
		end
	end
	if not root or root == "nil" then
		vim.notify("Obsidian graph: no active workspace", vim.log.levels.ERROR)
		return
	end
	root = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(root), ":p")):gsub("/+$", "")
	if vim.fn.isdirectory(root) == 0 then
		vim.notify("Obsidian graph: vault directory does not exist", vim.log.levels.ERROR)
		return
	end
	local s = {
		root = root,
		origin_win = api.nvim_get_current_win(),
		origin_path = api.nvim_buf_get_name(0),
		local_view = opts.local_view or false,
		depth = opts.depth or 1,
		labels = true,
		cx = 0,
		cy = 0,
		zoom = 1,
		generation = 0,
	}
	s.buf = api.nvim_create_buf(false, true)
	vim.bo[s.buf].bufhidden, vim.bo[s.buf].filetype = "wipe", "obsidian_graph"
	s.win = api.nvim_open_win(s.buf, true, dimensions())
	vim.wo[s.win].wrap, vim.wo[s.win].cursorline, vim.wo[s.win].signcolumn = false, false, "no"
	vim.wo[s.win].list = false
	vim.wo[s.win].spell, vim.wo[s.win].cursorcolumn, vim.wo[s.win].foldenable = false, false, false
	active = s
	for name, link in pairs({
		ObsidianGraphNode = "Identifier",
		ObsidianGraphNeighbor = "String",
		ObsidianGraphSelected = "IncSearch",
		ObsidianGraphLink = "Special",
	}) do
		api.nvim_set_hl(0, name, { default = true, link = link })
	end
	s.group = api.nvim_create_augroup("ObsidianGraphView" .. s.buf, { clear = true })
	api.nvim_create_autocmd("VimResized", {
		group = s.group,
		callback = function()
			if alive(s) then
				api.nvim_win_set_config(s.win, dimensions())
				render(s)
			end
		end,
	})
	api.nvim_create_autocmd("WinClosed", {
		group = s.group,
		pattern = tostring(s.win),
		callback = function()
			if active == s then
				active = nil
				s.generation = s.generation + 1
				vim.schedule(function()
					close(s)
				end)
			end
		end,
	})
	mappings(s)
	refresh(s)
	return s
end

function M.setup()
	-- The registry drives both :Obsidian completion and its command picker.
	require("obsidian").register_command("graph", {
		nargs = 0,
		func = function()
			M.open()
		end,
	})
end

return M
