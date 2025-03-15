{lib, config, pkgs, pkgs-unstable, custom}:
let gui = config.extra.applications.gui; in
{config = lib.mkIf gui
{
  extra = {firefox.enable =true;
    xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/terminal" = [
      "alacritty.desktop"
      "kitty.desktop"
    ];
  };
    alacritty.enable = lib.mkDefault true;
  };
  home.packages = lib.mkIf   gui.enable (  
    [custom.rnote ]
     (with pkgs; [


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

        steam

        #zoom-us

        jellyfin-media-player # see https://github.com/jellyfin/jellyfin-media-player/issues/165

        discord
        whatsapp-for-linux
        signal-desktop
        mattermost-desktop

        nemo-with-extensions
      ]) ++ lib.optional gui.pinentry-qt pkgs.pinentry-qt );
};}