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
set autoindent
set expandtab
set ts=2 sw=2
set formatoptions-=cro
set splitbelow
set timeoutlen=250
set linebreak
"autocmd FileType * set formatoptions-=cro ts=2 sw=2 expandtab
"set nowrap
"set cursorline
"set cursorcolumn
"set iskeyword-=_,-
set termguicolors

" //StatusLine//
set noshowmode
set laststatus=3
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

highlight StatusLine guibg=#D00000 guifg=#000000 gui=bold
highlight StatusLineArrow guibg=#200000 guifg=#D00000
highlight StatusLineNC guibg=#900000 guifg=#000000 gui=bold
highlight StatusLineNCArrow guibg=#160000 guifg=#900000
highlight StatusLineInfo guibg=#200000 guifg=#A00000 gui=none
highlight StatusLineInfoMain guibg=#200000 guifg=#D00000 gui=bold
highlight StatusLineNCInfo guibg=#160000 guifg=#600000 gui=none
highlight StatusLineNCInfoMain guibg=#160000 guifg=#A00000 gui=bold

set statusline=%#StatusLine#\ %{ModeName()}%{IsModified()}%#StatusLineArrow#%{eval('g:isInsert')}\ %#StatusLineInfo#%<%{expand('%:p:h')}/%#StatusLineInfoMain#%{expand('%:t:r')}.%{expand('%:e')}\ %#StatusLineInfo#%=%h%r%w[%n][%c:%l][%p%%/%L]
augroup StatusLineChange
  autocmd!
  autocmd InsertEnter * let g:isInsert = ''
  autocmd InsertLeave * let g:isInsert = ' '
  autocmd WinEnter * setlocal statusline=%#StatusLine#\ %{ModeName()}%{IsModified()}%#StatusLineArrow#%{eval('g:isInsert')}\ %#StatusLineInfo#%<%{expand('%:p:h')}/%#StatusLineInfoMain#%{expand('%:t:r')}.%{expand('%:e')}\ %#StatusLineInfo#%=%h%r%w[%n][%c:%l][%p%%/%L]
	autocmd WinLeave * setlocal statusline=%#StatusLineNC#\ %{ModeName()}%{IsModified()}%#StatusLineNCArrow#\ %#StatusLineNCInfo#%<%{expand('%:p:h')}/%#StatusLineNCInfoMain#%{expand('%:t:r')}.%{expand('%:e')}\ %#StatusLineNCInfo#%=%h%r%w[%n][%c:%l][%p%%/%L]
augroup END

" //Highlights//
highlight Normal guibg=none guifg=#D00000 gui=none
highlight Comment guibg=none guifg=#900000 gui=none
highlight Include guibg=none guifg=#D00000 gui=none
highlight Define guibg=none guifg=#D00000 gui=underline
highlight Bold guibg=none guifg=#D00000 gui=bold
highlight Constant guibg=none guifg=#FF0000 gui=bold
highlight Conditional guibg=none guifg=#D00000 gui=underline
highlight NonText guibg=none guifg=#600000 gui=none
highlight Error guifg=#D00000 guibg=#600000 gui=bold,underline
highlight Number guibg=none guifg=#FF0000 gui=bold
highlight String guibg=none guifg=#A00000 gui=none
highlight Float guibg=none guifg=#D00000 gui=underline
highlight Delimiter guibg=none guifg=#900000 gui=none
highlight Function guibg=none guifg=#FF0000 gui=bold
highlight Special guibg=none guifg=#FF0000 gui=bold
highlight Statement guibg=none guifg=#D00000 gui=none
highlight Identifier guibg=none guifg=#D00000 gui=none
highlight LineNr guibg=none guifg=#D00000
highlight LineNrAbove guibg=none guifg=#800000 gui=none
highlight LineNrBelow guibg=none guifg=#800000 gui=none
highlight Todo guibg=#D00000 guifg=#600000
highlight WildMenu guibg=none guifg=#D00000
highlight MatchParen guibg=#600000 guifg=#D00000 gui=none
highlight TabLine guibg=none guifg=#D00000 gui=bold,underline
highlight TabLineSel guibg=#D00000 guifg=#000000 gui=bold
highlight TabLineFill guibg=none guifg=#D00000 gui=bold,underline
highlight Visual guibg=#600000 guifg=#FF0000 gui=none
highlight Repeat guibg=none guifg=#D00000 gui=bold
highlight IncSearch guibg=#600000 guifg=#D00000 gui=underline
highlight Search guibg=#300000 guifg=#A00000 gui=underline
highlight CurSearch guibg=#600000 guifg=#D00000 gui=underline
highlight SpecialKey guibg=none guifg=#D00000 gui=none
highlight PreProc guibg=none guifg=#D00000 gui=none
highlight Operator guibg=none guifg=#800000 gui=none
highlight Type guibg=none guifg=#D00000 gui=bold
highlight Conditional guibg=none guifg=#D00000 gui=bold
highlight Title guibg=none guifg=#D00000 gui=none
highlight Boolean guibg=none guifg=#D00000 gui=bold
highlight Cursor guibg=none guifg=#D00000
highlight CursorLine guibg=#300000
highlight CursorLineFold guibg=none guifg=#600000 gui=none
highlight CursorLineNr guibg=none guifg=none gui=none
highlight CursorColumn guibg=#202020
highlight Folded guibg=none guifg=#600000 gui=bold
highlight FoldColumn guibg=none guifg=#D00000 gui=none
highlight SignColumn guibg=none guifg=#D00000
highlight Pmenu guibg=none guifg=#D00000
highlight PmenuSel guibg=#D00000 guifg=#000000
highlight PmenuSbar guibg=none guifg=#D00000
highlight PmenuThumb guibg=#D00000 guifg=none
highlight Directory guibg=none guifg=#D00000
highlight VertSplit guibg=none guifg=#600000
highlight ErrorMsg guibg=#600000 guifg=#D00000
highlight ModeMsg guibg=none guifg=#D00000 gui=underline
highlight MoreMsg guibg=none guifg=#D00000 gui=underline
highlight DiffAdd guibg=none guifg=#00FF00 gui=none
highlight DiffChange guibg=none guifg=#FFF000 gui=none
highlight DiffDelete guibg=none guifg=#600000 gui=none
highlight DiffText guibg=#0000FF guifg=#00FFFF gui=none
highlight SpellBad guibg=#600000 guifg=#D00000 gui=underline
highlight Underlined guibg=none guifg=#D00000 gui=underline
highlight NormalFloat guibg=none
highlight WinActive guibg=#D00000 guifg=#000000 gui=bold
highlight WinInactive guibg=#300000 guifg=#D00000
highlight! link WinNeighbor WinInactive
highlight @variable guibg=none guifg=#D00000 gui=none
highlight QuickFixLine guibg=#400000 guifg=#D00000 gui=none

" //Save/Quit//
:map <silent> <C-S> :w<CR>
:map <silent> <C-S><C-S> :w!<CR>
:map <silent> <C-S><C-A> :wa<CR>
:map <silent> <C-S><C-Q> :wq<CR>
:map <silent> <C-S><C-Q> :waq<CR>
:map <silent> <C-Q> :q<CR>
:map <silent> <C-Q><C-Q> :q!<CR>
:map <silent> <C-Q><C-A> :qa<CR>
:map <silent> <C-Q><C-A><C-Q> :qa!<CR>

:map <space>h :noh<CR>:echo '["' . @/ . '" cleared]'<CR>
:nmap ' `
:noremap <silent> <c-/> K
:nnoremap <silent> <space>v :source ~/.config/nvim/vimrc.vim<CR>:noh<CR>:echo "[VIM Reloaded]"<CR>
nnoremap <silent> <space>b :silent !open %<CR>
let g:cwd = system('~/.scripts/./cwd.sh')

" //Normal Mode Navigation//
:noremap <silent> MM zz
:noremap <silent> J L
:noremap <silent> K H
:noremap <silent> L $
:noremap <silent> H 0
:noremap <silent> gK kgJ
:nnoremap <silent> <C-J> <C-F>
:nnoremap <silent> <C-K> <C-B>
:vnoremap <silent> <C-J> <C-F>
:vnoremap <silent> <C-K> <C-B>
:nnoremap ;j <C-O>
:nnoremap ;k <C-I>
:nnoremap <C-S-K> kzz
:nmap <C-S-J> jzz

" //Insert Mode Navigation//
:inoremap <C-H> <Left>
:inoremap <C-J> <Down>
:inoremap <C-K> <Up>
:inoremap <C-L> <Right>
:cnoremap <C-H> <Left>
:cnoremap <C-J> <Down>
:cnoremap <C-K> <Up>
:cnoremap <C-L> <Right>

" //Copy Text//
:vnoremap <expr> <C-C> mode() ==# "v" ? '"+y:echo @+<CR>' : '<ESC>`<v`>"+y'
:nnoremap <C-C> :let @+ = @0<CR>:echo @0<CR>
:nnoremap <silent> yp :let @" = expand("%")<CR>p
:nnoremap <silent> yP :let @" = expand("%:p")<CR>p
:nnoremap <silent> yc :let @" = @:<CR>p

" //Windows//
:tnoremap <silent> <C-Q> <C-\><C-N>:q<CR>
:tnoremap <C-W> <C-\><C-N><C-W>
:tnoremap <silent> <S-ESC> <C-\><C-N>
:nnoremap <silent> <C-W>v <C-W>v<C-W>w
autocmd InsertEnter * :setlocal norelativenumber
autocmd InsertLeave * :setlocal relativenumber

" //Tabs//
:noremap <silent> <C-T>n :tabnew \| lua Snacks.dashboard.open()<CR>
:noremap <C-T>l gt
:noremap <C-T>h gT
:noremap <C-T>q :tabclose<CR>

" //LazyVim//
:map <silent> <space>l :Lazy<CR>

" //Commentary//
:xmap <space>c gc
:nmap <space>c gc
:omap <space>c gc
:nmap <space>cc gcc

" //GITSIGNS//
 highlight GitSignsAdd guifg=#D00000
 highlight GitSignsChange guifg=#600000
 highlight GitSignsDelete guifg=#D00000
 highlight GitSignsAddLn guibg=#202020
 highlight GitSignsChangeLn guibg=#202020

" //DIAGNOSTICS//
highlight DiagnosticError guibg=#300000 guifg=#D00000
highlight DiagnosticWarn guibg=#300000 guifg=#ff7f7f
highlight DiagnosticInfo guifg=#ffbf7f
highlight DiagnosticHint guibg=#301818 guifg=#A00000 gui=italic

highlight DiagnosticSignError guibg=none guifg=#D00000
highlight DiagnosticSignWarn guibg=none guifg=#D00000
highlight! link DiagnosticSignInfo DiagnosticInfo
highlight! link DiagnosticSignHint DiagnosticHint

highlight DiagnosticUnderlineError guibg=none guifg=none guisp=#A00000
highlight DiagnosticUnderlineWarn guibg=none guifg=none guisp=#ff7f7f
highlight DiagnosticUnderlineHint guibg=none guifg=none guisp=#A00000

" //undo-persistence//
" guard for distributions lacking the 'persistent_undo' feature.
if has('persistent_undo')
    " define a path to store persistent undo files.
    let target_path = expand('~/.config/vim-persisted-undo/')
    " create the directory and any parent directories
    " if the location does not exist.
    if !isdirectory(target_path)
        call system('mkdir -p ' . target_path)
    endif
    " point Vim to the defined undo directory.
    let &undodir = target_path
    " finally, enable undo persistence.
    set undofile
endif
