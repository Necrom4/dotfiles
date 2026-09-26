return {
	"crnvl96/lazydocker.nvim",
	keys = {
		{
			"<leader>td",
			function()
				local file = vim.api.nvim_buf_get_name(0)
				if vim.bo.buftype ~= "" or file == "" or not vim.uv.fs_stat(file) then
					return require("lazydocker").toggle()
				end

				-- lazydocker filters containers by the stack in its cwd, and the plugin has no cwd option:
				-- its terminal float inherits the window-local dir, so set it temporarily and restore it after.
				local win = vim.api.nvim_get_current_win()
				local had_lcd = vim.fn.haslocaldir() == 1
				local had_tcd = vim.fn.haslocaldir(-1, 0) == 1
				local prev = vim.fn.getcwd()
				vim.cmd("noautocmd lcd " .. vim.fn.fnameescape(vim.fs.dirname(file)))
				local ok, err = pcall(require("lazydocker").toggle)
				vim.api.nvim_win_call(win, function()
					local cmd = had_lcd and "lcd" or had_tcd and "tcd" or "cd"
					vim.cmd("noautocmd " .. cmd .. " " .. vim.fn.fnameescape(prev))
				end)
				if not ok then
					error(err)
				end
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
