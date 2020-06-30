;;; init.el --- init.el
;;; Commentary:
;; Settings for Emacs.
;;; Code:

;; 同名で拡張子がelcとelのファイルがあった場合、新しい方を読む
;; load時に拡張子まで指定されていた場合はこの限りではない
(setq load-prefer-newer t)


;; Emacs24から標準搭載されたパッケージマネージャの設定
;; package.elの設定
(when (require 'package nil t)
  (setq package-user-dir "~/.emacs.d/elpa/")

  ;;パッケージリポジトリにMarmaladeと開発運営のELPAを追加
  (add-to-list 'package-archives
               '("gnu" . "http://elpa.gnu.org/packages/"))
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives
               '("ELPA" . "http://tromey.com/elpa/"))
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.org/packages/"))
  (add-to-list 'package-archives
               '("org" . "http://orgmode.org/elpa/"))
  ;;インストールしたパッケージにロードパスを通して読み込む
  (package-initialize)

  ;;パッケージ情報を更新
  (unless package-archive-contents (package-refresh-contents))
  (unless (package-installed-p 'use-package)
    ;; use-packageのインストール
    (package-install 'use-package))

  (setq use-package-enable-imenu-support t)
  ;; (setq use-package-always-ensure t)
  ;; M-x use-package-report
  (setq use-package-compute-statistics t))

(eval-when-compile
  (require 'use-package))


;; Emacsの標準的な設定

;; 全体的な環境設定 ;;

;; メニューバーを消す
(menu-bar-mode -1)
;; ツールバーを消す
(tool-bar-mode 0)
;; スタートアップメッセージを非表示
(setq inhibit-startup-message t)

;; バッファ終端で newline を入れない
(setq next-line-add-newlines nil)

;; 対応する括弧を光らせる。
(show-paren-mode 1)

;; スクロールは1行ずつ
;; (setq scroll-conservatively 1)

;; Beep音を消す(その代わりにBeep音が鳴るタイミングで画面が点滅)
(setq visible-bell t)
;; Beep音を鳴らす(画面の点滅は無い)
;(setq visible-bell nil)
;; Beep音も点滅もしないように無効な関数を設定してみる
(setq ring-bell-function 'ignore)

;; リージョンに色を付ける
(setq transient-mark-mode t)

;; 他のエディタなどがファイルを書き換えたらすぐにそれを反映する
;; auto-revert-modeを有効にする
;; (auto-revert-mode t)
(global-auto-revert-mode 1)

;; モードラインに行数とカラムを表示
(column-number-mode 1)

;; 矩形モード
;; C-return
;; (cua-mode t)


;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist (cons "." "~/.emacs.d/backup/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backup/") t)))


;; 行番号表示
(when (version<= "26.0.50" emacs-version )
  ;; (global-display-line-numbers-mode 1)
  ;; 最初から幅を確保
  (custom-set-variables '(display-line-numbers-width-start t))
  
  ;; 行番号エリアの色
  ;; (set-face-attribute 'line-number nil
  ;;                     :foreground "ivory4"
  ;;                     :background "gray1")
  ;; (set-face-attribute 'line-number-current-line nil
  ;;                     :foreground "turquoise3")
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (add-hook 'text-mode-hook 'display-line-numbers-mode)
  )

;; ファイルの終端をフリンジを使い判り易くする
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)


;; Unicodeをメインにする場合の設定
;使用する言語環境
(set-language-environment 'Japanese)
;開く場合に優先する文字コード
(prefer-coding-system       'utf-8)
;デフォルトで使用する文字コード
(set-default-coding-systems 'utf-8)
;新しいファイルを作成するときの文字コード
;; (setq default-buffer-file-coding-system 'utf-8)
(setq buffer-file-coding-system 'utf-8)


;; Emacs24から標準になったelectric系の機能を有効にする
(when (>= emacs-major-version 24)
  ;; 自動で閉じカッコを入れる
  ;;(electric-pair-mode t)
  ;; 改行時にインデント
  (electric-indent-mode t)
  ;; 自動で改行
  ; (electric-layout-mode t)
  )

;; electricをemacs全体で有効にしたくない場合は
;; add-hookで個別に設定する
(defun electric-pair ()
  "If at end of line, insert character pair without surrounding spaces.
    Otherwise, just insert the typed character."
  (interactive)
  (if (eolp) (let (parens-require-spaces) (insert-pair)) (self-insert-command 1)))

;; コメント内または文字列内の場合はelectricを無効
(defadvice electric-pair-post-self-insert-function
    (around electric-pair-post-self-insert-function-around activate)
  "Don't insert the closing pair in comments or strings"
  (unless (nth 8 (save-excursion (syntax-ppss (1- (point)))))
    ad-do-it))


;; フレームの設定
(when window-system
  ;; タイトルバー設定
  ;; タイトルバーにファイル名を表示
  ;; (setq frame-title-format "%b")
  ;; ウィンドウタイトルをファイルパスに
  (setq frame-title-format (format "%%f - Emacs @%s" (system-name)))
  (setq frame-resize-pixelwise t)
  ;; サイズ
  (add-to-list 'default-frame-alist `(width . (text-pixels . ,(- (/ (x-display-pixel-width) 2) 150))))
  (add-to-list 'default-frame-alist `(height . (text-pixels . ,(- (x-display-pixel-height) 200))))
  ;; 位置
  (add-to-list 'default-frame-alist '(left . 100))
  (add-to-list 'default-frame-alist '(top . 80)))

(setq initial-frame-alist default-frame-alist)


;; モードラインに改行コードを表示
(setq eol-mnemonic-dos "(CRLF)")
(setq eol-mnemonic-mac "(CR)")
(setq eol-mnemonic-unix "(LF)")
(setq eol-mnemonic-undecided "(??)")

;; モードラインの色
;; (set-face-foreground 'mode-line "DeepSkyBlue")
;; (set-face-background 'mode-line "gray19")
;; (set-face-background 'mode-line-inactive "gray10")


;; 編集行のハイライト
(defface hlline-face
  '((((class color)
      (background dark))
     ;; (:background "midnight blue"))
     ;; (:background "gray30"))
     ;; (:background "dark slate gray"))
     ;; (:background "gray10"
     ;;              :underline "gray24"))
     ;; (:background nil
     ;;              :underline "RoyalBlue1"))
     (:background nil
                  :underline "dark slate blue"))

    (((class color)
      (background light))
     (:background "ForestGreen"))
    (t
     ()))
  "*Face used by hl-line.")

(setq hl-line-face 'hlline-face)
;; (setq hl-line-face 'underline) ; 下線
(global-hl-line-mode)



;; 右端で折り返さない
(setq-default truncate-lines t)
;;====================================
;;; 折り返し表示ON/OFF
;;====================================
(defun my-toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))
(global-set-key (kbd "C-c t r") 'my-toggle-truncate-lines) 


;; ediff
;; コントロール用のバッファを同一フレーム内に表示
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; diffのバッファを上下ではなく左右に並べる
(setq ediff-split-window-function 'split-window-horizontally)

(add-hook 'ediff-load-hook
          (lambda ()
            (set-face-foreground
             ediff-even-diff-face-A "navy")
            (set-face-foreground
             ediff-even-diff-face-B "navy")
            (set-face-foreground
             ediff-even-diff-face-C "navy")
            (set-face-foreground
             ediff-odd-diff-face-A "navy")
            (set-face-foreground
             ediff-odd-diff-face-B "navy")
            (set-face-foreground
             ediff-odd-diff-face-C "navy")
            (set-face-background
             ediff-even-diff-face-A "dark gray")
            (set-face-background
             ediff-even-diff-face-B "dark gray")
            (set-face-background
             ediff-even-diff-face-C "dark gray")
            (set-face-background
             ediff-odd-diff-face-A "dark gray")
            (set-face-background
             ediff-odd-diff-face-B "dark gray")
            (set-face-background
             ediff-odd-diff-face-C "dark gray")))


;; eww
;; eww(emacs web wowser)
;;デフォルトの検索エンジンはduckduckgoのままだが地域を日本として検索するように設定
;;(setq eww-search-prefix "https://duckduckgo.com/html/?kl=jp-jp&q=")
;;広告なし
;; (setq eww-search-prefix "https://duckduckgo.com/html/?kl=jp-jp&k1=-1&q=")
;; (setq eww-search-prefix "https://duckduckgo.com/html/?kl=jp-jp&k1=-1&kc=-1&kf=-1&q=")

;; eww for google
(defvar eww-disable-colorize t)
(defun shr-colorize-region--disable (orig start end fg &optional bg &rest _)
  (unless eww-disable-colorize
    (funcall orig start end fg)))
(advice-add 'shr-colorize-region :around 'shr-colorize-region--disable)
(advice-add 'eww-colorize-region :around 'shr-colorize-region--disable)
(defun eww-disable-color ()
  "eww で文字色を反映させない"
  (interactive)
  (setq-local eww-disable-colorize t)
  (eww-reload))
(defun eww-enable-color ()
  "eww で文字色を反映させる"
  (interactive)
  (setq-local eww-disable-colorize nil)
  (eww-reload))
(setq eww-search-prefix "http://www.google.co.jp/search?q=")


;; ショートカットキー設定
;; M-g で指定行へ移動
(global-set-key (kbd "M-g") 'goto-line)

;; 複数行コメントブロック
;; (global-set-key (kbd "C-c >") 'comment-region)
;; (global-set-key (kbd "C-c <") 'uncomment-region)
;; 今の標準
;; default key map "M-;"
;; (global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)


;; C-h でbackspace
(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))

;; 各OSに依存した設定
(cond
 ((eq system-type 'windows-nt)
  (load "~/.emacs.d/init-windows"))
 ((eq system-type 'darwin)
  (load "~/.emacs.d/init-macos"))
 ((eq system-type 'gnu/linux)
  (load "~/.emacs.d/init-xwindow"))
 )


;; packages

(use-package bind-key
  :ensure t)

(use-package diminish
  :ensure t
  :config
  )

(use-package auto-package-update
  :ensure t
  :disabled t
  :config
  ;; interval 10days
  (setq auto-package-update-delete-old-versions t
        auto-package-update-interval 10)
  (auto-package-update-maybe))

(use-package smooth-scrolling
  :ensure t
  :config
  (smooth-scrolling-mode 1)
  :custom
  (mouse-wheel-scroll-amount '(5 ((shift) . 1)))        ;; one line at a time
  (mouse-wheel-progressive-speed nil)                   ;; don't accelerate scrolling
  (mouse-wheel-follow-mouse 't)                         ;; scroll window under mouse
  (scroll-step 1)                                       ;; keyboard scroll one line at a time
  )

(use-package ctags-update
  :ensure t
  :defer t
  :bind (([f5] . ctags-update))
  ;; :init
  ;; (setq ctags-command "ctags -R -e")
  :custom
  (ctags-command "ctags -R -e")
  )

(use-package cp5022x
  :ensure t)

;; 同名ファイルのバッファ名の識別文字列を変更
(use-package uniquify
  :custom
  (uniquify-buffer-name-style 'post-forward-angle-brackets)
  (uniquify-min-dir-content  2))


(use-package anzu
  :ensure t
  :diminish anzu-mode
  ;; :bind (
  ;;     ("C-c r" . anzu-query-replace)
  ;;     ("C-c R" . anzu-query-replace-regexp))
  :config
  (global-anzu-mode +1))


;; 前回編集していた場所を記憶
(use-package saveplace
  :ensure t
  :config
  (save-place-mode 1))

(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode "EdCnf"
  :config
  (editorconfig-mode 1))


(use-package expand-region
  :ensure t
  :defer t
  :bind (
         ("C-@" . er/expand-region)
         ("C-M-@" . er/contract-region)))

(use-package multiple-cursors
  :ensure t
  :defer t
  :bind (
         ("C->" . mc/mark-next-like-this)
         ("C-M->" . mc/skip-to-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))


;; yank時に一定時間だけハイライトさせる
(use-package volatile-highlights
  :ensure t
  :config
  (volatile-highlights-mode t))


(use-package whitespace
  :ensure t
  :custom
  ;; 可視化するものを指定
  (whitespace-style
   '(face           ; faceで可視化
     ;; trailing       ; 行末
     ;; empty          ; 空行
     ;; spaces
     tabs
     newline
     ;; space-mark     ; マークを表示
     ;; tab-mark
     newline-mark
     ))
  
  (whitespace-display-mappings
   '(
     (newline-mark ?\n    [?\x2193 ?\n] [?$ ?\n])
     ))
  
  :config
  (set-face-attribute 'whitespace-tab nil
                      :background "gray6"
                      :foreground "LightSkyBlue"
                      :underline nil)

  (set-face-attribute 'whitespace-newline nil
                      :background nil
                      :foreground "DimGray"
                      :underline nil)

  (global-whitespace-mode 1))


;; theme
(use-package tron-legacy-theme
  :ensure t
  :init
  :custom
  (tron-legacy-theme-dark-fg-bright-comments t)
  :config
  (load-theme 'tron-legacy t)

  ;;themeで設定された色を少し変える
  ;; 行番号エリアの色
  (set-face-attribute 'line-number nil
                      :foreground "ivory4"
                      :background "gray3")
  
  (set-face-attribute 'line-number-current-line nil
                      :foreground "turquoise3")

  ;; モードラインの色
  (set-face-foreground 'mode-line "DeepSkyBlue")
  (set-face-background 'mode-line "gray19")
  (set-face-background 'mode-line-inactive "gray10")
  )


;; 英語か日本語かは自動判定してくれる
;; region指定してC-M-tすると、そのregionの翻訳をしてくれる
;; region指定せずにC-M-tすると、現在位置のwordを翻訳してくれる
;; C-u C-M-tすると、自分で調べたいものを入力できる
(use-package google-translate
  :ensure t
  :init
  (require 'google-translate-default-ui)
  (defun google-translate-enja-or-jaen (&optional string)
    "regionか現在位置の単語を翻訳する。C-u付きでquery指定も可能"
    (interactive)
    (setq string
          (cond ((stringp string) string)
                (current-prefix-arg
                 (read-string "Google Translate: "))
                ((use-region-p)
                 (buffer-substring (region-beginning) (region-end)))
                (t
                 (thing-at-point 'word))))
    (let* ((asciip (string-match
                    (format "\\`[%s]+\\'" google-translate-english-chars)
                    string)))
      (run-at-time 0.1 nil 'deactivate-mark)
      (google-translate-translate
       (if asciip "en" "ja")
       (if asciip "ja" "en")
       string)))

  ;; 2019-05-21
  ;; Fix error of "Failed to search TKK"
  (defun google-translate--get-b-d1 ()
    ;; TKK='427110.1469889687'
    (list 427110 1469889687))

  ;; 2020-05-12
  ;; args-out-of-range [] 1
  (defun google-translate-json-suggestion (json)
    "Retrieve from JSON (which returns by the
`google-translate-request' function) suggestion. This function
does matter when translating misspelled word. So instead of
translation it is possible to get suggestion."
    (let ((info (aref json 7)))
      (if (and info (> (length info) 0))
          (aref info 1)
        nil)))
  :bind(
        ("C-M-t" . google-translate-enja-or-jaen))
  :custom
  (google-translate-english-chars "[:ascii:]" "これらの文字が含まれているときは英語とみなす")
  )


;; vlf
;;Automatically lanches for large file.
(use-package vlf
  :ensure t
  :config
  (require 'vlf-setup)
  )


;; ddskk
(use-package ddskk
  :ensure t
  :bind (("C-x j" . skk-mode))
  :init
  (setq skk-byte-compile-init-file t
        skk-init-file "~/.emacs.d/init-ddskk")
  :custom
  (skk-user-directory "~/.ddskk")
  (default-input-method "japanese-skk")
  :config
  (require 'skk-study)
  (setq skk-study-sesearch-times 10)
  :hook
  (emacs-startup . (lambda () (skk-mode) (skk-latin-mode-on)))
  (prog-mode . (lambda () (skk-mode) (skk-latin-mode-on)))
  )

(use-package telephone-line
  :ensure t
  :init
  ;; 色の定義
  (defface my-important-label   '((t (:foreground "cyan" :background "gray1" :inherit mode-line))) "")
  (defface my-information-label '((t (:foreground "RoyalBlue" :background "gray5" :inherit mode-line))) "")
  (defface my-notice-label      '((t (:foreground "PaleGreen" :background "gray5" :inherit mode-line))) "")
  (defface my-warning-label     '((t (:foreground "OrangeRed1" :background "gray1" :inherit mode-line))) "")

  :custom
  ;; 高さ
  (telephone-line-height 26)

  ;; セパレータの形を指定
  (telephone-line-primary-left-separator 'telephone-line-cubed-left)
  (telephone-line-secondary-left-separator 'telephone-line-cubed-hollow-left)
  (telephone-line-primary-right-separator 'telephone-line-gradient)
  (telephone-line-secondary-right-separator 'telephone-line-nil)

  ;; 左側で表示するコンテンツの設定
  (telephone-line-lhs
   '((nil          . (telephone-line-input-info-segment))
     (important    . (telephone-line-major-mode-segment))
     (information  . (telephone-line-vc-segment))
     (nil          . (telephone-line-projectile-buffer-segment
                      telephone-line-position-segment
                      telephone-line-filesize-segment))))
  ;; 右側で表示するコンテンツの設定
  (telephone-line-rhs
   '((warning      .       (telephone-line-flycheck-segment))
     (notice       .       (telephone-line-minor-mode-segment))))

  (telephone-line-faces
   '((important    .       (my-important-label . my-important-label))
     (information  .       (my-information-label . my-information-label))
     (notice       .       (my-notice-label . my-notice-label))
     (warning      .       (my-warning-label . my-warning-label))
     (evil         .       telephone-line-evil-face)
     (accent       .       (telephone-line-accent-active . telephone-line-accent-inactive))
     (nil          .       (mode-line . mode-line-inactive))))

  :config
  (telephone-line-mode 1))


(use-package git-gutter
  :ensure t
  :custom
  ;; (git-gutter:window-width 2)
  (git-gutter:modified-sign "~")
  (git-gutter:added-sign "+")
  (git-gutter:deleted-sign "-")

  ;; first character should be a space
  (git-gutter:lighter " GG")
  ;; (git-gutter:update-interval 2)

  :custom-face
  (git-gutter:modified ((t (:foreground "DarkGoldenrod" :background "gray2"))))
  (git-gutter:added ((t (:foreground "DarkCyan" :background "gray2"))))
  (git-gutter:deleted ((t (:foreground "DeepPink" :background "gray2"))))

  :config
  (global-git-gutter-mode +1))


;; recentf
(use-package recentf-ext
  :ensure t
  :defer t
  :custom
  (recentf-max-saved-items 3000)
  (recentf-save-file "~/.emacs.d/recentf")
  (recentf-exclude '("recentf"))
  (recentf-auto-cleanup 30)
  ;; (recentf-auto-cleanup 'never)
  (recentf-auto-save-timer
   (run-with-idle-timer 30 t 'recentf-save-list))
  :config
  (recentf-mode 1)
  )


(use-package helm
  :ensure t
  :defer t
  :bind (
  ;; ファイル関係(履歴やバッファなどのファイルリスト)
  ("C-;" . helm-for-files)
  ;; ctagsによる関数ジャンプ
  ;; ("M-." . helm-etags-select)
  ;; 過去にコピーした履歴から選んで貼り付け
  ("M-y" . helm-show-kill-ring)
  ;; バッファ内の関数を絞り込む
  ("C-c i" . helm-imenu)

  ("M-x" . helm-M-x)
  ("C-x C-f" . helm-find-files)

  :map helm-find-files-map
  ("C-h" . delete-backward-char)
  ("TAB" . helm-execute-persistent-action)
  )

  :custom
  ;; (helm-M-x-fuzzy-match t)
  (helm-idle-delay             0.3)
  (helm-input-idle-delay       0.3)
  (helm-candidate-number-limit 200)

  ;; locateを使わないようにする
  (helm-for-files-preferred-list
   '(helm-source-buffers-list
     helm-source-recentf
     helm-source-bookmarks
     helm-source-file-cache
     helm-source-files-in-current-dir
     ;; helm-source-locate
     ))

  :config
  (helm-mode 1))


(use-package helm-descbinds
  :ensure t
  :defer t
  :bind(
        ("C-c b" . helm-descbinds))
  :config
  (helm-descbinds-mode))

(use-package helm-migemo
  :ensure t
  :defer t
  :config
  (helm-migemo-mode 1))

(use-package helm-ag
 :ensure t
 :defer t
 :bind (
        ;; ディレクトリも再起的に検索するには、C-uを最初に打つ
        ("C-c g" . helm-do-ag)))

(use-package helm-swoop
  :ensure t
  :defer t
  :after helm
  :bind (
         ("M-i" . helm-swoop)
         ("M-I" . helm-swoop-back-to-last-point)
         ("C-c M-i" . helm-multi-swoop)
         ("C-x M-i" . helm-multi-swoop-all)

         :map isearch-mode-map
         ("M-i" . helm-swoop-from-isearch)
         :map helm-swoop-map
         ("M-i" . helm-multi-swoop-all-from-helm-swoop)
         ("M-m" . helm-multi-swoop-current-mode-from-helm-swoop)
         ("C-r" . helm-previous-line)
         ("C-s" . helm-next-line)
         :map helm-multi-swoop-map
         ("C-r" . helm-previous-line)
         ("C-s" . helm-next-line)
         )

  :custom
  (helm-multi-swoop-edit-save t)
  (helm-swoop-move-to-line-cycle t)
  ;; If you prefer fuzzy matching
  ;; (helm-swoop-use-fuzzy-match t)
  )


(use-package projectile
  :ensure t
  :after (helm)
  :diminish projectile-mode

  :bind-keymap
  ("s-p" . projectile-command-map)
  ("C-c p" . projectile-command-map)

  :custom
  (projectile-completion-system 'helm)

  :config
  (projectile-mode +1))


(use-package helm-projectile
  :ensure t
  :defer t
  :after (projectile helm)
  :diminish projectile-mode
  :init
  ;; :bind (
  ;;        ("C-c p p" . helm-projectile-switch-project))
  :config
  (helm-projectile-on))


(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode "UndoT"
  :config
  (global-undo-tree-mode t))


;; Install fonts file after install package.
;; M-x all-the-icons-install-fonts
(use-package all-the-icons
  :ensure t
  )

(use-package neotree
  :ensure t
  :defer t
  :after (all-the-icons)
  :bind (
         ([f8] . neotree-toggle)
         )

  :custom
  ;; Press '?' for neotree help.
  ;; 隠しファイルをデフォルトで表示
  (neo-show-hidden-files t)
  ;; キーバインドをシンプルにする
  (neo-keymap-style 'concise)
  ;; neotree ウィンドウを表示する毎に current file のあるディレクトリを表示する
  (neo-smart-open t)

  (neo-theme (if (display-graphic-p) 'icons 'arrow))

  (neo-window-fixed-size nil)
  (neo-window-width 40)
  (neo-autorefresh t)
  )


(use-package company
  :ensure t
  :defer t
  :diminish company-mode
  :hook
  ;; プログラミング言語時に有効にする
  (prog-mode . company-mode)
  :bind (
         ;; ("<tab>" . company-indent-or-complete-common)
         :map company-active-map
              ;; C-n, C-pで補完候補を次/前の候補を選択
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ;; C-sで絞り込む
              ("C-s" . company-filter-candidates)
              ;; TABで候補を設定
              ("C-i" . company-complete-selection)
         :map company-search-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              )
  :custom
  (company-idle-delay 0.2) ; デフォルトは0.5
  (company-minimum-prefix-length 2) ; デフォルトは4
  (company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
  (completion-ignore-case t)
  (company-dabbrev-char-regexp "\\(\\sw\\|\\s_\\|_\\|-\\)")    ; -_を含むものも補完対象とする

  :custom-face
  ;; 色をauto-completeっぽく
  (company-tooltip
   ((t (:foreground "black" :background "lightgrey"))))
  (company-tooltip-common
   ((t (:foreground "black" :background "lightgrey"))))
  (company-tooltip-common-selection
   ((t (:foreground "white" :background "steelblue"))))
  (company-tooltip-selection
   ((t (:foreground "black" :background "steelblue"))))
  (company-preview-common
   ((t (:background nil :foreground "lightgrey" :underline t))))
  (company-scrollbar-fg
   ((t (:background "orange"))))
  (company-scrollbar-bg
   ((t (:background "gray40"))))


  :config
  ;; 全バッファで有効にする
  ;; (global-company-mode +1)
  )

(use-package company-quickhelp
  :ensure t
  :after (company)
  :hook
  (company-mode . company-quickhelp-mode)
  )


(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :bind (
         :map yas-minor-mode-map
         ;; 既存スニペットを挿入する
         ("C-x i i" . yas-insert-snippet)
         ;; 新規スニペットを作成するバッファを用意する
         ("C-x i n" . yas-new-snippet)
         ;; 既存スニペットを閲覧・編集する
         ("C-x i v" . yas-visit-snippet-file)
         )
  :custom
  (yas-snippet-dirs
   '("~/.emacs.d/yasnippets/snippets")
   )
  :init
  (yas-global-mode 1))


(use-package flycheck
  :ensure t
  :bind (
         ("C-c n" . flycheck-next-error)
         ("C-c p" . flycheck-previous-error)
         ("C-c d" . flycheck-list-errors))
  :hook
  ;; (php-mode . (lambda () (setq flycheck-phpcs-standard "PSR2")
  (prog-mode . flycheck-mode)
  ;; :config
  ;; (global-flycheck-mode t)
  )

(use-package flycheck-pos-tip
  :ensure t
  :defer t
  :after (flycheck)
  :config
  (flycheck-pos-tip-mode))


(use-package flycheck-phpstan
  :ensure t
  :defer t
  :config
  (defun my-php-mode-hook ()
    "My PHP-mode hook."
    (require 'flycheck-phpstan)
    (flycheck-mode t)
    (flycheck-select-checker 'phpstan))

  (add-hook 'php-mode-hook 'my-php-mode-hook)
  )

(use-package slime
  :ensure t
  :defer t
  :custom
  ;; (inferior-lisp-program "clisp")
  (inferior-lisp-program "sbcl")
  :config
  (slime-setup '(slime-repl slime-fancy slime-banner)))

(use-package rvm
  :ensure t
  :defer t
  :config
  (rvm-use-default) ;; use rvm's default ruby for the current Emacs session
  )


(use-package imenu-list
  :ensure t
  :defer t
  :bind (
         ("C-'" . imenu-list-smart-toggle)
         )
  :custom
  ;; (setq imenu-list-focus-after-activation t)
  ;; (setq imenu-list-auto-resize t)
  (imenu-list-idle-update-delay-time 2)
  )


(use-package rainbow-mode
  :ensure t
  :defer t
  :hook
  (css-mode . rainbow-mode)
  (scss-mode . rainbow-mode)
  (sass-mode-hook . rainbow-mode)
  ;; (add-hook 'html-mode-hook 'rainbow-mode)
  )

(use-package rainbow-delimiters
  :ensure t
  :defer t

  :init
  (require 'cl-lib)
  (require 'color)
  (defun rainbow-delimiters-using-stronger-colors ()
    (cl-loop
     for index from 1 to rainbow-delimiters-max-face-count
     do
     (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
       (cl-callf color-saturate-name (face-foreground face) 30))))

  :hook
  (prog-mode . rainbow-delimiters-mode)
  (emacs-startup . rainbow-delimiters-using-stronger-colors))


(use-package highlight-indent-guides
  :ensure t
  :diminish highlight-indent-guides-mode
  :defer t
  :custom
  ;; (highlight-indent-guides-method 'fill)

  ;; (highlight-indent-guides-method 'column)

  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-character ?\|)

  ;; (highlight-indent-guides-method 'bitmap)

  ;; (highlight-indent-guides-auto-enabled t)
  (highlight-indent-guides-auto-enabled nil)

  ;; (highlight-indent-guides-auto-odd-face-perc 15)
  ;; (highlight-indent-guides-auto-even-face-perc 15)

  ;; (highlight-indent-guides-auto-character-face-perc 20)

  ;; (highlight-indent-guides-delay 0.3)

  :custom-face
  ;; (highlight-indent-guides-odd-face ((t (:background "darkgray"))))
  ;; (highlight-indent-guides-even-face ((t (:background "dimgray"))))
  (highlight-indent-guides-character-face ((t (:foreground "DarkSlateBlue"))))

  :hook
  (prog-mode . highlight-indent-guides-mode)
  (yaml-mode . highlight-indent-guides-mode)
  )

(use-package ag
  :ensure t
  )

(use-package dumb-jump
  :ensure t
  :defer t
  ;; :hook
  ;; (prog-mode . dumb-jump-mode)
  ;; (php-mode . dumb-jump-mode)
  :custom
  (dumb-jump-selector 'helm)
  (dumb-jump-use-visible-window nil)

  (dumb-jump-default-project "")
  (dumb-jump-force-searcher 'ag)

  :config
  ;; C-M-g jump
  ;; C-M-p back
  ;; C-M-q
  (dumb-jump-mode)

  ;; :bind
  ;; (define-key global-map [(super .)] 'dumb-jump-go)
  ;; (define-key global-map [(super shift .)] 'dumb-jump-back)
  ;; (define-key global-map (kbd "S-.") 'dumb-jump-go)
  ;; (define-key global-map (kbd "S-,") 'dumb-jump-back)
  ;; (global-set-key (kbd "S-.") 'dumb-jump-go)
  ;; (global-set-key (kbd "S-,") 'dumb-jump-back)
  )

(use-package smart-jump
  :ensure t
  ;; :bind
  ;; ([(super d)] . smart-jump-go)
  :config
  ;; (smart-jump-register :modes '(php-mode))
  (smart-jump-setup-default-registers)
  )


(use-package dockerfile-mode
  :ensure t
  :mode
  ("Dockerfile\\'" . dockerfile-mode))



(use-package php-mode
  :ensure t
  ;; :pin melpa-stable
  :defer t
  :mode
  ("\\.php$" . php-mode)
  ("\\.inc$" . php-mode)
  ("\\.ctp$" . php-mode)
  :custom
  (php-manual-url 'ja)
  (php-mode-coding-style 'psr2)
  :config
  ;; M-fなどの単語単位の移動をキャメルケース単位にする
  (subword-mode 1)
  )

(use-package company-phpactor
  :ensure t
  :disabled t
  )

(use-package phpactor
  ;; phpactor-install-or-update
  :ensure t
  :disabled t
  :after (php-mode smart-jump)
  :hook
  ((php-mode . (lambda () (set (make-local-variable 'company-backends)
                               '(;; list of backends
                                 company-phpactor
                                 company-files
                                 )))))
  :config
  (phpactor-smart-jump-register)
  )


(use-package yaml-mode
  :ensure t
  :defer t
  :mode
  ("\\.yml$" . yaml-mode))


(use-package adoc-mode
  :ensure t
  :defer t
  :mode
  ("\\.adoc$" . adoc-mode)
  ("\\.asciidoc$" . adoc-mode))



(use-package web-mode
  :ensure t
  :defer t
  :mode
  ("\\.html\\'" . web-mode)
  ("\\.xhtml\\'" . web-mode)
  ("\\.shtml\\'" . web-mode)
  ("\\.tpl\\'" . web-mode)
  ("\\.ctp\\'" . web-mode)
  ("\\.ejs\\'" . web-mode)
  ("\\.[agj]sp\\'" . web-mode)
  ("\\.as[cp]x\\'" . web-mode)
  ("\\.tag\\'" . web-mode)
  ("\\.tag\\.js\\'" . web-mode)
  ("\\.vue\\'" . web-mode)
  :custom
  ;; web-modeの設定
  (web-mode-markup-indent-offset 4) ;; html indent
  (web-mode-css-indent-offset 4)    ;; css indent
  (web-mode-code-indent-offset 4)   ;; script indent(js,php,etc..)
  (web-mode-comment-style 2)
  :bind (
         :map web-mode-map
              ("C-;" . nil)
              ("C-c C-;" . web-mode-comment-or-uncomment)
              )
  :config
  (defun my-web-mode-hook ()
    "Hooks for Web mode."
    ;; 変更日時の自動修正
    (setq time-stamp-line-limit -200)
    (if (not (memq 'time-stamp write-file-hooks))
	(setq write-file-hooks
	      (cons 'time-stamp write-file-hooks)))
    (setq time-stamp-format " %3a %3b %02d %02H:%02M:%02S %:y %Z")
    (setq time-stamp-start "Last modified:")
    (setq time-stamp-end "$")
    )
  (add-hook 'web-mode-hook  'my-web-mode-hook))


(use-package js2-mode
  :ensure t
  :defer t
  :mode
  ("\\.js$" . js2-mode)
  ("\\.json$" . js2-mode)
  :hook
  (js2-mode . electric-pair-mode)
  )

(use-package tern
  :ensure t
  )

(use-package company-tern
  :ensure t
  :disabled t
  :defer t
  :custom
  (company-tern-property-marker "")
  :hook
  (js2-mode-hook . tern-mode) ; 自分が使っているjs用メジャーモードに変える
  :config
  
  ;; nodeのnpmでternをグローバルにインストールしておく
  ;; M-. 定義ジャンプ
  ;; M-, 定義ジャンプから戻る
  ;; C-c C-r 変数名のリネーム
  ;; C-c C-c 型の取得
  ;; C-c C-d docsの表示
  (defun company-tern-depth (candidate)
    "Return depth attribute for CANDIDATE. 'nil' entries are treated as 0."
    (let ((depth (get-text-property 0 'depth candidate)))
      (if (eq depth nil) 0 depth)))
  (add-to-list 'company-backends 'company-tern) ; backendに追加
  (add-to-list 'company-backends '(company-tern :with company-dabbrev-code))
  )



;;; init.el ends here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ctags-command "ctags -R -e" t)
 '(display-line-numbers-width-start t)
 '(mouse-wheel-follow-mouse t)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (5 ((shift) . 1))))
 '(package-selected-packages (quote (use-package)))
 '(scroll-step 1)
 '(tron-legacy-theme-dark-fg-bright-comments t)
 '(uniquify-buffer-name-style (quote post-forward-angle-brackets) nil (uniquify))
 '(uniquify-min-dir-content 2)
 '(whitespace-display-mappings (quote ((newline-mark 10 [8595 10] [36 10]))))
 '(whitespace-style (quote (face tabs newline newline-mark))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-preview-common ((t (:background nil :foreground "lightgrey" :underline t))))
 '(company-scrollbar-bg ((t (:background "gray40"))))
 '(company-scrollbar-fg ((t (:background "orange"))))
 '(company-tooltip ((t (:foreground "black" :background "lightgrey"))))
 '(company-tooltip-common ((t (:foreground "black" :background "lightgrey"))))
 '(company-tooltip-common-selection ((t (:foreground "white" :background "steelblue"))))
 '(company-tooltip-selection ((t (:foreground "black" :background "steelblue"))))
 '(git-gutter:added ((t (:foreground "DarkCyan" :background "gray2"))))
 '(git-gutter:deleted ((t (:foreground "DeepPink" :background "gray2"))))
 '(git-gutter:modified ((t (:foreground "DarkGoldenrod" :background "gray2"))))
 '(highlight-indent-guides-character-face ((t (:foreground "DarkSlateBlue")))))
