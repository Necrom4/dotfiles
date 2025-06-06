return {
	"crnvl96/lazydocker.nvim",
	lazy = true,
	dependencies = { "MunifTanjim/nui.nvim" },
	keys = {
		{
			"<leader>td",
			function()
				if vim.api.nvim_buf_get_name(0) ~= "" then -- Check if there's at least one buffer
					vim.api.nvim_exec2("cd %:h", { output = false }) -- switch to current directory so that Lazydocker filters containers from current stack
				end

				require("lazydocker").toggle()
			end,
			desc = "Open LazyDocker",
		},
	},
	opts = {
		window = {
			settings = {
				width = 0.9,
				height = 0.9,
			},
		},
	},
}
