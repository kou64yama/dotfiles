;;; font-config.el --- Emacs font configuration
;;; Commentary:
;;; Code:

(defvar font-family nil)
(defvar font-fontset-list nil)
(defvar font-height nil)
(defvar font-scale 1)

(defun font-config-apply ()
  (interactive)
  (set-face-attribute 'default nil
                      :family font-family
                      :height (round (* font-height font-scale)))
  (dolist (fontset-list font-fontset-list)
    (let ((spec (car fontset-list))
          (family (car (cdr fontset-list))))
      (set-fontset-font nil spec (font-spec :family family)))))

;;;###autoload
(defun font-config-increment-scale ()
  (interactive)
  (setq font-scale (* font-scale 1.1))
  (font-config-apply))

;;;###autoload
(defun font-config-decrement-scale ()
  (interactive)
  (setq font-scale (/ font-scale 1.1))
  (font-config-apply))

;;;###autoload
(defun font-config-reset-scale ()
  (interactive)
  (setq font-scale 1)
  (font-config-apply))

(defun font-config-set-family (list)
  (let ((family (car list))
        (fontset-list (cdr list)))
    (setq font-family (font-config-find-exists family)
          font-fontset-list nil)
    (dolist (fontset fontset-list)
      (let ((font-spec (car fontset))
            (family (font-config-find-exists (cdr fontset))))
        (add-to-list 'font-fontset-list (list font-spec family))))))

(defun font-config-find-exists (list)
  (let ((availables (font-family-list))
        (head (car list)))
    (if (or (eq head nil) (member head availables))
        head
      (font-config-find-exists (cdr list)))))

(defcustom font-config-height (face-attribute 'default :height)
  "The font-config height."
  :group 'font-config
  :set (lambda (var val)
         (set var val)
         (setq font-height val)
         (font-config-apply)))

(defcustom font-config-family-alist
  (list (list (face-attribute 'default :family)))
  "The font-config family alist."
  :group 'font-config
  :set (lambda (var val)
         (set var val)
         (font-config-set-family val)
         (font-config-apply)))

(provide 'font-config)
;;; font-config.el ends here
