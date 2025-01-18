return {
  'is0n/fm-nvim',
  opts = {
    ui = {
      float = {
        border = "rounded",
      },
    },
    mappings = {
      vert_split = "<C-s>",
      horz_split = "<C-h>",
      tabedit    = "<C-t>",
      edit       = "<C-e>",
      ESC        = "<ESC>",
    },
  },
  keys = {
    { '<leader>x', function()
        if vim.api.nvim_buf_get_name(0) == '' then
          vim.cmd [[Vifm --select %:p:h]]
        else
          vim.cmd [[Vifm --select %]]
        end
      end, { desc = 'Open File Manager (vifm)' }
    },
  },
}
