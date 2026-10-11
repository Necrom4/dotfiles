return {
	"bullets-vim/bullets.nvim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	opts = {
		enabled_file_types = { "markdown", "text", "gitcommit", "scratch" },
		checkbox_markers = " /x",
		-- Alt-x owns task mutation; keep list helpers without stealing <leader>x.
		set_mappings = false,
		nested_checkboxes = false,
		custom_mappings = {
			{ "i", "<CR>", "<Plug>(bullets-newline)" },
			{ "i", "<C-CR>", "<CR>" },
			{ "n", "o", "<Plug>(bullets-newline)" },
			{ "n", "gN", "<Plug>(bullets-renumber)" },
			{ "x", "gN", "<Plug>(bullets-renumber)" },
			{
				"i",
				"<C-t>",
				function()
					if not require("bullets.actions").demote() then
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "in", false)
					end
				end,
			},
			{
				"i",
				"<C-d>",
				function()
					if not require("bullets.actions").promote() then
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "in", false)
					end
				end,
			},
			{
				"n",
				">>",
				function()
					if not require("bullets.actions").demote() then
						vim.cmd("normal! >>")
					end
				end,
			},
			{
				"n",
				"<<",
				function()
					if not require("bullets.actions").promote() then
						vim.cmd("normal! <<")
					end
				end,
			},
		},
	},
	keys = {
		{
			"<a-x>",
			function()
				require("utils.markdown_tasks").cycle()
			end,
			ft = "markdown",
			desc = "Cycle task and update parent/child tasks",
			silent = true,
		},
	},
}
