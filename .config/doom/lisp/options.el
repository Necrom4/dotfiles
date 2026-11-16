;;; lisp/options.el -*- lexical-binding: t; -*-

(setq display-line-numbers-type 'relative
      scroll-margin 0)

;; nowrap
(setq-default truncate-lines t)

;; FILETYPES

;; .env, .env.local, .env.production...
(add-to-list 'auto-mode-alist '("/\\.env\\(?:\\.[^/]*\\)?\\'" . sh-mode))
;; yadm alternates (`file.ext##os.Darwin,e.ext`): drop the `##...` suffix and
;; pick the mode from what's left
(add-to-list 'auto-mode-alist '("##[^/]*\\'" nil t))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\.j2\\'" . yaml-mode))

;; Files in /tmp (sudoedit, pass, ...) don't leave an undo history behind
(after! undo-fu-session
  (add-to-list 'undo-fu-session-incompatible-files "\\`/\\(?:private/\\)?tmp/"))

;; GUI (what Neovide does for Neovim)
(setq doom-font (font-spec :family "CommitMono Nerd Font Mono"
                           :size (if (featurep :system 'macos) 16.0 10.0)))
(setq-default line-spacing 1)
(add-to-list 'default-frame-alist '(alpha-background . 85))
;; Left option is Meta, right option still types special characters
(setq ns-option-modifier 'meta
      ns-right-option-modifier 'none)
