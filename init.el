;; Some of the settings are inspired by
;; https://people.gnome.org/~federico/blog/bringing-my-emacs-from-the-past.html
;;
;; work around bug where dynamically generated menus are blank
(menu-bar-mode -1)
(menu-bar-mode 1)
;; disable tool bar
(tool-bar-mode -1)
(require 'package)
;; Add melpa to your packages repositories
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; (package-refresh-contents)
;;(package-install 'intero)
;; Use-package for civilized configuration
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
;; Set customization data in a specific file, without littering
;; my init files.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Which-key to get hints when typing command prefixes
(use-package which-key
  :diminish
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom)
  (setq which-key-idle-delay 0.1))

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      use-package-always-ensure t
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

;; (setq treemacs-toggle-fixed-width t)
(setq treemacs-width 50)

;; lsp-mode supports snippets, but in order for them to work you need to use yasnippet
;; If you don't want to use snippets set lsp-enable-snippet to nil in your lsp-mode settings
;;   to avoid odd behavior with snippets and indentation
(use-package yasnippet)

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )

;; (use-package fill-column-indicator)
;; (add-hook 'after-change-major-mode-hook 'fci-mode)
;; (setq fci-rule-column 80)

(global-display-line-numbers-mode)
(setq frame-resize-pixelwise t)
(xterm-mouse-mode 1)
;; requires the Linux xclip package to be installed
(use-package xclip)
(xclip-mode 1)

(global-set-key [f8] 'treemacs)

(setq debug-on-error t)

(setq lsp-enable-file-watchers nil)
(setq treemacs-no-png-images t)

;; ----------------------------- intero for Haskell -----------------------

;; Install Intero
;; (add-hook 'haskell-mode-hook 'intero-mode)

;; ----------------------------- fonts -----------------------

(cond
 ((member "Monaco" (font-family-list))
  (set-face-attribute 'default nil :font "Monaco-12"))
 ((member "Inconsolata" (font-family-list))
  (set-face-attribute 'default nil :font "Inconsolata-12"))
 ((member "Consolas" (font-family-list))
  (set-face-attribute 'default nil :font "Consolas-11"))
 ((member "DejaVu Sans Mono" (font-family-list))
  (set-face-attribute 'default nil :font "DejaVu Sans Mono-10")))


;; ----------------------------- rust config -----------------------

(use-package flycheck)
(use-package rustic)
(use-package lsp-ui)
(use-package helm-lsp
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))
; auto-completion and code snippets

(use-package yasnippet
  :ensure
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode))

(use-package company
  :ensure
  :bind
  (:map company-active-map
              ("C-n". company-select-next)
              ("C-p". company-select-previous)
              ("M-<". company-select-first)
              ("M->". company-select-last))
  (:map company-mode-map
        ("<tab>". tab-indent-or-complete)
        ("TAB". tab-indent-or-complete)))

(defun company-yasnippet-or-completion ()
  (interactive)
  (or (do-yas-expand)
      (company-complete-common)))

(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "::") t nil)))))

(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

(defun tab-indent-or-complete ()
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (if (or (not yas/minor-mode)
            (null (do-yas-expand)))
        (if (check-expansion)
            (company-complete-common)
          (indent-for-tab-command)))))

;; for Cargo.toml and other config files
(use-package toml-mode :ensure)

;; ----------------------------- end rust config -----------------------

