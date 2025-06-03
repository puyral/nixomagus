{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  pkgs-stable,
  custom,
  pkgs-rapid-photo-downloader,
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
      let
        darktable = pkgs-unstable.darktable.override { stdenv = pkgs-unstable.clangStdenv; };

      in
      [
        custom.rnote
        darktable
      ]

      ++ (with pkgs-stable; [

        btop
        # nvtopPackages.full
        # intel-gpu-tools

        gimp-with-plugins

        # cudaPackages.cudatoolkit

        #logseq

        # pkgs-rapid-photo-downloader.rapid-photo-downloader
        rapid-photo-downloader

        youtube-music

        obs-studio
        obs-studio-plugins.obs-pipewire-audio-capture
        obs-studio-plugins.wlrobs

        texliveFull
      ])
      ++ (with pkgs; [
        thunderbird
        vscode
        # pavucontrol
        pwvucontrol

        kdePackages.okular

        libsForQt5.xp-pen-g430-driver
        zotero

        emacs

        blender
        #davinci-resolve
        libsForQt5.kdenlive
        inkscape-with-extensions
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

        nautilus
        nautilus-open-any-terminal
        sushi
        code-nautilus
      ])
      ++ (with pkgs-unstable; [
      ])
      ++ lib.optional gui.pinentry-qt pkgs.pinentry-qt;
  };
}
