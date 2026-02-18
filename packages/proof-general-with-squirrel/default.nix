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
    # Find the proof-general elpa directory name dynamically
    PG_DIR=$(find ${pkgs.emacsPackages.proof-general}/share/emacs/site-lisp/elpa -type d -name "proof-general-*" -printf "%f\n" 2>/dev/null | head -1)
    echo $PG_DIR

    # Create output directory structure
    mkdir -p $out/share/emacs/site-lisp/elpa

    # Copy the original proof-general package
    cp -r ${pkgs.emacsPackages.proof-general}/share/* $out/share/

    # Make copied files writable so we can modify them
    chmod -R u+w $out/share

    # Add squirrel directory
    mkdir -p $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel
    cp ${src}/utils/* $out/share/emacs/site-lisp/elpa/$PG_DIR/squirrel/

    patch $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.el < ${./proof-site.patch}
    patch $out/share/emacs/site-lisp/elpa/$PG_DIR/proof-general.el < ${./proof-general.patch}

    rm -f $out/share/emacs/site-lisp/elpa/$PG_DIR/generic/proof-site.elc
  '';
}
