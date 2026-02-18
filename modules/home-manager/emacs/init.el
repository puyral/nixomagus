;; Load ProofGeneral
(require 'proof-site)

;; Squirrel prover integration
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/PG/squirrel"))

;; Add squirrel to proof-assistant-table
(setq proof-assistant-table
      (cons '(squirrel "Squirrel" "sp")
            proof-assistant-table))

(require 'proof-easy-config)
(require 'squirrel-syntax)
(require 'squirrel)
