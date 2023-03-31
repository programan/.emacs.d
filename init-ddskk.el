;;; init-ddskk.el --- init-ddskk.el
;;; Commentary:
;; Settings for skk.
;;; Code:


(setq skk-tut-file "~/.emacs.d/share/skk/SKK.tut")
(setq skk-large-jisyo "~/.emacs.d/share/skk/SKK-JISYO.L")
(setq SKK_SET_JISYO t)

;; skk用のstickyキー設定
;; ;キーで変換モード
;; 「有る」が
;;   "; a ; r u"で変換可能
;; (setq skk-sticky-key ";")

;; インライン候補縦表示
;; (setq skk-show-inline 'vertical)
(setq skk-show-candidates-always-pop-to-buffer t)

;; 候補表示件数を2列
(setq skk-henkan-number-to-display-candidates 5)

;; 日本語表示しない
(setq skk-japanese-message-and-error nil)

(setq skk-show-japanese-menu nil)

;;モードで RET を入力したときに確定のみ行い、改行はしない
(setq skk-egg-like-newline t)  

;; lisp-interaction-mode
(add-hook 'lisp-interaction-mode-hook
          #'(lambda()
             (eval-expression (skk-mode) nil)
             ))

;; find-file(C-xC-f)
;; バッファを開くとskk-mode
(add-hook 'find-file-hooks
          #'(lambda()
             (eval-expression (skk-mode) nil)
             (skk-latin-mode-on)
             ))

;(add-hook 'isearch-mode-hook
;          #'(lambda ()
;             (when (and (boundp 'skk-mode)
;                        skk-mode
;                        skk-isearch-mode-enable)
;               (skk-isearch-mode-setup))))

;(add-hook 'isearch-mode-end-hook
;          #'(lambda ()
;             (when (and (featurep 'skk-isearch)
;                        skk-isearch-mode-enable)
;               (skk-isearch-mode-cleanup))))

;; melpaからskkをインストールした場合、skk-setup.elが含まれていない様子
;; skk-setup.elからコピペ

;;; Isearch setting.
(defun skk-isearch-setup-maybe ()
  (require 'skk-vars)
  (when (or (eq skk-isearch-mode-enable 'always)
            (and (boundp 'skk-mode)
                 skk-mode
                 skk-isearch-mode-enable))
    (skk-isearch-mode-setup)))

(defun skk-isearch-cleanup-maybe ()
  (require 'skk-vars)
  (when (and (featurep 'skk-isearch)
             skk-isearch-mode-enable)
    (skk-isearch-mode-cleanup)))

(add-hook 'isearch-mode-hook #'skk-isearch-setup-maybe)
(add-hook 'isearch-mode-end-hook #'skk-isearch-cleanup-maybe)


;; ミニバッファ上でも skk-mode にする
;; skk-latin-mode でアルファベット入力にしておく
(add-hook 'minibuffer-setup-hook
          #'(lambda()
             (progn
               (eval-expression (skk-mode) nil)
               (skk-latin-mode (point))
               ;; ミニバッファ上に「nil」と表示させないために, 空文字をミニバッファに表示
               (minibuffer-message "")
               )))


;;; init-skk.el ends here

