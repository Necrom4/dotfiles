-- KEYMAPS --

local function feedkeys(key)
	return function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "c", false)
	end
end

-- SAVE/QUIT

-- Save the current file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s>", "<cmd>w<cr>", { noremap = true, silent = true })
-- Force save the current file with force
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-s>", "<cmd>w!<cr>", { noremap = true, silent = true })
-- Save all files
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-a>", "<cmd>wa<cr>", { noremap = true, silent = true })
-- Save and quit
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-q>", "<cmd>wq<cr>", { noremap = true, silent = true })
-- Save all files and quit
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-a><c-q>", "<cmd>waq<cr>", { noremap = true, silent = true })
-- Quit the current file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q>", "<cmd>q<cr>", { noremap = true, silent = true })
-- Force quit the current file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-q>", "<cmd>q!<cr>", { noremap = true, silent = true })
-- Quit all files
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-a>", "<cmd>qa<cr>", { noremap = true, silent = true })
-- Force quit all file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-a><c-q>", "<cmd>qa!<cr>", { noremap = true, silent = true })

-- NAVIGATION
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "gj", "j", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "gk", "k", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-j>", "<c-f>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-k>", "<c-b>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "MM", "zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "J", "L", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "K", "H", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "L", "$", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "H", "0", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzz", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true, silent = true })
vim.keymap.set("n", "[;", "<c-o>", { noremap = true, silent = true })
vim.keymap.set("n", "];", "<c-i>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-h>", "<left>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-j>", "<down>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-k>", "<up>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-l>", "<right>", { noremap = true, silent = true })
vim.keymap.set("c", "<c-h>", feedkeys("<left>"), { noremap = true, silent = true })
vim.keymap.set("c", "<c-j>", feedkeys("<down>"), { noremap = true, silent = true })
vim.keymap.set("c", "<c-k>", feedkeys("<up>"), { noremap = true, silent = true })
vim.keymap.set("c", "<c-l>", feedkeys("<right>"), { noremap = true, silent = true })
vim.keymap.set("t", "<c-q>", [[<c-\><c-n>:q<cr>]], { noremap = true, silent = true })
vim.keymap.set("t", "<c-w>", [[<c-\><c-n><c-w>]], { noremap = true, silent = true })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>h", "<cmd>-tabmove<cr>", { desc = "Move Tab Left" })
vim.keymap.set("n", "<leader><tab>l", "<cmd>+tabmove<cr>", { desc = "Move Tab Right" })
vim.keymap.set("n", "<leader><tab>{", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab>}", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- default LazyVim disabled keymaps
vim.keymap.del("n", "<leader>K")

--keywordprg
vim.keymap.set("n", "<leader>?", "<cmd>norm! K<cr>", { desc = "MAN" })
