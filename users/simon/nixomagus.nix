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
    ./hyprland.nix
    ./alacritty.nix
    ./custom-packages.nix
    ./systemd-services/services.nix
    ./i3/i3.nix
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/terminal" = [
      "alacritty.desktop"
      "kitty.desktop"
    ];
  };

  home = {

    packages =
      let
        enblend-enfuse = pkgs.enblend-enfuse.override (overlays.gottagofast attrs);
        hugin = pkgs.hugin.override { inherit enblend-enfuse; };
      in
      [
        hugin
        enblend-enfuse
      ]
      ++ (with custom; [ clocktui ])
      ++ (with pkgs; [

        pinentry-qt

        btop
        htop
        nvtopPackages.full
        intel-gpu-tools

        gimp-with-plugins

        cudaPackages.cudatoolkit

        #logseq

        #      mattermost-desktop

        rapid-photo-downloader
      ])
      ++ (with pkgs-unstable; [
        # # Adds the 'hello' command to your environment. It prints a friendly
        # # "Hello, world!" when run.
        # pkgs.hello

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')
        firefox
        thunderbird
        vscode
        pavucontrol

        okular

        emacs

        blender
        davinci-resolve
        libsForQt5.kdenlive
        inkscape-with-extensions
        darktable
        # hugin # -> custom
        geeqie
        feh

        spotify
        mpv
        mpd
        ncmpcpp
        cava

        blueberry
        easyeffects

        steam

        zoom-us

        jellyfin-media-player # see https://github.com/jellyfin/jellyfin-media-player/issues/165

        discord
        whatsapp-for-linux
        signal-desktop

        kitty
        # alacritty # <- set up elsewhere

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
