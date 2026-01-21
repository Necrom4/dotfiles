vim.opt.autowrite = false -- Enable auto write
vim.opt.hidden = true -- This makes vim act like all other editors, buffers can exist in the background without being in a window.
vim.opt.list = false -- Show some invisible characters (tabs...
vim.opt.scrolloff = 0 -- Lines of context
vim.opt.wrap = false -- Disable line wrap

if vim.fn.has("wsl") == 1 then
	vim.g.clipboard = {
		name = "WslClipboard",
		copy = {
			["+"] = "clip.exe",
			["*"] = "clip.exe",
		},
		paste = {
			["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
			["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
		},
		cache_enabled = 0,
	}
end

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
		[".*%.sh##.*"] = "sh",
	},
})
vim.filetype.add({
	pattern = {
		[".*%.zsh##.*"] = "zsh",
	},
})
vim.filetype.add({
	pattern = {
		[".*%.tpl%.yaml"] = "helm",
	},
})
