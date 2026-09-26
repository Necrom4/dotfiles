local save_dir = "~/Desktop"

local function snap_path()
	return vim.fn.expand(save_dir) .. "/CodeSnap_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
end

local function exit_visual()
	vim.api.nvim_feedkeys(vim.keycode("<esc>"), "nx", false)
end

-- CodeSnapHighlightSave is a no-op upstream (`save_highlight` is empty), so mirror `copy_highlight` but save
local function save_highlight(path)
	local config_module = require("codesnap.config")
	local ok, original = pcall(config_module.get_config)
	if not ok or not original or not original.content or not original.content.content then
		vim.notify(tostring(original or "No code is selected"), vim.log.levels.ERROR)
		return
	end
	local config = vim.deepcopy(original)

	require("codesnap.modal").pop_modal(config.content.content, vim.bo.filetype, function(selection)
		if not selection then
			return
		end
		local lines = vim.split(config.content.content, "\n", { plain = true })
		if selection[1] < 1 or selection[2] > #lines or selection[1] > selection[2] then
			vim.notify("Invalid selection range", vim.log.levels.ERROR)
			return
		end
		config.content.highlight_lines = {
			{ selection[1], selection[2], require("codesnap.static").config.highlight_color },
		}
		local saved, err = pcall(require("codesnap.module").load_generator().save, path, config)
		vim.cmd("delmarks <>")
		if saved then
			vim.notify("Save snapshot in " .. path .. " successfully")
		else
			vim.notify(tostring(err), vim.log.levels.ERROR)
		end
	end)
end

return {
	"mistricky/codesnap.nvim",
	keys = {
		{ "<leader>csc", "<esc><cmd>CodeSnap<cr>", mode = "x", desc = "To clipboard" },
		{
			"<leader>css",
			function()
				exit_visual()
				vim.cmd.CodeSnapSave(snap_path())
			end,
			mode = "x",
			desc = "Save to ~/Desktop",
		},
		{ "<leader>csvc", "<esc><cmd>CodeSnapHighlight<cr>", mode = "x", desc = "To clipboard with highlight" },
		{
			"<leader>csvs",
			function()
				exit_visual()
				save_highlight(snap_path())
			end,
			mode = "x",
			desc = "Save to ~/Desktop with highlight",
		},
		{ "<leader>csa", "<esc><cmd>CodeSnapASCII<cr>", mode = "x", desc = "Copy as text" },
	},
	opts = {
		show_line_number = true,
		show_workspace = true,
		snapshot_config = {
			window = {
				mac_window_bar = false,
				margin = { x = 0, y = 0 },
			},
			code_config = {
				font_family = "CommitMono Nerd Font Mono",
				breadcrumbs = {
					enable = true,
					separator = "/",
					font_family = "CommitMono Nerd Font Mono",
				},
			},
			watermark = {
				content = "Necrom",
			},
		},
	},
}
