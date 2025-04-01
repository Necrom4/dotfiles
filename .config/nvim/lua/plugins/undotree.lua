return {
	"mbbill/undotree",
	config = function()
		vim.g.undotree_WindowLayout = 2
		vim.g.undotree_ShortIndicators = 1
		vim.g.undotree_TreeNodeShape = ""
		vim.g.undotree_TreeVertShape = "│"
	end,
	keys = {
		{
			"<leader>uu",
			function()
				-- Check if an UndoTree buffer exists and is visible
				local undotree_open = false
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "undotree" then
						undotree_open = true
						break
					end
				end

				-- Toggle UndoTree
				vim.cmd("UndotreeToggle")

				-- Send notification based on new state
				local status = undotree_open and "Disabled" or "Enabled"
				local log_level = undotree_open and vim.log.levels.WARN or vim.log.levels.INFO
				vim.notify(status .. " **Undotree**", log_level, { title = "Undotree" })
			end,
			desc = "Toggle Undotree",
			silent = true,
		},
	},
}
