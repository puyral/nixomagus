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
  #         intel-gpu-tools

  imports = [
    ./hyprland.nix
    ./alacritty.nix
    ./custom-packages.nix
    ./systemd-services/services.nix
    ./i3/i3.nix
    ./firefox.nix
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/terminal" = [
      "alacritty.desktop"
      "kitty.desktop"
    ];
  };

  home = {

    packages =
      (with pkgs; [

        pinentry-qt

        btop
        htop
        # nvtopPackages.full

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

        rnote
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
      ]);
    # ++ (import ./custom-packages.nix) attrs;

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Let Home Manager install and manage itself.
    # programs.home-manager.enable = true;

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
