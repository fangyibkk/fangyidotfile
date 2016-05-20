# fangyidotfile
This .emacs file is intended to provide a fast track to emacs new comers.
Some terms are adapted to avoid learning a bunch of emacs vocaburary so don't take it so serious.

# Getting start
Download Emacs GUI version.
Then download .emacs file after that paste the file into you home directory.
(If you don't know you can figure it out by open the terminal; type `cd` then `ENTER` then type `pwd` then `ENTER`, here you get home directory)

# Basic usage

## files
- space then `f`: open current directory and searching for file
- space then `k`: close current open file.
- alt+`f`: find files in the project. The project is the directory that has .projectile file. If there is no such file, you can create one to make it a project.
(sometimes this command is not automatically update for the new files, so that you should press space then m after that run projectile-cache-invalidated)
- alt+`b`: open the list of open files
- alt+`p`: switch between project

## comment
- space then `c` then `i`: commite current line
- space then `c` then `c`: comment current line then duplicate into another line

## window
- alt+`3`: split vertically
- alt+`0`: maximize another open window
- alt+`1`: maximize current window
space+o: switching between window

## evil-mode
This makes emacs behave like vim. Basically there are three modes in vim: 
1. insert mode: you can type in this mode. Enter this mode by press `i` and exit by `esc`.
2. normal mode: for viewing basic motion are up(`k`) down(`j`) left(`h`) right(`l`).
3. visual mode: for selecting. enter this mode by press `v` and exit by `esc`

I suggest the following link for basic vim and it should take roughly 25 minutes:
http://www.openvim.com/
http://yannesposito.com/Scratch/en/blog/Learn-Vim-Progressively/

Then here is some of my useful example before and after apply a command (| is a cursor)<br />

1. `cw` <br />
before: long|longlonglonglongword <br />
after: long| <br />

2. `ct`: cut until someting <br />
  1. `c` then `t` then `)`  <br />
before: foobar(int| a) <br />
after `ct)`: foobar(int|) <br />
  2. `c` then `t` then `}` <br />
before: foobar() { return| 0; } <br />
after `ct}`: foobar() { return|} <br />
  3. Just like above examples, you can cut until everything you want. <br />

3. `/` search for something
before: foo| bar baz zzz <br />
after `/z`: foo bar ba|z zzz <br />
after `n`: foo bar baz |zzz <br />
after `N`: foo bar ba|z zzz <br />
in vim every thing with shift is backward <br />
for searching backward is shift + `/` i.e. `?` <br />
before: foo bar baz |zzz <br />
after `?z`: foo bar ba|z zzz <br />
