;;; lisp/editing.el -*- lexical-binding: t; -*-

;; FLASH
;; s jumps anywhere on screen, S grows the selection by syntax node
(map! :nvo "s" #'evil-avy-goto-char-timer
      :nv  "S" #'expreg-expand)

;; SPIDER: w/e/b stop at camelCase humps. Evil ignores subword-mode, but
;; splits words where `evil-cjk-word-separating-categories' says so.
(define-category ?U "Uppercase")
(define-category ?u "Lowercase")
(modify-category-entry (cons ?A ?Z) ?U)
(modify-category-entry (cons ?a ?z) ?u)
(after! evil
  (setq-default evil-cjk-word-separating-categories
                (cons '(?u . ?U) (default-value 'evil-cjk-word-separating-categories))))

;; SURROUND (gs*, like nvim-surround's mappings; frees gs from easymotion)
(map! :m "gs" nil
      :n "gsa" #'evil-surround-region
      :n "gsA" #'evil-Surround-region
      :n "gsd" #'evil-surround-delete
      :n "gsr" #'evil-surround-change
      :v "gsa" #'evil-surround-region
      :v "gsA" #'evil-Surround-region)

;; TEXT OBJECTS
(evil-define-text-object +evil:git-hunk-txtobj (_count &optional _beg _end _type)
  "Git hunk."
  :type line
  (if-let* ((ov (and (fboundp 'diff-hl-hunk-overlay-at)
                     (diff-hl-hunk-overlay-at (point)))))
      (list (overlay-start ov) (overlay-end ov))
    (user-error "No hunk here")))

(evil-define-text-object +evil:subword-inner-txtobj (_count &optional _beg _end _type)
  "Subword (fooBar -> foo, Bar)."
  (save-excursion
    (let ((end (progn (subword-forward) (point))))
      (list (progn (subword-backward) (point)) end))))

(evil-define-text-object +evil:subword-outer-txtobj (_count &optional _beg _end _type)
  "Subword, with its trailing separator."
  (save-excursion
    (let ((end (progn (subword-forward) (skip-chars-forward "_-") (point))))
      (subword-backward)
      (when (memq (char-before) '(?_ ?-))
        (unless (memq (char-before end) '(?_ ?-)) (backward-char)))
      (list (point) end))))

(evil-define-text-object +evil:number-txtobj (_count &optional _beg _end _type)
  "Number."
  (save-excursion
    (skip-chars-backward "0-9.")
    (when (eq (char-before) ?-) (backward-char))
    (if (looking-at "-?[0-9]+\\(?:\\.[0-9]+\\)?")
        (list (match-beginning 0) (match-end 0))
      (user-error "No number here"))))

(evil-define-text-object +evil:line-inner-txtobj (_count &optional _beg _end _type)
  "Line, characterwise, without indentation or trailing whitespace."
  (save-excursion
    (list (progn (back-to-indentation) (point))
          (progn (end-of-line) (skip-chars-backward " \t") (point)))))

(evil-define-text-object +evil:line-outer-txtobj (_count &optional _beg _end _type)
  "Line, characterwise."
  (list (line-beginning-position) (line-end-position)))

(evil-define-text-object +evil:url-txtobj (_count &optional _beg _end _type)
  "URL."
  (if-let* ((bounds (bounds-of-thing-at-point 'url)))
      (list (car bounds) (cdr bounds))
    (user-error "No URL here")))

(evil-define-text-object +evil:buffer-txtobj (_count &optional _beg _end _type)
  "Entire buffer."
  :type line
  (list (point-min) (point-max)))

(map! (:map evil-inner-text-objects-map
       "g" #'+evil:git-hunk-txtobj
       "e" #'+evil:subword-inner-txtobj
       "d" #'+evil:number-txtobj
       "_" #'+evil:line-inner-txtobj
       "L" #'+evil:url-txtobj)
      (:map evil-outer-text-objects-map
       "g" #'+evil:git-hunk-txtobj
       "e" #'+evil:subword-outer-txtobj
       "d" #'+evil:number-txtobj
       "_" #'+evil:line-outer-txtobj)
      :ov "gG" #'+evil:buffer-txtobj)

;; DIAL: C-a / C-x increment numbers and cycle these words
(after! rotate-text
  (setq rotate-text-words
        (append '(("true" "false")
                  ("enable" "disable")
                  ("on" "off")
                  ("yes" "no")
                  ("and" "or")
                  ("show" "hide")
                  ("visible" "hidden")
                  ("start" "stop")
                  ("success" "failure")
                  ("pass" "fail")
                  ("high" "medium" "low")
                  ("todo" "doing" "done")
                  ("add" "remove")
                  ("active" "inactive")
                  ("dev" "test" "staging" "prod" "production")
                  ("draft" "published")
                  ("read" "write" "execute")
                  ("run" "build" "test" "deploy")
                  ("light" "dark"))
                rotate-text-words))
  (add-to-list 'rotate-text-patterns '("[=!]=" +dial--toggle-equality))
  (add-to-list 'rotate-text-patterns '("[✔❌]" +dial--toggle-check)))

(defun +dial--toggle-equality (text _arg) (if (string= text "==") "!=" "=="))
(defun +dial--toggle-check (text _arg) (if (string= text "✔") "❌" "✔"))

(defun +dial--rotate (count)
  "Rotate the text at point, or the next number on the line, like Vim's C-a."
  (condition-case nil
      (rotate-text count)
    (error
     (let ((pos (point)))
       (if (re-search-forward "[0-9]" (line-end-position) t)
           (progn (backward-char) (rotate-text count))
         (goto-char pos)
         (user-error "Nothing to increment"))))))

(defun +dial/increment (count)
  (interactive "p")
  (+dial--rotate count))

(defun +dial/decrement (count)
  (interactive "p")
  (+dial--rotate (- count)))

(map! :n "C-a" #'+dial/increment
      :n "C-x" #'+dial/decrement)

;; TEXT CASE (ga prefix)
(defvar +text-case-commands
  '(("snake_case"    . string-inflection-snake-case)
    ("camelCase"     . string-inflection-lower-camel-case)
    ("PascalCase"    . string-inflection-camel-case)
    ("CONSTANT_CASE" . string-inflection-upcase)
    ("dash-case"     . string-inflection-kebab-case)))

(defun +text-case/convert ()
  "Convert the word (or selection) to a case picked from a list."
  (interactive)
  (let ((choice (completing-read "Convert case: " +text-case-commands nil t)))
    (call-interactively (alist-get choice +text-case-commands nil nil #'string=))))

(map! :nv "ga" nil
      :nv "ga." #'+text-case/convert
      :nv "gas" #'string-inflection-snake-case
      :nv "gac" #'string-inflection-lower-camel-case
      :nv "gap" #'string-inflection-camel-case
      :nv "gan" #'string-inflection-upcase
      :nv "gad" #'string-inflection-kebab-case
      :nv "gau" #'evil-upcase
      :nv "gal" #'evil-downcase)

;; AUTO-SAVE (norg -> org, erb, css, scss)
(setq auto-save-visited-interval 0.5
      auto-save-visited-predicate
      (lambda ()
        (or (derived-mode-p 'org-mode 'css-mode 'css-ts-mode 'scss-mode)
            (and buffer-file-name
                 (string-match-p "\\.\\(?:erb\\|rhtml\\)\\'" buffer-file-name)))))
(auto-save-visited-mode +1)

;; FORMATTING (conform.nvim -> apheleia)
(after! apheleia
  (setf (alist-get 'pg_format apheleia-formatters) '("pg_format" "-")
        (alist-get 'sql-mode apheleia-mode-alist) 'pg_format
        (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff)
        (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))
