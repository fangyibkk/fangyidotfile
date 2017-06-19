" Basic
syntax on
filetype plugin indent on
au BufNewFile,BufRead *.hql set filetype=sql
colorscheme evening

nnoremap y "+y
vnoremap y "+y

"set clipboard=unnamedplus
"set clipboard=unnamed
set noswapfile
set relativenumber
set hlsearch
set number
set guifont=Lucida_Console:h10



" Vim internal encoding
set encoding=utf-8

" Homemade statusline
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
set laststatus=2



set listchars=tab:>-,trail:~,extends:>,precedes:<
set list

" Tab and indentation
set autoindent
set shiftwidth=4
set softtabstop=4
set expandtab
set tabstop=4
