return {
	"hat0uma/csvview.nvim",
	opts = function()
		Snacks.toggle
			.new({
				id = "csv",
				name = "CsvView",
				get = function()
					return require("csvview").is_enabled()
				end,
				set = function(state)
					local delimiter = vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col("."))
					if delimiter and delimiter ~= "" then
						vim.cmd(
							string.format("CsvViewToggle display_mode=border header_lnum=1 delimiter=%s", delimiter)
						)
					end
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
			:map("<leader>ux")
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
