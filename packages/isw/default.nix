{
  lib,
  stdenv,
  python3,
  coreutils,
  isw-src,
  ...
}:

stdenv.mkDerivation rec {
  pname = "isw";
  # Release is old and missing features such as setting the battery charging limit
  version = "unstable-2021-02-26";

  src = isw-src;

  buildInputs = [
    python3
    coreutils
  ];

  dontBuild = true;
  dontConfigure = true;

  postPatch = ''
    patchShebangs isw
    substituteInPlace usr/lib/systemd/system/isw@.service \
      --replace "/usr/bin/sleep" "${coreutils}/bin/sleep" \
      --replace "/usr/bin/isw" "$out/bin/isw"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 etc/isw.conf $out/etc/isw.conf
    install -Dm644 usr/lib/systemd/system/isw@.service $out/lib/systemd/system/isw@.service
    install -Dm644 isw $out/bin/isw

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fan control tool for MSI gaming series laptops";
    homepage = "https://github.com/YoyPa/isw";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
  };
}
