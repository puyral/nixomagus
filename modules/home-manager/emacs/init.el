;; Register Squirrel with Proof General before loading proof-site
(add-to-list 'proof-assistant-table-default '(squirrel "Squirrel" "sp"))

;; Load ProofGeneral
(require 'proof-site)

;; Squirrel prover integration
(with-eval-after-load 'proof-site
  (require 'squirrel)
  (require 'ansi-color))