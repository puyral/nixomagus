;; Load ProofGeneral
(require 'proof-site)

;; Squirrel prover integration (defered until after proof-general is loaded)
(with-eval-after-load 'proof-site
  (require 'squirrel nil t)
  (require 'ansi-color))