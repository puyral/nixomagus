{
  config,
  pkgs,
  system,
  pkgs-unstable,
  overlays,
  mconfig,
  custom,
  nixpkgs-unstable,
  rootDir,
  ...
}@attrs:
{
  imports = [
    # ./hyprland.nix
    # ./alacritty.nix
    # ./custom-packages.nix
    ./systemd-services/services.nix
    # ./i3/i3.nix
    ./logseq
    ./firefox.nix
  ];

  programs.firefox.nativeMessagingHosts = [ pkgs.gnome-browser-connector ];
  home = {

    packages =
      [ ]
      ++ (with pkgs; [
        # pinentry-qt

        btop
        htop
        intel-gpu-tools
        nvtopPackages.intel
      ])
      ++ (with pkgs-unstable; [
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
        # (pkgs.jellyfin-media-player.overrideAttrs (oldAttrs: {
        #   postInstall =
        #     oldAttrs.postInstall
        #     + ''
        #       wrapProgram $out/bin/jellyfinmediaplayer \
        #         --set QT_QPA_PLATFORM xcb
        #     '';
        # }))

        discord
        whatsapp-for-linux
        signal-desktop

        xournalpp
        custom.rnote
        krita

        koreader
      ]);
    sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };
  };

}
