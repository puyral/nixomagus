{
  pkgs,
  pkgs-unstable,
  is_nixos,
  config,
  ...
}:
{
  home = {

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "simon";
    homeDirectory = "/home/simon";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages =
      [ ]
      # (with custom; [ clocktui ])
      ++ (with pkgs; [

        git
        git-crypt
        gh
        gnupg
        vim
        htop

        # gitui
        lazygit
        lazysql
        # nbstripout # for jupyter notebooks. This way I can support all of them

        # docker
      ])
      ++ (with pkgs-unstable; [
        nixd
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
      #      CONFIG_LOCATION = if is_nixos then "/config" else "$HOME/.config/home-manager/";
    };
  };
  extra.gitConfigFetcher.location =
    if is_nixos then "/config" else "${config.home.homeDirectory}/.config/home-manager";
}
