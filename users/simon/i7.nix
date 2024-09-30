{
  config,
  pkgs,
  system,
  pkgs-unstable,
  overlays,
  mconfig,
  custom,
  ...
}@attrs:
{
  imports = [
    # ./hyprland.nix
    ./alacritty.nix
    # ./custom-packages.nix
    ./systemd-services/services.nix
    # ./i3/i3.nix
    # ./logseq
  ];

  home = {

    packages =
      [ ]
      ++ (with pkgs; [
        # pinentry-qt

        btop
        htop
        intel-gpu-tools

        #logseq

        youtube-music
      ])
      ++ (with pkgs-unstable; [
        firefox
        thunderbird
        vscode
        pavucontrol

        okular

        geeqie
        feh

        mpv
        mpd
        ncmpcpp
        cava

        blueberry
        easyeffects

        jellyfin-media-player # see https://github.com/jellyfin/jellyfin-media-player/issues/165

        discord
        whatsapp-for-linux
        signal-desktop
      ]);

    # see https://nixos.wiki/wiki/Logseq
    #nixpkgs.overlays = [
    #  (
    #    final: prev: {
    #      logseq = prev.logseq.overrideAttrs (oldAttrs: {
    #        postFixup = ''
    #          makeWrapper ${prev.electron_20}/bin/electron $out/bin/${oldAttrs.pname} \
    #            --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
    #            --add-flags $out/share/${oldAttrs.pname}/resources/app \
    #            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
    #            --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [ prev.stdenv.cc.cc.lib ]}"
    #        '';
    #      });
    #    }
    #  )
    #];
  };

}
