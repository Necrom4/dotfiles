local M = {}

local function stem(path)
	return path:gsub("%.[mM][dD]$", "")
end

local function key(value)
	return stem(vim.trim(value)):lower()
end

local function decode(value)
	return (value:gsub("%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end))
end

-- Ignore examples in fenced/inline code and HTML comments, not just raw regex matches.
function M.parse(lines)
	local links, meta, start = {}, {}, 1
	if lines[1] == "---" then
		for i = 2, #lines do
			if lines[i] == "---" or lines[i] == "..." then
				local ok, yaml = pcall(require, "obsidian.yaml")
				if ok then
					local success, value = pcall(yaml.loads, table.concat(lines, "\n", 2, i - 1))
					if success and type(value) == "table" then
						meta = value
					end
				end
				start = i + 1
				break
			end
		end
	end
	local fence, fence_len, comment
	for i = start, #lines do
		local line = lines[i]
		local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
		if marker then
			if not fence then
				fence, fence_len = marker:sub(1, 1), #marker
			elseif marker:sub(1, 1) == fence and #marker >= fence_len then
				fence = nil
			end
		elseif not fence then
			local clean, pos = {}, 1
			while pos <= #line do
				local a, b = line:find(comment and "-->" or "<!--", pos, true)
				if not a then
					if not comment then
						table.insert(clean, line:sub(pos))
					end
					break
				end
				if not comment then
					table.insert(clean, line:sub(pos, a - 1))
				end
				comment, pos = not comment, b + 1
			end
			line = table.concat(clean):gsub("(`+)(.-)%1", "")
			for target in line:gmatch("%[%[([^%]]+)%]%]") do
				table.insert(links, { target = target:match("^[^|#^]*"), wiki = true })
			end
			for target in line:gmatch("%]%(([^%)]+)%)") do
				target = target:match("^%s*<([^>]+)>") or target:match("^%s*(.-)%s+[\"']") or vim.trim(target)
				table.insert(links, { target = decode(target):match("^[^#]*"), wiki = false })
			end
		end
	end
	return links, meta
end

function M.build(root, notes)
	local graph = { root = root, nodes = notes, edges = {}, by_path = {}, warnings = {} }
	local lookup = {}
	local function add(value, node)
		if value == nil or type(value) == "table" then
			return
		end
		local k = key(tostring(value))
		lookup[k] = lookup[k] or {}
		if not vim.tbl_contains(lookup[k], node) then
			table.insert(lookup[k], node)
		end
	end
	for _, node in ipairs(notes) do
		graph.by_path[node.path] = node
		node.neighbors, node.degree = {}, 0
		add(node.rel, node)
		add(vim.fs.basename(node.rel), node)
		add(node.meta.id, node)
		local aliases = node.meta.aliases or {}
		if type(aliases) == "string" then
			aliases = { aliases }
		end
		if type(aliases) == "table" then
			for _, alias in ipairs(aliases) do
				add(alias, node)
			end
		end
	end
	local seen = {}
	for _, node in ipairs(notes) do
		for _, link in ipairs(node.links) do
			local target = vim.trim(link.target or "")
			if target ~= "" and not target:match("^%a[%w+.-]*:") then
				local relative = vim.fs.normalize(vim.fs.dirname(node.rel) .. "/" .. target)
				local exact = target:gsub("^/", "")
				local dest = graph.by_path[root .. "/" .. (exact:lower():match("%.md$") and exact or exact .. ".md")]
				local local_dest =
					graph.by_path[root .. "/" .. (relative:lower():match("%.md$") and relative or relative .. ".md")]
				if not link.wiki or target:match("^%.") or not target:find("/", 1, true) then
					dest = local_dest or dest
				else
					dest = dest or local_dest
				end
				if not dest and link.wiki then
					local candidates = lookup[key(target)] or {}
					if #candidates == 1 then
						dest = candidates[1]
					end
				end
				if dest and dest ~= node then
					local edge_key = node.path < dest.path and node.path .. "\0" .. dest.path or dest.path .. "\0" .. node.path
					if not seen[edge_key] then
						seen[edge_key] = true
						table.insert(graph.edges, { node, dest })
						node.neighbors[dest], dest.neighbors[node] = true, true
						node.degree, dest.degree = node.degree + 1, dest.degree + 1
					end
				end
			end
		end
	end
	return graph
end

-- Work in short scheduled batches; closing the view cancels indexing.
function M.scan(root, done, cancelled)
	local queue, notes, warnings = { root }, {}, {}
	local files, directory, iterator = {}, nil, nil
	local loaded = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			loaded[vim.api.nvim_buf_get_name(buf)] = buf
		end
	end
	local function step()
		if cancelled() then
			return
		end
		local deadline = vim.uv.hrtime() + 6000000
		repeat
			if #files > 0 then
				local path = table.remove(files)
				local ok, lines = pcall(function()
					return loaded[path] and vim.api.nvim_buf_get_lines(loaded[path], 0, -1, false) or vim.fn.readfile(path)
				end)
				if ok then
					local links, meta = M.parse(lines)
					local rel = path:sub(#root + 2)
					table.insert(
						notes,
						{ path = path, rel = rel, label = stem(vim.fs.basename(rel)), links = links, meta = meta }
					)
				else
					table.insert(warnings, path)
				end
			else
				if not iterator then
					directory = table.remove(queue)
					if not directory then
						table.sort(notes, function(a, b)
							return a.rel < b.rel
						end)
						local graph = M.build(root, notes)
						graph.warnings = warnings
						done(graph)
						return
					end
					local ok, value = pcall(vim.fs.dir, directory)
					if ok then
						iterator = value
					else
						table.insert(warnings, directory)
						iterator = function() end
					end
				end
				local ok, name, kind = pcall(iterator)
				if not ok then
					table.insert(warnings, directory)
					name = nil
				end
				if not name then
					iterator = nil
				elseif name:sub(1, 1) ~= "." then
					local path = directory .. "/" .. name
					if kind == "directory" then
						table.insert(queue, path)
					elseif kind == "file" and name:lower():match("%.md$") then
						table.insert(files, path)
					end
				end
			end
		until vim.uv.hrtime() >= deadline
		vim.schedule(step)
	end
	vim.schedule(step)
end

function M.subgraph(graph, center, depth)
	if not center then
		return { nodes = {}, edges = {} }
	end
	local included, frontier = { [center] = true }, { center }
	for _ = 1, depth do
		local next_frontier = {}
		for _, node in ipairs(frontier) do
			for neighbor in pairs(node.neighbors) do
				if not included[neighbor] then
					included[neighbor] = true
					table.insert(next_frontier, neighbor)
				end
			end
		end
		frontier = next_frontier
	end
	local result = { nodes = {}, edges = {} }
	for _, node in ipairs(graph.nodes) do
		if included[node] then
			table.insert(result.nodes, node)
		end
	end
	for _, edge in ipairs(graph.edges) do
		if included[edge[1]] and included[edge[2]] then
			table.insert(result.edges, edge)
		end
	end
	return result
end

return M
