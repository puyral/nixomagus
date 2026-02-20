(message "========== LOADING CUSTOM INIT.EL ==========")
;; Squirrel
(provide 'squirrel)
(require 'ansi-color)

;; mouse in TUI
(xterm-mouse-mode 1)


;; Enable Evil
;; (require 'evil)
(evil-mode 1)

(message "========== CUSTOM INIT.EL DONE ==========")
