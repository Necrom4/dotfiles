-- Single-press < / > promote/demote (the global maps in config/keymaps.lua are
-- noremap, so they would bypass neorg's buffer-local << / >>).
vim.keymap.set("n", "<", "<Plug>(neorg.promo.demote)", { buffer = true, desc = "[neorg] Demote object" })
vim.keymap.set("n", ">", "<Plug>(neorg.promo.promote)", { buffer = true, desc = "[neorg] Promote object" })
