return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
		{
			"saghen/blink.compat",
			lazy = true,
		},
		"hrsh7th/cmp-calc",
		"moyiz/blink-emoji.nvim",
		"bydlw98/blink-cmp-env",
		"Kaiser-Yang/blink-cmp-git",
		"folke/lazydev.nvim",
		"MahanRahmati/blink-nerdfont.nvim",
		"mikavilpas/blink-ripgrep.nvim",
		"ribru17/blink-cmp-spell",
		"archie-judd/blink-cmp-words",
		"marcoSven/blink-cmp-yanky",
	},
	version = "*",
	event = { "InsertEnter", "CmdlineEnter" },
	opts = {
		keymap = {
			preset = "enter",
			["<C-K>"] = { "select_prev", "fallback" },
			["<C-J>"] = { "select_next", "fallback" },
			["<S-TAB>"] = { "select_prev", "fallback" },
			["<TAB>"] = { "select_next", "fallback" },
			["<C-U>"] = { "cancel" },
			["<C-E>"] = { "hide" },
			["<C-D>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-S>"] = {
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
			default = {
				"buffer",
				"calc",
				"emoji",
				"env",
				"git",
				"lazydev",
				"lsp",
				"nerdfont",
				"path",
				"ripgrep",
				"snippets",
				"spell",
				"thesaurus",
				"yank",
			},
			providers = {
				calc = {
					name = "calc",
					module = "blink.compat.source",
				},
				emoji = {
					name = "Emoji",
					module = "blink-emoji",
					score_offset = 15, -- Tune by preference
					opts = { insert = true }, -- Insert emoji (default) or complete its name
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
				git = {
					module = "blink-cmp-git",
					name = "Git",
					opts = {},
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
				nerdfont = {
					name = "Nerd Fonts",
					module = "blink-nerdfont",
					score_offset = 10, -- Tune by preference
					opts = { insert = true }, -- Insert emoji (default) or complete its name
				},
				ripgrep = {
					name = "Ripgrep",
					module = "blink-ripgrep",
				},
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
				},
				thesaurus = {
					name = "blink-cmp-words",
					module = "blink-cmp-words.thesaurus",
					-- All available options
					opts = {
						-- A score offset applied to returned items.
						-- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
						score_offset = 0,

						-- Default pointers define the lexical relations listed under each definition,
						-- see Pointer Symbols below.
						-- Default is as below ("antonyms", "similar to" and "also see").
						definition_pointers = { "!", "&", "^" },

						-- The pointers that are considered similar words when using the thesaurus,
						-- see Pointer Symbols below.
						-- Default is as below ("similar to", "also see" }
						similarity_pointers = { "&", "^" },

						-- The depth of similar words to recurse when collecting synonyms. 1 is similar words,
						-- 2 is similar words of similar words, etc. Increasing this may slow results.
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
				},
			},
		},
	},
	opts_extend = {
		"sources.default",
	},
}
