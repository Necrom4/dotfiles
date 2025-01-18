return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = {
      -- path_display = { "smart" },
      mappings = {
        i = {
          ["<esc>"] = require("telescope.actions").close,
          ["<c-q>"] = require("telescope.actions").close,
          ["<c-d>"] = require("telescope.actions").delete_buffer,
          ["<c-r>"] = require("telescope.actions").delete_mark,
          ["<c-k>"] = require("telescope.actions").move_selection_previous,
          ["<c-j>"] = require("telescope.actions").move_selection_next,
          ["<c-l>"] = require("telescope.actions").select_default,
          -- ["<c-b>"] = function() vim.cmd "normal! delmarks" end,
        },
      },
      dynamic_preview_title = true,
    },
    pickers = {
      find_files = {
        hidden = { true },
      },
      grep_string = {
        additional_args = { "--hidden" },
      },
      live_grep = {
        additional_args = { "--hidden" },
      },
    },
  },
  keys = {
    { '<leader>f', ":Telescope<CR>" },
    { '<leader>f', "y<ESC>:Telescope live_grep default_text=<C-r>0<CR>", mode = 'v' },
  },
}
