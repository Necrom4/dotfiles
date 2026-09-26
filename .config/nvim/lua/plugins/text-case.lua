return {
	"johmsalas/text-case.nvim",
	opts = {},
	keys = {
		{ "ga", mode = { "n", "x" } },
		{
			"ga.",
			function()
				local tc = require("textcase")
				local visual = vim.fn.mode():find("[vV\22]") ~= nil
				if visual then
					vim.api.nvim_feedkeys(vim.keycode("<esc>"), "nx", false)
				end
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
					if not choice then
						return
					elseif visual then
						vim.cmd("normal! gv")
						tc.visual(choice[2])
					else
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
