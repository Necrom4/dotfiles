return {
	{
		"catppuccin/nvim",
		enabled = false,
	},
	-- refactoring.nvim uses the built-in `vim.async` on Neovim >= 0.13, so
	-- LazyVim's async.nvim dependency is only needed (with config/async_shim.lua)
	-- on 0.12. Keeping it off on 0.13 stops it shadowing promise-async's `async`.
	{
		"lewis6991/async.nvim",
		enabled = vim.fn.has("nvim-0.13") == 0,
	},
}
