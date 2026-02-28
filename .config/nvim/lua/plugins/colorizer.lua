local colored = true

return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = function()
		Snacks.toggle({
			id = "colorizer",
			name = "Colorizer",
			get = function()
				return colored
			end,
			set = function()
				colored = not colored
				vim.cmd("ColorizerToggle")
			end,
		}):map("<leader>uC")

		return {
			lazy_load = true,
			options = {
				parsers = {
					css = true,
					hex = {
						rrggbbaa = true,
						aarrggbb = true,
					},
					tailwind = {
						enable = true,
						lsp = true,
					},
					sass = {
						enable = true,
					},
					xterm = { enable = true },
				},
				always_update = true,
			},
		}
	end,
}
