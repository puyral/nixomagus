{ stdenv, fetchurl, ... }:
let
  rule = fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    hash = "sha256-yjxld5ebm2jpfyzkw+vngBfHu5Nfh2ioLUKQQDY4KYo=";
  };
in
stdenv.mkDerivation {
  name = "probe-rs-udev";

  src = ./.;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp '${rule}' $out/lib/udev/rules.d/69-probe-rs.rules
  '';
}
