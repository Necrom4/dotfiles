-- Promote/demote ATX headers (# Title) in markdown. Other lines fall through
-- to bullets.nvim's list promote/demote, then to plain << / >>.
local M = {}

local function header_level(lnum)
	local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
	local hashes = line:match("^(#+)%s") or line:match("^(#+)$")
	if not hashes or #hashes > 6 then
		return nil
	end
	-- skip "# comments" inside fenced code blocks
	local parser_ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
	if parser_ok and parser then
		parser:parse()
	end
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = 0, pos = { lnum - 1, 0 } })
	if ok and node then
		while node do
			if node:type() == "atx_heading" then
				return #hashes
			end
			if node:type() == "fenced_code_block" or node:type() == "indented_code_block" then
				return nil
			end
			node = node:parent()
		end
		return nil
	end
	return #hashes
end

---@param delta 1|-1 1 = demote (add a #), -1 = promote (remove a #)
function M.shift(delta)
	local level = vim.bo.filetype == "markdown" and header_level(vim.fn.line("."))
	if not level then
		local ok, actions = pcall(require, "bullets.actions")
		if ok and actions[delta > 0 and "demote" or "promote"]() then
			return
		end
		return vim.cmd("normal! " .. vim.v.count1 .. (delta > 0 and ">>" or "<<"))
	end
	local new = level + delta * vim.v.count1
	if new < 1 or new > 6 then
		return vim.notify(("Header level must stay between 1 and 6 (h%d)"):format(level), vim.log.levels.INFO)
	end
	local line = vim.api.nvim_get_current_line()
	vim.api.nvim_set_current_line(string.rep("#", new) .. line:sub(level + 1))
end

return M
