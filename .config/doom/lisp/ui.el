;;; lisp/ui.el -*- lexical-binding: t; -*-

(setq doom-theme 'tokyonight-moon)

;; Transparent background in the terminal, like tokyonight's `transparent'
(defun +ui-transparent-tty-background-h (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame))))
(add-hook 'doom-load-theme-hook #'+ui-transparent-tty-background-h)
(add-hook 'after-make-frame-functions #'+ui-transparent-tty-background-h)

;; No cursorline highlight
(setq global-hl-line-modes nil)

;; nvim-numbertoggle: absolute numbers in insert state, relative otherwise
(add-hook! 'evil-insert-state-entry-hook
  (when display-line-numbers (setq display-line-numbers t)))
(add-hook! 'evil-insert-state-exit-hook
  (when display-line-numbers (setq display-line-numbers 'relative)))

;; mini.trailspace
(add-hook! '(prog-mode-hook text-mode-hook conf-mode-hook)
  (setq-local show-trailing-whitespace t))

(after! doom-modeline
  (setq doom-modeline-vcs-max-length 23
        doom-modeline-buffer-encoding 'nondefault
        doom-modeline-modal-icon nil))

;; todo-comments
(after! hl-todo
  (setq hl-todo-keyword-faces
        (append '(("TEST" . "#4FD6BE")
                  ("PERF" . "#4FD6BE")
                  ("NOTE" . "#C099FF"))
                hl-todo-keyword-faces)))

;; tint.nvim: dim inactive windows, off until toggled with SPC u D w
(use-package! auto-dim-other-buffers
  :commands auto-dim-other-buffers-mode)

;; nvim-colorizer
(use-package! rainbow-mode
  :hook ((css-mode css-ts-mode scss-mode web-mode conf-mode) . rainbow-mode))
