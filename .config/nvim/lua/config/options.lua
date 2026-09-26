vim.opt.autowrite = false -- Enable auto write
vim.opt.list = false -- Show some invisible characters (tabs...
vim.opt.scrolloff = 0 -- Lines of context
vim.opt.wrap = false -- Disable line wrap

vim.opt.shortmess:append("S")
vim.opt.spelllang = { "en", "fr", "pt" }

vim.filetype.add({
	pattern = {
		[".env.*"] = "sh",
		[".*%.(%a+)##.*"] = function(_, _, capture)
			return capture
		end,
		[".*##.*e%.(%a+)$"] = function(_, _, capture)
			return capture
		end,
		[".*%.yaml%.j2"] = "yamljinja",
		[".*%.yml%.j2"] = "yamljinja",
		[".*%.tpl%.yaml"] = "helm",
	},
})

vim.treesitter.language.register("jinja", "yamljinja")

-- Neovide
if vim.g.neovide then
	local is_mac = vim.fn.has("mac") == 1
	-- Window
	vim.g.neovide_opacity = 0.85
	vim.g.neovide_window_blurred = true
	-- Floating windows
	vim.g.neovide_floating_shadow = false
	-- Text
	vim.o.guifont = "CommitMono Nerd Font Mono,LegacyComputing:h" .. (is_mac and 16 or 10)
	vim.opt.linespace = 1
	-- Input
	vim.g.neovide_input_macos_option_key_is_meta = "only_left"
	vim.g.neovide_input_use_logo = is_mac
end
