local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {'nvim-telescope/telescope.nvim', dependencies = {'nvim-lua/plenary.nvim'}},
  -- {'s1n7ax/nvim-window-picker'},
  {'mhinz/vim-startify'},
  {'dstein64/vim-win'},
	{'is0n/fm-nvim'},
  {'kdheepak/lazygit.nvim'},
  {'arecarn/vim-crunch'},
  {'hrsh7th/nvim-cmp',
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-calc",
  }},
  {"norcalli/nvim-colorizer.lua"},
  {"numToStr/FTerm.nvim"},
  {"nvimdev/indentmini.nvim"},
  {"nvim-treesitter/nvim-treesitter"},
  {"lewis6991/gitsigns.nvim"},
  {"petertriho/nvim-scrollbar"},
  {"kevinhwang91/nvim-hlslens"},
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    event = "VeryLazy",
    config = function()
      require('tiny-devicons-auto-colors').setup({
        colors = {"#D00000"},
      })
    end
  },
})

local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)

-- NVIM-CMP
local cmp = require'cmp'

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = {
		["<C-K>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		["<C-J>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		["<TAB>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		["<C-S-K>"] = cmp.mapping(cmp.mapping.select_prev_item({count = 5}), {'i', 'c'}),
		["<C-S-J>"] = cmp.mapping(cmp.mapping.select_next_item({count = 5}), {'i', 'c'}),
		["<C-P>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), {'i', 'c'}),
		["<C-N>"] = cmp.mapping(cmp.mapping.scroll_docs(5), {'i', 'c'}),
		["<C-d>"] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		["<C-e>"] = cmp.mapping {
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		},
		-- ["<CR>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { 'i', 'c' }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	},
	sources = cmp.config.sources({
		{ name = 'buffer',
			option = {
				get_bufnrs = function()
					return vim.api.nvim_list_bufs()
				end
			}
		},
		{ name = 'calc' },
		{ name = 'path' },
    { name = "nvim_lsp" },
	}),
	experimental = {
		ghost_text = true,
	},
	formatting = {
		fields = {"abbr"},
	}
})

cmp.setup.cmdline('/', {
	sources = {
		{ name = 'buffer' }
	}
})

cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

-- FTERM
vim.keymap.set('n', '<space>t', '<CMD>lua require("FTerm").toggle()<CR>')
-- vim.keymap.set('t', '<c-q>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
vim.api.nvim_create_user_command('FTermOpen', require('FTerm').open, { bang = true })

require'FTerm'.setup({
    border = 'rounded',
})

-- TELESCOPE
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space>f', ":Telescope<CR>", {})
vim.keymap.set('v', '<space>f', "y<ESC>:Telescope live_grep default_text=<C-r>0<CR>", {})

local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		-- path_display = { "smart" },
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<c-q>"] = actions.close,
				["<c-d>"] = actions.delete_buffer,
				["<c-r>"] = actions.delete_mark,
				["<c-k>"] = actions.move_selection_previous,
				["<c-j>"] = actions.move_selection_next,
				["<c-l>"] = actions.select_default,
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
			additional_args = {"--hidden"}
		},
		live_grep = {
			additional_args = {"--hidden"}
		},
	},
})

-- FM-NVIM
require('fm-nvim').setup{
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
		ESC        = "<ESC>"
	},
}

vim.keymap.set('n', '<space>x', function()
  if vim.api.nvim_buf_get_name(0) == '' then
    vim.cmd [[Vifm --select %:p:h]]
  else
    vim.cmd [[Vifm --select %]]
  end
end, { desc = 'Open File Manager (vifm)' })

-- NVIM-TREESITTER
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,  -- Enable Treesitter-based syntax highlighting
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'vs',
      scope_incremental = '<CR>',
      node_incremental = '<TAB>',
      node_decremental = '<S-TAB>',
    },
  },
}

-- INDENTMINI
require("indentmini").setup()
-- Colors are applied automatically based on user-defined highlight groups.
-- There is no default value.
vim.cmd.highlight('IndentLine guifg=#400000')
-- Current indent line highlight
vim.cmd.highlight('IndentLineCurrent guifg=#800000')

-- GITSIGNS
require('gitsigns').setup {
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 200,
  },
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', 'h]', function()
      if vim.wo.diff then
        vim.cmd.normal({'h]', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', 'h[', function()
      if vim.wo.diff then
        vim.cmd.normal({'h[', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<space>hs', gitsigns.stage_hunk)
    map('n', '<space>hr', gitsigns.reset_hunk)
    map('v', '<space>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<space>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<space>hS', gitsigns.stage_buffer)
    map('n', '<space>hu', gitsigns.undo_stage_hunk)
    map('n', '<space>hR', gitsigns.reset_buffer)
    map('n', '<space>hp', gitsigns.preview_hunk)
    map('n', '<space>hb', function() gitsigns.blame_line{full=true} end)
    map('n', '<space>tb', gitsigns.toggle_current_line_blame)
    map('n', '<space>hd', gitsigns.diffthis)
    map('n', '<space>hD', function() gitsigns.diffthis('~') end)
    map('n', '<space>td', gitsigns.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- COLORIZER
require('colorizer').setup()

require("scrollbar").setup({
  handle = {
    color = '#600000',
  },
  marks = {
    Search = { color = '#D00000' },
    Error = { color = '#D00000' },
    Warn = { color = '#D00000' },
    Info = { color = '#D00000' },
    Hint = { color = '#D00000' },
    Misc = { color = '#D00000' },
  },
  handlers = { search = true },
})

-- LSP
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "ast_grep",
    "harper_ls",
    "pyright",
    "clangd",
    "lua_ls",
    "yamlls",
  },
  automatic_installation = true,
})
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
  function(server_name)
    lspconfig[server_name].setup {}
  end,
})

vim.diagnostic.config({
  signs = false,
})

-- STARTIFY
function _G.webDevIcons(path)
  local filename = vim.fn.fnamemodify(path, ':t')
  local extension = vim.fn.fnamemodify(path, ':e')
  return require'nvim-web-devicons'.get_icon(filename, extension, { default = true })
end
