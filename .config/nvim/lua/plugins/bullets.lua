local function cycle_checkbox_state()
	local line = vim.api.nvim_get_current_line()
	local prefix, marker, suffix = line:match("^([ \t]*[-+*] +%[)([ x%-])(%].*)$")
	if not marker then
		return
	end

	local next_marker = { [" "] = "-", ["-"] = "x", x = " " }
	vim.api.nvim_set_current_line(prefix .. next_marker[marker] .. suffix)
end

return {
	"bullets-vim/bullets.nvim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	opts = {
		enabled_file_types = { "markdown", "text", "gitcommit", "scratch" },
		checkbox_markers = " -x",
	},
	keys = {
		{
			"<a-x>",
			cycle_checkbox_state,
			ft = "markdown",
			desc = "Cycle checkbox state",
			silent = true,
		},
	},
}
