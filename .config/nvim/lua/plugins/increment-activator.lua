return {
  "nishigori/increment-activator",
  event = { "BufNewFile", "BufReadPost" },
  init = function()
    vim.g.increment_activator_filetype_candidates = {
      ["_"] = {
        { "enable", "disable" },
        { "enabled", "disabled" },
      },
    }
  end,
}
