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

		map("n", "<leader>uN", function()
			haunt.toggle_all_lines()
		end, { desc = "Toggle Annotations" })

		map("n", prefix .. "d", function()
			haunt.delete()
		end, { desc = "Delete" })

		map("n", prefix .. "D", function()
			haunt.clear_all()
		end, { desc = "Delete all" })

		-- move
		map("n", "]n", function()
			haunt.prev()
		end, { desc = "Previous Annotation" })

		map("n", "[n", function()
			haunt.next()
		end, { desc = "Next Annotation" })

		-- picker
		map("n", "<leader>sA", function()
			haunt_picker.show()
		end, { desc = "Annotations" })

		-- quickfix
		map("n", "<leader>Qa", function()
			haunt.to_quickfix()
		end, { desc = "Annotations" })

		map("n", "<leader>QA", function()
			haunt.to_quickfix({ current_buffer = true })
		end, { desc = "Buffer Annotations" })

		-- yank
		map("n", prefix .. "y", function()
			haunt.yank_locations({ current_buffer = true })
		end, { desc = "Yank" })

		map("n", prefix .. "Y", function()
			haunt.yank_locations()
		end, { desc = "Yank all" })
	end,
}
