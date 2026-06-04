return {
	"johmsalas/text-case.nvim",
	opts = {},
	keys = {
		"ga",
		{
			"ga.",
			function()
				local tc = require("textcase")
				local methods = {
					{ "snake_case", "to_snake_case" },
					{ "camelCase", "to_camel_case" },
					{ "PascalCase", "to_pascal_case" },
					{ "CONSTANT_CASE", "to_constant_case" },
					{ "dash-case", "to_dash_case" },
					{ "dot.case", "to_dot_case" },
					{ "Title Case", "to_title_case" },
					{ "path/case", "to_path_case" },
					{ "phrase case", "to_phrase_case" },
				}
				vim.ui.select(methods, {
					prompt = "Convert case:",
					format_item = function(item)
						return item[1]
					end,
				}, function(choice)
					if choice then
						tc.current_word(choice[2])
					end
				end)
			end,
			mode = { "n", "x" },
			desc = "Text case",
		},
	},
	cmd = { "Subs", "TextCaseStartReplacingCommand" },
}
