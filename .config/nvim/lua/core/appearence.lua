-- HIGHLIGHTS

local set_hl = vim.api.nvim_set_hl
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

-- General
set_hl(0, "Normal", { bg = "none", fg = colors.red_2 })
set_hl(0, "NormalNC", { bg = "none", fg = colors.red_2 })
set_hl(0, "Comment", { bg = "none", fg = colors.red_4 })
set_hl(0, "Include", { bg = "none", fg = colors.red_2 })
set_hl(0, "Define", { bg = "none", fg = colors.red_2, underline = true })
set_hl(0, "Bold", { bg = "none", fg = colors.red_2, bold = true })
set_hl(0, "Constant", { bg = "none", fg = colors.red_2 })
set_hl(0, "Conditional", { bg = "none", fg = colors.red_2, bold = true })
set_hl(0, "NonText", { bg = "none", fg = colors.red_4 })
set_hl(0, "Error", { bg = colors.red_4, fg = colors.red_1, bold = true, underline = true })
set_hl(0, "Number", { bg = "none", fg = colors.red_1, bold = true })
set_hl(0, "Float", { bg = "none", fg = colors.red_1, bold = true })
set_hl(0, "String", { bg = "none", fg = colors.red_3 })
set_hl(0, "Delimiter", { bg = "none", fg = colors.red_3 })
set_hl(0, "Function", { bg = "none", fg = colors.red_2 })
set_hl(0, "Special", { bg = "none", fg = colors.red_2 })
set_hl(0, "Statement", { bg = "none", fg = colors.red_1, bold = true })
set_hl(0, "Identifier", { bg = "none", fg = colors.red_2, bold = true })
set_hl(0, "Todo", { bg = colors.red_2, fg = colors.red_4 })
set_hl(0, "WildMenu", { bg = "none", fg = colors.red_2 })
set_hl(0, "MatchParen", { bg = colors.red_4, fg = colors.red_1, bold = true })
set_hl(0, "Visual", { bg = colors.red_5, fg = colors.red_1 })
set_hl(0, "Repeat", { bg = "none", fg = colors.red_2, bold = true })
set_hl(0, "SpecialKey", { bg = "none", fg = colors.red_2 })
set_hl(0, "PreProc", { bg = "none", fg = colors.red_2 })
set_hl(0, "Operator", { bg = "none", fg = colors.red_4 })
set_hl(0, "Type", { bg = "none", fg = colors.red_2 })
set_hl(0, "Title", { bg = "none", fg = colors.red_1, bold = true })
set_hl(0, "Boolean", { bg = "none", fg = colors.red_1, bold = true })
set_hl(0, "Directory", { bg = "none", fg = colors.red_4 })
set_hl(0, "QuickFixLine", { bg = colors.red_5, fg = colors.red_2 })
set_hl(0, "markdownCode", { bg = colors.red_5, fg = colors.red_1 })
set_hl(0, "markdownCodeBlock", { bg = colors.red_6, fg = colors.red_2 })

-- Search
set_hl(0, "IncSearch", { bg = colors.red_5, fg = colors.red_1, underline = true })
set_hl(0, "Search", { bg = colors.red_6, fg = colors.red_4, underline = true })
set_hl(0, "CurSearch", { bg = colors.red_5, fg = colors.red_1, underline = true })

-- StatusLine
set_hl(0, "StatusLine", { bg = colors.red_2, fg = colors.monochrome_7, bold = true})
-- set_hl(0, "StatusLineArrow", { bg = colors.red_6, fg = colors.red_2 })
-- set_hl(0, "StatusLineInfo", { bg = colors.red_6, fg = colors.red_3 })
-- set_hl(0, "StatusLineInfoMain", { bg = colors.red_6, fg = colors.red_1, bold = true })
set_hl(0, "StatusLineNC", { bg = colors.red_4, fg = colors.monochrome_7 })
-- set_hl(0, "StatusLineNCArrow", { bg = colors.monochrome_7, fg = colors.red_6 })
-- set_hl(0, "StatusLineNCInfo", { bg = colors.monochrome_7, fg = colors.red_6 })
-- set_hl(0, "StatusLineNCInfoMain", { bg = colors.monochrome_7, fg = colors.red_6 })

-- TabLine
set_hl(0, "TabLine", { bg = colors.red_6, fg = colors.red_2 })
set_hl(0, "TabLineSel", { bg = colors.red_2, fg = colors.monochrome_7, bold = true })
set_hl(0, "TabLineFill", { bg = colors.monochrome_7, fg = colors.red_6 })

-- Cursor
set_hl(0, "Cursor", { bg = "none", fg = colors.red_2 })
set_hl(0, "CursorLine", { bg = colors.red_6 })
set_hl(0, "CursorLineFold", { bg = "none", fg = colors.red_4 })

-- Folds
set_hl(0, "Folded", { bg = "none", fg = colors.red_1, bold = true })
set_hl(0, "FoldedLinesAmount", { fg = colors.red_2, bg = "none" })

-- Columns
set_hl(0, "LineNr", { bg = "none", fg = colors.red_2 })
set_hl(0, "LineNrAbove", { bg = "none", fg = colors.red_4 })
set_hl(0, "LineNrBelow", { bg = "none", fg = colors.red_4 })
set_hl(0, "CursorLineNr", { bg = "none", fg = "none" })
set_hl(0, "SignColumn", { bg = "none", fg = colors.red_2 })
set_hl(0, "FoldColumn", { bg = "none", fg = colors.red_2 })
set_hl(0, "CursorColumn", { bg = colors.monochrome_6 })

-- Windows
set_hl(0, "VertSplit", { bg = "none", fg = colors.red_4 })

-- Diff Highlights
set_hl(0, "DiffAdd", { bg = "none", fg = colors.green })
set_hl(0, "DiffChange", { bg = "none", fg = colors.yellow })
set_hl(0, "DiffDelete", { bg = "none", fg = colors.red_4 })
set_hl(0, "DiffText", { bg = colors.brown, fg = colors.yellow })

-- Error
set_hl(0, "SpellBad", { bg = colors.red_4, fg = colors.red_2, underline = true })
set_hl(0, "ErrorMsg", { bg = colors.red_4, fg = colors.red_2 })
set_hl(0, "ModeMsg", { bg = "none", fg = colors.red_2, underline = true })
set_hl(0, "MoreMsg", { bg = "none", fg = colors.red_2, underline = true })
set_hl(0, "Underlined", { bg = "none", fg = colors.red_2, underline = true })

-- Window Highlights
set_hl(0, "WinActive", { bg = colors.red_2, fg = colors.monochrome_7, bold = true })
set_hl(0, "WinInactive", { bg = colors.red_6, fg = colors.red_2 })
set_hl(0, "WinNeighbor", { link = "WinInactive" })
set_hl(0, "NormalFloat", { bg = "none" })
set_hl(0, "Pmenu", { bg = "none", fg = colors.red_2 })
set_hl(0, "PmenuSel", { bg = colors.red_2, fg = "none" })
set_hl(0, "PmenuSbar", { bg = "none", fg = colors.red_2 })
set_hl(0, "PmenuThumb", { bg = colors.red_2, fg = "none" })

-- Treesitter
set_hl(0, "@variable", { bg = "none", fg = colors.red_2 })

-- GitSigns
set_hl(0, "GitSignsAdd", { fg = colors.red_2 })
set_hl(0, "GitSignsChange", { fg = colors.red_4 })
set_hl(0, "GitSignsDelete", { fg = colors.red_2 })
set_hl(0, "GitSignsAddLn", { bg = colors.monochrome_6 })
set_hl(0, "GitSignsChangeLn", { bg = colors.monochrome_6 })

-- Diagnostics
set_hl(0, "DiagnosticError", { bg = colors.red_6, fg = colors.red_1, bold = true })
set_hl(0, "DiagnosticWarn", { bg = "none", fg = colors.bright_pink })
set_hl(0, "DiagnosticInfo", { fg = colors.bright_pink })
set_hl(0, "DiagnosticHint", { bg = "none", fg = colors.red_5, italic = true })

set_hl(0, "DiagnosticSignError", { bg = "none", fg = colors.red_2 })
set_hl(0, "DiagnosticSignWarn", { bg = "none", fg = colors.red_2 })
set_hl(0, "DiagnosticSignInfo", { link = "DiagnosticInfo" })
set_hl(0, "DiagnosticSignHint", { link = "DiagnosticHint" })

set_hl(0, "DiagnosticUnderlineError", { bg = "none", fg = "none", sp = colors.red_3, underline = true })
set_hl(0, "DiagnosticUnderlineWarn", { bg = "none", fg = "none", sp = colors.bright_pink, underline = true })
set_hl(0, "DiagnosticUnderlineHint", { bg = "none", fg = "none", sp = colors.red_3, underline = true })

-- Blink
set_hl(0, "BlinkCmpGhostText", { fg = colors.red_5 })
set_hl(0, "BlinkCmpScrollBarThumb", { bg = colors.red_3 })
set_hl(0, "BlinkCmpMenuSelection", { bg = colors.red_5, fg = colors.red_1, bold = true })

-- STATUSLINE CONFIG

-- Disable showmode and enable global statusline
vim.opt.showmode = false
vim.opt.laststatus = 3
