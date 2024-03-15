syntax on
set mouse=a
set number
set relativenumber
filetype indent on
set wildmenu
set showmatch
set ruler
set noswapfile
set hlsearch
set incsearch
" set autoindent
" set noexpandtab
" set ts=4 sw=4
" set formatoptions-=cro
set splitbelow
set timeoutlen=250
set linebreak
autocmd FileType * set formatoptions-=cro ts=2 sw=2 noexpandtab
" set nowrap
" set cursorline
" set cursorcolumn

" //StatusLine//
set noshowmode
let g:isInsert = ''

function! IsModified()
    if &modified
        return ''
    else
        return ' '
    endif
endfunction
function! ModeName()
  let mode_dict = {'n': 'NORMAL', 'i': 'INSERT', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-V>": 'V-BLOCK', 'R': 'REPLACE', 's': 'SELECT', 'S': 'S-LINE', "\<C-S>": 'S-BLOCK', 't': 'TERMINAL', 'c': 'COMMAND'}
  return get(mode_dict, mode(), 'UNKNOWN')
endfunction

highlight StatusLineMe ctermbg=160 ctermfg=16 cterm=reverse
highlight StatusLineNCMe ctermbg=88 ctermfg=16 cterm=reverse
highlight Italica ctermbg=16 ctermfg=196 cterm=italic

set statusline=%#StatusLine#\ %{ModeName()}%{IsModified()}%#StatusLineMe#%#Normal#%{eval('g:isInsert')}\ %<%{expand('%:p:h')}/%#Boolean#%{expand('%:t:r')}%#Normal#.%{expand('%:e')}\ %=%h%r%w[%n][%c:%l][%p%%/%L]
augroup StatusLineChange
  autocmd!
  autocmd InsertEnter * let g:isInsert = ''
  autocmd InsertLeave * let g:isInsert = ' '
  autocmd WinEnter * setlocal statusline=%#StatusLine#\ %{ModeName()}%{IsModified()}%#StatusLineMe#%#Normal#%{eval('g:isInsert')}\ %<%{expand('%:p:h')}/%#Boolean#%{expand('%:t:r')}%#Normal#.%{expand('%:e')}\ %=%h%r%w[%n][%c:%l][%p%%/%L]
  autocmd WinLeave * setlocal statusline=%#StatusLineNC#\ %{ModeName()}%{IsModified()}%#StatusLineNCMe#%{eval('g:isInsert')}\ %<%{expand('%:p:h')}/%#Normal#%{expand('%:t:r')}%#StatusLineNCMe#.%{expand('%:e')}\ %=%h%r%w[%n][%c:%l][%p%%/%L]
augroup END

autocmd ModeChanged * if mode() == 'i' | highlight LineNr ctermbg=16 ctermfg=88 | else | highlight LineNr ctermbg=16 ctermfg=196 | endif

" //Highlights//
highlight Normal ctermbg=16 ctermfg=196 cterm=none
highlight Comment ctermbg=16 ctermfg=88 cterm=none
highlight Include ctermbg=16 ctermfg=196 cterm=bold
highlight Define ctermbg=16 ctermfg=196 cterm=bold
highlight Constant ctermbg=16 ctermfg=196 cterm=bold
highlight Conditional ctermbg=16 ctermfg=196 cterm=underline
highlight NonText ctermbg=16 ctermfg=88 cterm=none
highlight Error ctermfg=196 ctermbg=88 cterm=bold
highlight Number ctermbg=16 ctermfg=196 cterm=none
highlight String ctermbg=16 ctermfg=124 cterm=none
highlight Float ctermbg=16 ctermfg=196 cterm=bold
highlight Function ctermbg=16 ctermfg=196 cterm=bold
highlight Special ctermbg=16 ctermfg=196 cterm=none
highlight Statement ctermbg=16 ctermfg=196 cterm=bold
highlight Identifier ctermbg=16 ctermfg=196 cterm=none
" highlight LineNr ctermbg=16 ctermfg=196
highlight LineNrAbove ctermbg=16 ctermfg=88 cterm=none
highlight LineNrBelow ctermbg=16 ctermfg=88 cterm=none
highlight Todo ctermbg=196 ctermfg=88
highlight WildMenu ctermbg=16 ctermfg=196
highlight MatchParen ctermbg=88 ctermfg=196 cterm=none
highlight TabLine ctermbg=16 ctermfg=196 cterm=bold,underline
highlight TabLineSel ctermbg=196 ctermfg=16 cterm=bold
highlight TabLineFill ctermbg=16 ctermfg=196 cterm=bold,underline
highlight Visual ctermbg=196 ctermfg=16 cterm=none
highlight Repeat ctermbg=16 ctermfg=196 cterm=bold
highlight IncSearch ctermbg=16 ctermfg=160
highlight Search ctermbg=88 ctermfg=196
highlight SpecialKey ctermbg=16 ctermfg=196 cterm=none
highlight PreProc ctermbg=16 ctermfg=196 cterm=none
highlight StatusLine ctermbg=16 ctermfg=160
highlight StatusLineNC ctermbg=16 ctermfg=88
highlight StatusLineTerm ctermbg=160 ctermfg=16
highlight StatusLineTermNC ctermbg=88 ctermfg=16
highlight Operator ctermbg=16 ctermfg=196 cterm=none
highlight Type ctermbg=16 ctermfg=196 cterm=bold
highlight Conditional ctermbg=16 ctermfg=196 cterm=bold
highlight Title ctermbg=16 ctermfg=196 cterm=none
highlight Boolean ctermbg=16 ctermfg=196 cterm=bold
highlight Special ctermbg=16 ctermfg=196
highlight Cursor ctermbg=16 ctermfg=196
highlight CursorLine ctermbg=none ctermfg=none cterm=none
highlight CursorLineFold ctermbg=none ctermfg=88 cterm=none
highlight CursorLineNr ctermbg=none ctermfg=none cterm=none
highlight CursorColumn ctermbg=none ctermfg=none cterm=none
highlight Folded ctermbg=16 ctermfg=88 cterm=bold
highlight FoldColumn ctermbg=none ctermfg=88 cterm=none
highlight SignColumn ctermbg=16 ctermfg=196
highlight Pmenu ctermbg=16 ctermfg=196
highlight PmenuSel ctermbg=196 ctermfg=16
highlight PmenuSbar ctermbg=16 ctermfg=196
highlight Directory ctermbg=16 ctermfg=196
highlight VertSplit ctermbg=16 ctermfg=88
highlight ErrorMsg ctermbg=88 ctermfg=196
highlight ModeMsg ctermbg=16 ctermfg=196 cterm=underline
highlight MoreMsg ctermbg=16 ctermfg=196 cterm=underline
highlight DiffAdd ctermbg=16 ctermfg=40 cterm=none
highlight DiffChange ctermbg=16 ctermfg=39 cterm=none
highlight DiffDelete ctermbg=16 ctermfg=88 cterm=none
highlight DiffText ctermbg=20 ctermfg=51 cterm=none
highlight SpellBad ctermbg=88 ctermfg=196 cterm=underline

" Use an autocmd to trigger the setup function when entering TelescopePrompt
augroup TelescopeMappings
  autocmd!
  autocmd FileType TelescopePrompt call SetupTelescopeMappings()
augroup END

" //Save/Quit//
:noremap <silent> <C-S> :w<CR>
:vnoremap <silent> <C-S> <C-C>:w<CR>
:inoremap <silent> <C-S> <C-O>:w<CR>
:noremap <silent> <C-Q> :q<CR>
:vnoremap <silent> <C-Q> <C-C>:q<CR>
:inoremap <silent> <C-Q> <C-O>:q<CR>
" :tnoremap <silent> <C-Q> <C-\><C-N>:q!<CR>
:noremap <silent> <C-S><C-A> :wa<CR>
:vnoremap <silent> <C-S><C-A> <C-C>:wa<CR>
:inoremap <silent> <C-S><C-A> <C-O>:wa<CR>
:noremap <silent> <C-Q><C-A> :qa<CR>
:vnoremap <silent> <C-Q><C-A> <C-C>:qa<CR>
:inoremap <silent> <C-Q><C-A> <C-O>:qa<CR>
:tnoremap <silent> <C-Q><C-A> <C-\><C-N>:qa<CR>
:noremap <silent> <C-Q><C-Q> :q!<CR>
:vnoremap <silent> <C-Q><C-Q> <C-C>:q!<CR>
:inoremap <silent> <C-Q><C-Q> <C-O>:q!<CR>
:noremap <silent> <C-S><C-Q> :wq<CR>
:vnoremap <silent> <C-S><C-Q> <C-C>:wq<CR>
:inoremap <silent> <C-S><C-Q> <C-O>:wq<CR>
:noremap <silent> <C-S><C-Q><C-A> :wqa<CR>
:vnoremap <silent> <C-S><C-Q><C-A> <C-C>:wqa<CR>
:inoremap <silent> <C-S><C-Q><C-A> <C-O>:wqa<CR>
:tnoremap <silent> <C-S><C-A><C-Q> <C-\><C-N>:wqa<CR>
:noremap <silent> <C-Q><C-A><C-Q> :qa!<CR>
:vnoremap <silent> <C-Q><C-A><C-Q> <C-C>:qa!<CR>
:inoremap <silent> <C-Q><C-A><C-Q> <C-O>:qa!<CR>
:tnoremap <silent> <C-Q><C-A><C-Q> <C-\><C-N>:qa!<CR>

:map <silent> <enter> A<enter><esc>
:map <silent> <S-enter> I<enter><esc>kcc<esc>
" :nnoremap <silent> <BS> i<BS><ESC>l
" :nnoremap <silent> <TAB> i<TAB><ESC>l
" :nnoremap <silent> <SPACE> i<SPACE><ESC>l
:map <space>h :noh<CR>:echo '["' . @/ . '" cleared]'<CR>
:nmap ' `
:noremap <silent> <c-/> K
:vnoremap <expr> <silent> <space>= mode() ==# "v" ? "<ESC>:set paste<CR>a<CR><ESC>`<i<CR><ESC>V:!bc<CR>gJkgJ:set nopaste<CR>" : ":!bc<CR>"
:nnoremap <silent> <space>v :source ~/.config/nvim/vimrc.vim<CR>:noh<CR>:echo "[VIM Reloaded]"<CR>
" :tnoremap <silent> <S-Space> <ESC>a<space>
nnoremap <silent> <space>b :silent !open %<CR>
let g:cwd = system('~/42/Scripts/./cwd.sh')

" //Normal Mode Navigation//
:noremap <silent> MM zz
:noremap <silent> J L
:noremap <silent> K H
:noremap <silent> L $
:noremap <silent> H 0
" :noremap <silent> JJ J
:noremap <silent> gK kgJ
:nnoremap <silent> <C-J> <C-F>
:nnoremap <silent> <C-K> <C-B>
:vnoremap <silent> <C-J> <C-F>
:vnoremap <silent> <C-K> <C-B>
" :inoremap <silent> <S-BS> <DEL>
:nnoremap ;j <C-O>
:nnoremap ;k <C-I>
:nnoremap <C-S-K> kzz
:nmap <C-S-J> jzz

" //Insert Mode Navigation//
:inoremap <C-h> <Left>
:inoremap <C-S-H> <Esc>bi
:inoremap <C-j> <Down>
:inoremap <C-S-J> <Esc>gja
:inoremap <C-k> <Up>
:inoremap <C-S-K> <Esc>gka
:inoremap <C-l> <Right>
:inoremap <C-S-L> <Esc>lea
:cnoremap <C-h> <Left>
:cnoremap <C-j> <Down>
:cnoremap <C-k> <Up>
:cnoremap <C-l> <Right>
" :tnoremap <C-h> <Left>
" :tnoremap <C-S-H> <Esc>bi
" :tnoremap <C-j> <Down>
" :tnoremap <C-k> <Up>
" :tnoremap <C-l> <Right>
" :tnoremap <C-S-L> <Esc>lwi

" //Copy Text//
:vnoremap <expr> <C-C> mode() ==# "v" ? '"+y:echo @+<CR>' : '<ESC>`<v`>"+y'
:nnoremap <C-C> :let @+ = @0<CR>:echo @0<CR>
:nnoremap <silent> yp :let @" = expand("%")<CR>p
:nnoremap <silent> yP :let @" = expand("%:p")<CR>p
:nnoremap <silent> yc :let @" = @:<CR>p

" //Windows//
autocmd BufLeave term://* set nonumber norelativenumber
autocmd ModeChanged * if mode() == 't' | set nonumber norelativenumber | else | set number | endif
autocmd ModeChanged * if mode() != 't' | match ErrorMsg '\s\+$' | else | highlight clear ErrorMsg | endif
:tnoremap <C-W> <C-\><C-N><C-W>
:tnoremap <silent> <S-ESC> <C-\><C-N>
:nnoremap <silent> <C-W>v <C-W>v<C-W>w
" :map <silent> <space>W <C-W>v<C-W>s:ter<CR><C-W>h<C-W>s<space>w1<ESC>
autocmd BufWinEnter,WinEnter term://* startinsert
augroup toogle_relatie_number
	au!
	autocmd InsertEnter * :setlocal norelativenumber
	autocmd InsertLeave * :setlocal relativenumber
augroup END
" augroup TerminalInsertMode
" 	autocmd!
" 	autocmd BufEnter term://* startinsert
" augroup END

" //Tabs//
:noremap <C-T>n :tabnew \| Startify<CR>
:noremap <C-T>l gt
:noremap <C-T>h gT
:noremap <C-T>q :tabclose<CR>

" //Folds//
" autocmd FileType * nnoremap <buffer> <silent> zf :set foldcolumn=1<CR>zf
" autocmd FileType * vnoremap <buffer> <silent> zf :<C-u>set foldcolumn=1<CR>gvzf
" :nnoremap <silent> Zo zR
" :nnoremap <silent> Zc zM

" //42 header//
let g:user42 = 'dferreir'
let g:mail42 = 'dferreir@student.42.fr'

" //LazyVim//
:map <silent> <space>l :Lazy<CR>

" //LazyGit//
:nnoremap <silent> <space>g :LazyGit<CR>

" //vim-win//
:nnoremap <silent> <space>w :Win<CR>

" //Commentary//
:xnoremap <space>c <Plug>Commentary
:nnoremap <space>c <Plug>Commentary
:onoremap <space>c <Plug>Commentary
:nnoremap <space>cc <Plug>CommentaryLine

" //Startify//
" function! S_Windows()
" 	wincmd v
" 	wincmd l
" 	normal gg
" 	wincmd s
" 	ter
" 	wincmd h
" 	normal gg
" 	wincmd s
" 	normal gg
" 	wincmd k
" endfunction

:nnoremap <silent> <space>e :Startify<CR>

let g:startify_custom_indices = map(range(1,100), 'string(v:val)')

let g:startify_fortune_use_unicode = 0

let g:startify_custom_header = [
	\ '  ╭────────────────────────────────────────────────────────╮',
	\ '  │ ███╗   ██╗███████╗ ██████╗██████╗  ██████╗ ███╗   ███╗ │',
	\ '  │ ████╗  ██║██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗ ████║ │',
	\ '  │ ██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██╔████╔██║ │',
	\ '  │ ██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║╚██╔╝██║ │',
	\ '  │ ██║ ╚████║███████╗╚██████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║ │',
	\ '  │ ╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ │',
	\ '  ╰────────────────────────────────────────────────────────╯',
	\]
" │╭─╮╰╯

let g:startify_commands = [
	\ {'f': ['󰈞  Find file', ':Telescope find_files']},
	\ {'w': ['󰍉  Find word', ':Telescope live_grep']},
	\ {'.': ['  CWD', "execute 'cd ' . g:cwd"]},
	\ {'r': ['  Recently opened files', ':Telescope oldfiles']},
	\ {'x': ['  Xplorer', ':Vifm']},
	\ {'t': ['  Terminal', ':FTermOpen']},
	\ {'m': ['  Marks', ':Telescope marks']},
	\ {'T': ['  Trash', ':! rm -rf /Users/dferreir/.local/share/vifm/Trash']},
    \ ]

let g:startify_bookmarks = [
      \ { 'bv': '~/.config/nvim/vimrc.vim'},
      \ { 'bl': '~/.config/nvim/init.lua'},
      \ { 'bx': '~/.config/vifm/vifmrc'},
      \ { 'bz': '~/.zshrc'},
      \ { 'bb': '~/.bashrc'},
      \ { 'bp': '~/.p10k.zsh'},
      \ { 'bm': '~/42/Templates/Makefile'},
      \ { 'b4': '~/42/Cursus/'},
      \ { 'bs': '~/42/Scripts/'},
      \ { 'blu': '~/.local/share/nvim/lazy/'},
      \ ]

let g:startify_lists = [
    \ { 'type': 'commands',  'header': ['   Commands']       },
    \ { 'type': 'files',     'header': ['   MRU']            },
    \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
    "\ { 'type': 'sessions',  'header': ['   Sessions']       },
    \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
    \ ]

" //VCOOLOR//
let g:vcoolor_disable_mappings = 1
" let g:vcoolor_map = '<space>C'
noremap <silent> <space>C :VCoolor<CR>

" //GITGUTTER//
" highlight GitGutterAdd guifg=#00FF00 ctermfg=Green
" highlight GitGutterChange guifg=#FFFF00 ctermfg=Yellow
" highlight GitGutterDelete guifg=#FF0000 ctermfg=Red
" let g:gitgutter_enabled=1
" let g:gitgutter_map_keys=0
" set signcolumn=yes
" let g:gitgutter_async=0
