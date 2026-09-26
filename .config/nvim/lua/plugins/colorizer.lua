return {
	"catgoose/nvim-colorizer.lua",
	event = "LazyFile",
	opts = function()
		Snacks.toggle({
			id = "colorizer",
			name = "Colorizer",
			get = function()
				return require("colorizer").is_buffer_attached(0)
			end,
			set = function(state)
				if state then
					require("colorizer").attach_to_buffer(0)
				else
					require("colorizer").detach_from_buffer(0)
				end
			end,
		}):map("<leader>uC")

		return {
			lazy_load = true,
			filetypes = { "*", "!bigfile" },
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
				always_update = false,
			},
		}
	end,
}
