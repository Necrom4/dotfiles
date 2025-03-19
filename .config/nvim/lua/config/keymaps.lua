-- KEYMAPS --

-- SAVE/QUIT

-- Save the current file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s>", "<cmd>w<cr><esc>", { noremap = true, silent = true })
-- Force save the current file with force
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-s>", "<cmd>w!<cr><esc>", { noremap = true, silent = true })
-- Save all files
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-a>", "<cmd>wa<cr><esc>", { noremap = true, silent = true })
-- Save and quit
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-q>", "<cmd>wq<cr><esc>", { noremap = true, silent = true })
-- Save all files and quit
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-a><c-q>", "<cmd>waq<cr><esc>", { noremap = true, silent = true })
-- Quit the current file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q>", "<cmd>q<cr><esc>", { noremap = true, silent = true })
-- Force quit the current file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-q>", "<cmd>q!<cr><esc>", { noremap = true, silent = true })
-- Quit all files
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-a>", "<cmd>qa<cr><esc>", { noremap = true, silent = true })
-- Force quit all file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-a><c-q>", "<cmd>qa!<cr><esc>", { noremap = true, silent = true })

-- NAVIGATION
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-j>", "<c-f>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-k>", "<c-b>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "MM", "zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "J", "L", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "K", "H", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "L", "$", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "H", "0", { noremap = true, silent = true })
vim.keymap.set("n", "gK", "kgJ", { noremap = true, silent = true })
vim.keymap.set("n", "[;", "<c-o>", { noremap = true, silent = true })
vim.keymap.set("n", "];", "<c-i>", { noremap = true, silent = true })
vim.keymap.set("n", "<c-s-k>", "kzz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-s-j>", "jzz", { noremap = true, silent = true })
vim.keymap.set("i", "<c-h>", "<left>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-j>", "<down>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-k>", "<up>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-l>", "<right>", { noremap = true, silent = true })
vim.keymap.set("c", "<c-h>", "<left>", { noremap = true, silent = true })
vim.keymap.set("c", "<c-j>", "<down>", { noremap = true, silent = true })
vim.keymap.set("c", "<c-k>", "<up>", { noremap = true, silent = true })
vim.keymap.set("c", "<c-l>", "<right>", { noremap = true, silent = true })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- new file
vim.keymap.set("n", "<leader>N", "<cmd>enew<cr>", { desc = "New File" })

-- Yank filename
vim.keymap.set("n", "yp", function()
	vim.fn.setreg('"', vim.fn.expand("%")) -- Set unnamed register to the file name
	vim.cmd("normal! p") -- Paste the filename
end, { noremap = true, silent = true })
-- Yank full path
vim.keymap.set("n", "yP", function()
	vim.fn.setreg('"', vim.fn.expand("%:p")) -- Set unnamed register to the full path
	vim.cmd("normal! p") -- Paste the path
end, { noremap = true, silent = true })
-- Yank cmd
vim.keymap.set("n", "yc", function()
	vim.fn.setreg('"', vim.fn.getreg(":")) -- Set unnamed register to the last command
	vim.cmd("normal! p") -- Paste the command
end, { noremap = true, silent = true })
-- default LazyVim disabled keymaps
vim.keymap.del("s", "<Tab>")
vim.keymap.del({ "i", "s" }, "<S-Tab>")

-- LAZYDOCKER
vim.api.nvim_create_user_command("Lazydocker", function()
	Snacks.terminal("lazydocker")
end, {})

-- NEORG
vim.keymap.set("n", "gt", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", {})

-- Remap ' to `
vim.keymap.set("n", "'", "`", { noremap = true })
