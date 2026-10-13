-- Run with the real config: nvim --headless '+luafile tests/obsidian_graph_command.lua' +qa
require("lazy").load({ plugins = { "obsidian.nvim" } })
local commands = require("obsidian.commands")
assert(commands.commands.graph, "Graph registered")
assert(vim.tbl_contains(commands.get_completions("gr", "Obsidian gr", 11), "graph"), "Graph completion")
assert(vim.fn.exists(":ObsidianGraph") == 0, "Standalone command removed")
local picker = require("obsidian.picker")
local original_select = picker.select
local choices
picker.select = function(items) choices = items end
commands.show_menu({ range = 0 })
picker.select = original_select
assert(vim.tbl_contains(choices, "graph"), "Graph offered by Obsidian picker")
local graph = require("obsidian_graph")
local original_open, called = graph.open, false
graph.open = function() called = true end
vim.cmd("Obsidian graph")
graph.open = original_open
assert(called, "Obsidian graph invokes view")
print("Obsidian command integration tests passed")
