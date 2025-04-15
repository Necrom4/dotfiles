return {
	"folke/todo-comments.nvim",
	keys = {
		{ "<leader>xt", false },
		{ "<leader>xT", false },
		{ "<leader>Xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
		{
			"<leader>XT",
			"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
			desc = "Todo/Fix/Fixme (Trouble)",
		},
	},
}
