{ config, pkgs, system, ... }@attrs:
# let mhyprland = import ./hyprland.nix;
# in
{
  imports = [
    ./hyprland.nix
    ./shell.nix
    ./alacritty.nix
    ./custom-packages.nix
    ./systemd-services/services.nix
  ];
  nixpkgs.config = { allowUnfree = true; };
  home = {
    # inherit (import ./hyprland.nix);
    # inherit (import ./wallpaper.nix);

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "simon";
    homeDirectory = "/home/simon";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
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

      git
      git-crypt
      gh
      gnupg
      pinentry-qt

      emacs

      btop
      htop
      nvtop
      intel-gpu-tools

      blender
      # davinci-resolve
      inkscape-with-extensions
      gimp-with-plugins
      darktable
      # hugin # -> custom
      rapid-photo-downloader
      geeqie feh

      spotify
      mpv
      mpd
      ncmpcpp
      cava

      blueberry

      steam

      direnv
      nil

      zoom-us

      jellyfin-media-player # see https://github.com/jellyfin/jellyfin-media-player/issues/165

      # logseq

      discord
      mattermost-desktop
      whatsapp-for-linux
      signal-desktop

      cudaPackages.cudatoolkit

      kitty
      # alacritty # <- set up elsewhere

      texliveFull

      ripgrep

      cinnamon.nemo-with-extensions
    ];
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

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/simon/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      # EDITOR = "emacs";
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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
