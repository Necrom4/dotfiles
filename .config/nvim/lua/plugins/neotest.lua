return {
	"nvim-neotest/neotest",
	opts = {},
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
			desc = "Run File (Neotest)",
		},
		{
			"<a-t>T",
			function()
				require("neotest").run.run(vim.uv.cwd())
			end,
			desc = "Run All Test Files (Neotest)",
		},
		{
			"<a-t>r",
			function()
				require("neotest").run.run()
			end,
			desc = "Run Nearest (Neotest)",
		},
		{
			"<a-t>l",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Run Last (Neotest)",
		},
		{
			"<a-t>s",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle Summary (Neotest)",
		},
		{
			"<a-t>o",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Show Output (Neotest)",
		},
		{
			"<a-t>O",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Toggle Output Panel (Neotest)",
		},
		{
			"<a-t>S",
			function()
				require("neotest").run.stop()
			end,
			desc = "Stop (Neotest)",
		},
		{
			"<a-t>w",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "Toggle Watch (Neotest)",
		},
	},
}
