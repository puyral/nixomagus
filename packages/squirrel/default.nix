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
  ...
}:

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
}
