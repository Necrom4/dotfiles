local detach_hook_registered = false

return {
	"lewis6991/gitsigns.nvim",
	event = "LazyFile",
	dependencies = {
		{
			"purarue/gitsigns-yadm.nvim",
			opts = {
				disable_inside_gitdir = false,
				on_yadm_attach = function(event)
					if vim.b[event.bufnr].minidiff_untracked then
						return
					end
					vim.b[event.bufnr].yadm_tracked = true
					vim.b[event.bufnr].minidiff_disable = true
					if package.loaded["mini.diff"] then
						require("mini.diff").disable(event.bufnr)
					end
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
		},
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 500,
		},
		_on_attach_pre = function(bufnr, callback)
			require("gitsigns-yadm").yadm_signs(callback, { bufnr = bufnr })
		end,
		on_attach = function(buffer)
			-- An old asynchronous attach can finish after a tracking-status refresh.
			if vim.b[buffer].minidiff_untracked then
				return false
			end
			if not detach_hook_registered then
				detach_hook_registered = true
				require("gitsigns.manager").on_detach(function(buf)
					if vim.api.nvim_buf_is_valid(buf) then
						vim.b[buf].minidiff_gitsigns_attached = false
					end
				end)
			end
			vim.b[buffer].minidiff_gitsigns_attached = true
			vim.b[buffer].minidiff_disable = true
			if package.loaded["mini.diff"] then
				require("mini.diff").disable(buffer)
			end
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
			map("n", "<leader>gu", gs.stage_hunk, "Toggle Stage Hunk")
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
