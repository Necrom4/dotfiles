local utils = require("core.utils")

return {
	"saghen/blink.cmp",
	dependencies = {
		{
			"saghen/blink.compat",
			lazy = true,
		},
		"hrsh7th/cmp-calc",
		{
			"MattiasMTS/cmp-dbee",
			dependencies = {
				{ "kndndrj/nvim-dbee" },
			},
			ft = "sql",
			opts = {},
		},
		"moyiz/blink-emoji.nvim",
		"bydlw98/blink-cmp-env",
		"folke/lazydev.nvim",
		"MahanRahmati/blink-nerdfont.nvim",
		"mikavilpas/blink-ripgrep.nvim",
		"rafamadriz/friendly-snippets",
		"ribru17/blink-cmp-spell",
		"archie-judd/blink-cmp-words",
		"marcoSven/blink-cmp-yanky",
	},
	version = "*",
	event = { "InsertEnter", "CmdlineEnter" },
	opts = {
		keymap = {
			preset = "none",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-c>"] = { "cancel" },
			["<C-e>"] = { "hide" },
			["<C-d>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-t>"] = {
				function(cmp)
					cmp.show({ providers = { "snippets" } })
				end,
			},
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		cmdline = {
			completion = {
				list = { selection = { preselect = false } },
				menu = { auto_show = true },
				keymap = {
					["<C-j>"] = { "select_next" },
					["<C-k>"] = { "select_prev" },
				},
			},
		},
		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 100,
				window = {
					border = "rounded",
				},
			},
			list = { selection = { preselect = false } },
			ghost_text = { enabled = true, show_without_selection = true },
			menu = {
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon" },
					},
				},
				border = "rounded",
			},
		},
		signature = { enabled = true },
		sources = {
			default = function()
				local base = {
					"buffer",
					"calc",
					"emoji",
					"env",
					"lazydev",
					"lsp",
					"nerdfont",
					"path",
					"snippets",
					"spell",
					"thesaurus",
					"yank",
				}
				if not utils.is_yadm() then
					table.insert(base, "ripgrep")
				end
				return base
			end,
			per_filetype = {
				sql = { "dbee", "buffer" },
			},
			providers = {
				buffer = { score_offset = 800 },
				calc = {
					name = "calc",
					module = "blink.compat.source",
					score_offset = 1000,
					transform_items = function(ctx, items)
						for _, item in ipairs(items) do
							item.kind_icon = "󰃬"
							item.kind_hl = "Error"
						end
						return items
					end,
				},
				dbee = {
					name = "cmp-dbee",
					module = "blink.compat.source",
					score_offset = 1000,
					transform_items = function(ctx, items)
						for _, item in ipairs(items) do
							item.kind_icon = "󰆼"
							item.kind_name = "DBee"
							item.kind_hl = "BlinkCmpKindDBee"
						end
						return items
					end,
				},
				emoji = {
					name = "Emoji",
					module = "blink-emoji",
					score_offset = 1000,
					opts = { insert = true },
				},
				env = {
					name = "Env",
					module = "blink-cmp-env",
					opts = {
						item_kind = require("blink.cmp.types").CompletionItemKind.Variable,
						show_braces = false,
						show_documentation_window = true,
					},
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 1000,
				},
				lsp = { score_offset = 900 },
				nerdfont = {
					name = "Nerd Fonts",
					module = "blink-nerdfont",
					score_offset = 1000,
					opts = { insert = true },
				},
				path = { score_offset = 1000 },
				ripgrep = {
					name = "Ripgrep",
					module = "blink-ripgrep",
					opts = {},
					score_offset = 800,
				},
				snippets = { score_offset = 900 },
				spell = {
					name = "Spell",
					module = "blink-cmp-spell",
					opts = {
						enable_in_context = function()
							local curpos = vim.api.nvim_win_get_cursor(0)
							local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
							local in_spell_capture = false
							for _, cap in ipairs(captures) do
								if cap.capture == "spell" then
									in_spell_capture = true
								elseif cap.capture == "nospell" then
									return false
								end
							end
							return in_spell_capture
						end,
					},
					score_offset = 400,
				},
				thesaurus = {
					name = "blink-cmp-words",
					module = "blink-cmp-words.thesaurus",
					opts = {
						score_offset = 300,
						definition_pointers = { "!", "&", "^" },
						similarity_pointers = { "&", "^" },
						similarity_depth = 2,
					},
				},
				yank = {
					name = "yank",
					module = "blink-yanky",
					opts = {
						minLength = 5,
						onlyCurrentFiletype = true,
						trigger_characters = { '"' },
						kind_icon = "󰅍",
					},
					score_offset = 700,
				},
			},
		},
	},
	opts_extend = {
		"sources.default",
	},
}
