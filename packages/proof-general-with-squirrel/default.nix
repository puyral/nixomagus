{
  lib,
  pkgs,
  squirrel,
  ...
}:
pkgs.emacsPackages.trivialBuild rec {
  src = squirrel.src;
  pname = "proof-general-with-squirrel";
  version = "unstable";
  packageRequires = [ squirrel ] ++ pkgs.emacsPackages.proof-general.packageRequires;
  buildCommand = ''
    PG_DIR=$(find ${pkgs.emacsPackages.proof-general}/share/emacs/site-lisp/elpa -type d -name "proof-general-*" -printf "%f\n" 2>/dev/null | head -1)
    mkdir -p $out/share/emacs/site-lisp/elpa
    cp -r ${pkgs.emacsPackages.proof-general}/share/* $out/share/
    chmod -R u+w $out/share
    mkdir -p $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel
    {
      echo ";;; squirrel.el --- Proof General for the Squirrel Prover."
      echo ""
      echo "(defvar squirrel-toolbar-entries nil)"
      echo "(defvar squirrel-menu-entries nil)"
      echo "(defvar squirrel-prog-args nil)"
      echo "(defvar squirrel-favourites nil)"
      echo "(defvar squirrel-toolbar-palettes nil)"
      echo "(defvar squirrel-toolbar-toggle-list nil)"
      echo "(defvar squirrel-menu-logic nil)"
      echo "(defvar squirrel-menu-commands nil)"
      echo "(defvar squirrel-help-menu-entries nil)"
      echo "(defvar squirrel-toolbar-buttons nil)"
      echo "(defvar squirrel-menu-automation nil)"
      echo "(defvar squirrel-prog-env nil)"
      echo "(defvar squirrel-process-regexp nil)"
      echo "(defvar squirrel-prog-args-quiet nil)"
      echo "(defvar squirrel-main-menu-entries nil)"
      echo "(defvar squirrel-goal-custom nil)"
      echo "(defvar squirrel-response-start-regexp nil)"
      echo "(defvar squirrel-response-end-regexp nil)"
      echo "(defvar squirrel-one-command-per-line t)"
      echo "(defvar squirrel-version \"unstable\")"
      echo "(defvar squirrel-marker-regexp nil)"
      echo "(defvar squirrel-prog-contents-list nil)"
      echo "(defvar squirrel-newline-command nil)"
      echo "(defvar proof-marker-regexp nil)"
      echo ""
      cat ${src}/utils/squirrel.el
    } > $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel/squirrel.el
    cp ${src}/utils/squirrel-syntax.el $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel/
    patch $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.el < ${./proof-site.patch}
    patch $out/share/emacs/site-lisp/elpa/$PG_DIR/proof-general.el < ${./proof-general.patch}
    rm -f $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.elc
  '';
}
