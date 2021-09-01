;;; init-windows.el --- init-windows.el
;;; Commentary:
;; Settings for windows.
;;; Code:

;キーボードから入力される文字コード
(set-keyboard-coding-system 'sjis)

;ターミナルの文字コード
(set-terminal-coding-system 'utf-8)

;ファイル名の文字コード
(setq default-file-name-coding-system 'japanese-cp932-dos)

;クリップボードの文字コード
;; MS Windows clipboard
(set-clipboard-coding-system 'utf-16le-dos)

;; MS-Windows shell-mode
(add-hook
 'shell-mode-hook
 '(lambda ()
   (set-buffer-process-coding-system 'sjis 'sjis)))

;; Cygwin入ってる場合に設定しておくとfind grep使える
;; (setq find-dired-find-program "c:\\cygwin\\bin\\find.exe")
;; (setq find-program "c:\\cygwin\\bin\\find.exe")
;; (setenv "PATH" (format "c:\\cygwin\\bin;%s" (getenv "PATH")))

;; (setq find-dired-find-program "c:\\MinGW\\msys\\1.0\\bin\\find.exe")
;; (setq find-program "c:\\MinGW\\msys\\1.0\\bin\\find.exe")
;; (setenv "PATH" (format "c:\\MinGW\\msys\\1.0\\bin;%s" (getenv "PATH")))

;(setq exec-path (append exec-path '(getenv "PATH")))
;(setq exec-path (append exec-path '(format "c:/cygwin/bin;%s" (getenv "PATH"))))

;; シフト + 矢印で範囲選択
(setq pc-select-selection-keys-only t)
(when (<= emacs-major-version 23)
  (pc-selection-mode 1)
)

(when (eq window-system 'w32)
  ;; 透明度の設定(active . inactive)
  (add-to-list 'default-frame-alist '(alpha . (90 . 80)))
  ;; ツールバーの非表示
  (tool-bar-mode 0))

;; フォント
(add-to-list 'default-frame-alist '(font . "HackGenNerd-11"))


; 機種依存文字
;; (require 'cp5022x)
; charset と coding-system の優先度設定
(set-charset-priority 'ascii
                      'japanese-jisx0208
                      'latin-jisx0201
                      'katakana-jisx0201
                      'iso-8859-1
                      'cp1252
                      'unicode)
(set-coding-system-priority 'utf-8
                            'euc-jp
                            'iso-2022-jp
                            'cp932)
;; ctags.elの設定
;; (setq ctags-update-command (expand-file-name  "c:/ctags/ctags.exe"))


;; migmo
(use-package migemo
  :ensure t
  :if (executable-find "cmigemo")
  :config
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-dictionary "c:/cmigemo/dict/cp932/migemo-dict")
  ;; (setq migemo-dictionary "c:/cmigemo/dict/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'cp932-unix)
  (load-library "migemo")
  (migemo-init))


;; Windowsの場合はtrampでplinkコマンドを使用する
;; Puttyをインストールしてplinkにパスを通しておく
;; NG C-x C-f /ssh:username@hostname#port:/path/to/file
;; OK C-x C-f /plink:username@hostname#port:/path/to/file
;; OK C-x C-f /plink:username@hostname#port|sudo:hostname:/path/to/file
;; pageantで保存してあるセッション名を使う場合は、C-x C-f /plinkx:
(setq-default tramp-default-method "plink")

;;; init-windows.el ends here
