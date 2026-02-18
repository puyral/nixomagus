;; Load ProofGeneral
(require 'proof-site)

;; Squirrel prover integration
(with-eval-after-load 'proof-general
  (require 'ansi-color)
  (require 'squirrel))