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
  
  squirrel-mode-epkgs = pkgs.emacsPackages.trivialBuild rec {
    pname = "squirrel-mode";
    version = "unstable";
    src = squirrel-prover-src;
    packageRequires = [ pkgs.emacsPackages.proof-general ];
    allowCompilation = false;
buildCommand = ''
       mkdir  -p $out/share/emacs/site-lisp
        { echo '(message "========== SQUIRREL.EL LOADED FROM NIX STORE ==========")'; cat ${src}/utils/squirrel.el; } > $out/share/emacs/site-lisp/squirrel.el
        cp ${src}/utils/squirrel-syntax.el $out/share/emacs/site-lisp/
      '';
  };
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      extraPackages = epkgs: [
        epkgs.proof-general
        squirrel-mode-epkgs
      ] ++ cfg.extensions;
      extraConfig = builtins.readFile ./init.el;
    };

    home.packages = [ ] ++ lib.optional cfg.squirrel.enable pkgs-self.squirrel;
  };
}
 
