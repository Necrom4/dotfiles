-- Turn the selection (or the word under the cursor) into a markdown link.
-- Take the URL from: "x prefix register > clipboard (if it is a URL) > register picker
local markdown_link = require("utils.markdown_link")

vim.keymap.set({ "x", "n" }, "gsl", function()
	markdown_link.link()
end, { buffer = true, desc = "Surround with markdown link (clipboard)" })
vim.keymap.set({ "x", "n" }, "gsL", function()
	markdown_link.link({ pick = true })
end, { buffer = true, desc = "Surround with markdown link (pick register)" })

-- Promote/demote headers with < and > (counts work: 2> adds two #).
-- Anything that is not an ATX header falls through to the normal < / > behaviour
-- (including bullets.nvim's list promote/demote).
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

local function shift_header(delta, bullets_action, fallback)
	return function()
		local lnum = vim.fn.line(".")
		local level = header_level(lnum)
		if not level then
			local ok, actions = pcall(require, "bullets.actions")
			if ok and actions[bullets_action]() then
				return
			end
			return vim.cmd("normal! " .. vim.v.count1 .. fallback)
		end
		local new = level + delta * vim.v.count1
		if new < 1 or new > 6 then
			return vim.notify(("Header level must stay between 1 and 6 (h%d)"):format(level), vim.log.levels.INFO)
		end
		local line = vim.api.nvim_get_current_line()
		vim.api.nvim_set_current_line(string.rep("#", new) .. line:sub(level + 1))
	end
end

vim.keymap.set("n", ">", shift_header(1, "demote", ">>"), { buffer = true, desc = "Demote header / indent" })
vim.keymap.set("n", "<", shift_header(-1, "promote", "<<"), { buffer = true, desc = "Promote header / indent" })
