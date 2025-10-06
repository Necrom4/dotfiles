return {
	"nvim-neotest/neotest",
	dependencies = {
		"zidhuss/neotest-minitest",
	},
	opts = {
		adapters = {
			["neotest-minitest"] = {},
		},
		icons = {
			child_indent = "│",
			child_prefix = "├",
			collapsed = "─",
			expanded = "╮",
			failed = "",
			final_child_indent = " ",
			final_child_prefix = "╰",
			non_collapsible = "─",
			notify = "",
			passed = "",
			running = "",
			running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
			skipped = "◌",
			unknown = "",
			watching = "",
		},
	},
	keys = {
		{ "<leader>t", false },
		{ "<leader>tt", false },
		{ "<leader>tT", false },
		{ "<leader>tr", false },
		{ "<leader>tl", false },
		{ "<leader>ts", false },
		{ "<leader>to", false },
		{ "<leader>tO", false },
		{ "<leader>tS", false },
		{ "<leader>tw", false },
		{ "<a-t>", "", desc = "+test" },
		{
			"<a-t>t",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run File",
		},
		{
			"<a-t>T",
			function()
				require("neotest").run.run(vim.uv.cwd())
			end,
			desc = "Run All Test Files",
		},
		{
			"<a-t>r",
			function()
				require("neotest").run.run()
			end,
			desc = "Run Nearest",
		},
		{
			"<a-t>l",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Run Last",
		},
		{
			"<a-t>s",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle Summary",
		},
		{
			"<a-t>o",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Show Output",
		},
		{
			"<a-t>O",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Toggle Output Panel",
		},
		{
			"<a-t>S",
			function()
				require("neotest").run.stop()
			end,
			desc = "Stop",
		},
		{
			"<a-t>w",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "Toggle Watch",
		},
	},
}
