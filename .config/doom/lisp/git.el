;;; lisp/git.el -*- lexical-binding: t; -*-

;; YADM
;; Magit can't take --git-dir/--work-tree for a whole session, so it reaches
;; the yadm repo through a TRAMP method that runs inside `yadm enter'
(after! tramp
  (add-to-list 'tramp-methods
               '("yadm"
                 (tramp-login-program "yadm")
                 (tramp-login-args (("enter")))
                 (tramp-login-env (("SHELL") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c")))))

(defun +yadm/magit-status ()
  "Magit for the yadm repository."
  (interactive)
  (require 'tramp)
  (magit-status "/yadm::"))

(defun +yadm/find-file ()
  "Pick a file tracked by yadm."
  (interactive)
  (let* ((default-directory "~/")
         (files (process-lines "yadm" "ls-files")))
    (find-file (expand-file-name (completing-read "Config file: " files nil t) "~/"))))

(defun +yadm/stage-file ()
  "Stage the current file, in yadm if it's tracked there."
  (interactive)
  (if (and buffer-file-name
           (zerop (call-process "yadm" nil nil nil "ls-files" "--error-unmatch" buffer-file-name)))
      (progn (call-process "yadm" nil nil nil "add" buffer-file-name)
             (message "yadm: staged %s" (file-name-nondirectory buffer-file-name)))
    (call-interactively #'magit-file-stage)))

;; GITSIGNS
(defun +vc-gutter/first-hunk ()
  (interactive)
  (goto-char (point-min))
  (diff-hl-next-hunk))

(defun +vc-gutter/last-hunk ()
  (interactive)
  (goto-char (point-max))
  (diff-hl-previous-hunk))

(defun +git/diff-file-against-previous ()
  "Diff the current file against HEAD~."
  (interactive)
  (magit-diff-range "HEAD~" nil (list (magit-file-relative-name))))

(map! :n "]g" #'diff-hl-next-hunk
      :n "[g" #'diff-hl-previous-hunk
      :n "]G" #'+vc-gutter/last-hunk
      :n "[G" #'+vc-gutter/first-hunk
      :leader
      (:prefix "g"
       :desc "Neogit (Magit)"      "g" #'magit-status
       :desc "Stage Hunk"          "s" #'+vc-gutter/stage-hunk
       :desc "Reset Hunk"          "r" #'+vc-gutter/revert-hunk
       :desc "Stage Buffer"        "S" #'magit-file-stage
       :desc "Unstage Buffer"      "u" #'magit-file-unstage
       :desc "Reset Buffer"        "R" #'vc-revert
       :desc "Preview Hunk Inline" "p" #'diff-hl-show-hunk
       :desc "Blame Line"          "b" #'blamer-show-commit-info
       :desc "Blame Buffer"        "B" #'magit-blame-addition
       :desc "Diff This"           "d" #'magit-diff-buffer-file
       :desc "Diff This ~"         "D" #'+git/diff-file-against-previous
       :desc "Add File"            "a" #'+yadm/stage-file
       :desc "Yadm"                "y" #'+yadm/magit-status))

;; Inline blame of the current line, like gitsigns' current_line_blame
(use-package! blamer
  :hook (doom-first-file . global-blamer-mode)
  :config
  (setq blamer-idle-time 0.5
        blamer-min-offset 4))

;; DIFF
(defun +diff/windows ()
  "Diff the two visible windows (like :diffthis in both), or the file against HEAD."
  (interactive)
  (let ((windows (window-list nil 'no-minibuf)))
    (if (= (length windows) 2)
        (ediff-buffers (window-buffer (car windows)) (window-buffer (cadr windows)))
      (call-interactively #'magit-diff-buffer-file))))
