return {
	"Wansmer/treesj",
	keys = {
		{ "gl", ":TSJToggle<CR>", desc = "Toggle line form" },
	},
	opts = {
		use_default_keymaps = false,
		max_join_length = 1000,
		langs = {
			sql = {
				array = {
					both = {
						omit = { "array", "[", "]" },
					},
					split = {
						separator = ",",
						inner_indent = "normal",
						last_indent = "inner",
					},
					join = {
						space_in_brackets = true,
						separator = ", ",
					},
				},
			},
		},
	},
}
