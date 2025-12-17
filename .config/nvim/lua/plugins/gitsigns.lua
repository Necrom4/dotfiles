return {
	"lewis6991/gitsigns.nvim",
	lazy = false,
	dependencies = {
		{
			"purarue/gitsigns-yadm.nvim",
			opts = {
				disable_inside_gitdir = false,
				on_yadm_attach = function()
					vim.b.yadm_tracked = true
					vim.b.minidiff_disable = true
				end,
			},
		},
	},
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 200,
		},
		_on_attach_pre = function(bufnr, callback)
			require("gitsigns-yadm").yadm_signs(callback, { bufnr = bufnr })
		end,
		on_attach = function(buffer)
			vim.b.minidiff_disable = true
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
			end

			map("n", "]g", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "Next Hunk")
			map("n", "[g", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "Prev Hunk")
			map("n", "]G", function()
				gs.nav_hunk("last")
			end, "Last Hunk")
			map("n", "[G", function()
				gs.nav_hunk("first")
			end, "First Hunk")
			map({ "n", "x" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
			map({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
			map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
			map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
			map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
			map("n", "<leader>gp", gs.preview_hunk_inline, "Preview Hunk Inline")
			map("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, "Blame Line")
			map("n", "<leader>gB", function()
				gs.blame()
			end, "Blame Buffer")
			map("n", "<leader>gd", gs.diffthis, "Diff This")
			map("n", "<leader>gD", function()
				gs.diffthis("~")
			end, "Diff This ~")
			map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
		end,
	},
}
