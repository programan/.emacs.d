;;; init-xwindow.el --- init-xwindow.el
;;; Commentary:
;; Settings for xwindow.
;;; Code:

;キーボードから入力される文字コード
(set-keyboard-coding-system 'utf-8)

;ターミナルの文字コード
(set-terminal-coding-system 'utf-8)

;; ファイル名の文字コード
(set-file-name-coding-system 'utf-8)

;クリップボードの文字コード
(set-clipboard-coding-system 'utf-8)

(when (eq window-system 'x)
  ;; コピーした内容を PRIMARY,CLIPBOARD セクションにもコピーする
  (setq select-enable-clipboard t)
  ;; C-yでクリップボードの内容をペースト(ヤンク)する
  (global-set-key "\C-y" 'x-clipboard-yank)
  ;; 透明度の設定(active . inactive)
  (add-to-list 'default-frame-alist '(alpha . (85 . 80)))
  ;; ツールバーの非表示
  (tool-bar-mode 0))

;; シフト + 矢印で範囲選択
(setq pc-select-selection-keys-only t)

;; フォントの指定
(add-to-list 'default-frame-alist '(font . "HackGenNerd-11"))

(use-package exec-path-from-shell
  :ensure t
  :config
  ;; 環境変数を見えるようにする
  (exec-path-from-shell-initialize)
  )

;; migmo
(use-package migemo
  :ensure t
  :if (executable-find "cmigemo")
  :config
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (load-library "migemo")
  (migemo-init))

;;; init-xwindow.el ends here
