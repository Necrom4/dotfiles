-- Extends LazyVim's editor.dial extra, which provides the keymaps, the base
-- augend groups and appends the default group to every filetype group.
return {
	"monaqa/dial.nvim",
	opts = function(_, opts)
		local augend = require("dial.augend")

		local make_const = function(elements, word)
			return augend.constant.new({
				elements = elements,
				word = word ~= false,
				cyclic = true,
			})
		end

		vim.list_extend(opts.groups.default, {
			make_const({ "enable", "disable" }),
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
			make_const({ "✔", "❌" }, false),
			make_const({ "add", "remove" }),
			make_const({ "Add", "Remove" }),
			make_const({ "active", "inactive" }),
			make_const({ "Active", "Inactive" }),
			make_const({ "dev", "test", "staging", "prod", "production" }),
			make_const({ "draft", "published" }),
			make_const({ "Draft", "Published" }),
			make_const({ "read", "write", "execute" }),
			make_const({ "run", "build", "deploy" }),
			make_const({ "Run", "Build", "Test", "Deploy" }),
			make_const({ "light", "dark" }),
			make_const({ "Light", "Dark" }),
			make_const({ "==", "!=" }, false),
		})

		-- "and"/"or" now lives in default, which the extra appends to every group.
		-- Filetype augends come first, so `==` cycles to `~=` in lua.
		opts.groups.lua = { make_const({ "==", "~=" }, false) }
		opts.groups.python = nil
		opts.dials_by_ft.python = nil
	end,
}
