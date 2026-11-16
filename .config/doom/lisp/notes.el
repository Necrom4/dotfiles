;;; lisp/notes.el -*- lexical-binding: t; -*-

;; ORG (what neorg is to Neovim)
(defun +notes/open-index ()
  "Open the notes index."
  (interactive)
  (find-file (expand-file-name "index.org" org-directory)))

;; single < / > (de)nest headings and list items, g>> / g<< whole subtrees
(map! :after evil-org
      :map evil-org-mode-map
      :n ">"   #'org-metaright
      :n "<"   #'org-metaleft
      :n "g>>" #'org-demote-subtree
      :n "g<<" #'org-promote-subtree)

;; OBSIDIAN (the vault of this machine's yadm class)
(use-package! obsidian
  :commands (obsidian-jump obsidian-search obsidian-capture obsidian-backlinks)
  :init
  (let ((class (string-trim
                (or (ignore-errors (car (process-lines "yadm" "config" "local.class")))
                    ""))))
    (setq obsidian-directory
          (expand-file-name (if (string-empty-p class) "default" (downcase class))
                            "~/vaults/")))
  :config
  (global-obsidian-mode +1))
