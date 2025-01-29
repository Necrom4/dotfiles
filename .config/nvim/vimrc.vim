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

set statusline=%#StatusLine#\ %{ModeName()}%{IsModified()}%#StatusLineArrow#%{eval('g:isInsert')}\ %#StatusLineInfo#%<%{expand('%:p:h')}/%#StatusLineInfoMain#%{expand('%:t:r')}.%{expand('%:e')}\ %#StatusLineInfo#%=%h%r%w[%n][%c:%l][%p%%/%L]
augroup StatusLineChange
  autocmd!
  autocmd InsertEnter * let g:isInsert = ''
  autocmd InsertLeave * let g:isInsert = ' '
  autocmd WinEnter * setlocal statusline=%#StatusLine#\ %{ModeName()}%{IsModified()}%#StatusLineArrow#%{eval('g:isInsert')}\ %#StatusLineInfo#%<%{expand('%:p:h')}/%#StatusLineInfoMain#%{expand('%:t:r')}.%{expand('%:e')}\ %#StatusLineInfo#%=%h%r%w[%n][%c:%l][%p%%/%L]
	autocmd WinLeave * setlocal statusline=%#StatusLineNC#\ %{ModeName()}%{IsModified()}%#StatusLineNCArrow#\ %#StatusLineNCInfo#%<%{expand('%:p:h')}/%#StatusLineNCInfoMain#%{expand('%:t:r')}.%{expand('%:e')}\ %#StatusLineNCInfo#%=%h%r%w[%n][%c:%l][%p%%/%L]
augroup END
