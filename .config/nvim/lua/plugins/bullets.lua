return {
	"bullets-vim/bullets.vim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	keys = {
		{
			"<a-x>",
			"<Plug>(bullets-toggle-checkbox)",
			ft = "markdown",
			silent = true,
		},
	},
	config = function()
		-- Disable deleting the last empty bullet when pressing <cr> or 'o'
		-- default = 1
		vim.g.bullets_delete_last_bullet_if_empty = 1
		vim.g.bullets_pad_right = 2
	end,
}
