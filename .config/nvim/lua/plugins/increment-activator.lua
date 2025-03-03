return {
  {
    "nishigori/increment-activator",
    keys = {
      { '<c-a>', desc = 'increment' },
      { '<c-x>', desc = 'decrement' }
    },
    init = function()
      vim.g.increment_activator_filetype_candidates = {
        ["_"] = {
          { "enable", "disable" },
          { "enabled", "disabled" },
        },
      }
    end,
  },
  {
    "tpope/vim-speeddating",
    keys = {
      { '<c-a>', desc = 'increment' },
      { '<c-x>', desc = 'decrement' }
    },
  }
}
