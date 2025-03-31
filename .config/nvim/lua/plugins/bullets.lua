return {
	"bullets-vim/bullets.vim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	config = function()
		-- Disable deleting the last empty bullet when pressing <cr> or 'o'
		-- default = 1
		vim.g.bullets_delete_last_bullet_if_empty = 1
	end,
}
