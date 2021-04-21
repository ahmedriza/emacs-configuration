;;; package --- Summary
;;; init.el
;;; Commentary:
;;; Some of the settings are inspired by
;;; https://people.gnome.org/~federico/blog/bringing-my-emacs-from-the-past.html
;;;
;;; For LSP, see also:
;;; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
;;;
;;; work around bug where dynamically generated menus are blank
;;; Code:
(menu-bar-mode -1)
(menu-bar-mode 1)
;; disable tool bar
(tool-bar-mode -1)
;; auto close bracket insertion
(electric-pair-mode 1)
(column-number-mode t)

;; (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(global-display-fill-column-indicator-mode)
(setq-default display-fill-column-indicator-column 100)
;; (setq display-fill-column-indicator-character ?\N{U+2506})
;; (setq-default display-fill-column-indicator-character ?\N{U+2506})
;; (setq-default display-fill-column-indicator-character ?\N{U+250A})
;; (setq-default display-fill-column-indicator-character ?\N{U+254E})
;; (customize-face 'fill-column-indicator)

(defun indent-buffer ()
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))
;; (global-set-key [f12] 'indent-buffer)

(require 'package)
;; Add melpa to your packages repositories
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; Use-package for civilized configuration
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Set customization data in a specific file, without littering
;; my init files.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; move buffers between windows
(use-package buffer-move
  :config
  (global-set-key (kbd "<C-S-up>") 'buf-move-up)
  (global-set-key (kbd "<C-S-down>") 'buf-move-down)
  (global-set-key (kbd "<C-S-left>") 'buf-move-left)
  (global-set-key (kbd "<C-S-right>") 'buf-move-right)
  )

;; Which-key to get hints when typing command prefixes
(use-package which-key
  :diminish
  :config
  ;; Allow C-h to trigger which-key before it is done automatically
  (setq which-key-show-early-on-C-h t)
  ;; make sure which-key doesn't show normally but refreshes quickly after it is
  ;; triggered.
  (setq which-key-idle-delay 10000)
  (setq which-key-idle-secondary-delay 0.05)
  (which-key-mode)
  ;; (which-key-setup-side-window-bottom)
  ;; (setq which-key-idle-delay 0.1)
)

(use-package selectrum
  :ensure
  :init
  (selectrum-mode)
  :custom
  (completion-styles '(flex substring partial-completion)))

(fset 'yes-or-no-p 'y-or-n-p)
(recentf-mode 1)
(setq recentf-max-saved-items 100
      inhibit-startup-message t
      ring-bell-function 'ignore)

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      use-package-always-ensure t
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))


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

(global-display-line-numbers-mode)
(setq frame-resize-pixelwise t)
(xterm-mouse-mode 1)
;; requires the Linux xclip package to be installed
(use-package xclip)
(xclip-mode 1)

(setq debug-on-error t)

(global-set-key [f8] 'treemacs)
(setq lsp-enable-file-watchers nil)
(setq treemacs-no-png-images t)
;; (setq treemacs-toggle-fixed-width t)
(setq treemacs-width 55)
(when window-system
  (use-package treemacs
  :config
  (set-face-attribute 'treemacs-root-face nil
                        :foreground (face-attribute 'default :foreground)
                        :height 1.0
                        :weight 'normal)))

;; ----------------------------- magit -----------------------

(use-package magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (setq magit-refresh-status-buffer nil))

;; ----------------------------- intero for Haskell -----------------------

;; Install Intero
;; (add-hook 'haskell-mode-hook 'intero-mode)

;; ----------------------------- fonts -----------------------

(cond
 ((member "Monaco" (font-family-list))
  (set-face-attribute 'default nil :font "Monaco-11")) ((member "Inconsolata" (font-family-list))
  (set-face-attribute 'default nil :font "Inconsolata-11")) ((member "Consolas" (font-family-list))
  (set-face-attribute 'default nil :font "Consolas-10")) ((member "DejaVu Sans Mono" (font-family-list))
  (set-face-attribute 'default nil :font "DejaVu Sans Mono-9")))


;; ----------------------------- rust config -----------------------

(use-package flycheck)
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status)
              ("C-c C-c t" . lsp-goto-implementation)
              )
  :config
  ;; (setq rustic-format-on-save t)
  ;; (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook)
  (global-set-key [f12] 'rustic-format-buffer)
)
(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm
  (setq-local buffer-save-without-query t))

(use-package lsp-mode
  :ensure
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  ;; hide sideline code actions
  (lsp-ui-imenu-enable t)
  (lsp-ui-imenu-auto-refresh t)
  (lsp-ui-imenu-window-width 200)
  (lsp-ui-sideline-show-code-actions nil)
  ;; (lsp-eldoc-enable-hover nil)
  (lsp-signature-render-documentation nil)
  ;; (lsp-eldoc-render-all nil)
  ;; (lsp-idle-delay 0.6)
  ;; (lsp-rust-analyzer-server-display-inlay-hints nil)
  (lsp-headerline-breadcrumb-enable nil)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  )

; (use-package lsp-ui)
(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  ;; :custom
  ;; (lsp-ui-peek-always-show nil)
  ;; (lsp-ui-sideline-show-hover nil)
  ;; (lsp-ui-doc-enable nil)
  )

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

;; ----------------------------- org mode and babel-----------------

;; turn off electric-indent-mode in org-mode as it does some really
;; weird things to indentation
(add-hook 'org-mode-hook (lambda () (electric-indent-mode -1)))

;; active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((http . t)
   (shell . t)))

;; for Markdown export support
(require 'ox-md)
(use-package ox-hugo
  :ensure t ;; auto install from melpa
  :after ox)

;; ----------------------------- rest client -----------------------

;; https://emacs.stackexchange.com/questions/2427/how-to-test-rest-api-with-emacs
;; https://github.com/pashky/restclient.el
(require 'restclient)

;;
