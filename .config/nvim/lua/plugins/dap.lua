return {
	{
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
			{ "<leader>td", false },
			{
				"<a-d>B",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Breakpoint Condition",
			},
			{
				"<a-d>b",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<a-d>c",
				function()
					require("dap").continue()
				end,
				desc = "Run/Continue",
			},
			{
				"<a-d>a",
				function()
					require("dap").continue({ before = get_args })
				end,
				desc = "Run with Args",
			},
			{
				"<a-d>C",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<a-d>g",
				function()
					require("dap").goto_()
				end,
				desc = "Go to Line (No Execute)",
			},
			{
				"<a-d>i",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<a-d>j",
				function()
					require("dap").down()
				end,
				desc = "Down",
			},
			{
				"<a-d>k",
				function()
					require("dap").up()
				end,
				desc = "Up",
			},
			{
				"<a-d>l",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<a-d>o",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<a-d>O",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<a-d>P",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
			},
			{
				"<a-d>r",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<a-d>s",
				function()
					require("dap").session()
				end,
				desc = "Session",
			},
			{
				"<a-d>t",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<a-d>w",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Widgets",
			},
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		keys = {
			{ "<leader>du", false },
			{ "<leader>de", mode = { "n", "v" }, false },
			{
				"<a-d>u",
				function()
					require("dapui").toggle({})
				end,
				desc = "Dap UI",
			},
			{
				"<a-d>e",
				function()
					require("dapui").eval()
				end,
				desc = "Eval",
				mode = { "n", "v" },
			},
		},
	},
}
