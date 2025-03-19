{ pkgs, ... }:
{
  nixpkgs.config.overlays = [
    (self: super: {
      jellyfin-media-player = super.jellyfin-media-player.overrideAttrs (prevAttrs: {
        nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeBinaryWrapper ];

        postInstall =
          (prevAttrs.postInstall or "")
          + ''
            wrapProgram $out/bin/obs --set QT_QPA_PLATFORM xcb
          '';
      });
    })
  ];
}
