{
  lib,
  buildNpmPackage,
  python3Packages,
  python3,
  pkg-config,
  makeWrapper,
  nodejs,
  cairo,
  pango,
  libpng,
  libjpeg,
  giflib,
  librsvg,
  pixman,
  ...
}:

buildNpmPackage {
  pname = "bgutil-ytdlp-pot-provider-server";
  inherit (python3Packages.bgutil-ytdlp-pot-provider) version src;

  sourceRoot = "${python3Packages.bgutil-ytdlp-pot-provider.src.name}/server";

  npmDepsHash = "sha256-Qwwi6W+Oeu6ZeLmZP5vEfAKOJyivbULR5mlk7tcVIE8=";

  nativeBuildInputs = [
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = [
    cairo
    pango
    libpng
    libjpeg
    giflib
    librsvg
    pixman
  ];

  buildPhase = ''
    runHook preBuild
    npx tsc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    rm -rf node_modules/canvas/build/Release/obj.target
    mkdir -p $out/lib/bgutil-pot-server $out/bin
    cp -r build node_modules package.json $out/lib/bgutil-pot-server/
    makeWrapper ${lib.getExe nodejs} $out/bin/bgutil-pot-server \
      --add-flags "$out/lib/bgutil-pot-server/build/main.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Proof-of-origin token provider HTTP server for yt-dlp";
    homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
    license = licenses.gpl3Only;
    mainProgram = "bgutil-pot-server";
  };
}
