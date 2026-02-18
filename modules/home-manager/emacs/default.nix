{
  lib,
  config,
  pkgs,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.emacs;

  squirrel-mode-epkgs = pkgs.emacsPackages.trivialBuild rec {
    pname = "squirrel-mode";
    version = pkgs-self.squirrel.version;
    src = pkgs-self.squirrel.src;
    packageRequires = [ pkgs.emacsPackages.proof-general ];
    # allowCompilation = false;
    buildCommand = ''
       mkdir  -p $out/share/emacs/site-lisp
          echo "(message \"========== SQUIRREL.EL LOADED FROM NIX STORE ==========\")" > $out/share/emacs/site-lisp/squirrel.el
          echo "" >> $out/share/emacs/site-lisp/squirrel.el
          echo ";;; Define required variables for proof-easy-config" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-toolbar-entries nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-menu-entries nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-prog-args nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-favourites nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-toolbar-palettes nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-toolbar-toggle-list nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-menu-logic nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-menu-commands nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-help-menu-entries nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-toolbar-buttons nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-menu-automation nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-prog-env nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-process-regexp nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-prog-args-quiet nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-main-menu-entries nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-goal-custom nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-response-start-regexp nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-response-end-regexp nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-one-command-per-line t)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-version ${version})" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-marker-regexp nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-prog-contents-list nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar squirrel-newline-command nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "(defvar proof-marker-regexp nil)" >> $out/share/emacs/site-lisp/squirrel.el
          echo "" >> $out/share/emacs/site-lisp/squirrel.el
          echo "; Copy original squirrel.el content" >> $out/share/emacs/site-lisp/squirrel.el
          cat ${src}/utils/squirrel.el >> $out/share/emacs/site-lisp/squirrel.el
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