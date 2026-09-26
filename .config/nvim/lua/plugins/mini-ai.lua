return {
	"nvim-mini/mini.ai",
	opts = function(_, opts)
		-- `ig` is the git hunk textobject (gitsigns in tracked files, mini.diff in
		-- untracked ones), not "entire buffer".
		opts.custom_textobjects.g = false
	end,
}
