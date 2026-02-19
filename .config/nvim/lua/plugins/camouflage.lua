local concealed = true
local concealed_line = true

return {
	"zeybek/camouflage.nvim",
	event = "VeryLazy",
	opts = function()
		Snacks.toggle({
			id = "comouflage_toggle",
			name = "values",
			get = function()
				return concealed
			end,
			set = function()
				concealed = not concealed
				vim.cmd("CamouflageToggle")
			end,
			icon = {
				enabled = " ",
				disabled = " ",
			},
			color = {
				enabled = "red",
				disabled = "azure",
			},
			wk_desc = {
				enabled = "Show ",
				disabled = "Conceal ",
			},
		}):map("<leader>ucC")

		Snacks.toggle({
			id = "comouflage_follow_cursor",
			name = "cursor line",
			get = function()
				return concealed_line
			end,
			set = function()
				concealed_line = not concealed_line
				vim.cmd("CamouflageFollowCursor")
			end,
			icon = {
				enabled = " ",
				disabled = " ",
			},
			color = {
				enabled = "red",
				disabled = "azure",
			},
			wk_desc = {
				enabled = "Show ",
				disabled = "Conceal ",
			},
		}):map("<leader>ucc")

		return {
			pwned = {
				enabled = false,
				sign_text = "",
			},
		}
	end,
	keys = {
		{
			"<leader>cP",
			function()
				vim.cmd("CamouflagePwnedCheckLine")
			end,
			desc = "Pwned?",
		},
	},
}
