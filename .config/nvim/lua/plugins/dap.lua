return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "<leader>dB", false },
		{ "<leader>db", false },
		{ "<leader>dc", false },
		{ "<leader>da", false },
		{ "<leader>dC", false },
		{ "<leader>dg", false },
		{ "<leader>di", false },
		{ "<leader>dj", false },
		{ "<leader>dk", false },
		{ "<leader>dl", false },
		{ "<leader>do", false },
		{ "<leader>dO", false },
		{ "<leader>dP", false },
		{ "<leader>dr", false },
		{ "<leader>ds", false },
		{ "<leader>dt", false },
		{ "<leader>dw", false },
		{
			"<a-d><a-B>",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Breakpoint Condition",
		},
		{
			"<a-d><a-b>",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<a-d><a-c>",
			function()
				require("dap").continue()
			end,
			desc = "Run/Continue",
		},
		{
			"<a-d><a-a>",
			function()
				require("dap").continue({ before = get_args })
			end,
			desc = "Run with Args",
		},
		{
			"<a-d><a-C>",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to Cursor",
		},
		{
			"<a-d><a-g>",
			function()
				require("dap").goto_()
			end,
			desc = "Go to Line (No Execute)",
		},
		{
			"<a-d><a-i>",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<a-d><a-j>",
			function()
				require("dap").down()
			end,
			desc = "Down",
		},
		{
			"<a-d><a-k>",
			function()
				require("dap").up()
			end,
			desc = "Up",
		},
		{
			"<a-d><a-l>",
			function()
				require("dap").run_last()
			end,
			desc = "Run Last",
		},
		{
			"<a-d><a-o>",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<a-d><a-O>",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<a-d><a-P>",
			function()
				require("dap").pause()
			end,
			desc = "Pause",
		},
		{
			"<a-d><a-r>",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Toggle REPL",
		},
		{
			"<a-d><a-s>",
			function()
				require("dap").session()
			end,
			desc = "Session",
		},
		{
			"<a-d><a-t>",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<a-d><a-w>",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "Widgets",
		},
	},
}
