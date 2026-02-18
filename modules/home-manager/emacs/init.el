;; Load ProofGeneral
(require 'proof-site)

;; Squirrel prover integration
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/PG/squirrel"))
(require 'squirrel-syntax)
(require 'squirrel)