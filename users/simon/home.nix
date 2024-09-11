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
# let mhyprland = import ./hyprland.nix;
# in
{
  imports = [
    ./shell.nix
    ./ssh
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };

  home = {

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "simon";
    homeDirectory = "/home/simon";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages =
      (with custom; [ clocktui ])
      ++ (with pkgs; [

        git
        git-crypt
        gh
        gnupg

        docker
        texliveFull
      ])
      ++ (with pkgs-unstable; [
        nil
        ripgrep
        killall
      ]);

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
      EDITOR = "vim";
    };
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
