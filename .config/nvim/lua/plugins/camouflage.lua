return {
	"zeybek/camouflage.nvim",
	event = "VeryLazy",
	opts = {
		pwned = {
			enabled = false,
			sign_text = "",
		},
	},
	keys = {
		{ "<leader>uct", "<cmd>CamouflageToggle<cr>", desc = "Toggle Camouflage" },
		{ "<leader>ucr", "<cmd>CamouflageReveal<cr>", desc = "Reveal Line" },
		{ "<leader>ucy", "<cmd>CamouflageYank<cr>", desc = "Yank Value" },
		{ "<leader>ucf", "<cmd>CamouflageFollowCursor<cr>", desc = "Follow Cursor" },
		{
			"<leader>cP",
			function()
				-- vim.cmd("Sandman temp-net 1000")
				vim.cmd("CamouflagePwnedCheckLine")
			end,
			desc = "Pwned?",
		},
	},
}
