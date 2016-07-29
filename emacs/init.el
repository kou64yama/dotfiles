;;; init.el --- Emacs configuration

;; Copyright (c) 2016 YAMADA Koji

;; Author: YAMADA Koji <kou64yama@gmail.com>

;;; Commentary:
;;; Code:

(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

(let ((installed (locate-user-emacs-file "installed")))
  (unless (file-exists-p installed)
    (let ((python (or (executable-find "python2")
                      (executable-find "python2.7")
                      (executable-find "python2.6")
                      (executable-find "python")))
          (buf (get-buffer-create "*Cask*")))
      (cd user-emacs-directory)
      (call-process python nil buf nil (expand-file-name "~/.cask/bin/cask"))
      (display-buffer buf))
    (write-region "" nil installed)))

(add-to-list 'load-path (locate-user-emacs-file "lisp"))
(add-to-list 'load-path (locate-user-emacs-file "site-lisp"))

(require 'cask "~/.cask/cask.el" t)
(cask-initialize)

(eval-when-compile
  (require 'cl)
  (require 'use-package)
  (require 'f)
  (require 'dash)
  (dash-enable-font-lock))

(use-package benchmark-init
  :if (getenv "EMACS_BENCHMARK_INIT")
  :init (benchmark-init/activate))

(use-package diminish)

(use-package sensible
  :commands (sensible-initialize)
  :init (sensible-initialize))

(use-package exec-path-from-shell
  :if (member system-type '(darwin gnu/linux))
  :init (exec-path-from-shell-initialize)
  :config (exec-path-from-shell-copy-envs '("GOPATH")))

(use-package pallet
  :init (pallet-mode))

(use-package server
  :commands (server-running-p)
  :init (unless (server-running-p) (server-start)))

;; Migemo

(use-package migemo
  :if (executable-find "cmigemo")
  :commands (migemo-init)
  :init (migemo-init)
  :config
  (setq migemo-command (executable-find "cmigemo")
        migemo-options '("-q" "--emacs")
        migemo-user-dictionary nil
        migemo-regex-dictionary nil
        migemo-coding-system 'utf-8-unix
        migemo-directory (-first 'file-directory-p
                                 '("/usr/share/migemo/migemo-dict"))))

;; Appearance

(use-package font-config
  :bind (("C-+" . font-config-increment-scale)
         ("C--" . font-config-decrement-scale)
         ("C-0" . font-config-reset-scale))
  :init (require 'font-config nil t))

(use-package atom-one-dark-theme
  :init (load-theme 'atom-one-dark t))

(use-package powerline
  :init (powerline-default-theme))

(use-package smart-mode-line
  :init
  (setq sml/no-confirm-load-theme t)
  (sml/setup))

(use-package yascroll
  :if window-system
  :init (global-yascroll-bar-mode)
  :config (scroll-bar-mode -1))

(use-package mode-icons
  :init (mode-icons-mode))

(use-package eshell-git-prompt
  :init (eshell-git-prompt-use-theme 'powerline))

;; File

(use-package direx
  :bind (("C-x C-j" . direx:jump-to-directory-other-window)))

;; Minibuffer

(use-package ido
  :init (ido-mode)
  :config
  (setq ido-enable-flex-matching t
        ido-everywhere t
        ido-use-filename-at-point 'guess
        ido-create-new-buffer 'always))

(use-package ido-ubiquitous
  :init (add-hook 'ido-setup-hook 'ido-ubiquitous-mode))

(use-package ido-yes-or-no
  :init (add-hook 'ido-setup-hook 'ido-yes-or-no-mode))

(use-package ido-migemo
  :if (executable-find "cmigemo")
  :init (add-hook 'ido-setup-hook 'ido-migemo-mode)
  :config (setq ido-migemo-exclude-command-list '(smex)))

(use-package smex
  :bind (("M-x" . smex)
	 ("M-X" . smex-major-mode-commands)
	 ("C-c C-c M-x" . execute-extended-command)))

;; Input Method

(use-package ddskk
  :init (setq default-input-method "japanese-skk"))

(use-package ido-skk
  :init (ido-skk-mode))

;; Editor

(use-package editorconfig
  :init (editorconfig-mode))

(use-package autorevert
  :init (global-auto-revert-mode)
  :config (diminish 'auto-revert-mode))

(use-package linum
  :init (global-linum-mode))

(use-package expand-region
  :bind (("C-=" . er/expand-region)))

(use-package multiple-cursors
  :bind (("C-<" . mc/mark-previous-like-this)
         ("C->" . mc/mark-next-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package drag-stuff
  :init (drag-stuff-global-mode)
  :config (diminish 'drag-stuff-mode))

(use-package smartparens
  :init (smartparens-global-mode)
  :config
  (require 'smartparens-config)
  (diminish 'smartparens-mode))

(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package volatile-highlights
  :init (add-hook 'after-init-hook 'volatile-highlights-mode)
  :config (diminish 'volatile-highlights-mode))

;; Projectile

(use-package projectile
  :init (projectile-global-mode)
  :config (diminish 'projectile-mode))

;; Git

(use-package git-gutter-fringe+
  :if window-system
  :init (global-git-gutter+-mode)
  :config
  (diminish 'git-gutter+-mode)
  (fringe-helper-define 'git-gutter-fr+-modified '(top repeat) "xx")
  (fringe-helper-define 'git-gutter-fr+-added '(top repeat) "xx")
  (fringe-helper-define 'git-gutter-fr+-deleted '(top repeat) "xx"))

;; History

(use-package undo-tree
  :init (global-undo-tree-mode)
  :config (diminish 'undo-tree-mode))

(use-package undohist
  :commands (undohist-initialize)
  :init (undohist-initialize)
  :config (setq undohist-ignored-files '("/tmp" "COMMIT_EDITMSG")))

;; Syntax checker

(use-package flycheck
  :init (global-flycheck-mode)
  :config (setq flycheck-indication-mode 'right-fringe))

;; Autocomplete

(use-package company
  :init (global-company-mode)
  :config (diminish 'company-mode))

;; ElDoc

(use-package eldoc
  :init (add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
  :config (diminish 'eldoc-mode))

;; Snippets

(use-package yasnippet
  :init (yas-global-mode)
  :config (diminish 'yas-minor-mode))

;; Org

(use-package org
  :bind (("C-c a" . org-agenda))
  :config
  (setq org-agenda-files (-filter 'file-exists-p
                                  '("~/agenda"
                                    "~/dropbox/agenda"
                                    "~/dropbox/public/agenda"))))

(use-package org-autolist
  :init (add-hook 'org-mode-hook 'org-autolist-mode)
  :config (diminish 'org-autolist-mode))

;; Markdown

(use-package markdown
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode)))

;; HTML

(use-package web-mode
  :mode (("\\.phtml\\'" . web-mode)
         ("\\.tpl\\.php\\'" . web-mode)
         ("\\.[agj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.djhtml\\'" . web-mode)
         ("\\.html?\\'" . web-mode)))

;; PHP

(use-package php-mode
  :defer t
  :config (require 'php-ext))

;; JavaScript

(use-package js2-mode
  :mode (("\\.jsx?\\'" . js2-jsx-mode)))

(use-package js2-refactor
  :init (add-hook 'js2-mode-hook #'js2-refactor-mode)
  :config (diminish 'js2-refactor-mode))

;; Go

(use-package go-mode
  :config
  (let ((command (executable-find "goimports")))
    (when command (setq gofmt-command command)))
  (add-hook 'before-save-hook 'gofmt-before-save)
  (add-hook 'go-mode-hook 'go-eldoc-setup))

(use-package go-eldoc
  :init (add-hook 'go-mode-hook 'go-eldoc-setup))

(use-package company-go
  :init (add-hook 'go-mode-hook
                  (lambda ()
                    (add-to-list 'company-backends 'company-go))))

(defun load-if-exists (path)
  (when (file-exists-p path) (load path)))

(when window-system
  (-each (list "~/dropbox/public/emacs/window.el"
               "~/dropbox/emacs/window.el"
               (locate-user-emacs-file "window.el")) 'load-if-exists))
(-each (list "~/dropbox/public/emacs/local.el"
             "~/dropbox/emacs/local.el"
             (locate-user-emacs-file "local.el")) 'load-if-exists)

;;; init.el ends here
