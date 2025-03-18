-- KEYMAPS --

-- SAVE/QUIT

-- Save the current file
vim.keymap.set('n', '<c-s>', ':w<cr>', { noremap = true, silent = true })
-- Force save the current file with force
vim.keymap.set('n', '<c-s><c-s>', ':w!<cr>', { noremap = true, silent = true })
-- Save all files
vim.keymap.set('n', '<c-s><c-a>', ':wa<cr>', { noremap = true, silent = true })
-- Save and quit
vim.keymap.set('n', '<c-s><c-q>', ':wq<cr>', { noremap = true, silent = true })
-- Save all files and quit
vim.keymap.set('n', '<c-s><c-a><c-q>', ':waq<cr>', { noremap = true, silent = true })
-- Quit the current file
vim.keymap.set('n', '<c-q>', ':q<cr>', { noremap = true, silent = true })
-- Force quit the current file
vim.keymap.set('n', '<c-q><c-q>', ':q!<cr>', { noremap = true, silent = true })
-- Quit all files
vim.keymap.set('n', '<c-q><c-a>', ':qa<cr>', { noremap = true, silent = true })
-- Force quit all files
vim.keymap.set('n', '<c-q><c-a><c-q>', ':qa!<cr>', { noremap = true, silent = true })

-- NAVIGATION
vim.keymap.set({ 'n', 'v' }, '<c-j>', '<c-f>', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<c-k>', '<c-b>', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v', 'o' }, 'MM', 'zz', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v', 'o' }, 'J', 'L', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v', 'o' }, 'K', 'H', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v', 'o' }, 'L', '$', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v', 'o' }, 'H', '0', { noremap = true, silent = true })
vim.keymap.set('n', 'gK', 'kgJ', { noremap = true, silent = true })
vim.keymap.set('n', ';j', '<c-o>', { noremap = true, silent = true })
vim.keymap.set('n', ';k', '<c-i>', { noremap = true, silent = true })
vim.keymap.set('n', '<c-s-k>', 'kzz', { noremap = true, silent = true })
vim.keymap.set('n', '<c-s-j>', 'jzz', { noremap = true, silent = true })
vim.keymap.set('i', '<c-h>', '<left>', { noremap = true, silent = true })
vim.keymap.set('i', '<c-j>', '<down>', { noremap = true, silent = true })
vim.keymap.set('i', '<c-k>', '<up>', { noremap = true, silent = true })
vim.keymap.set('i', '<c-l>', '<right>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-h>', '<left>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-j>', '<down>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-k>', '<up>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-l>', '<right>', { noremap = true, silent = true })

-- COPY TEXT

-- Copy to system clipboard
vim.keymap.set("v", "<c-c>", '"+y', { noremap = true, silent = true })
-- Yank filename
vim.keymap.set('n', 'yp', function()
  vim.fn.setreg('"', vim.fn.expand('%')) -- Set unnamed register to the file name
  vim.cmd('normal! p')                   -- Paste the filename
end, { noremap = true, silent = true })
-- Yank full path
vim.keymap.set('n', 'yP', function()
  vim.fn.setreg('"', vim.fn.expand('%:p')) -- Set unnamed register to the full path
  vim.cmd('normal! p')                     -- Paste the path
end, { noremap = true, silent = true })
-- Yank cmd
vim.keymap.set('n', 'yc', function()
  vim.fn.setreg('"', vim.fn.getreg(':')) -- Set unnamed register to the last command
  vim.cmd('normal! p')                   -- Paste the command
end, { noremap = true, silent = true })

-- BETTER READABILITY
vim.keymap.set("n", "<leader>r", function()
  if vim.wo.wrap then
    vim.wo.wrap = false
    vim.cmd("LspStop")
    vim.cmd("echo 'Better readability ON'")
  else
    vim.wo.wrap = true
    vim.cmd("LspStart")
    vim.cmd("echo 'Better readability OFF'")
  end
end)

-- LAZYVIM
vim.keymap.set('n', '<leader>l', ':Lazy<cr>', { noremap = true, silent = true })

-- LAZYDOCKER
vim.api.nvim_create_user_command('Lazydocker', function()
  Snacks.terminal('lazydocker')
end, {})

-- OTHER

-- Remap ' to `
vim.keymap.set('n', "'", '`', { noremap = true })
