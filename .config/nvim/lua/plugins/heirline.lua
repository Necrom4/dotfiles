return {
  'rebelot/heirline.nvim',
  enabled = true,
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
      red_5 = "#4C0000",
      red_6 = "#330000",
      yellow = "#FFFF00",
      green = "#00BF00",
      brown = "#595900",
      bright_pink = "#FF7F7F",
    }

    local utils = require("heirline.utils")
    local conditions = require("heirline.conditions")
    local Align = { provider = "%=", hl = { bg = colors.red_6 }}
    local Space = { provider = " ", hl = { bg = colors.red_6 } }

    -- Mode Indicator Section
    local ViMode = {
      -- Custom mode indicator with `ViMode`
      init = function(self)
        self.mode = vim.fn.mode(1)  -- Get current mode using `vim.fn.mode`
      end,
      static = {
        mode_names = {
          n = "NORMAL", no = "MOTION", nov = "Mv", noV = "MV", ["no\22"] = "^M", niI = "Ni", niR = "Nr",
          niV = "Nv", nt = "Nt", v = "VISUAL", vs = "Vs", V = "V-LINE", Vs = "Vs", ["\22"] = "V-BLOCK",
          ["\22s"] = "^V", s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK", i = "INSERT", ic = "Ic", ix = "Ix",
          R = "REPLACE", Rc = "Rc", Rx = "Rx", Rv = "Rv", Rvc = "Rv", Rvx = "Rv", c = "COMMAND", cv = "Ex",
          r = "...", rm = "M", ["r?"] = "?", ["!"] = "!", t = "TERMINAL",
        },
      },
      provider = function(self)
        return " %2("..self.mode_names[self.mode].."%)"  -- Display the mode with padding and icon
      end,
      hl = { fg = colors.monochrome_7, bg = colors.red_2, bold = true },
    }
    local InsertIndicator = {
      init = function(self)
        self.is_insert = vim.fn.mode(1) == "i"
      end,
      provider = function(self)
        return self.is_insert and "" or " "
      end,
      hl = { fg = colors.red_2, bg = colors.red_6 },
      update = {
        "ModeChanged",
        pattern = "*:*",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
    }
    local FileModified = {
      provider = function()
        return vim.bo.modified and "" or " "  -- Modified buffer indicator
      end,
      hl = { fg = colors.monochrome_7, bg = colors.red_2 },
    }
    local Separator = {
      provider = "",  -- Separator
      hl = { fg = colors.red_2, bg = colors.red_6 },
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
      hl = { fg = colors.red_3, bg = colors.red_6 },
    }
    local FileName = {
      provider = function(self)
        local name = vim.fn.fnamemodify(self.filename, ":t")
        return name
      end,
      hl = { fg = colors.red_1, bg = colors.red_6, bold = true },
    }
    local FileIcon = {
      init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end,
      provider = function(self)
        return self.icon and (" " .. self.icon .. " ")
      end,
      hl = { fg = colors.red_2, bg = colors.red_6 }
    }
    local FileFlags = {
      {
        condition = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
        provider = "",
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
      hl = { fg = colors.red_2, bg = colors.red_6 },

      {
        condition = function(self)
          return self.has_changes
        end,
        provider = "["
      },
      {
        provider = function(self)
          local count = self.status_dict.added or 0
          return count > 0 and ("+" .. count)
        end,
      },
      {
        provider = function(self)
          if (self.status_dict.added or 0) > 0 and ((self.status_dict.changed or 0) > 0 or (self.status_dict.removed or 0) > 0) then
            return  "|"
          end
        end,
      },
      {
        provider = function(self)
          local count = self.status_dict.removed or 0
          return count > 0 and ("-" .. count)
        end,
      },
      {
        provider = function(self)
          if (self.status_dict.removed or 0) > 0 and (self.status_dict.changed or 0) > 0 then
            return  "|"
          end
        end,
      },
      {
        provider = function(self)
          local count = self.status_dict.changed or 0
          return count > 0 and ("~" .. count)
        end,
      },
      {
        condition = function(self)
          return self.has_changes
        end,
        provider = "]",
      },
    }

    local CursorPosition = {
      provider = "%c:%l/%L | %p%%",
      hl = { fg = colors.red_2, bg = colors.red_6 },
    }

    local ScrollBar = {
      static = {
        sbar = { '█', '▇', '▆', '▅', '▄', '▃', '▂', '▁' }
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
      hl = { fg = colors.red_6, bg = colors.red_2 },
    }

    return {
      statusline = { ViMode, FileModified, Separator, InsertIndicator, Space, FileNameBlock, Align, Space, Git, Space, CursorPosition, Space, ScrollBar },
    }
  end
}
