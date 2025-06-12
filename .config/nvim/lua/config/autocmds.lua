local utils = require("core.utils")
local system_type = utils.system_type()

-- Persistent undo
vim.opt.undofile = true
local vimrc_undofile_augroup = vim.api.nvim_create_augroup("vimrc_undofile", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "/tmp/*",
	group = vimrc_undofile_augroup,
	command = "setlocal noundofile",
})

-- Yank to number registers
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		if vim.v.event.operator == "y" then
			-- Shift registers "9" to "2" down
			for i = 9, 2, -1 do
				vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
			end
			-- Store the new yank in register "1" (but don't touch "0")
			vim.fn.setreg("1", vim.fn.getreg('"'))
		end
	end,
})

-- Display table instead of binary in .sqlite files
vim.api.nvim_create_autocmd("BufReadPre", {
	pattern = "*.sqlite",
	callback = function()
		local filepath = vim.fn.expand("%:p")

		-- Get first table name
		local table_name = utils.term_cmd('sqlite3 "' .. filepath .. '" ".tables"'):match("(%S+)")
		if not table_name then
			vim.notify("No tables found in database.", vim.log.levels.WARN)
			return
		end

		-- Build SQL query
		local query = 'sqlite3 -header -column "' .. filepath .. '" "SELECT * FROM ' .. table_name .. ';"'

		-- Replace current buffer content with query result
		vim.schedule(function()
			vim.cmd("%delete _") -- delete all lines quietly
			local data = vim.fn.systemlist(query)
			if vim.v.shell_error ~= 0 or not data or #data == 0 then
				data = { "Error querying database." }
			end

			vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
			vim.bo.buftype = "nofile"
			vim.bo.bufhidden = "wipe"
			vim.bo.swapfile = false
			vim.bo.modifiable = false
			vim.bo.readonly = true
			vim.bo.filetype = "sql"
		end)
	end,
})
