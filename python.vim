" Locate this file at YOUR_HOME_DIR\vimfiles\after\ftplugin

"set shiftwidth=4
"set softtabstop=4
"set expandtab
"set tabstop=4

setlocal noexpandtab
setlocal shiftround
setlocal autoindent

let s:tabwidth=4
let &l:tabstop = s:tabwidth
let &l:shiftwidth = s:tabwidth
let &l:softtabstop = s:tabwidth
