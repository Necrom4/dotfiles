;;; lisp/tools.el -*- lexical-binding: t; -*-

;; TMUX NAVIGATOR
;; M-h/j/k/l move between Emacs windows, then on to tmux panes at the edge.
;; tmux sends the keys here because tmux.conf's @vim_navigator_pattern
;; matches emacs.
(defun +tmux--select-pane (flag)
  "Run `tmux select-pane FLAG' from this frame's pane, if it's in tmux.
A daemon isn't started from tmux, so the env comes from the frame's client."
  (let ((tmux (getenv "TMUX" (selected-frame)))
        (pane (getenv "TMUX_PANE" (selected-frame))))
    (when (and tmux pane)
      (let ((process-environment
             (append (list (concat "TMUX=" tmux) (concat "TMUX_PANE=" pane))
                     process-environment)))
        (call-process "tmux" nil nil nil "select-pane" flag "-t" pane))
      t)))

(defun +tmux--navigate (dir flag)
  (require 'windmove)
  (condition-case nil
      (windmove-do-window-select dir)
    (user-error
     (unless (+tmux--select-pane flag)
       (user-error "No window %s" dir)))))

(defun +tmux/navigate-left ()  (interactive) (+tmux--navigate 'left "-L"))
(defun +tmux/navigate-down ()  (interactive) (+tmux--navigate 'down "-D"))
(defun +tmux/navigate-up ()    (interactive) (+tmux--navigate 'up "-U"))
(defun +tmux/navigate-right () (interactive) (+tmux--navigate 'right "-R"))
(defun +tmux/navigate-previous ()
  (interactive)
  (unless (+tmux--select-pane "-l")
    (evil-window-mru)))

;; TERMINAL
(defun +terminal/cwd ()
  "Terminal in the directory Emacs was started from."
  (interactive)
  (let ((default-directory command-line-default-directory))
    (+ghostel/here)))

;; One ESC goes to the program (lazygit, fzf...), two within 200ms leave
;; insert state
(defvar +ghostel--last-escape 0)
(defun +ghostel/escape ()
  (interactive)
  (if (< (- (float-time) +ghostel--last-escape) 0.2)
      (progn (setq +ghostel--last-escape 0)
             (evil-normal-state))
    (setq +ghostel--last-escape (float-time))
    (ghostel-send-key "escape")))

(after! evil-ghostel
  (evil-define-key* 'insert evil-ghostel-mode-map
                    (kbd "<escape>") #'+ghostel/escape))

;; EXPLORER (dirvish is the closest thing to yazi)
(defun +explorer/root ()
  (interactive)
  (dirvish (or (doom-project-root) default-directory)))

(defun +explorer/cwd-side ()
  (interactive)
  (let ((default-directory command-line-default-directory))
    (dirvish-side)))

;; QUICKFIX
;; grep/compile results are Emacs' quickfix list; embark-export + wgrep
;; make them editable like quicker.nvim (C-c C-e in a consult search)
(defun +quickfix/toggle ()
  (interactive)
  (if-let* ((buf next-error-last-buffer)
            ((buffer-live-p buf)))
      (if-let* ((win (get-buffer-window buf)))
          (delete-window win)
        (pop-to-buffer buf))
    (user-error "No quickfix list yet")))

(defconst +todo-keywords "TODO|FIX|FIXME|HACK|WARN|PERF|NOTE|TEST|BUG")

(defun +todo/search ()
  (interactive)
  (consult-ripgrep (doom-project-root) (concat "\\b(" +todo-keywords "):")))

(defun +todo/search-fixes ()
  (interactive)
  (consult-ripgrep (doom-project-root) "\\b(TODO|FIX|FIXME):"))

;; ANNOTATIONS (haunt.nvim -> bookmarks, which carry an annotation)
(defun +bookmark/annotate ()
  (interactive)
  (let ((bookmark-use-annotations t))
    (call-interactively #'bookmark-set)))

;; TASKS (overseer -> compile, with mise and just tasks)
(defun +tasks--candidates ()
  (append
   (when (executable-find "mise")
     (mapcar (lambda (line) (concat "mise run " (car (split-string line))))
             (ignore-errors (process-lines "mise" "tasks" "ls" "--no-header"))))
   (when (and (executable-find "just") (locate-dominating-file default-directory "justfile"))
     (mapcar (lambda (task) (concat "just " task))
             (split-string (car (ignore-errors (process-lines "just" "--summary"))))))))

(defun +tasks/run ()
  "Pick a mise/just task (or type a command) and run it in the project root."
  (interactive)
  (let* ((default-directory (or (doom-project-root) default-directory))
         (command (completing-read "Task: " (+tasks--candidates))))
    (compile command)))

(defun +tasks/list ()
  (interactive)
  (let ((buffers (seq-filter (lambda (b)
                               (with-current-buffer b (derived-mode-p 'compilation-mode)))
                             (buffer-list))))
    (if buffers
        (pop-to-buffer (completing-read "Task: " (mapcar #'buffer-name buffers) nil t))
      (user-error "No tasks have run yet"))))

;; CALC (calcium.nvim)
(defun +calc--bounds ()
  (if (use-region-p)
      (let ((end (region-end)))
        ;; a linewise selection ends at the start of the next line
        (when (and (> end (region-beginning)) (eq (char-before end) ?\n))
          (setq end (1- end)))
        (cons (region-beginning) end))
    (cons (line-beginning-position) (line-end-position))))

(defun +calc--eval (beg end)
  (let ((result (calc-eval (string-trim (buffer-substring-no-properties beg end)))))
    (if (listp result)
        (user-error "calc: %s" (cadr result))
      result)))

(defun +calc/append ()
  "Append the result of the selection (or line) to it."
  (interactive)
  (pcase-let* ((`(,beg . ,end) (+calc--bounds))
               (result (+calc--eval beg end)))
    (deactivate-mark)
    (goto-char end)
    (insert " = " result)))

(defun +calc/replace ()
  "Replace the selection (or line) with its result."
  (interactive)
  (pcase-let* ((`(,beg . ,end) (+calc--bounds))
               (result (+calc--eval beg end)))
    (deactivate-mark)
    (delete-region beg end)
    (goto-char beg)
    (insert result)))
