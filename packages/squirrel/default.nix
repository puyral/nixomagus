{
  lib,
  squirrel-prover-src,
  ocaml,
  buildDunePackage,
  fmt,
  ocamlgraph,
  sedlex,
  ppx_inline_test,
  menhir,
  menhirLib,
  zarith,
  alcotest,
  emacsPackages,
  ...
}:

rec { 
  
  
  
  squirrel =

buildDunePackage {
  pname = "squirrel";
  version = "0.16";

  src = squirrel-prover-src;

  duneVersion = "3";

  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    fmt
    ocamlgraph
    sedlex
    ppx_inline_test
    menhirLib
    zarith
    alcotest
  ];

  checkInputs = [ alcotest ];

  preBuild = ''
    substituteInPlace src/commit.ml.in --replace-warn "GITHASH" "nix-build"
    mv src/commit.ml.in src/commit.ml
  '';

  buildPhase = ''
    runHook preBuild
    dune build squirrel.exe ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -f _build/default/squirrel.exe $out/bin/squirrel
    cp -r theories $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "The Squirrel Prover is a proof assistant for protocols, based on first-order logic and provides guarantees in the computational model";
    homepage = "https://squirrel-prover.github.io/";
    license = licenses.cecill-b;
    maintainers = [ ];
    platforms = ocaml.meta.platforms;
  };
};

proof-general-with-squirrel = 
  let pg = emacsPackages.proof-genera ; in 
  emacsPackages.trivialBuild rec {
  src = squirrel-prover-src;
  pname = "proof-general-with-squirrel";
  version = "unstable";
  packageRequires = [ squirrel ] ++ pg.packageRequires;
  buildCommand = ''
    PG_DIR=$(find ${pg}/share/emacs/site-lisp/elpa -type d -name "proof-general-*" -printf "%f\n" 2>/dev/null | head -1)
    mkdir -p $out/share/emacs/site-lisp/elpa
    cp -r ${pg}/share/* $out/share/
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
};
}