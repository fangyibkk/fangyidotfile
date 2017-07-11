" Package
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" https://github.com/VundleVim/Vundle.vim/wiki/Vundle-for-Windows
set rtp+=$HOME/vimfiles/bundle/Vundle.vim
call vundle#begin('$HOME/vimfiles/bundle/')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim' "required

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

Plugin 'scrooloose/nerdcommenter'

call vundle#end()            " required
filetype plugin indent on    " required


" Basic
syntax on

" File type
au BufNewFile,BufRead *.hql set filetype=sql
au BufNewFile,BufRead *.handlebars set filetype=html


" Clipboard
nnoremap y "+y
vnoremap y "+y
set clipboard=unnamedplus
set clipboard=unnamed

" Prevent create junk file
set noswapfile
set relativenumber
set hlsearch
set number

" Font
set guifont=Lucida_Console:h10

" Vim internal encoding
set encoding=utf-8

set listchars=tab:>-,trail:~,extends:>,precedes:<
set list

" Tab and indentation
set autoindent
set shiftwidth=4
set softtabstop=4
set expandtab
set tabstop=4

" No beep
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set belloff=all

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set runtimepath^=~/vimfiles/bundle/ctrlp.vim

"Color theme
let g:molokai_original = 1
colorscheme molokai

" Prevent jjj, kkk from laging
set lazyredraw

" Status line
set laststatus=2
set ttimeoutlen=50


" Jumptag
function! JumpToCSS()
  let id_pos = searchpos("id", "nb", line('.'))[1]
  let class_pos = searchpos("class", "nb", line('.'))[1]

  if class_pos > 0 || id_pos > 0
    if class_pos < id_pos
      execute ":vim '#".expand('<cword>')."' **/*.css"
    elseif class_pos > id_pos
      execute ":vim '.".expand('<cword>')."' **/*.css"
    endif
  endif
endfunction

nnoremap <F9> :call JumpToCSS()<CR>
" Reload your vim with command
" :so %
