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
(add-to-list 'default-frame-alist '(font . "HackGen Console NF-16"))


;; Macでは¥とバックスラッシュが違う文字列として扱われるため制御する
;; ¥の代わりにバックスラッシュを入力する
;; (define-key global-map [?¥] [?\\])
;; mini bufferでも
;; (define-key key-translation-map (kbd "¥") (kbd "\\"))
;; C-x C-e 文字コードチェック
;; UTF8で¥は165, \は92
(define-key key-translation-map [165] [92])


;; Emacs29になるまではsvgのエラー回避のためこの関数、設定を有効にしておく
;; (defun image-type-available-p (type)
;;   "Return t if image type TYPE is available.
;; Image types are symbols like `xbm' or `jpeg'."
;;   (if (eq 'svg type)
;;       nil
;;     (and (fboundp 'init-image-library)
;;          (init-image-library type))))
(add-to-list 'image-types 'svg)


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


;; plantuml
;; Need plantuml.jar and graphviz.
;; C-c C-c preview
;; C-mouse scroll change image size
(use-package plantuml-mode
  :ensure t
  :mode (
         ("\\.pu\\'" . plantuml-mode)
         ("\\.plantuml\\'" . plantuml-mode)
         )
  :hook(
        (plantuml-mode . (lambda ()
                           (setq plantuml-executable-args
                                 (append plantuml-executable-args '("-charset" "UTF-8"))
                                 )
                           )
                       )
        )

  :custom
  (plantuml-executable-path "/usr/local/bin/plantuml")
  ;; (plantuml-jar-path "~/plantuml/plantuml.jar")
  (plantuml-java-options "")
  (plantuml-options "-charset UTF-8")
  (plantuml-default-exec-mode 'executable)
  ;; (plantuml-default-exec-mode 'jar)

  :config
  (defun plantuml-preview-frame (prefix)
    (interactive "p")
    (plantuml-preview 16))
  ;; (setq plantuml-output-type "svg")
  (setq plantuml-output-type "png")

  )

;;; init-macos.el ends here
