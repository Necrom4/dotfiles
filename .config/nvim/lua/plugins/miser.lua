return {
	"carldaws/miser.nvim",
	config = function()
		require("miser").setup({
			-- LazyVim (conform / LSP, <leader>cf) already handles formatting
			auto_format = false,
		})
	end,
}
