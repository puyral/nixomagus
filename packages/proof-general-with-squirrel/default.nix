{
  lib,
  pkgs,
  squirrel-prover-src,
  ...
}:
let
  proof-general = pkgs.emacsPackages.proof-general;
in
proof-general.overrideAttrs (oldAttrs: {
  buildCommand = ''
    ${oldAttrs.buildCommand or ""}

    # Add squirrel directory
    mkdir -p $out/share/emacs/site-lisp/elpa/proof-general-20250915.1038/squirrel
    if [ -d ${squirrel-prover-src}/utils ]; then
      cp ${squirrel-prover-src}/utils/squirrel.el $out/share/emacs/site-lisp/elpa/proof-general-20250915.1038/squirrel/
      cp ${squirrel-prover-src}/utils/squirrel-syntax.el $out/share/emacs/site-lisp/elpa/proof-general-20250915.1038/squirrel/
    fi

    # Update proof-site.el to register squirrel
    if [ -f $out/share/emacs/site-lisp/elpa/proof-general-20250915.1038/generic/proof-site.el ]; then
      sed -i '/^;; Entries in proof-assistant-table-default are lists of the form$/i \
    (squirrel "Squirrel" "sp")' $out/share/emacs/site-lisp/elpa/proof-general-20250915.1038/generic/proof-site.el 2>/dev/null || true

      # Remove compiled version so it gets recompiled
      rm -f $out/share/emacs/site-lisp/elpa/proof-general-20250915.1038/generic/proof-site.elc
    fi
  '';
})