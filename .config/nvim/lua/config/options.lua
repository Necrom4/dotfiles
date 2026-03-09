vim.opt.autowrite = false -- Enable auto write
vim.opt.hidden = true -- This makes vim act like all other editors, buffers can exist in the background without being in a window.
vim.opt.list = false -- Show some invisible characters (tabs...
vim.opt.scrolloff = 0 -- Lines of context
vim.opt.wrap = false -- Disable line wrap

vim.opt.spelllang = { "en", "fr", "pt" }

vim.diagnostic.config({
	signs = false,
})

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

vim.treesitter.language.register("yaml", "yamljinja")
