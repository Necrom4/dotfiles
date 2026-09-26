return {
	"hat0uma/csvview.nvim",
	init = function()
		require("utils.general").on_very_lazy(function()
			Snacks.toggle
				.new({
					id = "csv",
					name = "CsvView",
					get = function()
						return package.loaded["csvview"] ~= nil and require("csvview").is_enabled()
					end,
					set = function()
						-- Put the cursor on a delimiter to force it; otherwise csvview auto-detects.
						local char = vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col("."))
						local cmd = "CsvViewToggle display_mode=border header_lnum=1"
						if char:match("^[%p ]$") then
							cmd = cmd .. " delimiter=" .. (char == " " and "\\ " or char)
						end
						vim.cmd(cmd)
					end,
					icon = {
						enabled = " ",
						disabled = " ",
					},
					color = {
						enabled = "green",
						disabled = "yellow",
					},
					wk_desc = {
						enabled = "Disable ",
						disabled = "Enable ",
					},
				})
				:map("<leader>uv")
		end)
	end,
	opts = function()
		return {
			parser = { comments = { "#", "//" } },
			keymaps = {
				-- Text objects for selecting fields
				textobject_field_inner = { "if", mode = { "o", "x" } },
				textobject_field_outer = { "af", mode = { "o", "x" } },
				-- Excel-like navigation:
				-- Use <Tab> and <S-Tab> to move horizontally between fields.
				-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
				-- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
				jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
				jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
				jump_next_row = { "<Enter>", mode = { "n", "v" } },
				jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
			},
		}
	end,
	ft = {
		"csv",
		"tsv",
		"csv_semicolon",
		"csv_whitespace",
		"csv_pipe",
		"rfc_csv",
		"rfc_semicolon",
	},
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
}
