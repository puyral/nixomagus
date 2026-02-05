{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.keyring;
in
{
  # NB: gnome should be enabled
  options.extra.keyring.enable = lib.mkEnableOption "keyring";

  config = lib.mkIf cfg.enable {
    programs.git.settings = {
      credential.helper = "libsecret";
    };

    # 1. Enable the Home Manager GNOME Keyring service
    services.gnome-keyring = {
      enable = true;
      # You can specify the components you want to run.
      # 'secrets' is essential for password/credential storage.
      components = [
        "secrets"
        "ssh"
      ];
    };

    # 2. Ensure libsecret (which provides the git credential helper) is installed
    home.packages = with pkgs; [
      libsecret # Provides the git-credential-libsecret helper
      # You might also want seahorse for a GUI to manage keys
      # seahorse
    ];
  };
}
