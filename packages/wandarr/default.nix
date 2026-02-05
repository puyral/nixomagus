{
  stdenv,
  python3,
  makeWrapper,
  fetchFromGitHub,
  lib,
  ffmpeg,
  python3Packages,
  ...
}:

stdenv.mkDerivation {
  pname = "wandarr";
  version = "0.0.1-git";

  src = fetchFromGitHub {
    owner = "mlsmithjr";
    repo = "wandarr";
    rev = "master";
    sha256 = "sha256-1GmjRXjSelvMIfDUvekhcf4LRWhSXMQ/h+TJfdtJLi4="; # REPLACE with actual hash after first run
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  # Runtime dependencies
  propagatedBuildInputs = with python3Packages; [
    pyyaml
    requests
    rich
    # Add 'click' or 'argparse' if needed, though argparse is stdlib
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/wandarr

    # Copy the entire source tree to share to ensure relative imports work
    cp -r ./* $out/share/wandarr/

    # Create the binary wrapper
    # We point to main.py inside the share directory
    makeWrapper ${python3}/bin/python3 $out/bin/wandarr \
      --add-flags "$out/share/wandarr/main.py" \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/share/wandarr" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"
  '';

  meta = with lib; {
    description = "Distributed Transcoding Toolkit (Successor to pytranscoder)";
    homepage = "https://github.com/mlsmithjr/wandarr";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
