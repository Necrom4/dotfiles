return {
  'rebelot/heirline.nvim',
  opts = function ()
    local colors = {
      monochrome_1 = "#FFFFFF",
      monochrome_2 = "#CCCCCC",
      monochrome_3 = "#A5A5A5",
      monochrome_4 = "#7F7F7F",
      monochrome_5 = "#4C4C4C",
      monochrome_6 = "#333333",
      monochrome_7 = "#000000",
      red_1 = "#FF0000",
      red_2 = "#CC0000",
      red_3 = "#A50000",
      red_4 = "#7F0000",
      red_5 = "#590000",
      red_6 = "#4C0000",
      red_7 = "#330000",
      yellow = "#FFFF00",
      orange = "#FFAA00",
      brown = "#595900",
      green = "#00BF00",
      bright_pink = "#FF7F7F",
    }

    local utils = require("heirline.utils")
    local conditions = require("heirline.conditions")
    local Align = { provider = "%=" }
    local Space = { provider = " " }
    local RightSeparator = {
      provider = "",
      hl = { fg = colors.red_5 },
    }

    -- Mode Indicator Section
    local ViMode = {
      -- Custom mode indicator with `ViMode`
      init = function(self)
        self.mode = vim.fn.mode(1)  -- Get current mode using `vim.fn.mode`
      end,
      static = {
        mode_names = {
          n = "NORMAL", no = "MOTION", nov = "Mv", noV = "MV", ["no\22"] = "^M", niI = "Ni", niR = "Nr",
          niV = "Nv", nt = "WINDOW", v = "VISUAL", vs = "Vs", V = "V-LINE", Vs = "Vs", ["\22"] = "V-BLOCK",
          ["\22s"] = "^V", s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK", i = "INSERT", ic = "Ic", ix = "Ix",
          R = "REPLACE", Rc = "Rc", Rx = "Rx", Rv = "Rv", Rvc = "Rv", Rvx = "Rv", c = "COMMAND", cv = "Ex",
          r = "...", rm = "M", ["r?"] = "?", ["!"] = "!", t = "TERMINAL",
        },
      },
      provider = function(self)
        return " %2("..self.mode_names[self.mode].."%) "  -- Display the mode with padding and icon
      end,
      hl = { fg = colors.monochrome_7, bold = true },
      {
        condition = function()
          return not conditions.is_git_repo()
        end,
        provider = "",
        hl = { fg = colors.red_2, bg = colors.red_7 },
      },
    }
    local Branch = {
      condition = conditions.is_git_repo,

      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
      end,

      {
        provider = "",
        hl = { fg = colors.red_2 },
      },
      {   -- git branch name
        provider = function(self)
          return "  " .. self.status_dict.head .. " "
        end,
        hl = { fg = colors.red_1 },
      },
      {
        provider = "",
        hl = { fg = colors.red_5, bg = colors.red_7 },
      }
    }

    local FileNameBlock = {
      -- let's first set up some attributes needed by this component and its children
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
    }

    -- We can now define some children separately and add them later
    local FilePath = {
      provider = function(self)
        local path = vim.fn.fnamemodify(self.filename, ":h")
        return path .. "/"
      end,
      hl = { fg = colors.red_3 },
    }
    local FileName = {
      provider = function(self)
        local name = vim.fn.fnamemodify(self.filename, ":t")
        return name
      end,
      hl = { fg = colors.red_1, bold = true },
    }
    local FileIcon = {
      init = function(self)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end,
      {
        provider = function()
          return vim.bo.modified and "[" or " "
        end,
        hl = { fg = colors.red_1, bold = true },
      },
      {
        provider = function(self)
          return self.icon
        end,
        hl = { fg = colors.red_2 },
      },
      {
        provider = function()
          return vim.bo.modified and "]" or " "
        end,
        hl = { fg = colors.red_1, bold = true },
      },
    }
    local FileFlags = {
      {
        condition = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
        provider = " ",
        hl = { fg = colors.red_2 },
      },
    }
    FileNameBlock = utils.insert(FileNameBlock,
    { provider = '%<'},
    FilePath,
    FileName,
    FileIcon,
    FileFlags
    )

    local Git = {
      condition = conditions.is_git_repo,

      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
      end,
      hl = { fg = colors.red_2 },

      {
        condition = function(self)
          return self.has_changes
        end,
        provider = " "
      },
      {
        provider = function(self)
          local count = self.status_dict.added or 0
          return count > 0 and (" " .. count .. " ")
        end,
        hl = { fg = colors.green },
      },
      {
        provider = function(self)
          local count = self.status_dict.removed or 0
          return count > 0 and (" " .. count .. " ")
        end,
      },
      {
        provider = function(self)
          local count = self.status_dict.changed or 0
          return count > 0 and ("󰏬 " .. count .. " ")
        end,
        hl = { fg = colors.yellow },
      },
    }

    local Diagnostics = {

      condition = conditions.has_diagnostics,

      static = {
        error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
        warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
        info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
        hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
      },

      init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
      end,

      update = { "DiagnosticChanged", "BufEnter" },

      {
        provider = " "
      },
      {
        provider = function(self)
          -- 0 is just another output, we can decide to print it or not!
          return self.errors > 0 and (self.error_icon .. self.errors .. " ")
        end,
        hl = { fg = colors.red_1, bold = true },
      },
      {
        provider = function(self)
          return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
        end,
        hl = { fg = colors.bright_pink },
      },
      {
        provider = function(self)
          return self.info > 0 and (self.info_icon .. self.info .. " ")
        end,
        hl = { fg = colors.red_4 },
      },
      {
        provider = function(self)
          return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
        end,
        hl = { fg = colors.orange },
      },
    }

    local CursorPosition = {
      provider = "%c:%l/%L | %p%% ",
      hl = { fg = colors.red_1 },
    }

    local ScrollBar = {
      static = {
        sbar = { '▔', '🭶', '🭷', '🭸', '🭹', '🭺', '🭻', '▁' }
      },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i
        if lines > 0 then
          i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        else
          i = #self.sbar
        end
        return string.rep(self.sbar[i], 2)
      end,
      hl = { fg = colors.red_2 },
    }

    local BuffName = {
      provider = function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
      end
    }

    local WinBars = {
      fallthrough = false,
      {   -- An inactive winbar for regular files
        condition = function()
          return not conditions.is_active()
        end,
        utils.surround({ "█", "█" }, colors.red_7, { hl = { fg = colors.red_4, force = true }, BuffName, FileIcon }),
      },
      -- A winbar for regular files
      utils.surround({ "█", "█" }, colors.red_6, { hl = { fg = colors.red_1, force = true }, BuffName, FileIcon }),
    }

    local Tab = {
      provider = function(self)
        local win = vim.api.nvim_tabpage_get_win(self.tabpage) -- Get window associated with tab
        local buf = vim.api.nvim_win_get_buf(win) -- Get buffer associated with window
        local bufname = vim.api.nvim_buf_get_name(buf) -- Get buffer name
        local shortname = vim.fn.fnamemodify(bufname, ":t") -- Get short name

        return "%" .. self.tabnr .. "T" .. self.tabpage .. " • " .. shortname .. "%T"
      end,
    }

    local TabpageClose = {
      provider = function(self)
        return "%" .. self.tabnr .. "X %X"
      end,
      hl = { fg = colors.red_2 },
    }

    local TabBlock = {
      fallthrough = false,
      {
        condition = function(self)  -- Pass the tab data to the condition
          return self.is_active
        end,
        fallthrough = false,
        {
          condition = function(self)  -- Pass the tab data to the condition
            return self.tabnr == 1
          end,
          utils.surround({ "█", "█" }, colors.red_6, { hl = { fg = colors.red_2, force = true }, Tab, TabpageClose }),
        },
        utils.surround({ "█", "█" }, colors.red_6, { hl = { fg = colors.red_2, force = true }, Tab, TabpageClose }),
      },
      {
        condition = function(self)  -- Pass the tab data to the condition
          return self.tabnr == 1
        end,
        utils.surround({ "█", "█" }, colors.red_7, { hl = { fg = colors.red_4, force = true }, Tab, TabpageClose }),
      },
      utils.surround({ "█", "█" }, colors.red_7, { hl = { fg = colors.red_4, force = true }, Tab, TabpageClose }),
    }

    local TabLine = {
      utils.make_tablist(TabBlock),
    }

    return {
      statusline = {
        {{ ViMode }, hl = { bg = colors.red_2 }},
        {{ Branch }, hl = { bg = colors.red_5 }},
        {{ Space, FileNameBlock, Align, Space, Git, Diagnostics, RightSeparator }, hl = { bg = colors.red_7 }},
        {{ Space, CursorPosition, ScrollBar }, hl = { bg = colors.red_5 }},
      },
      winbar = { WinBars },
      tabline = { TabLine },
      opts = {
        disable_winbar_cb = function(args)
          return conditions.buffer_matches({
            buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
            filetype = { "^git.*", "norg", "fugitive", "Trouble", "dashboard" },
          }, args.buf)
        end,
      }
    }
  end
}
