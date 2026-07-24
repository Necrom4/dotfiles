vim.opt.autowrite = false -- Enable auto write
vim.opt.hidden = true -- This makes vim act like all other editors, buffers can exist in the background without being in a window.
vim.opt.list = false -- Show some invisible characters (tabs...
vim.opt.scrolloff = 0 -- Lines of context
vim.opt.wrap = false -- Disable line wrap

-- LazyVim defaults foldmethod to "indent", which makes Neovim scan the whole buffer
-- for indentation when a window first displays it -- a ~1s stall when opening huge
-- files. ufo manages folds itself with foldmethod=manual, so the global "indent" only
-- ever applies transiently before ufo attaches; make the default "manual" to skip the
-- scan. (Normal-file folding is unaffected -- ufo still provides it.)
vim.opt.foldmethod = "manual"

vim.opt.shortmess:append("S")
vim.opt.spelllang = { "en", "fr", "pt" }
vim.diagnostic.config({ signs = false })

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

-- Big files: disable per-buffer features BEFORE the read so they don't add to it.
-- undofile hashes the whole file (sha256) on read and swapfile churns it to disk;
-- on huge files that adds ~1s to opening. snacks `bigfile` runs post-read (too late for
-- the read itself), and config/autocmds.lua only loads on VeryLazy (after the launch
-- file is already read) -- so this guard lives in options.lua, which loads before the
-- first file is opened. Threshold matches snacks bigfile (1.5MB).
vim.api.nvim_create_autocmd("BufReadPre", {
	group = vim.api.nvim_create_augroup("bigfile_preread", { clear = true }),
	callback = function(ev)
		local ok, stat = pcall(vim.uv.fs_stat, ev.match)
		if ok and stat and stat.size > 1.5 * 1024 * 1024 then
			vim.bo[ev.buf].undofile = false
			vim.bo[ev.buf].swapfile = false
		end
	end,
})
