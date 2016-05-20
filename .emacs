;; load config file seperately
;; for better management

;; add load path
;; (add-to-list 'load-path "~/.emacs.d")
(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
         "~/.emacs.d/config")
        ((boundp 'user-init-directory)
         "~/.emacs.d/config")
        (t "~/.emacs.d/")))


(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))

(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  "Prevent annoying \"Active processes exist\" query when you quit Emacs."
  (flet ((process-list ())) ad-do-it))

(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)

;;; GLOBAL
;; easy keys to split window. Key based on ErgoEmacs keybinding
(global-set-key (kbd "M-0") 'delete-window) ; close current pane
(global-set-key (kbd "M-1") 'delete-other-windows) ; expand current pane
(global-set-key (kbd "M-3") 'split-window-right) ; split pane top/bottom
(global-set-key (kbd "M-o") 'other-window) ; cursor to other pane
(global-set-key (kbd "M-5") 'query-replace) ; used to be alt+% but lazy to hit shift
(global-set-key (kbd "M-6") 'query-replace-regexp) ; used to be alt+% but lazy to hit shift
(global-set-key (kbd "C-x C-k") 'kill-buffer) ; faster in god-mode
(global-set-key (kbd "M-s") 'magit-status) ; git status gs in godmode

;; swop C-a and M-m
(global-set-key (kbd "C-a") 'back-to-indentation)
(global-set-key (kbd "M-m") 'move-beginning-of-line)
;; change yes or no to y or p
(fset 'yes-or-no-p 'y-or-n-p)
;; no backup file
(setq make-backup-files nil)
;; line number but it's slow when too many line
;; see alternatives online
(global-linum-mode t )
;; fix el captain
;; allow it to beep instead of show magnify box
(setq ring-bell-function (lambda () (message "*woop*")))
;; set tabsize
(setq tab-width 4)
;; smooth scroll
(setq redisplay-dont-pause t
  scroll-margin 1
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)
;; change behaviour of comment dwim
;; to comment out the line
;; NOT append the comment to the end of the line
(defun comment-dwim-line (&optional arg)
        "Replacement for the comment-dwim command.
        If no region is selected and current line is not blank and we are not at the end of the line,
        then comment current line.
        Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
          (interactive "*P")
          (comment-normalize-vars)
          (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
              (comment-or-uncomment-region (line-beginning-position) (line-end-position))
            (comment-dwim arg)))
(global-set-key "\M-;" 'comment-dwim-line)

(defun duplicate-current-line ()
  (interactive)
  (beginning-of-line nil)
  (let ((b (point)))
    (end-of-line nil)
    (copy-region-as-kill b (point)))
  (beginning-of-line 2)
  (open-line 1)
  (yank)
  (back-to-indentation))

(global-set-key (kbd "C-c C-d") 'duplicate-current-line)

(require 'undo-tree)
(global-undo-tree-mode 1)
(defalias 'redo 'undo-tree-redo)
(global-set-key (kbd "C-S-/") 'redo)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Menlo"))))
 '(cursor ((t (:background "green1")))))


(defun create-newline-and-enter-sexp ()
  "Add two newlines and put the cursor at the right indentation
between them if a newline is attempted when the cursor is between
two curly braces, otherwise do a regular newline and indent"
  (interactive)
  (if (and (equal (char-before) 123) ; {
           (equal (char-after) 125)) ; }
      (progn (newline-and-indent)
             (split-line)
             (indent-for-tab-command))
    (newline-and-indent)))

(global-set-key (kbd "M-<return>") 'create-newline-and-enter-sexp)
;;; WEB-DEV 
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)) ;; auto evoke js mode
(add-hook 'js2-mode-hook 'ac-js2-mode)
(setq js2-highlight-level 3)

;;; for html css
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.handlebars?\\'" . web-mode))
(setq web-mode-css-indent-offset 2)
(setq web-mode-enable-css-colorization t)
(setq web-mode-enable-current-element-highlight t)
(setq web-mode-enable-current-column-highlight t)

;;; alt move line up-down
(defun move-line-down ()
(interactive)
(let ((col (current-column)))
(save-excursion
(forward-line)
(transpose-lines 1))
(forward-line)
(move-to-column col)))
 
(defun move-line-up ()
(interactive)
(let ((col (current-column)))
(save-excursion
(forward-line)
(transpose-lines -1))
(move-to-column col)))
 
;;yasnippet
;; should be loaded before auto complete so that they can work together
(add-to-list 'load-path "~/.emacs.d/elpa")
(require 'yasnippet)
(yas-global-mode 1)

;; auto complete mod
;; should be loaded after yasnippet so that they can work together
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)

;;; HELM 
;;;
(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "M-b") 'helm-mini)
(helm-autoresize-mode t)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

(setq helm-M-x-fuzzy-match t) ;; optional fuzzy matching for helm-M-x
(setq helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match    t)

(projectile-global-mode)

(define-key projectile-mode-map (kbd "M-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "M-d") 'projectile-find-dir)
(define-key projectile-mode-map (kbd "M-p") 'projectile-switch-project)
(define-key projectile-mode-map (kbd "M-f") 'projectile-find-file)
(define-key projectile-mode-map (kbd "M-g") 'projectile-grep)

(setq projectile-indexing-method 'natile)
(setq projectile-enable-caching t)
(setq projectile-completion-system 'helm)
(helm-projectile-on)

;; helm swoop
(require 'helm-swoop)
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
(define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)


(helm-mode 1)

;; helm ag
;; silver searcher
(custom-set-variables
 '(helm-ag-base-command "/usr/local/bin/ag")
 '(helm-ag-command-option "--all-text")
 '(helm-follow-mode-persistent t)
 '(helm-ag-use-agignore t)
 '(helm-ag-insert-at-point (quote symbol)))


(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.
Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; Activate installed packages
(package-initialize)


;; Assuming you wish to install "iedit" and "magit"
(ensure-package-installed 'iedit 'magit 'helm)

;;; powerline
(require 'powerline)
(powerline-default-theme)

;;; evil-mode
(evil-mode t)

(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("red" bar))
(setq evil-replace-state-cursor '("red" bar))
(setq evil-operator-state-cursor '("red" hollow))

;;; scroll up down
(define-key evil-normal-state-map (kbd "C-u") (lambda ()
                    (interactive)
                    (evil-scroll-up nil)))
(define-key evil-normal-state-map (kbd "C-d") (lambda ()
                        (interactive)
                        (evil-scroll-down nil)))

;; remap : to ;
(define-key evil-normal-state-map (kbd ";") 'evil-ex)

(defun switch-to-previous-buffer ()
      (interactive)
      (switch-to-buffer (other-buffer (current-buffer) 1)))

;; evil leader
(require 'evil-leader)
(global-evil-leader-mode)
(setq evil-leader/in-all-states 1)
;; unbind evil dafault SPC of forward char
(define-key evil-normal-state-map (kbd "SPC") nil)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "f" 'helm-find-files
  "e" 'eshell
  "b" 'switch-to-buffer
  "k" 'kill-buffer ;; more convenient than 'k'
  "m" 'helm-M-x ;; m for M-x
  "j" 'helm-bookmarks ;; j for jump to bookmark
  "0" 'delete-window ; close current pane                           
  "1" 'delete-other-windows ; expand current pane
  "2" 'switch-to-previous-buffer
  "3" 'split-window-right ; split pane top/bottom
  "o" 'other-window ; cursor to other pane                          
  "5" 'query-replace ; used to be alt+% but lazy to hit shift       
  "6" 'query-replace-regexp ; used to be alt+% but lazy to hit shift
  "g" 'helm-google
  "ag" 'helm-ag-project-root
  "rg" 'ranger
  )
;; nerd comment binding with leader key
(evil-leader/set-key
  "ci" 'evilnc-comment-or-uncomment-lines
  "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  "cc" 'evilnc-copy-and-comment-lines
  "cp" 'evilnc-comment-or-uncomment-paragraphs
  "cr" 'comment-or-uncomment-region
  "cv" 'evilnc-toggle-invert-comment-line-by-line
)

;;;This sets $MANPATH, $PATH and exec-path from your shell, but only on OS X.
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; dired quick copy enable default path of two folder copying
(setq dired-dwim-target t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-check-path (quote ("." "/Library/TeX/texbin")))
 '(ac-delay 0.05)
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(auth-source-save-behavior nil)
 '(blink-cursor-mode nil)
 '(custom-enabled-themes (quote (solarized-dark)))
 '(custom-safe-themes
   (quote
    ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(exec-path
   (quote
    ("/usr/bin" "/bin" "/usr/sbin" "/sbin" "/Applications/Emacs.app/Contents/MacOS/bin-x86_64-10_9" "/Applications/Emacs.app/Contents/MacOS/libexec-x86_64-10_9" "/Applications/Emacs.app/Contents/MacOS/libexec" "/Applications/Emacs.app/Contents/MacOS/bin" "/usr/local/bin")))
 '(helm-ag-base-command "/usr/local/bin/ag")
 '(helm-ag-command-option "--all-text")
 '(helm-ag-insert-at-point (quote symbol))
 '(helm-ag-use-agignore t)
 '(helm-follow-mode-persistent t)
 '(ido-enable-flex-matching t)
 '(ido-mode (quote both) nil (ido))
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(ispell-dictionary nil)
 '(menu-bar-mode nil)
 '(server-mode t)
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Menlo"))))
 '(cursor ((t (:background "green1")))))

;; use OSX dictionary
(setq ispell-program-name "/usr/local/Cellar/aspell/0.60.6.1/bin/aspell")
(setenv "DICTIONARY" "en_GB")
