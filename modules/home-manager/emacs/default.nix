{
  lib,
  config,
  pkgs,
  squirrel-prover-src,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.emacs;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      extraPackages =
        epkgs:
        [
          epkgs.proof-general
        ]
        ++ cfg.extensions;
    };

    home.file.".emacs.d/lisp/PG/squirrel/squirrel.el".source =
      "${squirrel-prover-src}/utils/squirrel.el";
    home.file.".emacs.d/lisp/PG/squirrel/squirrel-syntax.el".source =
      "${squirrel-prover-src}/utils/squirrel-syntax.el";

    home.file.".emacs.d/init.el" = lib.mkIf cfg.squirrel.enable {
      text = ''
        ;; Load ProofGeneral
        (require 'proof-site)

        ;; Configure Squirrel prover
        (load "~/.emacs.d/lisp/PG/squirrel/squirrel")
        (load "~/.emacs.d/lisp/PG/squirrel/squirrel-syntax")
      '';
    };

    home.packages = [ ] ++ lib.optional cfg.squirrel.enable pkgs-self.squirrel;
  };
}
