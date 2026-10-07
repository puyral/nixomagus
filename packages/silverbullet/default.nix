{
  lib,
  appimageTools,
  fetchurl,
  ...
}:

let
  pname = "silverbullet";
  version = "2.12.0";

  src = fetchurl {
    url = "https://release.silverbullet.md/electron/artifacts/${version}/linux/x64/SilverBullet-${version}-linux-x86_64.AppImage";
    hash = "sha256-CyS1zfbFwUvO3bffGp4nIdcPr3pwPNFR8W+k/gsZyYM=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Uncomment if something turns out to be missing at runtime:
  # extraPkgs = pkgs: [ pkgs.libsecret ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/silverbullet.desktop \
      $out/share/applications/silverbullet.desktop
    substituteInPlace $out/share/applications/silverbullet.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=silverbullet'

    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Open-source, self-hosted, offline-capable Personal Knowledge Management (PKM) web application";
    homepage = "https://silverbullet.md/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "silverbullet";
  };
}
