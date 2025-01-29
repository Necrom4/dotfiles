return {
  "ibhagwan/fzf-lua",
  dependencies = {
    'kevinhwang91/nvim-bqf',
  },
  enabled = false,
  opts = {
    -- fzf_opts = { ["--layout"] = "default" },
    fzf_colors = {
      true,
      ["fg"]          = { "fg", "Normal" },
      ["bg"]          = { "bg", "Normal" },
      ["hl"]          = { "fg", "Constant", "underline" },
      ["fg+"]         = { "fg", "String" },
      ["bg+"]         = { "bg", "Search" },
      ["hl+"]         = { "fg", "Constant", "underline" },
      ["info"]        = { "fg", "Normal" },
      ["prompt"]      = { "fg", "Comment" },
      ["pointer"]     = { "fg", "Normal" },
      ["marker"]      = { "fg", "Normal" },
      ["spinner"]     = { "fg", "Comment" },
      ["header"]      = { "fg", "Comment" },
      ["gutter"]      = "-1",
    },
    hls = {
      buf_nr = "Normal",
      buf_id = "Normal",
      buf_linenr = "Normal",
      buf_flag_cur = "Normal",
      buf_flag_alt = "Normal",
      header_bind = "Bold",
      header_text = "Bold",
      live_prompt = "Normal",
      prompt = "DiffText",
    },
  },
  keys = {
    { "<leader>f", ":FzfLua<CR>", desc = "Open Fzf.lua", silent = true },
  }
}
