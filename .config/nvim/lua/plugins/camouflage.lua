local function camouflage()
	return package.loaded.camouflage
end

return {
	"zeybek/camouflage.nvim",
	ft = {
		"env",
		"json",
		"toml",
		"yaml",
	},
	init = function()
		require("utils.general").on_very_lazy(function()
			Snacks.toggle({
				id = "camouflage_toggle",
				name = "values",
				get = function()
					return not camouflage() or camouflage().is_enabled()
				end,
				set = function()
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
				id = "camouflage_follow_cursor",
				name = "cursor line",
				get = function()
					return not camouflage() or not camouflage().is_follow_cursor_enabled()
				end,
				set = function()
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
		end)
	end,
	cmd = { "CamouflageToggle", "CamouflageFollowCursor", "CamouflagePwnedCheckLine" },
	opts = {
		checks = {
			pwned = {
				enabled = false,
				sign_text = "",
			},
		},
	},
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
