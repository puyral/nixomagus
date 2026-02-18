{
  lib,
  stdenv,
  fetchurl,
  emacs,
  proof-general,
  squirrel-prover-src,
}:

stdenv.mkDerivation {
  pname = "squirrel-mode";
  version = "unstable";

  src = squirrel-prover-src;

  buildInputs = [ emacs ];

  propagatedBuildInputs = [ proof-general ];

  buildPhase = ''
    mkdir -p $out/share/emacs/site-lisp/squirrel
    cp $src/utils/squirrel.el $out/share/emacs/site-lisp/squirrel/
    cp $src/utils/squirrel-syntax.el $out/share/emacs/site-lisp/squirrel/
  '';

  meta = with lib; {
    description = "Emacs mode for Squirrel proof assistant";
    homepage = "https://github.com/squirrel-prover/squirrel-prover";
    license = licenses.cecill-b;
    maintainers = [ ];
  };
}
