;; trux's .emacs file

;; when I search for multiple spaces, I want multiple spaces dammit
(set-variable 'search-whitespace-regexp nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))

;; fix for slow emacs when saving files
(setq write-region-inhibit-fsync t)

;; thank you emacs for saving my ass on multiple occasions
;; multiple backup files
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      kept-old-versions 4               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 8               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 60              ; number of seconds idle time before auto-save (default: 30)
      )
(setq auto-save-interval 900)            ; number of keystrokes between auto-saves (default: 300)

(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.emacs.d/backups/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

(setq initial-scratch-message "")

(setq inhibit-startup-message t)

;;; C Indentation
(setq c-auto-newline nil)
(setq c-auto-fill-prefix nil)
(setq c-auto-fill-mode nil)
(setq indent-tabs-mode nil)
(setq c-echo-syntactic-information-p t)

(setq-default indent-tabs-mode nil)

(defun my-c-mode-common-hook ()
  (setq indent-tabs-mode 'nil)
  (c-set-offset 'statement 0)
  (c-set-offset 'substatement 2)
  (c-set-offset 'substatement-open 2)
  (c-set-offset 'defun-block-intro 2)
  (c-set-offset 'statement-block-intro 2)
  (c-set-offset 'statement-case-intro 2)
  (c-set-offset 'statement-case-open 2)
)

(setq c-basic-offset 2)
(setq js-indent-level 2)

(setq sh-basic-offset 2)
(setq sh-indentation 2)

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c++-mode-common-hook 'my-c-mode-common-hook)

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
;(global-set-key [home] 'beginning-of-buffer)
;(global-set-key [end] 'end-of-buffer)
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)
(global-set-key (kbd "C-h") 'delete-backward-char)

(global-set-key "\C-o" 'gotonexttab)
(global-set-key "\C-x\C-g" 'goto-line)
(global-set-key "\C-x\C-x" 'replace-string)
(global-set-key "\C-ce" 'run-line-in-other-window)
(global-set-key "\C-x\C-b" 'electric-buffer-list)
;(define-key shell-mode-map "\C-z" 'shell-similar-input)
;(define-key inferior-lisp-mode-map "\C-z" 'shell-similar-input)
(global-set-key [f1] 'undo)
(global-set-key [f2] 'call-last-kbd-macro)
(global-set-key [f3] 'copy-region-as-kill)

; this causes emacs to NOT auto-indent text when pasted with mouse
(global-set-key (kbd "RET") 'electric-newline-and-maybe-indent)

;; Always end a file with a newline
(setq require-final-newline t)

;; Stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)

(display-time)

(require 'shell)      ;shell buffer
(require 'electric)      ;???  

(define-key minibuffer-local-map "\t" 'file-completion-hook)

(put 'eval-expression 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NWFunctions (legacy functions and so on)
;; by 'Beeblebrox' at warwick uni, apparently. No licence.
(defun query-kill-emacs ()
  "Asks if you want to quit emacs before quiting."
  (interactive)
  (if (nth 1 (frame-list))
      (delete-frame)
    (if (y-or-n-p "Are you sure you want to quit? ")
	(save-buffers-kill-emacs)
      (message "Quit aborted."))))

(defun query-quit (true)
  (interactive)
  (if true
      (if (< 21 emacs-major-version)
	  (global-set-key "\C-x\C-c"  'query-kill-emacs)
	(setq confirm-kill-emacs 'y-or-n-p))
    (global-set-key "\C-x\C-c" 'save-buffers-kill-emacs)
    (if (< 21 emacs-major-version)
	(setq confirm-kill-emacs nil))))

;	      (global-set-key "\C-x\C-c" 'save-buffers-kill-emacs))

(query-quit t)

;; ccrypt
; (require 'ps-ccrypt "ps-ccrypt.el")

(let ((frame-background-mode 'light)) (frame-set-background-mode nil))
