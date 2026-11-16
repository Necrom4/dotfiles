;;; lisp/keymaps.el -*- lexical-binding: t; -*-

;; SAVE / QUIT
;; C-q can't be both a command and a prefix in Emacs, so only the plain
;; quit survives; :qa lives on SPC q q
(map! :nvi "C-s C-s" #'save-buffer
      :nvi "C-s C-a" #'evil-write-all
      :nvi "C-s C-q" #'evil-save-and-close
      :nvi "C-q"     #'evil-quit)

;; CURSOR
;; j/k move by display line, unless given a count
(evil-define-motion +evil/next-line (count)
  :type line
  (if count (evil-next-line count) (evil-next-visual-line)))
(evil-define-motion +evil/previous-line (count)
  :type line
  (if count (evil-previous-line count) (evil-previous-visual-line)))

(map! :nv  "j"  #'+evil/next-line
      :nv  "k"  #'+evil/previous-line
      :nvo "gj" #'evil-next-line
      :nvo "gk" #'evil-previous-line
      :nvo "J"  #'evil-window-bottom
      :nvo "K"  #'evil-window-top
      :nvo "L"  #'evil-end-of-line
      :nvo "H"  #'evil-beginning-of-line
      :nv  "m"  #'evil-scroll-line-to-center)

;; insert / ex command line
(map! :i "C-j" #'next-line
      :i "C-k" #'previous-line
      :i "C-l" #'forward-char
      :i "C-h" #'backward-char
      (:map evil-ex-completion-map
       "C-j" #'next-line-or-history-element
       "C-k" #'previous-line-or-history-element
       "C-l" #'forward-char
       "C-h" #'backward-char))

;; SCROLL
(map! :nv "C-j"   #'evil-scroll-down
      :nv "C-k"   #'evil-scroll-up
      :nv "C-l"   #'evil-scroll-right
      :nv "C-h"   #'evil-scroll-left
      :nv "C-S-j" #'evil-scroll-line-down
      :nv "C-S-k" #'evil-scroll-line-up
      :nv "C-S-l" #'evil-scroll-column-right
      :nv "C-S-h" #'evil-scroll-column-left)

;; SEARCH
;; n always goes forward (even after ?), and centres on the match
(evil-define-motion +evil/search-next (count)
  :jump t
  :type exclusive
  (let ((evil-ex-search-direction 'forward))
    (evil-ex-search-next count))
  (when (and (evil-normal-state-p) (eq (window-buffer) (current-buffer)))
    (recenter)))
(evil-define-motion +evil/search-previous (count)
  :jump t
  :type exclusive
  (let ((evil-ex-search-direction 'forward))
    (evil-ex-search-previous count))
  (when (and (evil-normal-state-p) (eq (window-buffer) (current-buffer)))
    (recenter)))

(map! :nvo "n" #'+evil/search-next
      :nvo "N" #'+evil/search-previous)

;; MARKS / JUMPS
;; ` sets a mark (m is taken by zz), g` jumps to its exact position
(map! :nvo "`"  #'evil-set-marker
      :nvo "g`" #'evil-goto-mark
      :n   "[;" #'better-jumper-jump-backward
      :n   "];" #'better-jumper-jump-forward)

;; TABS (Doom workspaces: tab-like layouts that also persist across sessions)
(map! :n "] TAB" #'+workspace/switch-right
      :n "[ TAB" #'+workspace/switch-left
      :leader
      (:prefix "TAB"
       :desc "Close Tab"      "q" #'+workspace/kill
       :desc "Move Tab Right" "l" #'+workspace/swap-right
       :desc "Move Tab Left"  "h" #'+workspace/swap-left
       :desc "First Tab"      "{" #'+workspace/switch-to-0
       :desc "Last Tab"       "}" #'+workspace/switch-to-final))

;; WINDOWS
(map! :leader
      :desc "Split Below" "-" #'+evil/window-split-and-follow
      :desc "Split Right" "|" #'+evil/window-vsplit-and-follow)
(map! :map evil-window-map
      "n" #'ace-window
      "S" #'ace-swap-window
      "z" #'doom/window-maximize-buffer)

;; EDITING
;; < / > indent the line; g< / g> take a motion
(map! :n "<"  #'evil-shift-left-line
      :n ">"  #'evil-shift-right-line
      :n "g<" #'evil-shift-left
      :n "g>" #'evil-shift-right
      :nv "gJ" #'evil-join)

;; LEADER
;; Doom's toggles go where LazyVim has them (SPC u) to make room for
;; terminals on SPC t
(define-key doom-leader-map "u" (lookup-key doom-leader-map "t"))
;; SPC c c is compile in Doom (now SPC o t), and the calc group in Neovim
(define-key doom-leader-map (kbd "c c") nil)
;; History pickers join the help keys on SPC h, without touching C-h
(let ((map (make-sparse-keymap)))
  (set-keymap-parent map help-map)
  (define-key map "y" #'consult-yank-pop)
  (define-key map "c" #'consult-complex-command)
  (define-key doom-leader-map "h" map))
(after! which-key
  (which-key-add-key-based-replacements
    "SPC u" "toggle"
    "SPC h" "help/history"
    "SPC h y" "Yank History"
    "SPC h c" "Command History"))

(map! :leader
      :desc "Resume Picker" "=" #'vertico-repeat

      (:prefix "f"
       :desc "Atlas (Forge)"    "a" #'forge-dispatch
       :desc "Buffers"          "b" #'consult-buffer
       :desc "Find Config File" "c" #'+yadm/find-file
       :desc "Obsidian"         "o" #'obsidian-jump
       :desc "Yank History"     "y" #'consult-yank-pop)

      (:prefix "s"
       :desc "Grep (Root Dir)"    "g" #'+default/search-project
       :desc "Grep (cwd)"         "G" #'+default/search-cwd
       :desc "Lines"              "l" #'consult-line
       :desc "Search and Replace" "r" #'project-query-replace-regexp
       :desc "Annotations"        "A" #'consult-bookmark)

      (:prefix-map ("t" . "terminal")
       :desc "Root Dir"   "t" #'+ghostel/toggle
       :desc "Buffer Dir" "f" #'+ghostel/here
       :desc "CWD"        "T" #'+terminal/cwd)

      (:prefix-map ("x" . "explorer")
       :desc "Root Dir"            "x" #'dirvish-side
       :desc "CWD"                 "X" #'+explorer/cwd-side
       :desc "Root Dir (floating)" "f" #'+explorer/root
       :desc "CWD (floating)"      "F" #'dirvish)

      (:prefix-map ("Q" . "quickfix")
       :desc "Quickfix List"        "q" #'+quickfix/toggle
       :desc "Location List"        "l" #'consult-flymake
       :desc "Diagnostics"          "d" #'flymake-show-project-diagnostics
       :desc "Buffer Diagnostics"   "D" #'flymake-show-buffer-diagnostics
       :desc "Todo"                 "t" #'+todo/search
       :desc "Todo/Fix/Fixme"       "T" #'+todo/search-fixes
       :desc "Annotations"          "a" #'list-bookmarks)

      (:prefix-map ("a" . "annotations")
       :desc "Annotate"   "a" #'+bookmark/annotate
       :desc "Delete"     "d" #'bookmark-delete
       :desc "Delete all" "D" #'bookmark-delete-all
       :desc "Buffer Annotations" "l" #'consult-bookmark)

      (:prefix-map ("d" . "diff")
       :desc "Diff Windows" "d" #'+diff/windows
       :desc "File History" "h" #'magit-log-buffer-file)

      (:prefix-map ("." . "other")
       :desc "Dashboard"         "d" #'+doom-dashboard/open
       :desc "Reload Shell Env"  "s" #'doom/reload-env)

      (:prefix "o"
       :desc "Run Task"     "o" #'+tasks/run
       :desc "Rerun Task"   "t" #'recompile
       :desc "Task List"    "w" #'+tasks/list)

      (:prefix "n"
       :desc "Open Note" "n" #'+notes/open-index
       :desc "New Note"  "N" #'org-capture
       :desc "Scratch"   "s" #'doom/open-scratch-buffer)

      (:prefix "c"
       (:prefix ("c" . "calc")
        :desc "Calculate (append)"  "a" #'+calc/append
        :desc "Calculate (replace)" "r" #'+calc/replace
        :desc "Calc"                "c" #'calc
        :desc "Quick Calc"          "q" #'quick-calc))

      (:prefix "u"
       (:prefix ("D" . "dimming")
        :desc "Dim Inactive Windows" "w" #'auto-dim-other-buffers-mode)))

;; DEBUG (M-d, like <a-d> in Neovim)
(map! :nv "M-d" nil
      (:prefix ("M-d" . "debug")
       :nv "B" #'dape-breakpoint-expression
       :nv "b" #'dape-breakpoint-toggle
       :nv "c" #'+debug/continue
       :nv "a" #'dape
       :nv "C" #'dape-until
       :nv "i" #'dape-step-in
       :nv "j" #'dape-stack-select-down
       :nv "k" #'dape-stack-select-up
       :nv "l" #'dape-restart
       :nv "o" #'dape-step-out
       :nv "O" #'dape-next
       :nv "P" #'dape-pause
       :nv "r" #'dape-repl
       :nv "t" #'dape-quit
       :nv "w" #'dape-watch-dwim
       :nv "u" #'dape-info
       :nv "e" #'dape-evaluate-expression))

;; TMUX
(map! :nvi "M-h" #'+tmux/navigate-left
      :nvi "M-j" #'+tmux/navigate-down
      :nvi "M-k" #'+tmux/navigate-up
      :nvi "M-l" #'+tmux/navigate-right
      :nvi "M-w" #'+tmux/navigate-previous)
