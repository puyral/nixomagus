{
  lib,
  ...
}:
# let mhyprland = import ./hyprland.nix;
# in
{
  imports = [
    # ./shell.nix
    # ./ssh
    ./home.nix
  ];

  extra = {
    shell.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    ssh.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    lazygit.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    ntfy-client.enable = lib.mkDefault true;
    btop.enable = lib.mkDefault true;
    opencode.enable = lib.mkDefault true;
  };

  extra.emacs = {
    enable = lib.mkDefault true;
    squirrel.enable = lib.mkDefault false;
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
