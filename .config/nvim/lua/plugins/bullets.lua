return {
	"bullets-vim/bullets.nvim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	init = function()
		-- its plugin/ file would run setup() with the defaults (incl. >> / << maps) before ours
		vim.g.loaded_bullets_nvim = true
	end,
	opts = {
		enabled_file_types = { "markdown", "text", "gitcommit", "scratch" },
		checkbox_markers = " /x",
		-- Remove defaults that nest into a. / A. / i. / I., which Markdown doesn't
		-- render.
		outline_levels = { "num", "std-", "std*", "std+" },
		-- Alt-x owns task mutation; < / > are in config/keymaps.lua
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
		},
	},
}
