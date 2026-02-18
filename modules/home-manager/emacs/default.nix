{
  lib,
  config,
  pkgs,
  pkgs-self,
  squirrel-prover-src,
  ...
}:
let
  cfg = config.extra.emacs;
  squirrel-mode-epkgs = pkgs.emacsPackages.trivialBuild {
    pname = "squirrel-mode";
    version = "unstable";
    src = squirrel-prover-src;
    packageRequires = [ pkgs.emacsPackages.proof-general ];
    buildCommand = ''
      mkdir -p $out/share/emacs/site-lisp/squirrel
      cp ${squirrel-prover-src}/utils/squirrel.el $out/share/emacs/site-lisp/squirrel/
      cp ${squirrel-prover-src}/utils/squirrel-syntax.el $out/share/emacs/site-lisp/squirrel/
    '';
  };
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
          squirrel-mode-epkgs
        ]
        ++ cfg.extensions;
    };

    home.file.".emacs.d/init.el" = lib.mkIf cfg.squirrel.enable {
      text = builtins.readFile ./init.el;
    };

    home.packages = [ ] ++ lib.optional cfg.squirrel.enable pkgs-self.squirrel;
  };
}
