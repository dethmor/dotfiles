(setq exec-path (parse-colon-path (getenv "PATH"))
      scratch-buffer-file (locate-user-emacs-file "scratch"))

(add-hook
 'after-init-hook
 `(lambda ()
    (when (file-exists-p scratch-buffer-file)
      (with-current-buffer (get-buffer-create "*scratch*")
        (erase-buffer)
        (insert-file-contents scratch-buffer-file))) t))

(add-hook
 'window-configuration-change-hook
 `(lambda ()
    (let ((display-table (or buffer-display-table standard-display-table)))
      (when display-table
        ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Display-Tables.html
        (set-display-table-slot display-table 1 ? )
        (set-display-table-slot display-table 5 ?│)
        (set-window-display-table (selected-window) display-table))) t))

(add-hook
 'kill-emacs-hook
 `(lambda ()
    (with-current-buffer (get-buffer-create "*scratch*")
      (write-region (point-min) (point-max) scratch-buffer-file nil t)) t))

(add-hook
 'after-save-hook
 'executable-make-buffer-file-executable-if-script-p)

(add-hook
 'after-save-hook
 `(lambda ()
    (let ((current-file-name (buffer-file-name (current-buffer))))
      (when (and
             current-file-name
             (file-equal-p
              current-file-name
              (locate-user-emacs-file "init.el")))
        (eval-buffer))) t))

(add-hook
 'kill-emacs-hook
 `(lambda ()
    (let ((src-file (locate-user-emacs-file "init.el"))
          (elc-file (locate-user-emacs-file "init.elc")))
      (when (file-newer-than-file-p src-file elc-file)
        (byte-compile-file src-file))) t))

(add-hook
 'kill-buffer-hook
 `(lambda ()
    (when (equal
           (current-buffer)
           (get-buffer "*scratch*"))
      (rename-buffer "*scratch*<kill>" t)
      (clone-buffer "*scratch*")) t))

(add-hook
 'kill-emacs-hook
 `(lambda ()
    (when (file-exists-p custom-file)
      (delete-file custom-file)) t))

(custom-set-variables
 '(custom-file
   (locate-user-emacs-file
    (format "custom-%d.el" (emacs-pid))))
 '(ffap-bindings t)
 '(find-file-visit-truename t)
 '(global-auto-revert-mode t)

 '(indent-tabs-mode nil)
 '(inhibit-splash-screen t)
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(make-backup-files nil)
 '(menu-bar-mode nil)
 '(mode-line-format nil)
 '(ns-pop-up-frames nil)
 '(package-enable-at-startup t)
 '(pop-up-windows nil)
 '(require-final-newline 'visit-save)
 '(scroll-bar-mode nil)
 '(scroll-step 1)
 '(set-mark-command-repeat-pop t)
 '(split-width-threshold 0)
 '(system-time-locale "C")
 '(show-paren-mode t)
 ;;'(tool-bar-mode nil)
 '(vc-follow-symlinks nil)
 '(view-read-only t)
 '(viper-mode nil))

(load-theme 'anticolor t)
(defalias 'yes-or-no-p 'y-or-n-p)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(require 'package)
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-verbose t
      use-package-enable-imenu-support t
      use-package-compute-statistics t)

(require 'use-package)

(use-package cc-mode
  :hook (c-mode-common . my/c-mode-common)
  :init
  (defun my/c-mode-common ()
    (c-set-style "bsd")
    (setq indent-tabs-mode nil
          c-basic-offset 4)))

(use-package company
  :ensure t
  :commands company-complete
  :bind* (("C-M-i" . company-complete)
          :map company-active-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("C-s" . company-filter-candidates)
          ("C-i" . company-complete-selection)
          ("<tab>" . company-complete-selection)
          :map company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous))
  :custom
  (company-idle-delay nil)
  (company-selection-wrap-around t)
  :config
  (global-company-mode t))

(use-package company-ctags
  ;; create tags file in project root
  ;; find . -name "*.[ch]" | ctags -e -L -
  :ensure t
  :config
  (let ((global-tags (locate-user-emacs-file "TAGS")))
    (when (file-exists-p global-tags)
      (add-to-list
       'company-ctags-extra-tags-files
       '(global-tags))))
  (company-ctags-auto-setup))

;; (use-package ctags-update
;;   :if (executable-find "ctags")
;;   :ensure t
;;   :hook ((c-mode-common . turn-on-ctags-auto-update-mode)
;;          (emacs-lisp-mode . turn-on-ctags-auto-update-mode)
;;          (javascript-mode . turn-on-ctags-auto-update-mode)
;;          (python-mode . turn-on-ctags-auto-update-mode)
;;          (shell-script-mode . turn-on-ctags-auto-update-mode)
;;          (typescript-mode . turn-on-ctags-auto-update-mode))
;;   :bind (("C-c u" . ctags-update)))

(use-package ddskk
  :ensure t
  :bind (:map skk-j-mode-map
              ("C-M-j" . skk-undo-kakutei))
  :init
  (let ((skk-dict-path (locate-user-emacs-file "skk-dict")))
    (if (file-directory-p skk-dict-path)
        (shell-command-to-string (format "git -C %s pull origin master" skk-dict-path))
      (shell-command-to-string (format "git clone -v --depth=1 https://github.com/skk-dev/dict.git %s" skk-dict-path)))
    (setq skk-extra-jisyo-file-list
          (mapcar
           (lambda (file)
             (format "%s/%s" skk-dict-path file))
           '("SKK-JISYO.jinmei"
             "SKK-JISYO.fullname"
             "zipcode/SKK-JISYO.zipcode"
             "zipcode/SKK-JISYO.office.zipcode"
             "SKK-JISYO.station"
             "SKK-JISYO.okinawa"
             "SKK-JISYO.mazegaki"))
          skk-large-jisyo (format "%s/SKK-JISYO.L" skk-dict-path)))
  :custom
  (default-input-method "japanese-skk")
  (skk-sticky-key ";")
  (skk-status-indicator 'minor-mode)
  (skk-show-annotation t)
  (skk-anotation-delay 0)
  (skk-egg-link-newline t)
  (skk-auto-insert-paren nil)
  (skk-use-jisx0201-input-method t)
  (skk-latin-mode-string "A")
  (skk-hiragana-mode-string "あ")
  (skk-katakana-mode-string "ア")
  (skk-jisx0208-latin-mode-string "Ａ")
  (skk-jisx-0201-mode-string "ｱ")
  (skk-use-face nil)
  :config
  (require 'skk-study))

(use-package eshell
  :bind ("M-!" . eshell))

;; (use-package flycheck
;;   :ensure t)

;; (use-package gnus
;;   :if (file-exists-p (expand-file-name "~/.gnus"))
;;   :commands gnus)

(use-package highlight-indentation
  :ensure t
  :hook ((prog-mode . highlight-indentation-mode)
         (yaml-mode . highlight-indentation-mode)))

;; (use-package http
;;   :ensure t)

(use-package ido
  :custom
  (ido-enable-flex-matching t)
  :config
  (ido-mode t)
  (ido-everywhere t))

(use-package ido-vertical-mode
  :ensure t
  :custom
  (ido-vertical-define-keys 'C-n-C-p-up-and-down)
  :config
  (ido-vertical-mode t))

(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)))

(use-package literate-calc-mode
  :ensure t
  :bind (("M-+" . my/literate-calc-mode))
  :init
  (defun my/literate-calc-mode ()
    (interactive)
    (let ((buffer (get-buffer-create "*Literate Calc*")))
      (unless (eq buffer (current-buffer))
        (switch-to-buffer-other-window buffer)
        (literate-calc-mode)))))

;; (use-package lsp-mode
;;   :if (executable-find "npm")
;;   :ensure t
;;   :hook ((c-mode-common . lsp)
;;          (javascript-mode . lsp)
;;          (shell-script-mode . lsp)
;;          (typescript-mode . lsp))
;;   :custom
;;   (lsp-print-io nil)
;;   (lsp-trace nil)
;;   (lsp-print-perfomance nil)
;;   (lsp-auto-guess-root t)
;;   (lsp-document-sync-method 'incremental)
;;   (lsp-response-timeout 5))

;; (use-package lsp-ui
;;   :ensure t
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :custom
;;   (lsp-ui-doc-enable t)
;;   (lsp-ui-doc-header t)
;;   (lsp-ui-doc-include-signature t)
;;   (lsp-ui-doc-max-width 150)
;;   (lsp-ui-doc-max-height 30)
;;   (lsp-ui-peek-enable t))

;; (use-package magit
;;   :ensure t)

(use-package multiple-cursors
  :ensure t
  :bind (("C-c C-c" . mc/edit-lines)))

(use-package open-junk-file
  :ensure t
  :hook (kill-emacs . my/open-junk-file-delete-all-files)
  :commands (open-junk-file)
  :bind (("C-x j" . open-junk-file))
  :init
  (setq my/open-junk-file-directory (locate-user-emacs-file "junk"))
  (defun my/open-junk-file-delete-all-files ()
    (mapc (lambda (junk-file)
            (when (file-regular-p junk-file)
              (delete-file junk-file)))
          (directory-files-recursively my/open-junk-file-directory ".*" nil nil nil)))
  (unless (file-directory-p my/open-junk-file-directory)
    (make-directory my/open-junk-file-directory))
  (setq open-junk-file-format (format "%s/%%s." my/open-junk-file-directory)))

(use-package org-mode
  :commands (org-capture org-mode)
  :bind (("C-c c" . org-capture)
         ("C-c n" . my/org-capture-note)
         ("C-c r" . my/org-capture-ril)
         ("C-c w" . my/org-capture-wasted))
  :init
  (setq org-directory (expand-file-name "~/org"))
  (unless (file-directory-p org-directory)
    (make-directory org-directory))
  (defun my/org-capture-insert (content)
    (org-capture nil "n")
    (insert content)
    (org-capture-finalize))
  (defun my/org-capture-note (content)
    (interactive "sNote: ")
    (my/org-capture-insert content))
  (defun my/org-capture-ril (content)
    (interactive "sRead it Later: ")
    (my/org-capture-insert content))
  (defun my/org-capture-wasted (content)
    (interactive "nWasted: ")
    (my/org-capture-insert content))
  :custom
  (org-default-notes-file "notes.org")
  (org-capture-templates
   '(("n" "Note" entry
      (file+headline org-default-notes-file "Notes")
      "* %?\nEntered on %U\n %i\n %a")
     ("r" "Read it Later" checkitem
      (file+headline org-default-notes-file "Read it Later")
      "- [ ] %?")
     ("w" "Wasted" table-line
      (file+headline org-default-notes-file "Wasted")
      "|%<%F>|%?|"))))

(use-package package-utils
  :defer t
  :ensure t)

(use-package password-store
  :ensure t
  :commands (password-store-copy)
  :custom
  (pass-username-fallback-on-filename t))

(use-package password-store-otp
  :ensure t
  :commands (password-store-otp-token-copy))

(use-package pkgbuild-mode
  :if (executable-find "makepkg")
  :ensure t
  :mode ("PKGBUILD\\'")
  :custom
  (pkgbuild-makepkg-command "makepkg -m -C -c -f ")
  (pkgbuild-user-full-name "T.T.")
  (pkgbuild-user-mail-address "dt@8b.nz"))

(use-package popwin
  :ensure t
  :custom
  (display-buffer-function 'popwin:display-buffer)
  (popwin:popwindow-position 'bottom)
  :config
  (mapcar
   (lambda (newelt)
     (push newelt popwin:special-display-config))
   '(("*Backtrace*" :noselect)
     ("*Completions*" :noselect)
     ("*GNU Emacs*" :noselect)
     ("*Messages*" :noselect)
     ("*Process List*" :noselect)
     ("*Warnings*" :noselect)
     ("*Help*")
     ("*Literate Calc*")
     ("*eshell*")
     ("*use-package statistics*"))))

(use-package recentf
  :hook ((find-file . recentf-mode)
         (kill-buffer . my/recentf-push))
  :init
  (defun my/recentf-push ()
    (require 'recentf)
    (let ((file-name (buffer-file-name)))
      (when (and file-name (file-exists-p file-name))
        (recentf-push file-name))))
  :custom
  (recentf-max-saved-items 2000)
  (recentf-auto-ceanup 'never)
  (recentf-auto-save-timer (run-with-idle-timer 30 t 'recentf-save-list)))

(use-package shell-script-mode
  :mode ("\\.sh\\'"))

(use-package typescript-mode
  :ensure t
  :mode "\\.tsx?\\'")

(use-package visible-mark
  :ensure t
  :init
  (global-visible-mark-mode t)
  :custom
  (set-mark-command-repeat-pop t))

(use-package wihitespace
  :hook (before-save . whitespace-cleanup)
  :custom
  (whitespace-space-regexp "\\(\u3000+\\)")
  (whitespace-style
   '(face trailing spaces empty space-mark tab-mark))
  (whitespace-display-mappings
   '((space-mark ?\u3000 [?\u25a1])
     (tab-mark ?\t [?\u00bb ?\t] [?\\ ?\t])))
  :config
  (whitespace-mode t))

(use-package xclip
  ;; :if (and (string-equal system-type "gnu/linux")
  ;;          (executable-find "xclip"))
  :ensure t
  :init
  (xclip-mode))

(use-package yaml-mode
  :ensure t
  :mode ("\\.yaml\\'" "\\.yml\\'"))

;; init.el ends here
