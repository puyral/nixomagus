{
  lib,
  pkgs,
  squirrel-prover-src,
  ...
}:
pkgs.emacsPackages.trivialBuild {
  pname = "proof-general-with-squirrel";
  version = "unstable";
  packageRequires = [];
  buildCommand = ''
    # Find the proof-general elpa directory name dynamically
    PG_DIR=$(find ${pkgs.emacsPackages.proof-general}/share/emacs/site-lisp/elpa -type d -name "proof-general-*" -printf "%f\n" 2>/dev/null | head -1)

    # Create output directory structure
    mkdir -p $out/share/emacs/site-lisp/elpa

    # Copy the original proof-general package
    cp -r ${pkgs.emacsPackages.proof-general}/share/* $out/share/

    # Make copied files writable so we can modify them
    chmod -R u+w $out/share

    # Add squirrel directory
    mkdir -p $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel
    if [ -d ${squirrel-prover-src}/utils ]; then
      cp ${squirrel-prover-src}/utils/squirrel.el $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel/
      cp ${squirrel-prover-src}/utils/squirrel-syntax.el $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel/
    fi

    # Update proof-site.el to register squirrel
    if [ -f $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.el ]; then
      sed -i '/^;; Entries in proof-assistant-table-default are lists of the form$/i \
    (squirrel "Squirrel" "sp")' $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.el 2>/dev/null || true

      # Remove compiled version so it gets recompiled
      find . -name "*.elc" -exec rm {} \;
      # rm -f $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.elc
    fi
  '';
}