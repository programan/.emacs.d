;;; init-macos.el --- init-macos.el
;;; Commentary:
;; Settings for macOS.
;;; Code:

;; キーボードから入力される文字コード
;; (set-keyboard-coding-system 'sjis-mac)
(set-keyboard-coding-system 'utf-8-mac)

;; ターミナルの文字コード
(set-terminal-coding-system 'utf-8)

;; クリップボードの文字コード
(set-clipboard-coding-system 'utf-8)

;; ファイル名の文字コード
(set-file-name-coding-system 'utf-8)


;; 左のオプションキーをメタキーにする
(setq mac-option-modifier 'meta)

;; シフト + 矢印で範囲選択
(setq pc-select-selection-keys-only t)

(when (memq window-system '(mac ns))
  ;; ドラッグされたファイルは新規バッファで開く
  (define-key global-map [ns-drag-file] 'ns-find-file)
  (setq ns-pop-up-frames nil)
  ;; 透明度の設定(active . inactive)
  (add-to-list 'default-frame-alist '(alpha . (90 . 80)))
  ;; ツールバーの非表示
  (tool-bar-mode 0))


;; フォント設定
(add-to-list 'default-frame-alist '(font . "HackGenNerd-16"))


;; Macでは¥とバックスラッシュが違う文字列として扱われるため制御する
;; ¥の代わりにバックスラッシュを入力する
;; (define-key global-map [?¥] [?\\])
;; mini bufferでも
;; (define-key key-translation-map (kbd "¥") (kbd "\\"))
;; C-x C-e 文字コードチェック
;; UTF8で¥は165, \は92
(define-key key-translation-map [165] [92])


(use-package exec-path-from-shell
  :ensure t
  :config
  ;; 環境変数を見えるようにする
  (exec-path-from-shell-initialize)
  )

;; magit
;; (global-set-key (kbd "C-x g") 'magit-status)



;; migmo
(use-package migemo
  :ensure t
  :if (executable-find "cmigemo")
  :config
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (load-library "migemo")
  (migemo-init))


;;; init-macos.el ends here
