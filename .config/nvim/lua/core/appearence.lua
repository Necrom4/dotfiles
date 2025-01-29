local set_hl = vim.api.nvim_set_hl
local colors = {
    white = "#FFFFFF",
    brightest_grey = "#D8D8D8",
    bright_grey = "#A5A5A5",
    grey = "#7F7F7F",
    dark_grey = "#4C4C4C",
    darkest_grey = "#262626",
    black = "#000000",
    brightest_red = "#FF0000",
    red = "#D80000",
    bright_red = "#B20000",
    mid_red = "#7F0000",
    dark_red = "#4C0000",
    darkest_red = "#260000",
    yellow = "#FFFF00",
    green = "#00BF00",
    brown = "#595900",
    bright_pink = "#FF7F7F",
}

-- General
set_hl(0, "Normal", { bg = "none", fg = colors.red })
set_hl(0, "NormalNC", { bg = "none", fg = colors.red })
set_hl(0, "Comment", { bg = "none", fg = colors.mid_red })
set_hl(0, "Include", { bg = "none", fg = colors.red })
set_hl(0, "Define", { bg = "none", fg = colors.red, underline = true })
set_hl(0, "Bold", { bg = "none", fg = colors.red, bold = true })
set_hl(0, "Constant", { bg = "none", fg = colors.red })
set_hl(0, "Conditional", { bg = "none", fg = colors.red, bold = true })
set_hl(0, "NonText", { bg = "none", fg = colors.mid_red })
set_hl(0, "Error", { bg = colors.mid_red, fg = colors.brightest_red, bold = true, underline = true })
set_hl(0, "Number", { bg = "none", fg = colors.brightest_red, bold = true })
set_hl(0, "Float", { bg = "none", fg = colors.brightest_red, bold = true })
set_hl(0, "String", { bg = "none", fg = colors.mid_red })
set_hl(0, "Delimiter", { bg = "none", fg = colors.mid_red })
set_hl(0, "Function", { bg = "none", fg = colors.red })
set_hl(0, "Special", { bg = "none", fg = colors.red })
set_hl(0, "Statement", { bg = "none", fg = colors.brightest_red, bold = true })
set_hl(0, "Identifier", { bg = "none", fg = colors.red, bold = true })

set_hl(0, "QuickFixLine", { bg = "#400000", fg = colors.red })
set_hl(0, "markdownCode", { bg = "#330000", fg = colors.brightest_red })
set_hl(0, "markdownCodeBlock", { bg = "#220000", fg = colors.red })

set_hl(0, "Todo", { bg = colors.red, fg = colors.mid_red })
set_hl(0, "WildMenu", { bg = "none", fg = colors.red })
set_hl(0, "MatchParen", { bg = colors.mid_red, fg = colors.brightest_red, bold = true })
set_hl(0, "Visual", { bg = colors.dark_red, fg = colors.brightest_red })
set_hl(0, "Repeat", { bg = "none", fg = colors.red, bold = true })
set_hl(0, "IncSearch", { bg = colors.dark_red, fg = colors.brightest_red, underline = true })
set_hl(0, "Search", { bg = colors.darkest_red, fg = colors.mid_red, underline = true })
set_hl(0, "CurSearch", { bg = colors.dark_red, fg = colors.brightest_red, underline = true })
set_hl(0, "SpecialKey", { bg = "none", fg = colors.red })
set_hl(0, "PreProc", { bg = "none", fg = colors.red })
set_hl(0, "Operator", { bg = "none", fg = colors.mid_red })
set_hl(0, "Type", { bg = "none", fg = colors.red })
set_hl(0, "Title", { bg = "none", fg = colors.brightest_red, bold = true })
set_hl(0, "Boolean", { bg = "none", fg = colors.brightest_red, bold = true })

-- StatusLine
set_hl(0, "StatusLine", { bg = colors.red, fg = colors.black, bold = true})
set_hl(0, "StatusLineArrow", { bg = colors.darkest_red, fg = colors.red })
set_hl(0, "StatusLineInfo", { bg = colors.darkest_red, fg = colors.bright_red })
set_hl(0, "StatusLineInfoMain", { bg = colors.darkest_red, fg = colors.brightest_red, bold = true })
set_hl(0, "StatusLineNC", { bg = colors.mid_red, fg = colors.black })
set_hl(0, "StatusLineNCArrow", { bg = colors.black, fg = colors.darkest_red })
set_hl(0, "StatusLineNCInfo", { bg = colors.black, fg = colors.darkest_red })
set_hl(0, "StatusLineNCInfoMain", { bg = colors.black, fg = colors.darkest_red })

-- TabLine
set_hl(0, "TabLine", { bg = colors.darkest_red, fg = colors.red })
set_hl(0, "TabLineSel", { bg = colors.red, fg = colors.black, bold = true })
set_hl(0, "TabLineFill", { bg = colors.black, fg = colors.darkest_red })

-- Cursor Highlights
set_hl(0, "Cursor", { bg = "none", fg = colors.red })
set_hl(0, "CursorLine", { bg = colors.darkest_red })
set_hl(0, "CursorLineFold", { bg = "none", fg = colors.mid_red })

set_hl(0, "Folded", { bg = "none", fg = colors.dark_red, bold = true })

-- Columns
set_hl(0, "LineNr", { bg = "none", fg = colors.red })
set_hl(0, "LineNrAbove", { bg = "none", fg = colors.mid_red })
set_hl(0, "LineNrBelow", { bg = "none", fg = colors.mid_red })
set_hl(0, "SignColumn", { bg = "none", fg = colors.red })
set_hl(0, "FoldColumn", { bg = "none", fg = colors.red })
set_hl(0, "CursorLineNr", { bg = "none", fg = "none" })
set_hl(0, "CursorColumn", { bg = colors.darkest_grey })

-- Windows
set_hl(0, "Directory", { bg = "none", fg = colors.mid_red })
set_hl(0, "VertSplit", { bg = "none", fg = colors.mid_red })

-- Diff Highlights
set_hl(0, "DiffAdd", { bg = "none", fg = colors.green })
set_hl(0, "DiffChange", { bg = "none", fg = colors.yellow })
set_hl(0, "DiffDelete", { bg = "none", fg = colors.mid_red })
set_hl(0, "DiffText", { bg = colors.brown, fg = colors.yellow })

-- Error
set_hl(0, "SpellBad", { bg = colors.mid_red, fg = colors.red, underline = true })
set_hl(0, "ErrorMsg", { bg = colors.mid_red, fg = colors.red })
set_hl(0, "ModeMsg", { bg = "none", fg = colors.red, underline = true })
set_hl(0, "MoreMsg", { bg = "none", fg = colors.red, underline = true })
set_hl(0, "Underlined", { bg = "none", fg = colors.red, underline = true })

-- Window Highlights
set_hl(0, "WinActive", { bg = colors.red, fg = colors.black, bold = true })
set_hl(0, "WinInactive", { bg = colors.darkest_red, fg = colors.red })
set_hl(0, "WinNeighbor", { link = "WinInactive" })
set_hl(0, "NormalFloat", { bg = "none" })
set_hl(0, "Pmenu", { bg = "none", fg = colors.red })
set_hl(0, "PmenuSel", { bg = colors.red, fg = "none" })
set_hl(0, "PmenuSbar", { bg = "none", fg = colors.red })
set_hl(0, "PmenuThumb", { bg = colors.red, fg = "none" })

-- Treesitter
set_hl(0, "@variable", { bg = "none", fg = colors.red })

-- GitSigns
set_hl(0, "GitSignsAdd", { fg = colors.red })
set_hl(0, "GitSignsChange", { fg = colors.mid_red })
set_hl(0, "GitSignsDelete", { fg = colors.red })
set_hl(0, "GitSignsAddLn", { bg = colors.darkest_grey })
set_hl(0, "GitSignsChangeLn", { bg = colors.darkest_grey })

-- Diagnostics
set_hl(0, "DiagnosticError", { bg = colors.darkest_red, fg = colors.red })
set_hl(0, "DiagnosticWarn", { bg = colors.darkest_red, fg = colors.bright_pink })
set_hl(0, "DiagnosticInfo", { fg = colors.brown })
set_hl(0, "DiagnosticHint", { bg = colors.brown, fg = colors.bright_red, italic = true })

set_hl(0, "DiagnosticSignError", { bg = "none", fg = colors.red })
set_hl(0, "DiagnosticSignWarn", { bg = "none", fg = colors.red })
set_hl(0, "DiagnosticSignInfo", { link = "DiagnosticInfo" })
set_hl(0, "DiagnosticSignHint", { link = "DiagnosticHint" })

set_hl(0, "DiagnosticUnderlineError", { bg = "none", fg = "none", sp = "#A00000", underline = true })
set_hl(0, "DiagnosticUnderlineWarn", { bg = "none", fg = "none", sp = "#ff7f7f", underline = true })
set_hl(0, "DiagnosticUnderlineHint", { bg = "none", fg = "none", sp = "#A00000", underline = true })
