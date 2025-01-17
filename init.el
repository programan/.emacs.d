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
  ;; (add-to-list 'package-archives
  ;;              '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.org/packages/"))
  (add-to-list 'package-archives
               '("melpa-stable" . "http://stable.melpa.org/packages/"))
  (add-to-list 'package-archives
               '("ELPA" . "http://tromey.com/elpa/"))
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
  (add-hook 'conf-mode-hook 'display-line-numbers-mode)
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
     (:background unspecified
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
;; (setq eww-search-prefix "http://www.google.co.jp/search?q=")
(setq eww-search-prefix "https://www.google.com/search?&gws_rd=cr&complete=0&pws=0&tbs=li:1&q=")

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

;; C-x C-<tab>でフレーム切り替え
(global-set-key (kbd "C-x C-<tab>") 'other-frame)


;; 各OSに依存した設定
(cond
((eq system-type 'windows-nt)
 (load "~/.emacs.d/init-windows"))
 ((eq system-type 'darwin)
  (load "~/.emacs.d/init-macos"))
 ((eq system-type 'gnu/linux)
  (load "~/.emacs.d/init-xwindow"))
 )


;; ファイルを訪問時のフックからvc-find-file-hookを削除
;; こいつが有効だと、gitとかcvsとかのディレクトリがある場合に
;; 再帰的にいろいろ調査しようとして、動きがすごく重たい
;; ネットワークディレクトリ上のファイルを開くと顕著
;; gitとかcvsとかの便利機能をemacsで使わないならオフ
;; ちなみにgitはmagitというlispがある。でもWindowsでは動かないかも
;; (remove-hook 'find-file-hooks 'vc-find-file-hook)
(eval-after-load "vc" '(remove-hook 'find-file-hooks 'vc-find-file-hook))


;; warn when opening files bigger than 200MB
(setq large-file-warning-threshold 200000000)
;; gc 12MB
(setq gc-cons-threshold 12000000)


;;(remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)

;; 矩形モード
;; C-return
(cua-mode t)
;; デフォルトキーバインドを無効化
(setq cua-enable-cua-keys nil)



;; packages

(use-package bind-key
  :ensure t)

(use-package diminish
  :ensure t
  :config
  )

(use-package posframe
  :ensure t)

(use-package auto-package-update
  :ensure t
  ;; :disabled t
  :config
  ;; interval 1000days
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-interval 1000)
  (setq auto-package-update-prompt-before-update t)
  (auto-package-update-maybe)

  ;; now
  ;; (add-hook 'auto-package-update-before-hook
  ;;           (lambda () (message "I will update packages now")))
  ;; (save-window-excursion
  ;;   (auto-package-update-now))
  )

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

(use-package csv-mode
  ;; C-c C-a 整形
  ;; C-c C-u 戻す
  ;; C-c C-k フィールド番号(範囲または任意の番号)
  ;; C-c C-k 1 2 3
  ;; C-c C-k 2-4
  ;; C-c C-z 貼り付け
  ;; C-c C-t 行入れ替え
  :ensure t
  :pin gnu
  :mode
  ("\\.csv\\'" . csv-mode)
  )

;; 同名ファイルのバッファ名の識別文字列を変更
(use-package uniquify
  :custom
  (uniquify-buffer-name-style 'post-forward-angle-brackets)
  (uniquify-min-dir-content  2))

(use-package dired
  :custom
  ;; 2画面(2つのwindow)でdired使用時に移動(コピー先)をもう1つのdiredにする
  (dired-dwim-target t)
  ;; 常にディレクトリは再起コピー
  (dired-recursive-copies 'always)
  ;; dired検索時にファイル名だけにマッチ
  ;; (dired-isearch-filenames t)
  ;; ファイルリストのオプション(ls -alh)
  (dired-listing-switches "-alh")
)


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
  :diminish volatile-highlights-mode
  :config
  (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
  (vhl/install-extension 'undo-tree)

  (set-face-attribute
   'vhl/default-face nil :foreground "#008B8B" :background "#757575")
  (volatile-highlights-mode t)

  ;; ふわっとエフェクトの追加（ペースト時の色 => カーソル色 => 本来色）
  (defun my:vhl-change-color ()
    (let
        ((next 0.2)
         (reset 0.5)
         (colors '("#454545" "#262626" "#171717" "#080808" "#030303")))
      (dolist (color colors)
        (run-at-time next nil
                     'set-face-attribute
                     'vhl/default-face
                     nil :foreground "#008B8B" :background color)
        (setq next (+ 0.05 next)))
      (run-at-time reset nil 'vhl/clear-all))
    (set-face-attribute 'vhl/default-face
                        nil :foreground "#008B8B"
                        :background "#757575"))

  (defun my:yank (&optional ARG)
    (interactive)
    (yank ARG)
    (my:vhl-change-color))
  ;; (global-set-key (kbd "M-v") 'my:yank)
  (global-set-key (kbd "C-y") 'my:yank)

  (with-eval-after-load "org"
    (define-key org-mode-map (kbd "C-y")
      #'(lambda () (interactive)
         (org-yank)
         (my:vhl-change-color))))
  )


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
                      :background 'unspecified
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
                      :foreground "snow4"
                      :background "gray5")

  (set-face-attribute 'line-number-current-line nil
                      :foreground "turquoise2"
                      :background "black")

  ;; モードラインの色
  (set-face-foreground 'mode-line "DeepSkyBlue")
  (set-face-background 'mode-line "gray19")
  (set-face-background 'mode-line-inactive "gray10")
  )


(use-package websocket
  :ensure t)

(use-package web-server
  :ensure t)

(use-package uuidgen
  :ensure t)

;; 英語か日本語かは自動判定してくれる
;; region指定してC-M-tすると、そのregionの翻訳をしてくれる
;; region指定せずにC-M-tすると、現在位置のwordを翻訳してくれる
;; C-u C-M-tすると、自分で調べたいものを入力できる
(use-package google-translate
  :ensure t

  :custom
  (google-translate-backend-method 'curl)

  :config
  (require 'google-translate-default-ui)
  (defvar google-translate-english-chars "[:ascii:]’“”–"
    "これらの文字が含まれているときは英語とみなす")

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
                 ;; (thing-at-point 'word))))

                 (save-excursion
                   (let (s)
                     (forward-char 1)
                     (backward-sentence)
                     (setq s (point))
                     (forward-sentence)
                     (buffer-substring s (point)))))))

    (let* ((asciip (string-match
                    (format "\\`[%s]+\\'" google-translate-english-chars)
                    string)))
      (run-at-time 0.1 nil 'deactivate-mark)

      ;; (message "------!!!!!!!-----!!!!   `%s'..." string)
      (google-translate-translate
       (if asciip "en" "ja")
       (if asciip "ja" "en")
       string)))

  ;; 2019-05-21
  ;; Fix error of "Failed to search TKK"
  ;; (defun google-translate--get-b-d1 ()
  ;;   ;; TKK='427110.1469889687'
  ;;   (list 427110 1469889687))

  ;; 2020-05-12
  ;; args-out-of-range [] 1
;;   (defun google-translate-json-suggestion (json)
;;     "Retrieve from JSON (which returns by the
;; `google-translate-request' function) suggestion. This function
;; does matter when translating misspelled word. So instead of
;; translation it is possible to get suggestion."
;;     (let ((info (aref json 7)))
;;       (if (and info (> (length info) 0))
;;           (aref info 1)
;;         nil)))

  ;; 2020-12-04
  (defun google-translate--search-tkk ()
    "Search TKK." (list 430675 2721866130))

  :bind(
        ("C-M-g t" . google-translate-enja-or-jaen))
  )


;; vlf
;;Automatically lanches for large file.
(use-package vlf
  :ensure t
  :config
  (require 'vlf-setup)
  )


(use-package ag
  :ensure t
  )

;; (use-package rg
;;   :ensure t
;;   )

(use-package bash-completion
  :ensure t
  :init
  (bash-completion-setup)
  )


;; ddskk
(use-package ddskk
  :ensure t
  :bind (("C-x j" . skk-mode))
  :init
  ;; (setq skk-byte-compile-init-file t
  ;;       skk-init-file "~/.emacs.d/init-ddskk")
  (setq skk-init-file "~/.emacs.d/init-ddskk")

  :custom
  (skk-user-directory "~/.ddskk")
  (default-input-method "japanese-skk")
  :config
  (require 'skk-study)
  (setq skk-study-sesearch-times 10)
  :hook (
         (emacs-startup . (lambda () (skk-mode) (skk-latin-mode-on)))
         (prog-mode . (lambda () (skk-mode) (skk-latin-mode-on)))
         )
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
     ;; (nil          . (telephone-line-projectile-buffer-segment
     ;;                  telephone-line-position-segment
     ;;                  telephone-line-filesize-segment))
     (nil          . (telephone-line-buffer-name-segment
                      telephone-line-position-segment
                      telephone-line-filesize-segment))
     ))
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
  :hook (
         (prog-mode . git-gutter-mode)
         (text-mode . git-gutter-mode)
         (conf-mode . git-gutter-mode)
         )

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

  ;; :config
  ;; (global-git-gutter-mode +1)
  ;; (custom-set-variables
  ;;  '(git-gutter:disabled-modes '(js2-mode image-mode)))
  )

;; Git Lens
(use-package blamer
  :ensure t
  :after (posframe)
  :custom
  (blamer-idle-time 0.5)
  (blamer-min-offset 70)
  (blamer-pretty-time-p t)
  ;; (blamer-author-formatter "✎ %s ")
  ;; (blamer-datetime-formatter "[%s] ")
  ;; (blamer-commit-formatter "● %s")
  ;; (blamer--overlay-popup-position 'top)
  ;; (blamer-type 'visual)
  ;; (blamer-type 'posframe-popup)
  ;; (blamer-type 'overlay-popup)
  (blamer-type 'selected)
  (blamer-face ((t :foreground "#7a88cf"
                    :background nil
                    :height 140
                    :italic t)))
  :hook (
         (prog-mode . blamer-mode)
         (text-mode . blamer-mode)
         )
  ;; :config
  ;; (global-blamer-mode 1)
  )

;; recentf
(use-package recentf
  :custom
  (recentf-max-saved-items 1000)
  (recentf-save-file "~/.emacs.d/recentf")
  (recentf-exclude '("recentf" "/TAGS$" "/var/tmp/"))
  ;; (recentf-auto-cleanup 30)
  (recentf-auto-cleanup 'never)

  (recentf-auto-save-timer
   (run-with-idle-timer 30 t 'recentf-save-list))
  :config
  (recentf-mode 1)
  )

(use-package recentf-ext
  :ensure t
  :after (recentf)
  )


(use-package restclient
  :ensure t
  :mode (
         ("\\.httpreq\\'" . restclient-mode)
         )
  ;; C-c C-c：カーソルの下でクエリを実行し、応答をきれいに出力しようとします（可能な場合）
  ;; C-c C-r：同じですが、応答には何もしません。バッファを表示するだけです。
  ;; C-c C-v：と同じですがC-c C-c、フォーカスを他のウィンドウに切り替えません
  ;; C-c C-p：前のクエリにジャンプします
  ;; C-c C-n：次のクエリにジャンプ
  ;; C-c C-.：カーソルの下にクエリをマークします
  ;; C-c C-u：curlコマンドとしてカーソルの下のクエリをコピーします
  ;; C-c C-g：変数とリクエストのソースを使用してヘルムセッションを開始します（もちろん、ヘルムが利用可能な場合）
  ;; C-c n n：現在のリクエストの領域に絞り込む（ヘッダーを含む）
  ;; TAB：現在のリクエスト本文を非表示/表示する場合のみ
  ;; C-c C-a：折りたたまれた領域をすべて表示
  ;; C-c C-i：ポイントでのresclient変数に関する情報を表示する
  )


;; Install fonts file after install package.
;; M-x all-the-icons-install-fonts
(use-package all-the-icons
  :ensure t
  )

(use-package treemacs-all-the-icons
  :ensure t
  )

(use-package all-the-icons-dired
  :ensure t
  :defer t
  :hook
  (dired-mode . all-the-icons-dired-mode)
  )


(use-package counsel
  :ensure t
  :pin melpa
  :bind (
         ("C-x C-f" . counsel-find-file)
         ("M-x" . counsel-M-x)
         ("M-y" . counsel-yank-pop)
         ("C-c b" . counsel-descbinds)
         ;; ディレクトリも再起的に検索するには、C-uを最初に打つ
         ;; the_silver_searcherかripgrepをOSにインストールしておく
         ("C-c g" . counsel-ag)
         ;; ("C-c g" . counsel-rg)
         :map counsel-find-file-map
         ("C-l" . counsel-up-directory)
         )
  :config
  (counsel-mode 1)
  )

(use-package swiper
  :ensure t
  :pin melpa
  :bind (
         ;; ("C-s" . swiper-isearch)
         ("C-s" . swiper)
         ;; ("M-s M-s". swiper-all-thing-at-point)
         ("M-s M-s". swiper-thing-at-point)
         )
  )


(use-package ivy
  :ensure t
  :pin melpa
  :custom
  ;; ファイルリスト先頭または後尾で上下移動するとそれぞれ先頭後尾に移動する
  (ivy-wrap t)
  ;; プロンプトの表示が長い時に折り返す（選択候補も折り返される）
  (ivy-truncate-lines nil)
  ;; ivy-switch-buffer のリストに recent files と bookmark を含める
  (ivy-use-virtual-buffers t)
  ;; ivy-switch-buffer のリストにパスも含めて表示(同名ファイルで別ディレクトリも分けて表示)
  (ivy-virtual-abbreviate 'full)
  ;; ミニバッファのサイズ
  (ivy-height 20)
  (ivy-count-format "(%d/%d) ")

  :bind (
         ("C-;" . ivy-switch-buffer)
         :map ivy-minibuffer-map
         ("<escape>" . minibuffer-keyboard-quit)
         )
  :config
  ;; ミニバッファでコマンド発行を認める
  (when (setq enable-recursive-minibuffers t)
    (minibuffer-depth-indicate-mode 1))

  ;; Swiperでmigemo
  (defun my:ivy-migemo-re-builder (str)
    "Own function for my:ivy-migemo."
    (let* ((sep " \\|\\^\\|\\.\\|\\*")
           (splitted (--map (s-join "" it)
                            (--partition-by (s-matches-p " \\|\\^\\|\\.\\|\\*" it)
                                            (s-split "" str t)))))
      (s-join "" (--map (cond ((s-equals? it " ") ".*?")
                              ((s-matches? sep it) it)
                              (t (migemo-get-pattern it)))
                        splitted))))
  (setq ivy-re-builders-alist '((t . ivy--regex-plus)
                                (swiper . my:ivy-migemo-re-builder)))

  (ivy-mode 1)
  )


(use-package ivy-hydra
  :ensure t
  :pin melpa
  :custom
  ;; M-o を ivy-hydra-read-action に割り当てる．
  (ivy-read-action-function #'ivy-hydra-read-action)
  )


(use-package all-the-icons-ivy
  :ensure t
  :init (add-hook 'after-init-hook 'all-the-icons-ivy-setup)
  )


(use-package smex
  :ensure t
  :custom
  (smex-history-length 30)
  (smex-completion-method 'ivy)
  )

(use-package projectile
  :ensure t
  :diminish projectile-mode

  :bind-keymap (
                ("s-p" . projectile-command-map)
                ("C-c p" . projectile-command-map)
                )

  ;; :config
  ;; (projectile-mode +1)

  :hook (
         (prog-mode . projectile-mode)
         )
  )


(use-package projectile-rails
  :ensure t
  :diminish projectile-rails-mode
  :hook (
         ;; (projectile-mode . projectile-rails-on)
         (projectile-mode . projectile-rails-mode)
         )
  :bind (
         :map projectile-rails-mode-map
              ("C-c r" . projectile-rails-command-map)
         )
  ;; :custom
  ;; (projectile-rails-vanilla-command "bin/rails")
  ;; (projectile-rails-spring-command "bin/spring")
  ;; (projectile-rails-zeus-command "bin/zeus")
  )


(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode)
  )


(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode "UndoT"
  :custom
  (undo-tree-auto-save-history nil)
  :config
  (global-undo-tree-mode t))


(use-package neotree
  :disabled t
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



;; Cc Cw r  ワークスペースの名前を変更します
;; Cc Cw a  新しいワークスペースを作成します
;; Cc Cw d  ワークスペースを削除します
;; Cc Cw s  現在のワークスペースを切り替えます
;; Cc Cp a  ワークスペースに追加する新しいプロジェクトを選択します。
;; Cc Cp p  ワークスペースに追加するprojectileプロジェクトを選択します。
;; Cc Cp d  プロジェクトのポイントをワークスペースから削除します。
;; Cc Cp r  ポイントでプロジェクトの名前を変更します。
(use-package treemacs
  ;; :disabled t
  :ensure t
  :defer t
  :after (treemacs-all-the-icons)
  :bind (
         ([f8] . treemacs)
         )
  :config                                     ; 設定
  (treemacs-load-theme "all-the-icons")
  (progn
    ;; treemacsの見た目の設定
    (setq treemacs-width 40
          treemacs-width-is-initially-locked nil
          treemacs-no-delete-other-windows t
          treemacs-is-never-other-window t
          treemacs-position 'left
          treemacs-silent-refresh t
          treemacs-silent-filewatch t
          treemacs-filewatch-mode t
          treemacs-show-cursor nil
          treemacs-show-hidden-files t
          treemacs-eldoc-display t
          treemacs-follow-mode t
          treemacs-tag-follow-mode t
          treemacs-collapse-dirs 3)

    (when (eq system-type 'windows-nt)
      (setq treemacs-python-executable (executable-find "python")))

    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    ;; シンボルのフォント設定
    (with-eval-after-load 'treemacs
      (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)
      (treemacs-follow-mode t)
      (treemacs-tag-follow-mode t)
      (treemacs-filewatch-mode t)
      (treemacs-fringe-indicator-mode t))
    ))


(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t
  )

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode)
  )



(use-package dockerfile-mode
  :ensure t
  :mode
  ("Dockerfile\\'" . dockerfile-mode))

(use-package company-php
  :ensure t
  ;; :after (company)
  )

(use-package company
  :ensure t
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
              ;; ([tab] . company-complete-selection)
              ([tab] . company-indent-or-complete-common)
              ;; ("C-<tab>" . company-complete)
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

  (company-auto-expand t)
  (company-transformers '(company-sort-by-backend-importance))
  (company-dabbrev-downcase nil)

  :config
  ;; 全バッファで有効にする
  ;; (global-company-mode +1)

  ;; yasnippetとの連携
  (defvar company-mode/enable-yas t
    "Enable yasnippet for all backends.")
  (defun company-mode/backend-with-yas (backend)
    (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
        backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))

  ;; (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
  (setq company-backends (mapcar #'company-mode/backend-with-yas
                                 '(company-bbdb
                                   ;; company-eclim
                                   company-semantic
                                   company-clang
                                   ;; company-xcode
                                   company-cmake
                                   company-files
                                   (company-dabbrev-code
                                    company-gtags
                                    company-etags
                                    company-keywords)
                                   company-oddmuse company-dabbrev company-capf company-ac-php-backend)))
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
  :custom
  ;; ファイル編集後、2秒したらチェック実施
  (flycheck-idle-change-delay 2)
  ;; :bind (
  ;;        ("C-c n" . flycheck-next-error)
  ;;        ("C-c p" . flycheck-previous-error)
  ;;        ("C-c d" . flycheck-list-errors))
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
  ;;Phpstan official docker image.
  ;; https://github.com/emacs-php/phpstan.el
  ;; docker pull phpstan/phpstan
  ;; Put the ".dir-locals.el" file on the root directory of project.

  :ensure t
  :defer t
  :after (php-mode)
  ;; :init
  ;; ;; Always use Docker for PHPStan,
  ;; (setq-default phpstan-executable 'docker)

  :config
  (flycheck-add-next-checker 'php 'phpstan)
  ;; (flycheck-select-checker 'phpstan)
  )

(use-package sass-mode
  :ensure t
  :defer t
  :mode (
         ("\\.sass\\'" . sass-mode)
         ("\\.scss\\'" . sass-mode)
         )
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
  ;; (imenu-list-auto-resize t)
  (imenu-list-size 0.2)
  (imenu-list-idle-update-delay-time 2)
  )


(use-package rainbow-mode
  :ensure t
  :defer t
  :hook (
         (css-mode . rainbow-mode)
         (scss-mode . rainbow-mode)
         (sass-mode . rainbow-mode)
         (web-mode . rainbow-mode)
         ;; (html-mode-hook .'rainbow-mode)
         )
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

  :hook (
         (prog-mode . rainbow-delimiters-mode)
         (emacs-startup . rainbow-delimiters-using-stronger-colors)
         )
  )

;; 変数ごとの色分け
(use-package color-identifiers-mode
  :ensure t
  :diminish color-identifiers-mode
  ;; :hook (
  ;;        (prog-mode . color-identifiers-mode)
  ;;        )
  :config
  (add-hook 'after-init-hook 'global-color-identifiers-mode)
  )


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

  :hook (
         (prog-mode . highlight-indent-guides-mode)
         (yaml-mode . highlight-indent-guides-mode)
         )
  )


;; Language Server Protocolクライアント
;; the_silver_searcherかripgrepもOSに入れておく
;; 使いたい言語のLanguage Serverも別途入れておく
;; # ruby -> gem install solargraph
;; solargraph socket --host=0.0.0.0 --port=XXXXXX
;; サーバー起動し、Emacs側で
;; C-u M-x eglot
;; localhost:port_numberで接続
(use-package eglot
  ;; package-list-packagesでインストールしないと失敗する
  ;; -> errorは表示されるけどインストールは完了しているかも
  :ensure t
  :disabled t
  ;; GNU版を指定しないとproject.elが入り、emacsのbuilt-inのprojectとバッティングしてしまう
  ;; :pin gnu
  ;; :pin melpa
  ;; :hook (
  ;;        (ruby-mode . eglot-ensure)
  ;;        )
  :custom
  (eglot-connect-timeout 30)
  )


;; emacs標準
(use-package ruby-mode
  :mode (
         ("\\.rb\\'" . ruby-mode)
         ("\\.Capfile\\'" . ruby-mode)
         ("\\.Gemfile\\'" . ruby-mode)
         ("\\.[Rr]akefile\\'" . ruby-mode)
         )
  ;; #!/usr/bin/env ruby といった行で始まる、拡張子のないコマンドファイルを適切なモードで開く
  :interpreter "ruby"

  :custom
  ;; マジックコメントを自動挿入しない
  ;; # -*- coding: utf-8 -*-
  (ruby-insert-encoding-magic-comment nil)
  ;; ruby-modeのインデント
  (ruby-indent-level 2)
  (ruby-indent-tabs-mode nil)

  ;;括弧内の深いインデントの制御
  (ruby-deep-indent-paren-style nil)
  ;; (ruby-deep-arglist nil)

  ;; 連結されたメソッド呼び出しを揃える
  (ruby-align-chained-calls t)

  ;; flycheck
  (flycheck-check-syntax-automatically '(idle-change mode-enabled new-line save))

  :bind (
         :map ruby-mode-map
              ([return] . reindent-then-newline-and-indent)
              )

  :hook (
         (ruby-mode . (lambda ()
                        (when (>= emacs-major-version 24)
                          (set (make-local-variable 'electric-pair-mode) nil)
                          (set (make-local-variable 'electric-indent-mode) nil)
                          (set (make-local-variable 'electric-layout-mode) nil))

                        (flycheck-mode t)
                        )
                    )
         )
  )


(use-package ruby-electric
  :ensure t
  :after (ruby-mode)
  :diminish ruby-electric-mode

  :hook
  (ruby-mode . (lambda ()
                 (ruby-electric-mode t)))
  ;; if に対するendとか入れてくれる
  ;; emacs24標準のelectricとバッティングするので、ruby-mode時は
  ;; electric系はオフにする
  ;; (let ((rel (assq 'ruby-electric-mode minor-mode-map-alist)))
  ;;   (setq minor-mode-map-alist (append (delete rel minor-mode-map-alist) (list rel))))
  ;; (setq ruby-electric-expand-delimiters-list nil)
  )


(use-package ruby-block
  ;; :ensure t
  :load-path "~/.emacs.d/site-lisp/"
  :after (ruby-mode)
  :diminish ruby-block-mode
  :hook
  (ruby-mode . ruby-block-mode)

  :custom
  ;; ミニバッファに表示し, かつ, オーバレイする.
  (ruby-block-highlight-toggle t)
  ;; 何もしない
  ;;(ruby-block-highlight-toggle 'noghing)
  ;; ミニバッファに表示
  ;;(ruby-block-highlight-toggle 'minibuffer)
  ;; オーバレイする
  ;;(ruby-block-highlight-toggle 'overlay)
  )

(use-package inf-ruby
  :ensure t
  :custom
  (inf-ruby-default-implementation "pry")
  (inf-ruby-eval-binding "Pry.toplevel_binding")
  )


(use-package php-cs-fixer
  :ensure t
  )

(use-package php-mode
  :ensure t
  ;; :pin melpa-stable
  :defer t
  :mode (
         ("\\.php$" . php-mode)
         ("\\.inc$" . php-mode)
         ("\\.ctp$" . php-mode)
         )
  :custom
  (php-manual-url 'ja)
  (php-mode-coding-style 'psr2)
  (php-search-documentation-browser-function 'eww-browse-url)
  (php-style-delete-trailing-whitespace 1)
  :bind (
         )
  :hook (
         (php-mode . electric-pair-mode)
         ;; M-fなどの単語単位の移動をキャメルケース単位にする
         (php-mode . subword-mode)
         ;; (php-mode . my-php-flycheck-setup)
         )
  :config
  ;; (add-to-list 'company-backends 'company-php)
  ;; 保存時に実行
  ;; php-cs-fixerが古くて.php-cs-fixer.dist.phpを認識しないかも
  ;; (add-hook 'before-save-hook 'php-cs-fixer-before-save)
  )


(use-package yaml-mode
  :ensure t
  :defer t
  :mode
  ("\\.yml$" . yaml-mode))


(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (
         ("\\.md\\'" . gfm-mode)
         ("\\.mkd\\'" . gfm-mode)
         ("\\.mdwn\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode)
         )
  ;; デフォルトでtabは見出しの折り畳みのトグル
  ;; (bind-keys :map markdown-mode-map
  ;;            ("<Tab>" . markdown-cycle)
  ;;            ("<S-tab>" . markdown-shifttab)
  ;;            ("C-M-n" . outline-next-visible-heading)
  ;;            ("C-M-p" . outline-previous-visible-heading))

  :custom
  ;; (markdown-enable-math t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-command "marked")
  (markdown-enable-math t)
  (markdown-xhtml-body-preamble "<div class=\"markdown-body\">")
  (markdown-xhtml-body-epilogue "</div>")
  (markdown-content-type "application/xhtml+xml")
  ;; (markdown-content-type "application/html")
  (markdown-css-paths '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
                        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css"))

  :config
  (setq
   markdown-xhtml-header-content "
<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
<style>
.markdown-body {
  box-sizing: border-box;
  max-width: 1024px;
  width: 100%;
  margin: 40px auto;
  padding: 0 10px;
}
/*印刷時の改行コード*/
body>h1:not(:first-of-type) {
  page-break-before: always;
}
h2 {
  page-break-before: always;
}
hr {
  page-break-before: always;
}
/*hrの直後にh1, h2があった場合は改行コードを付けない*/
hr+h1 {
  page-break-before: avoid;
}
hr+h2 {
  page-break-before: avoid;
}
.markdown-body pre > code { white-space: pre-wrap; }
.markdown-body table { display:table; break-inside: auto; word-break: break-word; }
.markdown-body tr { break-inside: avoid; break-after: auto; }
/*印刷時のスタイル*/
@media print {
  @page {
    size: A4 landscape;
    margin-top: 0;
    margin-bottom: 6mm;
  }
  h1 {
    padding-top: 50mm;
  }
  h2 {
    padding-top: 10mm;
  }
}
</style>
<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js'></script>
<script>
hljs.highlightAll();
</script>
<script>
MathJax = {
  chtml: {
    matchFontHeight: false
  },
  tex: {
    inlineMath: [
      ['$','$'],
      // ['\\(', '\\)']
    ],
    displayMath: [
      ['$$', '$$'],
      // ['\\[', '\\]']
    ],
    processEscapes: true,      // use \$ to produce a literal dollar sign
  }
};
</script>
<script type='text/javascript' id='MathJax-script' async src='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js'></script>
"
   ))


(use-package markdown-preview-mode
  :ensure t
  :config
  (setq markdown-preview-http-port 19000)
  (setq markdown-preview-stylesheets (list "https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
                                           "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css"))
  ;; (setq markdown-preview-stylesheets (list "https://raw.githubusercontent.com/richleland/pygments-css/master/emacs.css"))
  (setq markdown-preview-javascript (list "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js"
                                          "
<script>
document.addEventListener('DOMContentLoaded', () => {
  hljs.highlightAll();
});
</script>
"
                                          "
<script>
MathJax = {
  tex: {
    inlineMath: [
      ['$','$'],
      // ['\(', '\)']
    ],
    displayMath: [
      ['$$', '$$'],
      // ['\[', '\]']
    ],
  }
};

setInterval(() => {
  document.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });

  MathJax.typesetClear();
  MathJax.startup.document.state(0);
  MathJax.texReset();
  MathJax.typeset();
}, 2000);
</script>
"
                                          "
<script type='text/javascript' id='MathJax-script' async src='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js'></script>
"
                                          ))
  )

(use-package markdown-toc
  :ensure t)

(use-package adoc-mode
  :ensure t
  :defer t
  :mode (
         ("\\.adoc$" . adoc-mode)
         ("\\.asciidoc$" . adoc-mode))
  )

;; mermaid-cliが必要
;; npm i -g mermaid.cli
(use-package mermaid-mode
  :ensure t
  :mode (
         ("\\.mmd\\'" . mermaid-mode)
         )
  :bind (
         :map mermaid-mode-map
              ("C-c C-c" . nil)
              ("C-c C-f" . nil)
              ("C-c C-b" . nil)
              ("C-c C-r" . nil)
              ("C-c C-o" . nil)
              ("C-c C-d" . nil)
              ("C-c C-d c" . mermaid-compile)
              ("C-c C-d f" . mermaid-compile-file)
              ("C-c C-d b" . mermaid-compile-buffer)
              ("C-c C-d r" . mermaid-compile-region)
              ("C-c C-d o" . mermaid-open-browser)
              ("C-c C-d d" . mermaid-open-doc)
              )
  )

(use-package web-mode
  :ensure t
  :defer t
  :mode (
         ("\\.html\\'" . web-mode)
         ("\\.xhtml\\'" . web-mode)
         ("\\.shtml\\'" . web-mode)
         ("\\.tpl\\'" . web-mode)
         ("\\.tmpl\\'" . web-mode)
         ("\\.ctp\\'" . web-mode)
         ("\\.ejs\\'" . web-mode)
         ("\\.[agj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.tag\\'" . web-mode)
         ("\\.tag\\.js\\'" . web-mode)
         ("\\.vue\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.blade\\.php\\'" . web-mode)
         )
  :custom
  ;; web-modeの設定
  (web-mode-attr-indent-offset nil)
  (web-mode-markup-indent-offset 4) ;; html indent
  (web-mode-css-indent-offset 4)    ;; css indent
  (web-mode-code-indent-offset 4)   ;; script indent(js,php,etc..)
  (web-mode-comment-style 2)
  (web-mode-enable-current-element-highlight t)
  (indent-tabs-mode nil)

  ;; タグを自動で閉じる
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-auto-closing t)
  (web-mode-auto-close-style 2)
  (web-mode-tag-auto-close-style 2)

  ;; 拡張子がjs,jsxのファイルはJavaScriptとして解釈させる
  ;; (web-mode-content-types-alist
  ;;  '(
  ;;    ("jsx" . "\\.js[x]?\\'")
  ;;    ;; ("js2" . "\\.js[x]?\\'")
  ;;    ))

  :bind (
         :map web-mode-map
              ("C-;" . nil)
              ("C-c C-;" . web-mode-comment-or-uncomment)
              )
  ;; :config
  ;; (defun my-web-mode-hook ()
  ;;   "Hooks for Web mode."
  ;;   ;; 変更日時の自動修正
  ;;   (setq time-stamp-line-limit -200)
  ;;   (if (not (memq 'time-stamp write-file-hooks))
  ;;   (setq write-file-hooks
  ;;         (cons 'time-stamp write-file-hooks)))
  ;;   (setq time-stamp-format " %3a %3b %02d %02H:%02M:%02S %:y %Z")
  ;;   (setq time-stamp-start "Last modified:")
  ;;   (setq time-stamp-end "$")
  ;;   )
  ;; (add-hook 'web-mode-hook  'my-web-mode-hook)
  )


(use-package auto-complete
  :ensure t
  :defer t
  :config
  ;; (ac-config-default)
  (ac-linum-workaround)
  )


(use-package js2-mode
  :ensure t
  :defer t
  :mode (
         ("\\.js\\'" . js2-mode)
         )
  :hook (
         (js2-mode . electric-pair-mode)
         )
  :bind (
         :map js2-mode-map
              ("M-." . nil)
              ("M-," . nil)
              )
  :custom
  ;; 関数の引数が複数個ある場合に、改行したら前の引数の位置にインデントを揃える
  (js-indent-align-list-continuation t)
  ;; (js-indent-align-list-continuation nil)
  (js2r-prefered-quote-type 2)

  :config
  ;; JavaScriptで#付きのメソッドやフィールドがprivateになる対応
  ;; ECMAScrpt2020
  ;; patch in basic private field support
  (advice-add #'js2-identifier-start-p
              :after-until
              (lambda (c) (eq c ?#)))
  (add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))
  ;; js2-modeではバックアップファイルを作らない
  ;; lspがimportのパスをバックアップファイルのパスで書き換えるのを防ぐ
  (add-hook 'js2-mode-hook (lambda () (setq backup-inhibited t)))

  ;; mmm-modeも起動
  ;; (add-hook 'js2-mode-hook
  ;;         (lambda ()
  ;;           (interactive)
  ;;           (mmm-mode)
  ;;           ))
  )

(use-package rjsx-mode
  :ensure t
  :mode (
         ("\\.jsx\\'" . rjsx-mode)
         ("components\\/.*\\.js\\'" . rjsx-mode)
         )
  :hook (
         (rjsx-mode . electric-pair-mode)
         )
  :bind (
         :map rjsx-mode-map
              ("M-." . nil)
              ("M-," . nil)
              )
  :custom
  ;; 関数の引数が複数個ある場合に、改行したら前の引数の位置にインデントを揃える
  (js-indent-align-list-continuation t)
  ;; (js-indent-align-list-continuation nil)
  (js2r-prefered-quote-type 2)

  :config
  (add-hook 'rjsx-mode-hook (lambda () (setq js2-basic-offset 2)))
  ;; rjsx-modeではバックアップファイルを作らない
  (add-hook 'rjsx-mode-hook (lambda () (setq backup-inhibited t)))
  )


;; nodeのnpmでjsonlintをグローバルにインストールしておく
(use-package json-mode
  :ensure t
  :mode (
         ("\\.json\\'" . json-mode)
         )
  )


(use-package typescript-mode
  :ensure t
  :mode (
         ("\\.ts\\'" . typescript-mode)
         )
  :hook (
         (typescript-mode . (lambda ()
                              (interactive)
                              (mmm-mode)))
         )
  )

;; Prettierの自動フォーマッター
;; npm i -g prettier
(use-package prettier-js
  :ensure t
  :hook ((js2-mode . prettier-js-mode)
         ;; (rjsx-mode . prettier-js-mode)
         )
  )


(use-package python-mode
  :ensure t
  :mode (
         ("\\.py\\'" . python-mode)
         )
  :custom
  (python-indent 4)
  (tab-width 4)
  (indent-tabs-mode nil)

  :hook (
         (python-mode . electric-pair-mode)
         ;; (python-mode . flymake-python-pyflakes-load)
         )
  )


(use-package mmm-mode
  :ensure t
  :commands mmm-mode
  :mode (
         ("\\.ts\\'" . typescript-mode)
         ("\\.tsx\\'" . typescript-mode)
         ;; ("\\.js\\'" . js2-mode)
         )

  :custom
  (mmm-global-mode t)
  (mmm-submode-decoration-level 1)

  :config
  (mmm-add-classes
   ;; '((mmm-jsx-mode
   ;;    :submode web-mode
   ;;    :face mmm-code-submode-face
   ;;    :front "\\((\\)[[:space:]\n]*<"
   ;;    :front-match 1
   ;;    :front-offset 1
   ;;    :back ">[[:space:]\n]*\\()\\)"
   ;;    :back-match 1
   ;;    :back-offset 1
   ;;    ))
   '((mmm-jsx-mode
      :submode web-mode
      :face mmm-code-submode-face
      ;; :front "\\(return\s\\|n\s\\|[^n]\\)<[a-zA-Z]+[^>]*>.*?\\(</[a-zA-Z]+>\\|$\\)"
      :front "\\((\\)[[:space:]\n]*<"
      :front-offset -2
      ;; :back "<\/[a-zA-Z]+>"
      :back ">[[:space:]\n]*\\()\\)"
      :back-offset -2
      :end-not-begin t
      ))
   )

  (mmm-add-mode-ext-class 'typescript-mode nil 'mmm-jsx-mode)
  ;; (mmm-add-mode-ext-class 'js2-mode "\\.jsx\\'" 'jsx)
  ;; (mmm-add-mode-ext-class 'js2-mode nil 'mmm-jsx-mode)

  (defun mmm-reapply ()
    (mmm-mode)
    (mmm-mode))

  (add-hook 'after-save-hook
            (lambda ()
              (when (string-match-p "\\.tsx?" buffer-file-name)
                (mmm-reapply)
                )))
  )


;; JavaScriptの関数定義ジャンプ
(use-package xref-js2
  :ensure t
  :after (js2-mode)
  :custom
  (xref-js2-search-program 'ag)
  :config
  (add-hook 'js2-mode-hook
            (lambda ()
              (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))
  )


;; https://emacs-lsp.github.io/lsp-mode/page/installation/
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook(
        ;; npm i -g typescript-language-server; npm i -g typescript
        (js-mode . lsp-deferred)
        (js2-mode . lsp-deferred)
        (rjsx-mode . lsp-deferred)
        (typescript-mode . lsp-deferred)
        ;; npm i -g pyright
        (python-mode . lsp-deferred)
        ;; composer global require jetbrains/phpstorm-stubs:dev-master
        ;; composer global require felixfbecker/language-server
        ;; または各プロジェクト毎にcomposer.jsonを用意してcomposer install
        ;; npmで提供されているlsp npm i -g intelephense
        ;; intelephenseの方が安定している感じ
        (php-mode . lsp-deferred)
        ;; npm i -g bash-language-server
        (sh-mode . lsp-deferred)
        ;; gem install solargraph
        (ruby-mode . lsp-deferred)
        )
  :custom
  (lsp-auto-configure t)
  (lsp-enable-completion-at-point t)
  (lsp-enable-xref t)
  (lsp-diagnostics-provider :flycheck)
  ;; (lsp-eldoc-enable-hover t)
  ;; (lsp-eldoc-render-all nil)

  (lsp-headerline-breadcrumb-enable t)
  (lsp-headerline-breadcrumb-segments '(project file symbols))

  ;; dockerのvolumeで共有されたファイルを扱う場合にLSPサーバーがファイルを検知して起動しなくなるのを防ぐ
  ;; (lsp-enable-file-watchers nil)
  ;; (lsp-file-watch-threshold nil)

  :config
  ;; watch 対象から外すリスト
  (dolist (dir '(
                 "[/\\\\]\\.venv$"
                 "[/\\\\]\\.mypy_cache$"
                 "[/\\\\]__pycache__$"
                 "[/\\\\]\\.node_modules$"
                 ))
    (push dir lsp-file-watch-ignored))
  )

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  )

;; MS製のlanguage server
;; npm i -g pyright
(use-package lsp-pyright
  :ensure t
  :after python-mode
  :init
  (defun lsp-pyright/python-mode-hook
    ()
    (require 'lsp-pyright)
    (when (fboundp 'flycheck-mode)
      ;; LSPで構文チェック
      ;; python3.5から導入されたmypyをオフ
      (setq flycheck-disabled-checkers '(python-mypy))
      ;; flake8を使う
      ;; (custom-set-variables
      ;;  '(flycheck-python-flake8-executable "python3")
      ;;  '(flycheck-python-pycompile-executable "python3")
      ;;  '(flycheck-python-pylint-executable "python3"))
      ;; (defvaralias 'flycheck-python-flake8-executable 'python-shell-interpreter)
      ;; (setq flycheck-python-flake8-executable "flake8")
      )
    )

  :hook (
         (python-mode . lsp-pyright/python-mode-hook)
         )
  )


;; .venvに入れたライブラリを含めた補完
;; pip install virtualenvwrapper
(use-package virtualenvwrapper
  :ensure t
  )

(use-package auto-virtualenvwrapper
  :ensure t
  :hook (
         ;; 自動で.venvのライブラリを使用
         (python-mode . auto-virtualenvwrapper-activate)
         )
  )


(use-package org
  :mode (
         ("\\.org$" . org-mode)
         )
  :bind (
         ("C-c cc" . org-capture)
         ("C-c cl" . org-store-link)
         ("C-c ca" . org-agenda)
         ("C-c cb" . org-iswitchb)
         )
  :custom
  ;; org-modeのタスク状態の遷移
  (org-todo-keywords '((sequence "TODO" "SOMEDAY" "WAITING" "|" "DONE" "CANCELED")))
  ;; タスク状態をDONEにした場合に時刻を挿入
  (org-log-done 'time)
  ;; メモファイルの場所
  (org-directory "~/Org")
  (org-default-notes-file "notes.org")
  ;; TODOリストで、子リストをDONEにしないと親をDONEにできない
  (org-enforce-todo-dependencies t)
  (org-agenda-files '("~/Org/gtd.org"
                      ;; "~/Org/project.org"
                      ))
  ;; Org-captureのテンプレートの設定
  ;; TODOはC-c C-dで締切入力、C-c C-sで作業予定日入力
  (org-capture-templates
   '(("t" "Todo" entry (file+headline "~/Org/gtd.org" "INBOX")
      "* TODO %?\n %i\n %a")
     ("n" "Note" entry (file+headline "~/Org/notes.org" "Notes")
      "* %U %?\n%i\n %a")
     ))

  ;; 長い文章を折り返す
  ;; (org-startup-truncated nil)

  (org-latex-default-class "myltjsarticle")
  (org-latex-prefer-user-labels t)

  (org-latex-compilers '("pdflatex" "xelatex" "lualatex" "uplatex"))

  ;; 勝手に入力される \hypersetup{} は使わない(usepackage の順序依存に配慮)
  (org-latex-with-hyperref nil)

  (org-latex-pdf-process
   '("platex -shell-escape %f"
     "platex -shell-escape %f"
     "pbibtex %b"
     "platex -shell-escape %f"
     "platex -shell-escape %f"
     "dvipdfmx %b.dvi"))

  (org-latex-title-command "\\maketitle")
  (org-latex-toc-command
   "\\tableofcontents \\clearpage")

  (org-latex-text-markup-alist '((bold . "\\textbf{%s}")
                                 (code . verb)
                                 (italic . "\\textit{%s}")
                                 (strike-through . "\\sout{%s}")
                                 (underline . "\\uline{%s}")
                                 (verbatim . protectedtexttt)))

  (org-export-latex-listings t)

  (org-latex-listings 'minted)
  (org-latex-minted-options
   '(("frame" "lines")
     ("framesep=2mm")
     ("linenos=true")
     ("baselinestretch=1.2")
     ("fontsize=\\footnotesize")
     ("breaklines")
     ("bgcolor=srcbg")
     ))

  :config
  ;; captureで書いたメモを見る設定
  (defun show-org-buffer (file)
    "Show an org-file FILE on the current buffer."
    (interactive)
    (if (get-buffer file)
        (let ((buffer (get-buffer file)))
          (switch-to-buffer buffer)
          (message "%s" file))
      (find-file (concat "~/Org/" file))))
  (global-set-key (kbd "C-M-^") #'(lambda () (interactive)
                                   (show-org-buffer "notes.org")))

  (add-to-list 'org-latex-packages-alist "\\hypersetup{setpagesize=false}" t)
  (add-to-list 'org-latex-packages-alist "\\hypersetup{colorlinks=true}" t)
  (add-to-list 'org-latex-packages-alist "\\hypersetup{linkcolor=blue}" t)
  ;; (add-to-list 'org-latex-packages-alist "\\hypersetup{pdfencoding=auto}" t)

  (require 'ox-latex)

  ;; インデントすると *.tex にそのまま入ってしまう
  ;; org-modeがデフォルトで挿入するpackageを抑制する[NO-DEFAULT-PACKAGES]
  (with-eval-after-load 'ox-latex
    (add-to-list 'org-latex-classes
                 '("myjsarticle"
                   "\\documentclass[uplatex,dvipdfmx,12pt]{jsarticle}
[NO-DEFAULT-PACKAGES]
\\usepackage{amsfonts}
\\usepackage{amsmath}
% \\usepackage{newtxtext,newtxmath}
\\usepackage[normalem]{ulem}
\\usepackage{textcomp}
\\usepackage{minted}
\\usemintedstyle{emacs}
\\usepackage[dvipdfmx]{graphicx}
\\usepackage[dvipdfmx]{color}
\\usepackage{booktabs}
\\usepackage{longtable}
\\usepackage{wrapfig}
\\usepackage[dvipdfmx]{hyperref}
\\usepackage{pxjahyper}
\\definecolor{srcbg}{rgb}{0.95,0.95,0.95}
% \\hypersetup{pdfencoding=auto}"
  ("\\section{%s}" . "\\section*{%s}")
  ("\\subsection{%s}" . "\\subsection*{%s}")
  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
  ("\\paragraph{%s}" . "\\paragraph*{%s}")
  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

    (add-to-list 'org-latex-classes
                 '("myltjsarticle"
                   "\\documentclass[titlepage,12pt,a4paper]{ltjsarticle}
[NO-DEFAULT-PACKAGES]
\\usepackage{ascmac}
\\usepackage{amsfonts}
\\usepackage{amssymb}
\\usepackage{amsmath}
\\usepackage[normalem]{ulem}
\\usepackage{textcomp}
\\usepackage{longtable}
\\usepackage{wrapfig}
\\usepackage{minted}
\\usemintedstyle{emacs}
\\usepackage{enumerate}
\\usepackage{boites,boites_exemples,graphicx}
\\usepackage{comment}
\\usepackage{cancel}
\\usepackage{xurl}
\\usepackage{xcolor}
\\usepackage{bookmark}
\\definecolor{srcbg}{rgb}{0.95,0.95,0.95}
\\hypersetup{unicode,bookmarksnumbered=true,hidelinks,final}"
  ("\\section{%s}" . "\\section*{%s}")
  ("\\subsection{%s}" . "\\subsection*{%s}")
  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
  ("\\paragraph{%s}" . "\\paragraph*{%s}")
  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
    )



  ;; org-modeでMarkdownのexportを有効にする
  (require 'ox-md nil t)
  )

(use-package org-bullets
  :ensure t
  :hook (
         (org-mode . org-bullets-mode)
         )
  )

(use-package geben
  :disabled t
  ;; :pin melpa
  ;; package-list-packagesでインストールしないと失敗する
  ;; :ensure t
  ;; M-x geben
  ;; portとか変えたい場合は
  ;; C-u M-x geben
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
 '(mouse-wheel-scroll-amount '(5 ((shift) . 1)))
 '(org-latex-hyperref-template nil nil nil "Customized with use-package org")
 '(org-latex-src-block-backend 'minted nil nil "Customized with use-package org")
 '(package-selected-packages '(use-package))
 '(python-indent-offset 4 nil nil "Customized with use-package python-mode")
 '(scroll-step 1)
 '(tron-legacy-theme-dark-fg-bright-comments t)
 '(uniquify-buffer-name-style 'post-forward-angle-brackets nil (uniquify))
 '(uniquify-min-dir-content 2)
 '(whitespace-display-mappings '((newline-mark 10 [8595 10] [36 10])))
 '(whitespace-style '(face tabs newline newline-mark)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(git-gutter:added ((t (:foreground "DarkCyan" :background "gray2"))))
 '(git-gutter:deleted ((t (:foreground "DeepPink" :background "gray2"))))
 '(git-gutter:modified ((t (:foreground "DarkGoldenrod" :background "gray2"))))
 '(highlight-indent-guides-character-face ((t (:foreground "DarkSlateBlue")))))
