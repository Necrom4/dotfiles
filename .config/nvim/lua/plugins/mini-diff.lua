return {
	"nvim-mini/mini.diff",
	version = false,
	config = function()
		local MiniDiff = require("mini.diff")

		MiniDiff.setup({
			view = {
				style = "sign",
				signs = {
					add = "┆",
					change = "┆",
					delete = "┄",
				},
			},
			source = MiniDiff.gen_source.save(),
			mappings = {
				goto_prev = "[g",
				goto_next = "]g",
			},
		})
	end,
}
