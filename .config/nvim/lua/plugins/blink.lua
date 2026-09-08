return {
	{
		"MattiasMTS/cmp-dbee",
		dependencies = {
			{ "kndndrj/nvim-dbee" },
		},
		ft = "sql",
		opts = {},
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			{
				"saghen/blink.compat",
				lazy = true,
			},
			"hrsh7th/cmp-calc",
			"bydlw98/blink-cmp-env",
			"newtoallofthis123/blink-cmp-fuzzy-path",
			"Kaiser-Yang/blink-cmp-git",
			"folke/lazydev.nvim",
			"mikavilpas/blink-ripgrep.nvim",
			"rafamadriz/friendly-snippets",
			"ribru17/blink-cmp-spell",
			"archie-judd/blink-cmp-words",
			"marcoSven/blink-cmp-yanky",
		},
		opts = {
			enabled = function()
				return vim.b.completion ~= false and not vim.tbl_contains({ "typr" }, vim.bo.filetype)
			end,
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-n>"] = {
					function(cmp)
						cmp.select_next({ jump_by = "source_id" })
					end,
				},
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
				-- Spell sources are available in every filetype, but their providers
				-- remain disabled until spelling is toggled on with <leader>us.
				default = function()
					local utils = require("utils.general")
					local base = {
						"buffer",
						"calc",
						"env",
						"fuzzy-path",
						"git",
						"lazydev",
						"lsp",
						"path",
						"snippets",
						"spell",
						"thesaurus",
						"yank",
					}
					if not utils.is_yadm_repo() then
						table.insert(base, "ripgrep")
					end
					return base
				end,
				per_filetype = {
					sql = { "dbee", "buffer" },
				},
				-- score_offset ladder. Ghost text always previews items[1], so anything
				-- ranked above `snippets` suppresses snippet previews. Utility sources
				-- are gated behind their own trigger characters and therefore do not
				-- need a high offset to be reachable.
				--
				--   1000  snippets, lazydev, dbee   (want to win outright)
				--    950  lsp
				--    900  path
				--    850  calc, env, git, fuzzy-path
				--    700  yank
				--    500  buffer
				--    400  ripgrep
				--    300  spell
				--    200  thesaurus
				providers = {
					buffer = { score_offset = 500 },
					calc = {
						name = "calc",
						module = "blink.compat.source",
						score_offset = 850,
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
					env = {
						name = "Env",
						module = "blink-cmp-env",
						opts = {
							item_kind = vim.lsp.protocol.CompletionItemKind.Variable,
							show_braces = false,
							show_documentation_window = true,
						},
						score_offset = 850,
					},
					["fuzzy-path"] = {
						name = "Fuzzy Path",
						module = "blink-cmp-fuzzy-path",
						score_offset = 850,
						opts = {
							filetypes = { "ruby", "*rb" },
							trigger_char = "/",
							max_results = 3,
							search_tool = "fd",
						},
					},
					git = {
						module = "blink-cmp-git",
						name = "Git",
						score_offset = 850,
						opts = {},
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 1000,
					},
					lsp = { score_offset = 950 },
					path = { score_offset = 900 },
					ripgrep = {
						name = "Ripgrep",
						module = "blink-ripgrep",
						opts = {},
						score_offset = 400,
					},
					snippets = {
						score_offset = 1000,
						-- Ghost text previews the expanded snippet body rather than just the
						-- trigger. See lua/utils/snippet_preview.lua for the full rationale.
						transform_items = function(ctx, items)
							return require("utils.snippet_preview").transform_items(ctx, items)
						end,
					},
					spell = {
						name = "Spell",
						module = "blink-cmp-spell",
						enabled = function()
							return vim.wo.spell
						end,
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
						score_offset = 300,
					},
					thesaurus = {
						name = "blink-cmp-words",
						module = "blink-cmp-words.thesaurus",
						enabled = function()
							return vim.wo.spell
						end,
						opts = {
							definition_pointers = { "!", "&", "^" },
							similarity_pointers = { "&", "^" },
							similarity_depth = 2,
						},
						score_offset = 200,
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
	},
}
