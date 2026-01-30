return {
	"folke/todo-comments.nvim",
	opts = {
		keywords = {
			TEST = { icon = " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
		},
	},
	keys = {
		{ "<leader>xt", false },
		{ "<leader>xT", false },
		{ "<leader>Qt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
		{
			"<leader>QT",
			"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
			desc = "Todo/Fix/Fixme (Trouble)",
		},
	},
}
