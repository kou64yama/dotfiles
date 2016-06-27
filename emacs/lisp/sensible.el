;;; sensible.el --- The sensible configuration of Emacs

;; Copyright (C) 2016 YAMADA Koji

;; Author: YAMADA Koji <kou64yama@gmail.com>
;; Maintainer: YAMADA Koji <kou64yama@gmail.com>
;; Version: 0.0.2
;; Keywords: sensible
;; URL: https://github.com/kou64yama/emacs-sensible
;; Package-Requires: nil

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; A set of the Emacs configuration that should be acceptable to
;; everyone.

;;; Code:

(defun load-if-exists (&rest file-list)
  (dolist (file file-list)
    (when (file-exists-p file)
      (load file))))

;;;###autoload
(defun sensible-initialize ()
  "Initialize the sensible configuration."
  (interactive)
  (when window-system
    (tool-bar-mode -1))
  (setq backup-inhibited t
	indent-tabs-mode nil
	inhibit-startup-screen t
        system-time-locale "C"))

(provide 'sensible)
;;; sensible.el ends here
