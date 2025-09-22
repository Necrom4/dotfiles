local utils = require("core.utils")

-- Reload zsh configuration by sourcing ~/.zshrc in a separate shell
vim.keymap.set("n", "<leader>.s", function()
	local output = utils.term_cmd("zsh -i -c 'source ~/.zshrc'")
	local exit_code = vim.v.shell_error
	if exit_code == 0 then
		vim.api.nvim_echo({ { "Successfully sourced ~/.zshrc", "NormalMsg" } }, false, {})
	else
		vim.api.nvim_echo({
			{ "Failed to source ~/.zshrc:", "ErrorMsg" },
			{ output, "ErrorMsg" },
		}, false, {})
	end
end, { desc = "Source ~/.zshrc" })

-- SAVE/QUIT
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-s>", "<cmd>w!<cr>", { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-a>", "<cmd>wa<cr>", { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-q>", "<cmd>wq<cr>", { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s><c-a><c-q>", "<cmd>waq<cr>", { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q>", "<cmd>q<cr>", { noremap = true, silent = true })
vim.keymap.set("t", "<c-q>", [[<c-\><c-n>:q<cr>]], { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-q>", "<cmd>q!<cr>", { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-a>", "<cmd>qa<cr>", { noremap = true, silent = true })
vim.keymap.set({ "i", "x", "n", "s" }, "<c-q><c-a><c-q>", "<cmd>qa!<cr>", { noremap = true, silent = true })

-- NAVIGATION

-- function allowing for in-cmdline navigation
local function feedkeys(key)
	return function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "c", false)
	end
end
-- ESC key in terminal
vim.keymap.set({ "t" }, "<esc>", "<s-esc>", { noremap = true, silent = true })
vim.keymap.set({ "t" }, "<s-esc>", "<c-\\><c-n>", { noremap = true, silent = true })
-- cursor position
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "gj", "j", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "gk", "k", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "m", "zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "J", "L", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "K", "H", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "L", "$", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "H", "0", { noremap = true, silent = true })
-- scroll one page
vim.keymap.set({ "n", "v" }, "<c-j>", "<c-d>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-k>", "<c-u>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-l>", "zL", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-h>", "zH", { noremap = true, silent = true })
-- scroll one line
vim.keymap.set({ "n", "v" }, "<c-s-j>", "<c-e>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-s-k>", "<c-y>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-s-l>", "zl", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<c-s-h>", "zh", { noremap = true, silent = true })
-- define mark
vim.keymap.set({ "n", "v", "o" }, "`", "m", { noremap = true, silent = true })
-- center on next search
vim.keymap.set("n", "n", "nzz", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true, silent = true })
-- move cursor in insert/cmdline modes
vim.keymap.set("i", "<c-j>", "<down>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-k>", "<up>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-l>", "<right>", { noremap = true, silent = true })
vim.keymap.set("i", "<c-h>", "<left>", { noremap = true, silent = true })
vim.keymap.set("c", "<c-j>", feedkeys("<down>"), { noremap = true, silent = true })
vim.keymap.set("c", "<c-k>", feedkeys("<up>"), { noremap = true, silent = true })
vim.keymap.set("c", "<c-l>", feedkeys("<right>"), { noremap = true, silent = true })
vim.keymap.set("c", "<c-h>", feedkeys("<left>"), { noremap = true, silent = true })
-- non-cursor navigation
-- normal mode to window mode
vim.keymap.set("t", "<c-w>", [[<c-\><c-n><c-w>]], { noremap = true, silent = true })
-- to next/last cursor position
vim.keymap.set("n", "[;", "<c-o>", { noremap = true, silent = true })
vim.keymap.set("n", "];", "<c-i>", { noremap = true, silent = true })
-- to next/last buffer
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
-- to next/last tab
vim.keymap.set({ "n", "t" }, "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set({ "n", "t" }, "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- TAB MANAGEMENT
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>l", "<cmd>+tabmove<cr>", { desc = "Move Tab Right" })
vim.keymap.set("n", "<leader><tab>h", "<cmd>-tabmove<cr>", { desc = "Move Tab Left" })
vim.keymap.set("n", "<leader><tab>{", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab>}", "<cmd>tablast<cr>", { desc = "Last Tab" })

-- motion indent
vim.keymap.set("n", "g<", "<", { noremap = true, desc = "Indent Left" })
vim.keymap.set("n", "g>", ">", { noremap = true, desc = "Indent Right" })

-- single click indent
vim.keymap.set("n", "<", "<<", { noremap = true, desc = "Indent Left" })
vim.keymap.set("n", ">", ">>", { noremap = true, desc = "Indent Right" })

vim.keymap.set("n", "gJ", "J")

-- default LazyVim disabled keymaps
vim.keymap.del("n", "<leader>K")
vim.keymap.del("n", "<leader>xl")
vim.keymap.del("n", "<leader>xq")

--keywordprg
vim.keymap.set("v", "<leader>sM", "<cmd>norm! K<cr>", { desc = "Man Pages" })

-- location list
vim.keymap.set("n", "<leader>Xl", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })

-- quickfix list
vim.keymap.set("n", "<leader>Xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

-- diff
Snacks.toggle
	.new({
		id = "diff_win",
		name = "Diff Window",
		get = function()
			return vim.wo.diff
		end,
		set = function(state)
			if state then
				vim.cmd("diffthis")
			else
				vim.cmd("diffoff")
			end
		end,
		icon = {
			enabled = " ",
			disabled = " ",
		},
		color = {
			enabled = "green",
			disabled = "yellow",
		},
		wk_desc = {
			enabled = "Disable ",
			disabled = "Enable ",
		},
	})
	:map("<leader>dd")
