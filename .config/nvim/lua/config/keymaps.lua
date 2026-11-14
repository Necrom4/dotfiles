local map = vim.keymap.set

-- DISABLED LAZYVIM KEYMAPS
-- Only for keys set by LazyVim's keymaps.lua; plugin keys are disabled with `false` in their spec.
for _, lhs in ipairs({
	"<leader>K",
	"<leader>L",
	"<leader>xl",
	"<leader>xq",
	"<leader>ft",
	"<leader>fT",
	"<leader>gG",
	"<leader>gL",
	"<leader>gb",
	"<leader>gf",
	"<leader>gl",
	"<leader>uc", -- conceal group
	"<leader>uD", -- dimming group
}) do
	pcall(vim.keymap.del, "n", lhs)
end
for _, lhs in ipairs({ "<leader>gB", "<leader>gY" }) do
	pcall(vim.keymap.del, "n", lhs)
	pcall(vim.keymap.del, "x", lhs)
end

-- SAVE / QUIT
map({ "i", "x", "n", "s" }, "<c-s><c-s>", "<cmd>w!<cr>", { silent = true })
map({ "i", "x", "n", "s" }, "<c-s><c-a>", "<cmd>wa<cr>", { silent = true })
map({ "i", "x", "n", "s" }, "<c-s><c-q>", "<cmd>wq<cr>", { silent = true })
map({ "i", "x", "n", "s" }, "<c-s><c-a><c-q>", "<cmd>waq<cr>", { silent = true })
map({ "i", "x", "n", "s" }, "<c-q>", "<cmd>q<cr>", { silent = true })
map("t", "<c-q>", [[<c-\><c-n>:q<cr>]], { silent = true })
map({ "i", "x", "n", "s" }, "<c-q><c-q>", "<cmd>q!<cr>", { silent = true })
map({ "i", "x", "n", "s" }, "<c-q><c-a>", "<cmd>qa<cr>", { silent = true })
map({ "i", "x", "n", "s" }, "<c-q><c-a><c-q>", "<cmd>qa!<cr>", { silent = true })

-- CURSOR
-- j/k move by display line, unless given a count
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "v", "o" }, "gj", "j", { silent = true })
map({ "n", "v", "o" }, "gk", "k", { silent = true })
map({ "n", "v", "o" }, "J", "L", { silent = true })
map({ "n", "v", "o" }, "K", "H", { silent = true })
map({ "n", "v", "o" }, "L", "$", { silent = true })
map({ "n", "v", "o" }, "H", "0", { silent = true })
map({ "n", "v", "o" }, "m", "zz", { silent = true })

-- insert / cmdline
local function feedkeys(key)
	return function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "c", false)
	end
end
map("i", "<c-j>", "<down>", { silent = true })
map("i", "<c-k>", "<up>", { silent = true })
map("i", "<c-l>", "<right>", { silent = true })
map("i", "<c-h>", "<left>", { silent = true })
map("c", "<c-j>", feedkeys("<down>"), { silent = true })
map("c", "<c-k>", feedkeys("<up>"), { silent = true })
map("c", "<c-l>", feedkeys("<right>"), { silent = true })
map("c", "<c-h>", feedkeys("<left>"), { silent = true })

-- SCROLL
-- one page
map({ "n", "v" }, "<c-j>", "<c-d>", { silent = true })
map({ "n", "v" }, "<c-k>", "<c-u>", { silent = true })
map({ "n", "v" }, "<c-l>", "zL", { silent = true })
map({ "n", "v" }, "<c-h>", "zH", { silent = true })
-- one line
map({ "n", "v" }, "<c-s-j>", "<c-e>", { silent = true })
map({ "n", "v" }, "<c-s-k>", "<c-y>", { silent = true })
map({ "n", "v" }, "<c-s-l>", "zl", { silent = true })
map({ "n", "v" }, "<c-s-h>", "zh", { silent = true })

-- SEARCH
-- n always goes forward (even after ?), and opens folds + centres on the match
map("n", "n", "'Nn'[v:searchforward].'zvzz'", { expr = true, desc = "Next Search Result", silent = true })
map("n", "N", "'nN'[v:searchforward].'zvzz'", { expr = true, desc = "Prev Search Result", silent = true })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- MARKS / JUMPS
-- ` sets a mark (m is taken by zz), g` jumps to its exact position
map({ "n", "v", "o" }, "`", "m", { silent = true })
map({ "n", "v", "o" }, "g`", "`", { silent = true })
map("n", "[;", "<c-o>", { silent = true })
map("n", "];", "<c-i>", { silent = true })

-- BUFFERS / TABS
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map({ "n", "t" }, "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map({ "n", "t" }, "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>l", "<cmd>+tabmove<cr>", { desc = "Move Tab Right" })
map("n", "<leader><tab>h", "<cmd>-tabmove<cr>", { desc = "Move Tab Left" })
map("n", "<leader><tab>{", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>}", "<cmd>tablast<cr>", { desc = "Last Tab" })

-- TERMINAL
-- one <esc> goes to the program (lazygit, fzf...), two within 200ms leave terminal mode
local term_esc_timer = assert(vim.uv.new_timer())
map("t", "<esc>", function()
	if term_esc_timer:is_active() then
		term_esc_timer:stop()
		vim.cmd("stopinsert")
	else
		term_esc_timer:start(200, 0, function() end)
		return "<esc>"
	end
end, { expr = true, desc = "Double escape to normal mode" })
map("t", "<s-esc>", "<c-\\><c-n>", { silent = true })
map("t", "<c-w>", [[<c-\><c-n><c-w>]], { silent = true })

-- EDITING
-- < / > indent the line; g< / g> take a motion
map("n", "<", "<<", { desc = "Indent Left" })
map("n", ">", ">>", { desc = "Indent Right" })
map("n", "g<", "<", { desc = "Indent Left" })
map("n", "g>", ">", { desc = "Indent Right" })
map({ "n", "x" }, "gJ", "J", { desc = "Join Lines" })

-- FOLDS
-- zm without a dead zone: clamp foldlevel to the deepest fold first
map("n", "zm", function()
	local max_depth = 0
	for line = 1, vim.api.nvim_buf_line_count(0) do
		max_depth = math.max(max_depth, vim.fn.foldlevel(line))
	end
	if vim.wo.foldlevel > max_depth then
		vim.wo.foldlevel = max_depth
	end
	vim.cmd("normal! " .. vim.v.count1 .. "zm")
end, { desc = "Fold more" })

-- QUICKFIX / LOCATION LIST
map("n", "<leader>Ql", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })
map("n", "<leader>Qq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

-- DIFF
Snacks.toggle
	.new({
		id = "diff_win",
		name = "Diff Window",
		get = function()
			return vim.wo.diff
		end,
		set = function(state)
			vim.cmd(state and "diffthis" or "diffoff")
		end,
		icon = { enabled = " ", disabled = " " },
		color = { enabled = "green", disabled = "yellow" },
		wk_desc = { enabled = "Disable ", disabled = "Enable " },
	})
	:map("<leader>dd")

-- GIT / YADM
map("n", "<leader>ga", function()
	require("utils.git").add_current_file()
end, { desc = "Add file", silent = true })
map("n", "<leader>gy", function()
	require("utils.git").switch_git_dir()
end, { desc = "Toggle Repo (project/yadm)", silent = true })
map("n", "<leader>fc", function()
	require("utils.git").pick_yadm_files()
end, { desc = "Find Config File", silent = true })

-- MARKDOWN / LISTS
-- buffer-local; also applied to buffers opened before this file loads (VeryLazy)
local function filetype_keymaps(filetypes, set)
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("keymaps_" .. table.concat(filetypes, "_"), { clear = true }),
		pattern = filetypes,
		callback = function(event)
			set(event.buf)
		end,
	})
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
			set(buf)
		end
	end
end

-- same filetypes as bullets.nvim's enabled_file_types
-- bullets.nvim handles list items and (markdown_headings) headers; anything else is plain << / >>
filetype_keymaps({ "markdown", "text", "gitcommit", "scratch" }, function(buf)
	map("n", ">", function()
		if not require("bullets.actions").demote() then
			vim.cmd("normal! " .. vim.v.count1 .. ">>")
		end
	end, { buffer = buf, silent = true, desc = "Demote header / list item / indent" })
	map("n", "<", function()
		if not require("bullets.actions").promote() then
			vim.cmd("normal! " .. vim.v.count1 .. "<<")
		end
	end, { buffer = buf, silent = true, desc = "Promote header / list item / indent" })
end)

filetype_keymaps({ "markdown" }, function(buf)
	-- URL from: "x prefix register > clipboard (if it is a URL) > register picker
	map({ "x", "n" }, "gsl", function()
		require("utils.markdown.link").link()
	end, { buffer = buf, silent = true, desc = "Surround with markdown link (clipboard)" })
	map({ "x", "n" }, "gsL", function()
		require("utils.markdown.link").link({ pick = true })
	end, { buffer = buf, silent = true, desc = "Surround with markdown link (pick register)" })
	map("n", "<a-x>", "<Plug>(bullets-cycle-checkbox)", {
		buffer = buf,
		remap = true,
		silent = true,
		desc = "Cycle task and update parent/child tasks",
	})
end)

-- OTHER
map("n", "<leader>.s", function()
	local output = require("utils.general").term_cmd("zsh -i -c 'source ~/.zshrc'")
	if vim.v.shell_error == 0 then
		vim.api.nvim_echo({ { "Successfully sourced ~/.zshrc", "NormalMsg" } }, false, {})
	else
		vim.api.nvim_echo({ { "Failed to source ~/.zshrc:", "ErrorMsg" }, { output, "ErrorMsg" } }, false, {})
	end
end, { desc = "Source ~/.zshrc" })

-- NEOVIDE
if vim.g.neovide then
	local is_mac = vim.fn.has("mac") == 1
	local c_c = is_mac and "<D-c>" or "<C-c>"
	local c_v = is_mac and "<D-v>" or "<C-v>"

	local function paste_in_prompt()
		local keys = vim.fn.escape(vim.fn.getreg("+"), [["\]])
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "c", false)
	end

	map("n", c_v, '"+p', { silent = true })
	map("i", c_v, '<ESC>"+pli', { silent = true })
	map("c", c_v, paste_in_prompt, { silent = true })
	map("t", c_v, paste_in_prompt, { silent = true })
	map("v", c_c, '"+y', { silent = true })
end
