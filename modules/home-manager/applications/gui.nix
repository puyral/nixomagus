{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  pkgs-stable,
  custom,
  xp-pen-pentablet,
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
    };
    xdg.mimeApps.defaultApplications = lib.mkIf config.extra.alacritty.enable {
      "x-scheme-handler/terminal" = [
        "alacritty.desktop"
      ];
    };
    home.packages =
      [
        custom.rnote
      ]

      ++ (with pkgs-stable; [

        btop
        # nvtopPackages.full
        # intel-gpu-tools

        gimp-with-plugins

        # cudaPackages.cudatoolkit

        #logseq

        rapid-photo-downloader

        youtube-music

        obs-studio
        obs-studio-plugins.obs-pipewire-audio-capture
        obs-studio-plugins.wlrobs

        texliveFull
      ])
      ++ (with pkgs-unstable; [
        thunderbird
        vscode
        pavucontrol

        kdePackages.okular

        libsForQt5.xp-pen-g430-driver
        zotero

        emacs

        blender
        #davinci-resolve
        libsForQt5.kdenlive
        inkscape-with-extensions
        darktable
        # hugin # -> custom
        geeqie
        feh
        xpano

        spotify
        mpv
        mpd
        ncmpcpp
        # cava

        blueberry
        easyeffects

        # steam
        obsidian

        #zoom-us

        jellyfin-media-player # see https://github.com/jellyfin/jellyfin-media-player/issues/165

        discord
        whatsapp-for-linux
        signal-desktop
        mattermost-desktop

        nemo-with-extensions
      ])
      ++ lib.optional gui.pinentry-qt pkgs.pinentry-qt;
  };
}
