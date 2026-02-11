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
	},
})
vim.filetype.add({
	pattern = {
		[".*%.(%a+)##.*"] = function(_, _, capture)
			return capture
		end,
	},
})
vim.filetype.add({
	pattern = {
		[".*##.*e%.(%a+)$"] = function(_, _, capture)
			return capture
		end,
	},
})
vim.filetype.add({
	pattern = {
		[".*%.tpl%.yaml"] = "helm",
	},
})
