;;; lisp/lsp.el -*- lexical-binding: t; -*-

;; Reuse the servers, linters and formatters Mason installed for Neovim.
;; Appended, so project-local tools (mise) still win.
(let ((mason-bin (expand-file-name "~/.local/share/nvim/mason/bin")))
  (when (file-directory-p mason-bin)
    (add-to-list 'exec-path mason-bin t)
    (setenv "PATH" (concat (getenv "PATH") path-separator mason-bin))))

;; miser.nvim: per-project tool versions and env from mise
(use-package! mise
  :hook (doom-first-file . global-mise-mode))

(after! eglot
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)))

;; Diagnostics as virtual text at the end of the line, no signs
(after! flymake
  (setq flymake-show-diagnostics-at-end-of-line 'short
        flymake-indicator-type nil))

;; LSP keys live under gr*, like Neovim 0.11+ (gr was Doom's eval operator)
(map! :n "gr" nil
      :n "grd" #'+lookup/definition
      :n "grD" #'eglot-find-declaration
      :n "gri" #'+lookup/implementations
      :n "grr" #'+lookup/references
      :n "grt" #'+lookup/type-definition
      :n "grI" #'eglot-show-call-hierarchy
      :n "grO" #'eglot-show-call-hierarchy
      :n "grn" #'eglot-rename
      :n "gra" #'eglot-code-actions
      :n "grA" #'eglot-code-action-organize-imports
      :n "grR" #'doom/move-this-file
      :n "gK"  #'+lookup/documentation
      :n "]d"  #'flymake-goto-next-error
      :n "[d"  #'flymake-goto-prev-error)

;; DEBUG
(defun +debug/continue ()
  "Continue the debug session, or start one."
  (interactive)
  (require 'dape)
  (call-interactively
   (if (dape--live-connection 'parent t) #'dape-continue #'dape)))
