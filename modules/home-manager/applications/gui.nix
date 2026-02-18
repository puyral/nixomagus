{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  pkgs-stable,
  pkgs-rpd,
  custom,
  ...
}:
let
  gui = config.extra.applications.gui;
in
{
  config = lib.mkIf gui.enable {
    services.mpris-proxy.enable = true;
    extra = {
      firefox.enable = true;
      alacritty.enable = lib.mkDefault true;
      vscode.enable = true;
      keyring.enable = lib.mkDefault true;
      darktable = {
        enable = true;
        full = true;
      };
    };
    xdg.mimeApps.defaultApplications = lib.mkIf config.extra.alacritty.enable {
      "x-scheme-handler/terminal" = [
        "alacritty.desktop"
      ];
    };
    home.packages =
      let
        # darktable = pkgs-unstable.darktable.override { stdenv = pkgs-unstable.clangStdenv; };

      in
      [
        # custom.rnote
      ]

      ++ (with pkgs-stable; [

        btop
        # nvtopPackages.full
        # intel-gpu-tools

        gimp-with-plugins

        # cudaPackages.cudatoolkit

        #logseq

        youtube-music

        obs-studio
        obs-studio-plugins.obs-pipewire-audio-capture
        obs-studio-plugins.wlrobs

        texliveFull
      ])
      ++ (with pkgs; [
        thunderbird
        pwvucontrol

        kdePackages.okular

        xp-pen-g430-driver
        zotero

        #davinci-resolve
        kdePackages.kdenlive
        inkscape-with-extensions
        geeqie
        feh
        # xpano
        # rapid-photo-downloader

        spotify
        mpv
        mpd
        ncmpcpp
        # cava

        blueberry
        easyeffects

        # steam
        obsidian

        discord
        wasistlos
        signal-desktop
        mattermost-desktop
        fluffychat

        nautilus
        nautilus-open-any-terminal
        sushi
        code-nautilus

        cemu
      ])
      ++ (with pkgs-unstable; [
        # darktable
        blender

        jellyfin-media-player
      ])
      ++ lib.optional gui.pinentry-qt pkgs.pinentry-qt;
  };
}
