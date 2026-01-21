return {
	"TheNoeTrevino/haunt.nvim",
	opts = {
		sign = "",
		annotation_prefix = "󰆉 ",
	},
	init = function()
		local haunt = require("haunt.api")
		local haunt_picker = require("haunt.picker")
		local map = vim.keymap.set
		local prefix = "<leader>a"

		-- annotations
		map("n", prefix .. "a", function()
			haunt.annotate()
		end, { desc = "Annotate" })

		map("n", prefix .. "t", function()
			haunt.toggle_annotation()
		end, { desc = "Toggle" })

		map("n", prefix .. "T", function()
			haunt.toggle_all_lines()
		end, { desc = "Toggle all" })

		map("n", prefix .. "d", function()
			haunt.delete()
		end, { desc = "Delete" })

		map("n", prefix .. "D", function()
			haunt.clear_all()
		end, { desc = "Delete all" })

		-- move
		map("n", "]n", function()
			haunt.prev()
		end, { desc = "Previous" })

		map("n", "[n", function()
			haunt.next()
		end, { desc = "Next" })

		-- picker
		map("n", "<leader>sA", function()
			haunt_picker.show()
		end, { desc = "Picker" })

		-- quickfix
		map("n", prefix .. "q", function()
			haunt.to_quickfix()
		end, { desc = "Quickfix" })

		map("n", prefix .. "Q", function()
			haunt.to_quickfix({ current_buffer = true })
		end, { desc = "Buffer Quickfix" })

		-- yank
		map("n", prefix .. "y", function()
			haunt.yank_locations({ current_buffer = true })
		end, { desc = "Yank" })

		map("n", prefix .. "Y", function()
			haunt.yank_locations()
		end, { desc = "Yank all" })
	end,
}
