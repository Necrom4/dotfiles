return {
	"lewis6991/gitsigns.nvim",
	event = { "VeryLazy" },
	dependencies = {
		{
			"purarue/gitsigns-yadm.nvim",
			opts = {
				on_yadm_attach = function()
					vim.b.yadm_tracked = true
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
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]g", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]g", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { desc = "Next Hunk" })

			map("n", "[g", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[g", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { desc = "Previous Hunk" })

			-- Actions
			map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage Hunk" })
			map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset Hunk" })
			map("v", "<leader>gs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Stage Hunk" })
			map("v", "<leader>gr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Reset Hunk" })
			map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage Buffer" })
			map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo Stage Hunk" })
			map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset Buffer" })
			map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview Hunk" })
			map("n", "<leader>gP", function()
				gitsigns.blame_line({ full = true })
			end, { desc = "Blame Line" })
			map("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
			map("n", "<leader>gd", gitsigns.toggle_deleted, { desc = "Toggle Deleted" })

			-- Text object
			map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
		end,
	},
}
