;;; init.el --- Emacs config

;;; Commentary:
;; This is my init.el. There are many like it, but this one is mine.

;;; Code:

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(load "~/.emacs.d/site-init.el" 'noerror)

(prefer-coding-system 'utf-8)
(setq tramp-default-method "ssh")

(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

;; (add-to-list 'default-frame-alist '(fullscreen . maximized))
;; (add-hook 'window-setup-hook 'toggle-frame-fullscreen t)
(setq use-dialog-box nil)
(tooltip-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)
(setq scroll-margin 1
      scroll-conservatively 1
      mouse-wheel-scroll-amount '(1))
(winner-mode 1)

(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode +1)

(setq scroll-error-top-bottom t
      scroll-preserve-screen-position t)

(when (fboundp 'global-so-long-mode)
  (global-so-long-mode 1))
(global-auto-revert-mode)
(defvar whitespace-style '(face trailing))
(whitespace-mode 1)
(defvar show-paren-delay 0)
(show-paren-mode 1)
(delete-selection-mode 1)

(setq undo-limit 8000000
      undo-strong-limit 12000000
      undo-outer-limit 12000000)

(setq dired-dwim-target t)

(defun voxlet/back-to-indentation-or-beginning ()
  "Back-to-indentation-or-beginning."
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point)))
      (beginning-of-line)))
(global-set-key (kbd "C-a") 'voxlet/back-to-indentation-or-beginning)

(global-set-key (kbd "C-z") 'undo)

(defun voxlet/marker-is-point-p (marker)
  "Test if MARKER is current point."
  (and (eq (marker-buffer marker) (current-buffer))
       (= (marker-position marker) (point))))

(defun voxlet/push-mark-maybe ()
  "Push mark onto `global-mark-ring' if mark head or tail is not current location."
  (if (not global-mark-ring) (error "Global mark ring is empty")
    (unless (or (voxlet/marker-is-point-p (car global-mark-ring))
                (voxlet/marker-is-point-p (car (reverse global-mark-ring))))
      (push-mark))))

(defun voxlet/backward-global-mark ()
  "Use `pop-global-mark', pushing current point if not on ring."
  (interactive)
  (voxlet/push-mark-maybe)
  (when (voxlet/marker-is-point-p (car global-mark-ring))
    (call-interactively 'pop-global-mark))
  (call-interactively 'pop-global-mark))

(defun voxlet/forward-global-mark ()
  "Hack `pop-global-mark' to go in reverse, pushing current point if not on ring."
  (interactive)
  (voxlet/push-mark-maybe)
  (setq global-mark-ring (nreverse global-mark-ring))
  (when (voxlet/marker-is-point-p (car global-mark-ring))
    (call-interactively 'pop-global-mark))
  (call-interactively 'pop-global-mark)
  (setq global-mark-ring (nreverse global-mark-ring)))

(global-set-key (kbd "C-,") 'voxlet/backward-global-mark)
(global-set-key (kbd "C-.") 'voxlet/forward-global-mark)

(electric-indent-mode -1)
(add-hook 'after-change-major-mode-hook (lambda() (electric-indent-mode -1)))
(define-key global-map (kbd "RET") 'newline-and-indent)

(setq-default indent-tabs-mode nil
              tab-width 2)
(defvar c-default-style "linux")
(defvaralias 'c-basic-offset 'tab-width)

(setq-default cursor-type '(bar . 1)
              cursor-in-non-selected-windows 'hollow)
(setq blink-cursor-blinks -1)

;; Packages
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(require 'package)
(assq-delete-all 'org package--builtins)
(add-to-list 'package-archives
	           '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
	           '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;;; Load org mode early to ensure that the orgmode ELPA version gets picked up,
;;; not the shipped version
(use-package org :pin org
  :ensure org-plus-contrib
  :custom
  (org-support-shift-select t)
  (org-replace-disputed-keys t)
  (org-startup-truncated nil)
  (org-startup-folded nil))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config (exec-path-from-shell-initialize))

(use-package delight
  :config
  (delight '((eldoc-mode nil "eldoc")
	     (whitespace-mode nil "whitespace"))))

(use-package super-save
  :config
  (super-save-mode +1))

(use-package all-the-icons)

(use-package dashboard
  :if (< (length command-line-args) 2)
  :custom
  (dashboard-items '((projects . 5)
                     (recents . 15)))
  (dashboard-center-content t)
  :hook
  (after-init . dashboard-refresh-buffer)
  :config
  (dashboard-setup-startup-hook))

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italics t)
  (doom-one-light-padded-modeline nil)
  :config
  (load-theme 'doom-one-light t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config)
  (doom-themes-treemacs-config)
  (set-face-background 'show-paren-match nil)
  (set-face-attribute 'highlight nil
                      :foreground (face-foreground 'default)
                      :background (doom-darken (face-background 'default) 0.03)))

(use-package doom-modeline
  :config (doom-modeline-mode 1))

(use-package solaire-mode
  :hook (((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
         (minibuffer-setup . solaire-mode-in-minibuffer))
  :config
  (solaire-global-mode +1)
  (solaire-mode-swap-bg))

(use-package ace-window
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-dispatch-always t)
  (aw-background nil)
  (aw-scope 'frame)
  (aw-ignore-on nil)
  :config
  (set-face-attribute 'aw-leading-char-face nil
                      :weight 'bold)
  :bind ("M-o" . ace-window))

(use-package treemacs
  :custom
  (treemacs-no-png-images nil)
  (treemacs-width 35)
  (treemacs-silent-refresh t)
  (treemacs-silent-filewatch t)
  (treemacs-file-event-delay 1000)
  (treemacs-file-follow-delay 0.05)
  :custom-face
  (treemacs-root-face ((t (:height 1.0 :weight normal))))
  :config
  (set-face-background 'hl-line (doom-darken (face-background 'default) 0.05))
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode nil)
  (pcase (cons (not (null (executable-find "git")))
               (not (null (treemacs--find-python3))))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))
  :bind
  (:map global-map
        ("C-x t o"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))
  (:map treemacs-mode-map
        ("<prior>" . nil)
        ("<next>" . nil)))

(use-package treemacs-projectile
  :after treemacs projectile)

(use-package treemacs-icons-dired
  :after treemacs dired
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit)

(use-package lsp-treemacs
  :after treemacs lsp-mode)

(use-package dired-subtree
  :after dired
  :bind
  (:map dired-mode-map
        ("<tab>" . dired-subtree-toggle)
        ("<backtab>" . dired-subtree-cycle))
  :hook (dired-mode . dired-hide-details-mode))

(use-package centaur-tabs
  :custom
  (centaur-tabs-style 'bar)
  (centaur-tabs-height 28)
  (centaur-tabs-set-icons t)
  (centaur-tabs-set-bar 'over)
  (centaur-tabs-set-close-button nil)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-modified-marker "● ")
  (centaur-tabs-adjust-buffer-order t)
  :custom-face
  (centaur-tabs-default ((t (:inherit 'variable-pitch))))
  (centaur-tabs-selected ((t (:inherit 'variable-pitch))))
  (centaur-tabs-selected-modified ((t (:inherit 'variable-pitch))))
  (centaur-tabs-unselected-modified ((t (:inherit 'variable-pitch))))
  :bind
  ("C-S-<tab>" . centaur-tabs-backward)
  ("C-S-<iso-lefttab>" . centaur-tabs-backward)
  ("s-{" . centaur-tabs-backward)
  ("C-<tab>" . centaur-tabs-forward)
  ("s-}" . centaur-tabs-forward)
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  :config
  (set-face-attribute 'centaur-tabs-unselected nil
                      :inherit 'variable-pitch
                      :foreground (doom-lighten
                                   (face-foreground 'default) 0.5))
  (centaur-tabs-mode t)
  (centaur-tabs-enable-buffer-reordering)
  (centaur-tabs-group-by-projectile-project))

(use-package view
  :bind
  ("<prior>" . View-scroll-half-page-backward)
  ("<next>" . View-scroll-half-page-forward))

(use-package beacon
  :custom
  (beacon-blink-when-point-moves-vertically 2)
  (beacon-color "#FFCC99")
  (beacon-size 20)
  (beacon-blink-delay 0.2)
  :config (beacon-mode 1))

(use-package avy
  :bind ("C-;" . avy-goto-char-2))

(use-package paren-face
  :custom (paren-face-regexp "[][{}()]")
  :config (global-paren-face-mode))

(use-package smart-mode-line
  :config
  (column-number-mode t)
  (sml/setup))

(use-package which-key
  :delight
  :defer 1
  :custom (which-key-idle-delay 0.01)
  :config (which-key-mode))

(use-package help-at-pt
  :custom
  (help-at-pt-timer-delay 1))

(use-package ivy
  :delight
  :defer 0.1
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "")
  (ivy-re-builders-alist '((swiper-isearch . ivy--regex-plus)
                           (counsel-git-grep . ivy--regex-plus)
                           (t . ivy--regex-fuzzy)))
  :config (ivy-mode)
  :bind
  ("C-r" . ivy-resume)
  ("C-x B" . ivy-switch-buffer-other-window))

(use-package counsel
  :delight
  :after ivy
  :config (counsel-mode))

(defun voxlet/swiper-isearch ()
  "Use swiper-isearch-thing-at-point, but only if we have a region."
  (interactive)
  (if (region-active-p)
      (swiper-isearch-thing-at-point)
    (swiper-isearch)))

(use-package swiper
  :after ivy
  :bind ("C-s" . voxlet/swiper-isearch))

(use-package ivy-rich
  :custom (ivy-format-function #'ivy-format-function-line)
  :config (ivy-rich-mode 1))

(use-package company
  :delight
  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 2)
  (company-tooltip-align-annotations t)
  (company-selection-wrap-around t)
  :bind ("TAB" . company-indent-or-complete-common)
  :config (global-company-mode))

(use-package company-flx
  :after company
  :config (company-flx-mode +1))

(use-package projectile
  :delight '(:eval (concat " " (projectile-project-name)))
  :custom (projectile-completion-system 'ivy)
  :config (projectile-mode +1)
  :bind-keymap ("M-p" . projectile-command-map))

(use-package counsel-projectile
  :after counsel projectile
  :config (counsel-projectile-mode))

(use-package column-enforce-mode
  :delight
  :config (global-column-enforce-mode t))

(use-package multiple-cursors
  :demand
  :bind
  ("M-m" . mc/mark-all-dwim)
  ("M-M" . mc/mark-more-like-this-extended)
  ("C-<up>" . mc/mark-previous-like-this)
  ("C-<down>" . mc/mark-next-like-this)
  ("M-<up>" . mc/skip-to-previous-like-this)
  ("M-<down>" . mc/skip-to-next-like-this)
  ("C-S-<up>" . mc/unmark-next-like-this)
  ("C-S-<down>" . mc/unmark-previous-like-this)
  ("C-x SPC" . set-rectangular-region-anchor)
  :config
  (set-face-attribute 'mc/cursor-bar-face nil :height 5))

(use-package expand-region
  :bind
  ("M-S-<up>" . 'er/expand-region)
  ("M-S-<down>" . 'er/contract-region))

(use-package hungry-delete
  :delight
  :config (global-hungry-delete-mode))

(use-package aggressive-indent
  :delight
  :custom (aggressive-indent-dont-electric-modes t)
  :config (global-aggressive-indent-mode 1))

(use-package whitespace-cleanup-mode
  :delight
  :config (global-whitespace-cleanup-mode))

(defun voxlet/add-space-after-insert (id action _context)
  (when (eq action 'insert)
    (save-excursion
      (forward-char (length (plist-get (sp-get-pair id) :close)))
      (when (or (eq (char-syntax (following-char)) ?w)
                (looking-at (sp--get-opening-regexp
                             (sp--get-allowed-pair-list))))
        (insert " ")))))

(use-package smartparens
  :delight
  :custom
  (sp-highlight-pair-overlay nil)
  :hook (clojure-mode . turn-on-smartparens-strict-mode)
  :bind
  ("C-<right>" . sp-forward-slurp-sexp)
  ("C-<left>" . sp-forward-barf-sexp)
  :init
  (smartparens-global-mode t)
  :config
  (require 'smartparens-config)
  (sp-with-modes sp-lisp-modes
    (sp-local-pair "(" nil :post-handlers '(:add voxlet/add-space-after-insert))
    (sp-local-pair "[" nil :post-handlers '(:add voxlet/add-space-after-insert))
    (sp-local-pair "{" nil :post-handlers '(:add voxlet/add-space-after-insert))))

(use-package lsp-mode
  :commands lsp
  :config (require 'lsp-clients))

(use-package lsp-ui)

(use-package flycheck
  :custom (sentence-end-double-space nil)
  :config
  (global-flycheck-mode))

(use-package magit
  :bind ("C-x g"))

(use-package vterm)

;; Clojure

(use-package inf-clojure
  :config
  (setf inf-clojure-project-type "generic")
  (setf inf-clojure-generic-cmd "joker")
  (defun inf-clojure--detect-repl-type (proc) 'joker))

(use-package yasnippet
  :delight (yas-minor-mode))

(use-package clj-refactor
  :delight
  :custom
  (cljr-warn-on-eval nil)
  (cljr-eagerly-build-asts-on-startup nil)
  :config (cljr-add-keybindings-with-prefix "C-c r")
  :hook
  (clojure-mode . clj-refactor-mode)
  (clojure-mode . yas-minor-mode))

(use-package flycheck-clojure
  :after flycheck
  :hook (flycheck-mode . flycheck-clojure-setup))

(use-package flycheck-joker)
(use-package flycheck-clj-kondo)

(use-package cider
  ;;:pin melpa-stable
  :delight " cider"
  :custom
  (cider-repl-pop-to-buffer-on-connect 'display-only)
  (cider-font-lock-dynamically '(macro core function var))
  (cider-overlays-use-font-lock t)
  (cider-save-file-on-load t)
  :hook
  ((cider-repl-mode cider-mode) . cider-company-enable-fuzzy-completion)
  (cider-mode . eldoc-mode)
  ;; :custom-face
  ;; (clojure-keyword-face ((t (:inherit font-lock-constant-face :slant italic))))
  ;; :config
  ;; (buffer-disable-undo "*cider-error*")
  )

(use-package clojure-mode
  :hook (clojure-mode . display-line-numbers-mode)
  :config
  (require 'flycheck-joker)
  (require 'flycheck-clj-kondo)
  (dolist (checker '(clj-kondo-clj clj-kondo-cljs clj-kondo-cljc clj-kondo-edn))
    (setq flycheck-checkers (cons checker (delq checker flycheck-checkers))))
  (dolist (checkers '((clj-kondo-clj . clojure-joker)
                      (clj-kondo-cljs . clojurescript-joker)
                      (clj-kondo-cljc . clojure-joker)
                      (clj-kondo-edn . edn-joker)))
    (flycheck-add-next-checker (car checkers) (cons 'error (cdr checkers)))))

;; JavaScript/TypeScript

(use-package js2-mode
  :mode "\\.js\\'"
  :custom (js2-basic-offset 2)
  :hook
  (js2-mode . js2-imenu-extras-mode)
  (js2-mode . eldoc-mode))

(use-package json-mode
  :custom
  (json-reformat:indent-width 2)
  (js-indent-level 2))

(use-package js2-refactor
  :config (js2r-add-keybindings-with-prefix "C-c r")
  :bind (:map js2-mode-map (("C-k" . js2r-kill)))
  :hook (js2-mode . js2-refactor-mode))

(use-package indium
  :hook (js2-mode . indium-interaction-mode))

(use-package typescript-mode
  :custom
  (typescript-indent-level 2)
  (typescript-auto-indent-flag nil)
  :hook
  (typescript-mode . eldoc-mode)
  (typescript-mode . display-line-numbers-mode))

(use-package tide
  :hook
  ((js2-mode typescript-mode) . tide-setup)
  ((js2-mode typescript-mode) . tide-hl-identifier-mode))

(use-package prettier-js
  :hook ((json-mode js2-mode typescript-mode) . prettier-js-mode))

(use-package add-node-modules-path
  :hook ((json-mode js2-mode typescript-mode) . add-node-modules-path))


;; Rust

(use-package toml-mode)

(use-package rust-mode
  :hook (rust-mode . lsp))

(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck-rust
  :after flycheck
  :hook (flycheck-mode . flycheck-rust-setup))

(use-package yaml-mode
  :config (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode)))

(use-package plantuml-mode
  :custom (plantuml-jar-path "~/bin/plantuml.jar"))

(use-package dockerfile-mode
  :mode "Dockerfile\\'")

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

;; (use-package gcmh
;;   :config (gcmh-mode 1))

(provide 'init)
;;; init.el ends here
