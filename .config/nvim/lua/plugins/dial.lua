return {
	"monaqa/dial.nvim",
	recommended = true,
	desc = "Increment and decrement numbers, dates, and more",
  -- stylua: ignore
  keys = {
    { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, desc = "Increment", mode = {"n"} },
    { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, desc = "Decrement", mode = {"n"} },
    { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, desc = "Increment", mode = {"v"} },
    { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, desc = "Decrement", mode = {"v"} },
  },
	opts = function()
		local augend = require("dial.augend")

		-- Define many togglable constants
		local make_const = function(elements, word)
			return augend.constant.new({
				elements = elements,
				word = word or true,
				cyclic = true,
			})
		end

		return {
			dials_by_ft = {
				css = "css",
				vue = "vue",
				javascript = "typescript",
				typescript = "typescript",
				typescriptreact = "typescript",
				javascriptreact = "typescript",
				json = "json",
				lua = "lua",
				markdown = "markdown",
				sass = "css",
				scss = "css",
				python = "python",
			},
			groups = {
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.decimal_int,
					augend.integer.alias.hex,
					augend.date.alias["%Y/%m/%d"],
					make_const({
						"first",
						"second",
						"third",
						"fourth",
						"fifth",
						"sixth",
						"seventh",
						"eighth",
						"ninth",
						"tenth",
					}, false),
					make_const({ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }),
					make_const({
						"January",
						"February",
						"March",
						"April",
						"May",
						"June",
						"July",
						"August",
						"September",
						"October",
						"November",
						"December",
					}),
					make_const({ "True", "False" }),
					make_const({ "true", "false" }),
					make_const({ "enable", "disable" }),
					make_const({ "enabled", "disabled" }),
					make_const({ "Enabled", "Disabled" }),
					make_const({ "on", "off" }),
					make_const({ "yes", "no" }),
					make_const({ "Yes", "No" }),
					make_const({ "and", "or" }),
					make_const({ "show", "hide" }),
					make_const({ "visible", "hidden" }),
					make_const({ "Visible", "Hidden" }),
					make_const({ "start", "stop" }),
					make_const({ "Start", "Stop" }),
					make_const({ "success", "failure" }),
					make_const({ "pass", "fail" }),
					make_const({ "Pass", "Fail" }),
					make_const({ "high", "medium", "low" }),
					make_const({ "todo", "doing", "done" }),
					make_const({ "TODO", "DOING", "DONE" }),
					make_const({ "✔️", "❌" }),
					make_const({ "add", "remove" }),
					make_const({ "Add", "Remove" }),
					make_const({ "active", "inactive" }),
					make_const({ "Active", "Inactive" }),
					make_const({ "dev", "test", "staging", "prod", "production" }),
					make_const({ "draft", "published" }),
					make_const({ "Draft", "Published" }),
					make_const({ "read", "write", "execute" }),
					make_const({ "run", "build", "test", "deploy" }),
					make_const({ "Run", "Build", "Test", "Deploy" }),
					make_const({ "light", "dark" }),
					make_const({ "Light", "Dark" }),
					augend.constant.alias.bool,
					augend.constant.new({
						elements = { "&&", "||" },
						word = false,
						cyclic = true,
					}),
					augend.constant.new({
						elements = { "==", "!=" },
						word = false,
						cyclic = true,
					}),
					augend.constant.new({
						elements = { "==", "~=" },
						word = false,
						cyclic = true,
					}),
				},
				vue = {
					make_const({ "let", "const" }),
					augend.hexcolor.new({ case = "lower" }),
					augend.hexcolor.new({ case = "upper" }),
				},
				typescript = {
					make_const({ "let", "const" }),
				},
				css = {
					augend.hexcolor.new({ case = "lower" }),
					augend.hexcolor.new({ case = "upper" }),
				},
				markdown = {
					augend.constant.new({
						elements = { "[ ]", "[x]" },
						word = false,
						cyclic = true,
					}),
					augend.misc.alias.markdown_header,
				},
				json = {
					augend.semver.alias.semver,
				},
				lua = {
					make_const({ "and", "or" }),
				},
				python = {
					make_const({ "and", "or" }),
				},
			},
		}
	end,
	config = function(_, opts)
		-- copy defaults to each group
		for name, group in pairs(opts.groups) do
			if name ~= "default" then
				vim.list_extend(group, opts.groups.default)
			end
		end
		require("dial.config").augends:register_group(opts.groups)
		vim.g.dials_by_ft = opts.dials_by_ft
	end,
}
